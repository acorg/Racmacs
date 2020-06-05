
// Function for generating a material from properties
R3JS.Material = function(properties){

    // Convert colors
    properties.color = new THREE.Color(properties.color.r,
                                       properties.color.g,
                                       properties.color.b);

    // Set object material
    if(properties.mat == "basic")    { var mat = new THREE.MeshBasicMaterial();   }
    if(properties.mat == "lambert")  { var mat = new THREE.MeshLambertMaterial(); }
    if(properties.mat == "phong")    { var mat = new THREE.MeshPhongMaterial();   }
    if(properties.mat == "line")     { 
        if(properties.gapSize){
            var mat = new THREE.LineDashedMaterial({
                scale: 200
            });
        } else {
            var mat = new THREE.LineBasicMaterial();
        }
    }

    // Set object material properties
    Object.assign(mat, properties);
    if(properties.doubleSide){
        mat.side = THREE.DoubleSide;
    }

    // Set clipping
    mat.clippingPlanes = [];

    return(mat);

}


R3JS.element.make = function(
    plotobj, 
    plotdims
    ){

    if(plotobj.type == "point"){
        // Point
        var element = this.constructors.point(
            plotobj,
            plotdims
        );
    } else if(plotobj.type == "line"){
        // GL Points
        var element = this.constructors.line(
            plotobj,
            plotdims
        );
    } else if(plotobj.type == "glpoints"){
        // GL Points
        var element = this.constructors.glpoints(
            plotobj,
            plotdims
        );
    } else if(plotobj.type == "glline"){
        // GL line
        var element = this.constructors.glline(
            plotobj,
            plotdims
        );
    } else if(plotobj.type == "text"){
        // Text
        var element = this.constructors.text(
            plotobj,
            plotdims
        );
    } else if(plotobj.type == "sphere"){
        // Sphere
        var element = this.constructors.sphere(
            plotobj,
            plotdims
        );
    } else if(plotobj.type == "surface"){
        // Surface
        var element = this.constructors.surface(
            plotobj,
            plotdims
        );
    } else if(plotobj.type == "grid"){
        // Grid
        var element = this.constructors.grid(
            plotobj,
            plotdims
        );
    } else if(plotobj.type == "shape"){
        // 3d shape
        var element = this.constructors.polygon3d(
            plotobj,
            plotdims
        );
    } else {
        throw("Plot object type '"+plotobj.type+"' not recognised.");
    }

    // Apply renderOrder
    if(plotobj.properties && plotobj.properties.renderOrder){
        element.setRenderOrder(plotobj.properties.renderOrder);
    }


    if(element.object.material){
        // element.object = R3JS.utils.separateSides(element.object);
    }

    // Return the object
    return(element);

};



// General function to populate the plot
R3JS.Scene.prototype.populatePlot = function(plotData){

    // Add any plot data
    if(plotData.plot){

        // Add all the elements
        for(var i=0; i<plotData.plot.length; i++){
            this.addPlotElement(
                plotData.plot[i]
            );
        }

        // Group the elements with each other
        for(var i=0; i<this.elements.length; i++){

            var element = this.elements[i];
            if(element.groupindices){

                element.group = [];
                for(var j=0; j<element.groupindices.length; j++){

                    element.group.push(
                        this.elements[element.groupindices[j]]
                    );

                }

            }

        }

    }

}

// Add a plot object
R3JS.Scene.prototype.addPlotElement = function(
    plotobj,
    scene
    ){

    // Set blank default properties
    if(!plotobj.properties) plotobj.properties = {};

    // Make the object
    var element = R3JS.element.make(
        plotobj,
        this.viewer
    );

    // Add highlighted point
    if(plotobj.highlight){
        
        // Link plot and highlight objects
        var hlelement = R3JS.element.make(
            plotobj.highlight, 
            this.viewer
        );
        hlelement.hide();
        element.highlight = hlelement;
        this.add(hlelement.object);

    }

    // Add interactivity
    if(plotobj.properties.interactive || plotobj.properties.label){
        this.addSelectableElements(element.elements());
    }

    // Work out toggle behaviour
    if(plotobj.properties.toggle){
        var toggle = plotobj.properties.toggle;
        var tog_index = this.toggles.names.indexOf(toggle);
        if(tog_index == -1){
            this.toggles.names.push(toggle);
            this.toggles.objects.push([element]);
        } else {
            this.toggles.objects[tog_index].push(element);
        }
    }
    
    // Add label info
    if(plotobj.properties.label){
        element.label = plotobj.properties.label;
    }

    // Work out if object is dynamically associated with a face
    if(plotobj.properties.faces){
        this.makeDynamic();
        this.dynamic_objects.push(element);
        if(plotobj.properties.faces.indexOf("x+") != -1){ this.dynamicDeco.faces[0].push(element) }
        if(plotobj.properties.faces.indexOf("y+") != -1){ this.dynamicDeco.faces[1].push(element) }
        if(plotobj.properties.faces.indexOf("z+") != -1){ this.dynamicDeco.faces[2].push(element) }
        if(plotobj.properties.faces.indexOf("x-") != -1){ this.dynamicDeco.faces[3].push(element) }
        if(plotobj.properties.faces.indexOf("y-") != -1){ this.dynamicDeco.faces[4].push(element) }
        if(plotobj.properties.faces.indexOf("z-") != -1){ this.dynamicDeco.faces[5].push(element) }
    }

    if(plotobj.properties.corners){
        this.makeDynamic();
        this.dynamic_objects.push(element);
        
        var corners  = plotobj.properties.corners[0];
        var edgecode = corners.substring(0,3);
        var poscode  = corners.substring(3,4);
        var a;
        var b;

        if(edgecode == "x--"){ a = 0  }
        if(edgecode == "x-+"){ a = 1  }
        if(edgecode == "x++"){ a = 2  }
        if(edgecode == "x+-"){ a = 3  }
        if(edgecode == "-y-"){ a = 4  }
        if(edgecode == "-y+"){ a = 5  }
        if(edgecode == "+y+"){ a = 6  }
        if(edgecode == "+y-"){ a = 7  }
        if(edgecode == "--z"){ a = 8  }
        if(edgecode == "-+z"){ a = 9  }
        if(edgecode == "++z"){ a = 10 }
        if(edgecode == "+-z"){ a = 11 }

        if(poscode == "r"){ b = 0 } // Up
        if(poscode == "u"){ b = 1 } // Down
        if(poscode == "f"){ b = 2 } // Front
        if(poscode == "l"){ b = 3 } // Left
        if(poscode == "d"){ b = 4 } // Right
        if(poscode == "b"){ b = 5 } // Back

        this.dynamicDeco.edges[a][b].push(element);

    }

    // Add any clipping planes
    var material = element.object.material;
    
    // Add it's own clipping planes
    if(plotobj.properties.clippingPlanes){

        var clippingPlanes = this.fetchClippingPlaneReference(
            plotobj.properties.clippingPlanes
        );

        if(material){
            material.clippingPlanes = material.clippingPlanes.concat(
                clippingPlanes
            );
        } else {
            for(var i=0; i<element.object.children.length; i++){
                if(element.object.children[i].material && element.object.children[i].material.clippingPlanes){
                    element.object.children[i].material.clippingPlanes = element.object.children[i].material.clippingPlanes.concat(
                        clippingPlanes
                    );
                }
            }
        }

    }

    // Add outer plot clipping planes
    if(!plotobj.properties.xpd){

        if(material){
            material.clippingPlanes = material.clippingPlanes.concat(
                this.plotPoints.clippingPlanes
            );
        } else {
            for(var i=0; i<element.object.children.length; i++){
                element.object.children[i].material.clippingPlanes = element.object.children[i].material.clippingPlanes.concat(
                    this.plotPoints.clippingPlanes
                );
            }
        }

    }

    if(plotobj.properties.breakupMesh){
        element.breakupMesh();
    }

    // Add group reference
    if(plotobj.group){
        element.groupindices = plotobj.group.map(x => x-1);
    }

    // Assign the ID
    var elements = element.elements();
    for(var i=0; i<elements.length; i++){
        elements[i].id = plotobj.ID[i]-1;
    }

    // Add reference of object to primary object list
    this.addElements(element.elements());
    this.add(element.object);

}
































// General function to populate the plot
function populatePlot(parent,
                      plotData,
                      scene){
    
    if(plotData.plot){
        for(var i=0; i<plotData.plot.length; i++){
            addPlotObject(plotData.plot[i],
                          plotData,
                          parent,
                          scene);
        }
    }

}











// Plot points
function addPlotObject(plotobj, 
                       plotData,
                       parent,
                       scene){

    // Make the object
    var object = make_object(plotobj, plotData, parent, scene);

    // Add highlighted point
    if(plotobj.highlight){
        
        // Link plot and highlight objects
        var hlobj = make_object(plotobj.highlight, plotData, parent, scene);
        hlobj.visible = false;
        object.highlight = hlobj;
        parent.add(hlobj);

    }

    // Add interactivity
    if(plotobj.properties.interactive || plotobj.properties.label){
        scene.selectable_objects.push(object);
    }

    // Work out toggle behaviour
    if(plotobj.properties.toggle){
        var toggle = plotobj.properties.toggle;
        var tog_index = scene.toggles.names.indexOf(toggle);
        if(tog_index == -1){
            scene.toggles.names.push(toggle);
            scene.toggles.objects.push([object]);
        } else {
            scene.toggles.objects[tog_index].push(object);
        }
    }
    
    // Add label info
    if(plotobj.properties.label){
        object.label = plotobj.properties.label;
    }

    // Work out if object is dynamically associated with a face
    if(plotobj.properties.faces){
        scene.dynamic_objects.push(object);
        if(plotobj.properties.faces.indexOf("x+") != -1){ scene.dynamicDeco.faces[0].push(object) }
        if(plotobj.properties.faces.indexOf("y+") != -1){ scene.dynamicDeco.faces[1].push(object) }
        if(plotobj.properties.faces.indexOf("z+") != -1){ scene.dynamicDeco.faces[2].push(object) }
        if(plotobj.properties.faces.indexOf("x-") != -1){ scene.dynamicDeco.faces[3].push(object) }
        if(plotobj.properties.faces.indexOf("y-") != -1){ scene.dynamicDeco.faces[4].push(object) }
        if(plotobj.properties.faces.indexOf("z-") != -1){ scene.dynamicDeco.faces[5].push(object) }
    }
    if(plotobj.properties.corners){
        
        scene.dynamic_objects.push(object);
        
        var corners  = plotobj.properties.corners[0];
        var edgecode = corners.substring(0,3);
        var poscode  = corners.substring(3,4);
        var a;
        var b;

        if(edgecode == "x--"){ a = 0  }
        if(edgecode == "x-+"){ a = 1  }
        if(edgecode == "x++"){ a = 2  }
        if(edgecode == "x+-"){ a = 3  }
        if(edgecode == "-y-"){ a = 4  }
        if(edgecode == "-y+"){ a = 5  }
        if(edgecode == "+y+"){ a = 6  }
        if(edgecode == "+y-"){ a = 7  }
        if(edgecode == "--z"){ a = 8  }
        if(edgecode == "-+z"){ a = 9  }
        if(edgecode == "++z"){ a = 10 }
        if(edgecode == "+-z"){ a = 11 }

        if(poscode == "r"){ b = 0 } // Up
        if(poscode == "u"){ b = 1 } // Down
        if(poscode == "f"){ b = 2 } // Front
        if(poscode == "l"){ b = 3 } // Left
        if(poscode == "d"){ b = 4 } // Right
        if(poscode == "b"){ b = 5 } // Back

        scene.dynamicDeco.edges[a][b].push(object);

    }

    // Add the object to the plot
    object.scene = scene;
    parent.add(object);

    // Add reference of object to primary object list
    scene.primary_objects.push(object);
    
    // Sort out groupings
    if(plotobj.group){
        object.group = [];
        for(var i=0; i<plotobj.group.length; i++){
            object.group.push(plotobj.group[i]-1);
        }
    }

    // Return the object
    return(object);

}


function normalise_coord(coord,
                         lims,
                         aspect){
    return(coord - lims[0])*aspect/(lims[1] - lims[0]);
}

function normalise_coords(coords, 
                          lims, 
                          aspect){

    norm_coords = [];
    for(var i=0; i<coords.length; i++){
        norm_coords.push(
            normalise_coord(coords[i], lims[i], aspect[i])
        );
    }
    return(norm_coords);

}




// // Function for plotting an object such as a line or a shape
// function make_object(object, plotData, parent, scene){

//     // Set defaults
//     object.lims      = plotData.lims;
//     object.aspect    = plotData.aspect;
//     object.normalise = plotData.normalise;
//     object.parent    = parent;
//     object.scene     = scene;

//     // Check object type has been defined
//     if(typeof(object.type) === "undefined"){
//         throw("Object type undefined");
//     }

//     // Create the plotting object
//     if(object.type == "point"){
//         var plotobject = make_point(object);
//     }
//     if(object.type == "glpoint"){
//         var plotobject = make_glpoint(object);
//     }
//     if(object.type == "line"){
//         var plotobject = make_line(object);
//     }
//     if(object.type == "glline"){
//         var plotobject = make_glline(object);
//     }
//     if(object.type == "arrow"){
//         var plotobject = make_arrow(object);
//     }
//     if(object.type == "surface"){
//         var plotobject = make_surface(object);
//     }
//     if(object.type == "grid"){
//         var plotobject = make_grid(object);
//     }
//     if(object.type == "sphere"){
//         var plotobject = make_sphere(object);
//     }
//     if(object.type == "shape"){
//         var plotobject = make_shape(object);
//     }
//     if(object.type == "triangle"){
//         var plotobject = make_triangle(object);
//     }
//     if(object.type == "text"){
//         var plotobject = make_textobject(object);
//     }
    
//     // Apply any rotations
//     if(object.properties.rotation){
//         plotobject.geometry.rotateX(object.properties.rotation[0]);
//         plotobject.geometry.rotateY(object.properties.rotation[1]);
//         plotobject.geometry.rotateZ(object.properties.rotation[2]);
//     }

//     // Apply renderOrder
//     if(object.properties.renderOrder){
//         plotobject.renderOrder = object.properties.renderOrder;
//     }

    // // Apply any special transformations
    // if(object.properties.renderSidesSeparately){
    //     plotobject = separate_sides(plotobject);
    // }
    // if(object.properties.removeSelfTransparency){
    //     plotobject = remove_self_transparency(plotobject);
    // }
//     if(object.properties.breakupMesh){
//         plotobject = breakup_mesh(plotobject);
//     }
    
//     return(plotobject);

// }


function make_triangle(object){

    // Make geometry
    var geo = new THREE.Geometry();

    // Create vertices
    for(var i=0; i<object.vertices.length; i++){

        // Normalise the coordinates
        var vertex = object.vertices[i];
        if(object.normalise){
            vertex = normalise_coords(vertex,
                                      object.lims,
                                      object.aspect);
        }

        // Append the vertex
        geo.vertices.push( 
            new THREE.Vector3().fromArray(vertex)
        );

    }

    // Create faces
    geo.faces.push(
        new THREE.Face3(0, 1, 2)
    );
    geo.computeFaceNormals();

    // Convert to buffer geometry
    geo = new THREE.BufferGeometry().fromGeometry(geo);

    // Get material
    var mat = get_object_material(object);

    // Make shape
    var triangle = new THREE.Mesh(geo, mat);

    // Return the shape
    return(triangle);

}

function make_shape(object){

    // Make geometry
    var geo = new THREE.Geometry();

    // Create vertices
    for(var i=0; i<object.vertices.length; i++){

        // Normalise the coordinates
        var vertex = object.vertices[i];
        if(object.normalise){
            vertex = normalise_coords(vertex,
                                      object.lims,
                                      object.aspect);
        }

        // Append the vertex
        geo.vertices.push( 
            new THREE.Vector3().fromArray(vertex)
        );

    }

    // Create faces
    for(var i=0; i<object.faces.length; i++){

        var face = object.faces[i];
        geo.faces.push(
            new THREE.Face3(face[0],
                            face[1],
                            face[2])
        );

    }
    
    //geo.mergeVertices();
    geo.computeFaceNormals();
    //geo.computeVertexNormals();
    // geo.computeMorphNormals();

    // Convert to buffer geometry
    geo = new THREE.BufferGeometry().fromGeometry(geo);
    
    
    var mat = get_object_material(object);
    // mat.flatShading = true;
    // mat.morphNormals = true;
    // mat.morphTargets = true;
    // mat.vertexColors = THREE.FaceColors;
    // console.log(mat);

    // Make shape
    var shape = new THREE.Mesh(geo, mat);

    // Return the shape
    return(shape);

}











function make_arrow(object){

    // Set from and to
    if(object.normalise){
        var from = normalise_coords(object.position.from, 
                                    object.lims, 
                                    object.aspect);
        var to   = normalise_coords(object.position.to, 
                                    object.lims, 
                                    object.aspect);
    } else {
        var from = object.position.from;
        var to   = object.position.to;
    }

    // Set object geometry
    var arrow = {
        headwidth  : 0.015,
        headlength : 0.03
    };
    var geo = line_geo3D(from, 
                         to, 
                         object.properties.lwd*0.01, 
                         false, 
                         0, 
                         0, 
                         false,
                         arrow);

    // Set object material
    var mat = get_object_material(object);

    // Make arrow object
    var arrow = new THREE.Mesh(geo, mat);

    // Return arrow
    return(arrow);       
    
}












// function lineMeshSegments(geo, mat, lwd){
    
//     var segments = new THREE.Geometry();
//     for(var i=0; i<geo.vertices.length; i+=2){
//         var linegeo = make_lineMeshGeo(geo.vertices[i].toArray(), 
//                                        geo.vertices[i+1].toArray(),
//                                        lwd, 
//                                        3);
//         segments.merge(linegeo);
//     }
//     segments = new THREE.BufferGeometry().fromGeometry( segments );
//     return(new THREE.Mesh(segments, mat));

// }

// function breakup_mesh(full_mesh){

//     // Make a group for the new broken mesh
//     var broken_mesh = new THREE.Group();

//     // Get the geometry
//     var geo = full_mesh.geometry;
//     if(!geo.isBufferGeometry){
//         geo = new THREE.BufferGeometry().fromGeometry(geo);
//     }

//     // Get the material
//     var mat = clone_material(full_mesh.material);

//     // Break apart the geometry
//     for(var i=0; i<(geo.attributes.position.count/3); i++){
    
//         var x_mean = (geo.attributes.position.array[i*9] + geo.attributes.position.array[i*9+3] + geo.attributes.position.array[i*9+6])/3
//         var y_mean = (geo.attributes.position.array[i*9+1] + geo.attributes.position.array[i*9+4] + geo.attributes.position.array[i*9+7])/3
//         var z_mean = (geo.attributes.position.array[i*9+2] + geo.attributes.position.array[i*9+5] + geo.attributes.position.array[i*9+8])/3
//         var g = new THREE.BufferGeometry();
//         var v = new Float32Array( [
//             geo.attributes.position.array[i*9] - x_mean,
//             geo.attributes.position.array[i*9+1] - y_mean,
//             geo.attributes.position.array[i*9+2] - z_mean,
//             geo.attributes.position.array[i*9+3] - x_mean,
//             geo.attributes.position.array[i*9+4] - y_mean,
//             geo.attributes.position.array[i*9+5] - z_mean,
//             geo.attributes.position.array[i*9+6] - x_mean,
//             geo.attributes.position.array[i*9+7] - y_mean,
//             geo.attributes.position.array[i*9+8] - z_mean
//         ] );
//         g.setAttribute( 'position', new THREE.BufferAttribute( v, 3 ) );
//         var c = new Float32Array( [
//             geo.attributes.color.array[i*9],
//             geo.attributes.color.array[i*9+1],
//             geo.attributes.color.array[i*9+2],
//             geo.attributes.color.array[i*9+3],
//             geo.attributes.color.array[i*9+4],
//             geo.attributes.color.array[i*9+5],
//             geo.attributes.color.array[i*9+6],
//             geo.attributes.color.array[i*9+7],
//             geo.attributes.color.array[i*9+8]
//         ] );
//         g.setAttribute( 'color', new THREE.BufferAttribute( c, 3 ) );
//         var n = new Float32Array( [
//             geo.attributes.normal.array[i*9],
//             geo.attributes.normal.array[i*9+1],
//             geo.attributes.normal.array[i*9+2],
//             geo.attributes.normal.array[i*9+3],
//             geo.attributes.normal.array[i*9+4],
//             geo.attributes.normal.array[i*9+5],
//             geo.attributes.normal.array[i*9+6],
//             geo.attributes.normal.array[i*9+7],
//             geo.attributes.normal.array[i*9+8]
//         ] );
//         g.setAttribute( 'normal', new THREE.BufferAttribute( n, 3 ) );
        
//         // Set clipping
//         var mesh = new THREE.Mesh( g, mat );
//         mesh.position.set(x_mean, y_mean, z_mean);
//         broken_mesh.add(mesh);

//     }
    
//     // Return the mesh as a new group
//     return(broken_mesh);

// }


// function separate_sides(full_mesh){
    
//     var mat = full_mesh.material;
//     var geo = full_mesh.geometry;

//     // mat.colorWrite = false;
//     mat.side = THREE.FrontSide;
//     var mat_cw = clone_material(mat);
//     // mat_cw.colorWrite = true;
//     mat_cw.side = THREE.BackSide;

//     var mesh  = THREE.SceneUtils.createMultiMaterialObject( 
//         geo,[mat,mat_cw]
//     );

//     return(mesh);

// }


// function remove_self_transparency(full_mesh){
    
//     var mat = full_mesh.material;
//     var geo = full_mesh.geometry;

//     mat.colorWrite = false;
//     // mat.side = THREE.FrontSide;
//     var mat_cw = clone_material(mat);
//     mat_cw.colorWrite = true;
//     // mat_cw.side = THREE.BackSide;

//     var mesh  = THREE.SceneUtils.createMultiMaterialObject( 
//         geo,[mat,mat_cw]
//     );

//     return(mesh);

// }


// function clone_material(material){
    
//     var mat = material.clone();
//     if(material.clippingPlanes){
//         mat.clippingPlanes = material.clippingPlanes;
//     }

//     return(mat);

// }


