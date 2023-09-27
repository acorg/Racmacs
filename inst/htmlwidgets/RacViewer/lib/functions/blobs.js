
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


// Show blobs in the viewer
Racmacs.Viewer.prototype.addTriangulationBlobs = function(blobdata){

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
    if (blob === null) return;
    
    // Hide the normal element
    this.pointElement.hide();

    // Get transformation and translation
    let transformation = this.viewer.data.transformation();
    let translation = this.viewer.data.translation();

    if(this.viewer.data.dimensions() == 2){

        // 2d blobs
        for(var i=0; i<blob.length; i++){

            var coords = blob[i].x.map(
                (x,j) => [blob[i].x[j], blob[i].y[j]]
            );

            // Apply map transformation to coordinates
            coords = coords.map(
                coord => Racmacs.utils.transformTranslateCoords(
                    coord,
                    transformation,
                    translation
                )
            );

            // Make 3d
            for(var j=0; j<coords.length; j++){
                while(coords[j].length < 3){
                    coords[j].push(0);
                }
            }


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
                        r:Array(coords.length*2).fill(outlinecolor[0]),
                        g:Array(coords.length*2).fill(outlinecolor[1]),
                        b:Array(coords.length*2).fill(outlinecolor[2]),
                        a:Array(coords.length*2).fill(outlinecolor[3])
                    }
                },
                viewport : this.viewer.viewport
            });

            if(this.blob == null){ this.blob = blob_element              }
            else                 { this.blob.mergeGeometry(blob_element) }

        }

    } else {

        // Get vertices and faces
        let vertices = blob[0].vertices;
        let normals  = blob[0].normals;
        let faces = [];
        for (var i=0; i<blob.length; i++) {
            faces = faces.concat(blob[i].faces);
        }

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
        this.blob = new Racmacs.element.Blob3d({
            faces        : faces,
            vertices     : vertices,
            normals      : normals,
            fillcolor    : this.fillColor,
            outlinecolor : this.outlineColor,
            viewport     : this.viewer.viewport
        });


    }

    // Show the blob
    if (this.blob) {
        this.bindElement(this.blob);
        this.showBlob();
    }

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

        // Dehover the point
        this.dehover();

    }

}

