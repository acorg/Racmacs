
R3JS.Viewer.prototype.eventListeners.push({
    name : "point-selected",
    fn : function(e){
        let point  = e.detail.point;
        let viewer = point.viewer;
        // Show bootstrap
        point.showBootstrapPoints();
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "point-deselected",
    fn : function(e){
        let point  = e.detail.point;
        let viewer = point.viewer;
        // Hide bootstrap
        point.hideBootstrapPoints();
    }
});


Racmacs.Point.prototype.hideBootstrap = function(){

	this.viewer.scene.remove(this.bootstrap_points);
	
}


Racmacs.Viewer.prototype.showBootstrapPoints = function(bootstrapdata){

    // Add bootstrap points
    for(var i=0; i<this.points.length; i++){
        this.points[i].addBootstrapPoints({
            coords : bootstrapdata.map(x => x.coords[i])
        });
    }

}


Racmacs.Viewer.prototype.removeBootstrapPoints = function(){

    // Remove any current blobs
    for(var i=0; i<this.points.length; i++){
        this.points[i].removeBootstrapPoints();
    }
    

}


// Show bootstrap points instead of a point
Racmacs.Point.prototype.addBootstrapPoints = function(data){

    // Get coords
    let coords = data.coords;

    // Remove NaN coords
    coords = coords.filter( value => value[0] !== null );

    // Get transformation and translation
    let transformation = this.viewer.data.transformation();
    let translation = this.viewer.data.translation();

    // Apply map transformation to coordinates
    coords = coords.map(
        coord => Racmacs.utils.transformTranslateCoords(
            coord,
            transformation,
            translation
        )
    );

    // Make 3d
    for(var i=0; i<coords.length; i++){
        while(coords[i].length < 3){
            coords[i].push(-0.2);
        }
    }

    // Create a points object
    if (this.viewer.mapdims.dimensions == 3) {
        var object = new THREE.Object3D();
        coords.map(coord => {
            var element = new R3JS.element.Point({
                coords : coord,
                size : 0.5,
                shape : "sphere",
                properties : {
                    lwd : 1,
                    fillcolor : {
                        r : 0.2,
                        g : 0.2,
                        b : 0.2
                    },
                    mat : "lambert"
                }
            });
            object.add(element.object);
        });
        this.bootstrapPoints = {
            object : object
        };
    } else {
        this.bootstrapPoints = new R3JS.element.glpoints({
            coords : coords,
            size : Array(coords.length).fill(1),
            properties : {
                color : {
                    r:Array(coords.length).fill(0),
                    g:Array(coords.length).fill(0),
                    b:Array(coords.length).fill(0),
                    a:Array(coords.length).fill(0.3)
                }
            },
            dimensions : 2,
            viewer : this.viewer
        });
    }
    
    // Show the blob
    if(this.selected) this.showBootstrapPoints();

}

// Remove blob and show point
Racmacs.Point.prototype.removeBootstrapPoints = function(){
    
    // Hide the blob
    this.hideBootstrapPoints();

    // Set blobs to null
    this.bootstrapPoints = null;

}


// Remove bootstrapPoints and show point
Racmacs.Point.prototype.showBootstrapPoints = function(){
    
    // Set bootstrapPoints
    if(this.bootstrapPoints){

        // Add to the scene
        this.viewer.scene.add(this.bootstrapPoints.object);

    }

}


// Remove bootstrapPoints and show point
Racmacs.Point.prototype.hideBootstrapPoints = function(){
    
    // Set bootstrapPoints
    if(this.bootstrapPoints){
        
        // Remove the blob from the scene
        this.viewer.scene.remove(this.bootstrapPoints.object);

    }

}


