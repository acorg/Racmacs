
// Function for generating default properties
R3JS.DefaultProperties = function(properties, n) {

    if (properties === undefined) properties = {};
    properties.color = R3JS.DefaultColor(properties.color, n);
    return properties;

}

// Function for generating a default array
R3JS.DefaultArray = function(array, defaultvalue, n) {

    if (array === undefined) array = [defaultvalue];
    if (array.length != n) array = Array(n).fill(array[0]);
    return array;

}

// Function for generating a color vector of the right length
R3JS.DefaultColor = function(color, n) {

    if (color === undefined) color = {};
    if (color.r === undefined) color.r = [0];
    if (color.g === undefined) color.g = [0];
    if (color.b === undefined) color.b = [0];
    if (color.a === undefined) color.a = [1];

    if (!Array.isArray(color.r)) color.r = [color.r];
    if (!Array.isArray(color.g)) color.g = [color.g];
    if (!Array.isArray(color.b)) color.b = [color.b];
    if (!Array.isArray(color.a)) color.a = [color.a];

    if (color.r.length != n) color.r = Array(n).fill(color.r);
    if (color.g.length != n) color.g = Array(n).fill(color.g);
    if (color.b.length != n) color.b = Array(n).fill(color.b);
    if (color.a.length != n) color.a = Array(n).fill(color.a);

    return color;

}

// Function for generating a material from properties
R3JS.Material = function(properties){

    // Convert colors
    properties.color = new THREE.Color(
        properties.color.r,
        properties.color.g,
        properties.color.b
    );

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
    if (properties.frontSide && properties.backSide) {
        mat.side = THREE.DoubleSide;
    } else if (properties.backSide) {
        mat.side = THREE.BackSide;
    } else {
        mat.side = THREE.FrontSide;
    }

    // Set clipping
    mat.clippingPlanes = [];

    return(mat);

}


R3JS.element.make = function(
    plotobj, 
    viewer
    ){

    // Apply any additional offset
    var plotdims = viewer.scene.plotdims;
    if(plotobj.properties && plotobj.properties.poffset && plotobj.position) {
        plotobj.position[0] = plotobj.position[0] + plotobj.properties.poffset[0]*plotdims.size[0]/plotdims.aspect[0];
        plotobj.position[1] = plotobj.position[1] + plotobj.properties.poffset[1]*plotdims.size[1]/plotdims.aspect[1];
        plotobj.position[2] = plotobj.position[2] + plotobj.properties.poffset[2]*plotdims.size[2]/plotdims.aspect[2];
    }

    if(plotobj.type == "point"){
        // Point
        var element = this.constructors.point(
            plotobj,
            viewer
        );
    } else if(plotobj.type == "line"){
        // GL Points
        var element = this.constructors.line(
            plotobj,
            viewer
        );
    } else if(plotobj.type == "glpoints"){
        // GL Points
        var element = this.constructors.glpoints(
            plotobj,
            viewer
        );
    } else if(plotobj.type == "glline"){
        // GL line
        var element = this.constructors.glline(
            plotobj,
            viewer
        );
    } else if(plotobj.type == "text"){
        // Text
        var element = this.constructors.text(
            plotobj,
            viewer
        );
    } else if(plotobj.type == "sphere"){
        // Sphere
        var element = this.constructors.sphere(
            plotobj,
            viewer
        );
    } else if(plotobj.type == "surface"){
        // Surface
        var element = this.constructors.surface(
            plotobj,
            viewer
        );
    } else if(plotobj.type == "grid"){
        // Grid
        var element = this.constructors.grid(
            plotobj,
            viewer
        );
    } else if(plotobj.type == "triangle"){
        // Triangles
        var element = this.constructors.triangles(
            plotobj,
            viewer
        );
    } else if(plotobj.type == "shape"){
        // 3d shape
        var element = this.constructors.polygon3d(
            plotobj,
            viewer
        );
    } else {
        throw("Plot object type '"+plotobj.type+"' not recognised.");
    }

    // Apply renderOrder
    if(plotobj.properties){
        
        // Set render order
        if (plotobj.properties.renderOrder !== undefined) {
            element.setRenderOrder(plotobj.properties.renderOrder);
        }

    }

    

    // if(element.object.material){
    //     // element.object = R3JS.utils.separateSides(element.object);
    // }

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

            // Add an element to it's own group if it has a label but no group
            if(element.label !== undefined && !element.groupindices){
                element.group = [element];
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

        if(plotobj.highlight.properties.faces){

            this.dynamic_objects.push(hlelement);
            if(plotobj.highlight.properties.faces.indexOf("x+") != -1){ this.dynamicDeco.faces[0].push(hlelement) }
            if(plotobj.highlight.properties.faces.indexOf("y+") != -1){ this.dynamicDeco.faces[1].push(hlelement) }
            if(plotobj.highlight.properties.faces.indexOf("z+") != -1){ this.dynamicDeco.faces[2].push(hlelement) }
            if(plotobj.highlight.properties.faces.indexOf("x-") != -1){ this.dynamicDeco.faces[3].push(hlelement) }
            if(plotobj.highlight.properties.faces.indexOf("y-") != -1){ this.dynamicDeco.faces[4].push(hlelement) }
            if(plotobj.highlight.properties.faces.indexOf("z-") != -1){ this.dynamicDeco.faces[5].push(hlelement) }

        }

        if(plotobj.properties.corners){

            this.dynamic_objects.push(hlelement);
            
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

            this.dynamicDeco.edges[a][b].push(hlelement);

        }

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






