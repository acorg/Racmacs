
function bind_mapRaytracing(viewport){
    
    // Add raycaster and function
    var raycaster = new THREE.Raycaster();
    viewport.raycaster = raycaster;

    function hover_intersects(intersected){

    	for(var i=0; i<intersected.length; i++){
    		viewport.points[intersected[i]].hover();
    	}

    }

    function dehover_intersects(intersected){

    	for(var i=0; i<intersected.length; i++){
    		viewport.points[intersected[i]].dehover();
    	}

    }

    viewport.getTopIntersected = function(intersects){

    	return(intersects.slice(0,1));

    }

    viewport.getIntersectPtIndices = function( mouse, camera ){

    	raycaster.setFromCamera( this.mouse, this.camera );
    	var intersects = raycaster.intersectObjects( this.scene.selectable_objects, false );

    }
	
	viewport.raytrace = function(){

		// Do raystracing and find intersections
        var intersected = viewport.getIntersectPtIndices( 
        	this.mouse, 
        	this.camera,
        	this.keydown && this.keydown.key == "Shift"
        );

		// Check if you have any intersections
		if ( intersected && intersected.length > 0 ) {

		  // Check if you've scrolled onto a new point
		  if ( this.intersected_points != intersected) {

		    // Restore emission to previously intersected point if not null
		    if (this.intersected_points){
		        dehover_intersects(this.intersected_points);
		    }

		    // Update intersected
		    this.intersected_points = intersected;

		    // Color new point accordingly
		    hover_intersects(this.intersected_points);

		  }

		} else {

		  if (this.intersected_points) {

		    dehover_intersects(this.intersected_points);

		  }

		  this.intersected_points = null;

		}

	}


}

