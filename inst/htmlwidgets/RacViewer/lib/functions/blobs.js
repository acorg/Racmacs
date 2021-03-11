
R3JS.Viewer.prototype.eventListeners.push({
    name : "point-selected",
    fn : function(e){
        let point  = e.detail.point;
        let viewer = point.viewer;
        point.showBlob()
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "point-deselected",
    fn : function(e){
        let point  = e.detail.point;
        let viewer = point.viewer;
        point.hideBlob()
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "points-selected",
    fn : function(e){
        let viewer = e.detail.viewer;
        viewer.points.map( p => p.hideBlob() );
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "points-deselected",
    fn : function(e){
        let viewer = e.detail.viewer;
        viewer.points.map( p => p.showBlob() );
    }
});

Racmacs.StressblobsPanel = class StressblobsPanel {

    constructor(viewer){

        // Create holder div
        this.div = document.createElement("div");
        this.div.classList.add("stressblobs-tab");
        
        var newStressBlobsWell = new Racmacs.utils.InputWell({
            inputs: [
                { id: "stresslim",   value: 1,      label : "Stress limit" },
                { id: "gridspacing", value: 0.25,   label : "Grid spacing" }
            ],
            submit: "Calculate stress blobs",
            fn : function(args){ viewer.onAddStressBlobs(args) }
        });
        this.div.appendChild(newStressBlobsWell.div);
        newStressBlobsWell.div.classList.add("shiny-element");

    }


}

// Show blobs in the viewer
Racmacs.Viewer.prototype.addStressBlobs = function(blobdata){

    // Show the blobs
    for(var i=0; i<this.points.length; i++){
        this.points[i].addBlob(blobdata[i]);
    }

}

// Remove blobs from viewer
Racmacs.Viewer.prototype.removeBlobs = function(){

    for(var i=0; i<this.points.length; i++){
        this.points[i].removeBlob();
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
        let normals  = blob.normals;

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
            // normals  : normals,
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

