

Racmacs.StressblobsPanel = class StressblobsPanel {

    constructor(viewer){

        // Create holder div
        this.div = document.createElement("div");
        this.div.classList.add("stressblobs-tab");

        var stressBlobsTable = new Racmacs.StressBlobsTable(viewer);
        this.div.appendChild(stressBlobsTable.div);
        
        var newStressBlobsWell = new Racmacs.utils.InputWell({
            inputs: [
                { id: "stresslim",   value: 1,      label : "Stress limit" },
                { id: "gridspacing", value: 0.25,   label : "Grid spacing" },
                { id: "gridmargin",  value: 4,      label : "Grid margin"  }
            ],
            submit: "Calculate stress blobs",
            fn : function(args){ viewer.onAddStressBlobs(args) }
        });
        this.div.appendChild(newStressBlobsWell.div);
        newStressBlobsWell.div.classList.add("shiny-element");

    }


}



Racmacs.StressBlobsTable = class StressBlobsList extends Racmacs.TableList {

    constructor(viewer){

        // Generate skeleton
        super({
            title   : "Stress blobs",
            checkbox_check_fn : function(){},
            checkbox_uncheck_fn : function(){
                viewer.removeBlobs();
            },
            headers : ["Stress lim", "Grid spacing", "Antigens", "Sera"]
        });

        // Bind to viewer
        viewer.blobTable = this;
        this.viewer = viewer;
        
    }

    addData(blobs){

        var stressBlobsTable = this;
        this.addRow({
            content : [blobs.stress_lim, blobs.grid_spacing, blobs.antigens, blobs.sera],
            fn : function(){
                stressBlobsTable.viewer.showBlobs(blobs.blob_data);
            }
        });

    }

}

// Show blobs in the viewer
Racmacs.Viewer.prototype.addBlobs = function(blobs, show=false){

    // Add to the blob panel
    if(this.blobTable){
        this.blobTable.addData(blobs);
    }

    // Show the blobs
    if(show){
        this.showBlobs(blobs.blob_data);
    }

}

// Show blobs in the viewer
Racmacs.Viewer.prototype.showBlobs = function(blobdata){

    if(this.blobTable){
        this.blobTable.checkbox.enable();
        this.blobTable.checkbox.check(false);
    }

    // Show the blobs
    for(var i=0; i<this.antigens.length; i++){
        if(blobdata.antigens[i] 
           && Object.keys(blobdata.antigens[i]).length !== 0){

            this.antigens[i].addBlob(blobdata.antigens[i]);

        } else {

            this.antigens[i].removeBlob();

        }
    }
    
    for(var i=0; i<this.sera.length; i++){
        if(blobdata.sera[i] 
           && Object.keys(blobdata.sera[i]).length !== 0){

            this.sera[i].addBlob(blobdata.sera[i]);

        } else {

            this.sera[i].removeBlob();

        }
    }

}

// Remove blobs from viewer
Racmacs.Viewer.prototype.removeBlobs = function(){

    if(this.blobTable){
        this.blobTable.checkbox.uncheck(false);
        this.blobTable.checkbox.disable();
    }
        
    for(var i=0; i<this.points.length; i++){
        this.points[i].removeBlob();
    }

    if(this.blobTable){
        this.blobTable.deselectAll();
    }

}



// Show blob instead of a point
Racmacs.Point.prototype.addBlob = function(blob){

    // Remove any current blobs
    this.removeBlob();

    // Hide the normal element
    this.pointElement.hide();

    // Get transformation and translation
    let transformation = this.viewer.data.transformation();
    let translation = this.viewer.data.translation();
    
    if(this.viewer.data.dimensions() == 2){
    
        // 2d blobs
        for(var i=0; i<blob.length; i++){

            var coords = blob[i].x.map(
                (x,j) => [blob[i].x[j], blob[i].y[j], 0]
            );

            // Apply map transformation to coordinates
            coords = coords.map(
                coord => Racmacs.utils.transformTranslateCoords(
                    coord,
                    transformation,
                    translation
                )
            );


            var fillcolor    = this.getFillColorRGBA();
            var outlinecolor = this.getOutlineColorRGBA();

            var blob_element = new R3JS.element.Polygon2d({
                coords : coords,
                properties : {
                    mat : "basic",
                    transparent : true,
                    fillcolor : {
                        r:fillcolor[0],
                        g:fillcolor[1],
                        b:fillcolor[2],
                        a:fillcolor[3]
                    },
                    outlinecolor : {
                        r:Array(coords.length).fill(outlinecolor[0]),
                        g:Array(coords.length).fill(outlinecolor[1]),
                        b:Array(coords.length).fill(outlinecolor[2]),
                        a:Array(coords.length).fill(outlinecolor[3])
                    }
                },
                viewport : this.viewer.viewport
            });

            if(this.blob == null){ this.blob = blob_element              }
            else                 { this.blob.mergeGeometry(blob_element) }

        }

    } else {

        // Get vertices and faces
        let vertices = blob.vertices;
        let faces    = blob.faces;

        // 3D blobs
        var fillcolor    = this.getFillColorRGBA();
        var outlinecolor = this.getOutlineColorRGBA();

        // Get transformation and translation
        let transformation = this.viewer.data.transformation();
        let translation = this.viewer.data.translation();

        // Apply the map transformation to the blob coordinates
        vertices = vertices.map(
            coord => Racmacs.utils.transformTranslateCoords(
                coord,
                transformation,
                translation
            )
        );

        // Generate the blob element
        this.blob = new R3JS.element.Polygon3d({
            faces    : faces,
            vertices : vertices,
            properties : {
                mat : "phong",
                transparent : true,
                fillcolor : {
                    r:fillcolor[0],
                    g:fillcolor[1],
                    b:fillcolor[2],
                    a:fillcolor[3]
                },
                outlinecolor : {
                    r:outlinecolor[0],
                    g:outlinecolor[1],
                    b:outlinecolor[2],
                    a:outlinecolor[3]
                }
            },
            viewport : this.viewer.viewport,
            outline : this.fillColor == "transparent"
        });

    }
    
    // Show the blob
    this.showBlob();

}

// Remove blob and show point
Racmacs.Point.prototype.removeBlob = function(){
    
    // Hide the blob
    this.hideBlob();

    // Set blobs to null
    this.blob = null;

}


// Remove blob and show point
Racmacs.Point.prototype.showBlob = function(){
    
    // Set blob
    if(this.blob){

        // Add to selectable elements
        this.viewer.scene.addSelectableElement(this.blob);

        // Add to the scene
        this.viewer.scene.add(this.blob.object);

        // Hide the point element again
        this.pointElement.hide();

        // Bind the blob element
        this.bindElement(this.blob);

    }

}


// Remove blob and show point
Racmacs.Point.prototype.hideBlob = function(){
    
    // Set blob
    if(this.blob){
        
        // Remove the blob from selectable elements
        this.viewer.scene.removeSelectableElement(this.blob);

        // Remove the blob from the scene
        this.viewer.scene.remove(this.blob.object);

        // Show the point element again
        this.pointElement.show();

        // Bind the point element
        this.bindElement(this.pointElement);

    }

}


// function bindBlobfunctions(viewport){

//     viewport.addBlobs = function(blobs){
        
//         for(var i=0; i<this.antigens.length; i++){
//             if(blobs.antigens[i] 
//                && Object.keys(blobs.antigens[i]).length !== 0){

//                 this.antigens[i].addBlob(blobs.antigens[i]);

//             }
//         }
        
//         for(var i=0; i<this.sera.length; i++){
//             if(blobs.sera[i] 
//                && Object.keys(blobs.sera[i]).length !== 0){

//                 this.sera[i].addBlob(blobs.sera[i]);

//             }
//         }

//     }

//     viewport.removeBlobs = function(){
        
//         for(var i=0; i<this.points.length; i++){
//             this.points[i].removeBlob();
//         }

//     }
    
//     // Set prototype functions
//     viewport.Point.prototype.addBlob = function(blob){
        
//         // Add the new blob geometry
//         this.removeBlob();
//         this.hidePointGeo();
//         this.blob = blob;
//         this.blobObject = this.generateBlobObject();
//         this.setBlobGeoFillCol(this.fillColor);
//         this.setBlobGeoOutlineCol(this.outlineColor);
//         viewport.scene.plotPoints.add(this.blobObject);

//     }

//     viewport.Point.prototype.removeBlob = function(){

//         // Remove any existing blob geometries
//         if(this.blobObject){
//             viewport.scene.plotPoints.remove(this.blobObject);
//             for (var i = 0; i < viewport.scene.selectable_objects.length; i++) {
//                 var obj = viewport.scene.selectable_objects[i];
//                 if (obj.uuid === this.blobSelector.uuid) {
//                     viewport.scene.selectable_objects.splice(i, 1);
//                     break;
//                 }
//             }
//         }
//         this.blob = null;
//         this.blobObject = null;
//         this.blobSelector = null;
//         this.showPointGeo();

//     }

// }

//     function convertBlob(object, blob, dim){

//         if(dim == 2){
//             convertBlob2D(object, blob);
//         }
//         if(dim == 3){
//             convertBlob3D(object, blob);
//         }

//         object.blob = true;
//         object.origScale = object.scale.x;
//         object.scale.set(1,1,1);
//         object.updateMatrixWorld();

//     }

//     function convertBlob2D(object, blob){

//         var fill    = object.children[0];
//         var outline = object.children[1];

//         // Work out geometry
//         for(var i=0; i<blob.length; i++){
//             var blobShape = new THREE.Shape();
//             blobShape.moveTo( blob[i].x[0]-object.position.x, blob[i].y[0]-object.position.y );
//             for(var j=0; j<blob[i].x.length; j++){
//                 blobShape.lineTo(blob[i].x[j]-object.position.x, blob[i].y[j]-object.position.y);
//             }
            
//             var blobshapegeo = new THREE.ShapeGeometry( blobShape );
//             var blobgeo      = new THREE.BufferGeometry().fromGeometry( blobshapegeo );
//         }
        
//         var bloboutlinegeo = convert2Outline(blobshapegeo.vertices, 0.1);
//         bloboutlinegeo     = new THREE.BufferGeometry().fromGeometry( bloboutlinegeo );

//         object.rotation.z = 0;

//         fill.geometry    = blobgeo;
//         outline.geometry = bloboutlinegeo;

//     }

//     function convertBlob3D(object, blob){

//         var fill    = object.children[0];
//         var outline = object.children[1];
//         outline.visible = false;
        
//         var blobgeo = new THREE.Geometry();
//         for(var i=0; i<blob.vertices.length; i++){
//             blobgeo.vertices.push(
//                 new THREE.Vector3(
//                     blob.vertices[i][0] - object.position.x,
//                     blob.vertices[i][1] - object.position.y,
//                     blob.vertices[i][2] - object.position.z
//                 )
//             );
//         }
//         for(var i=0; i<blob.faces.length; i++){
//             blobgeo.faces.push(
//                 new THREE.Face3( 
//                     blob.faces[i][2]-1, 
//                     blob.faces[i][1]-1, 
//                     blob.faces[i][0]-1
//                 )
//             );
//         }
        
//         blobgeo.mergeVertices();
//         blobgeo.computeVertexNormals();
//         blobgeo.computeFaceNormals();
//         var blobgeo   = new THREE.BufferGeometry().fromGeometry( blobgeo );
//         fill.geometry = blobgeo;

//     }


// }



// function convert2Outline(vertices, lwd){

//     var outline = new THREE.Geometry();

//     vertices.push(vertices[0]);
//     for(var i=0; i<(vertices.length-1); i++){
          
//         var line = line_geo2D(
//             vertices[i].toArray(),
//             vertices[i+1].toArray(), 
//             lwd,
//             true);

//         outline.merge(line);

//     }
//     return(outline);

// };

