
Racmacs.Viewer.prototype.dragMode = false;

Racmacs.Viewer.prototype.toggleDragMode = function(){

	if(this.dragMode){
    	this.exitDragMode();
    } else {
    	this.enterDragMode();
    }

}

Racmacs.Viewer.prototype.enterDragMode = function(){

	// Check some points have been selected
	if(this.selected_pts.length == 0){
		alert("First select some points to move");
		return(null);
	}

	// Trigger drag event and highlight any buttons
	console.log("Drag mode on");
	this.dragMode = true;
    if(this.onDragOn){ this.onDragOn() }
    if(this.btns.toggleDragMode){ this.btns.toggleDragMode.highlight() }

    // Function for starting a drag
	var viewer = this;
	this.startDrag = function(){

		if(viewer.raytracer.intersected.length > 0){

			var intersected_elements = viewer.raytracer.intersectedElements();
			if(intersected_elements[0].point.selected){
				viewer.navigable = false;
				viewer.primaryDragPoint = intersected_elements[0].point;
				viewer.viewport.div.addEventListener("mousemove", viewer.dragPoints);
			}

		}

	}

	// Function to end a drag
	this.endDrag = function(){

		viewer.navigable = true;
		viewer.primaryDragPoint = null;
		viewer.viewport.div.removeEventListener("mousemove", viewer.dragPoints);

		// Trigger events
	    viewer.onCoordsChange()
	    

	}

	// Function to drag a point
	this.dragPoints = function(){

		// Set variables    	
		var camera           = viewer.camera.camera;
		var mouse            = viewer.viewport.mouse;
		var points           = viewer.points;
		var scene            = viewer.scene;
		var primaryDragPoint = viewer.primaryDragPoint;

		// Store current point position
		var orig_position = primaryDragPoint.coordsVector.clone();
		var new_position  = primaryDragPoint.coordsVector.clone();

		// Project point position move to mouse and unproject back into scene
		new_position.applyMatrix4(scene.plotPoints.matrixWorld).project(camera);
		new_position.x = mouse.x;
		new_position.y = mouse.y;
		
		var inverse_mat = new THREE.Matrix4();
		inverse_mat.getInverse(scene.plotPoints.matrixWorld);
		new_position.unproject(camera).applyMatrix4(inverse_mat);

		// Work out how far the point has moved
		var delta = [new_position.x - orig_position.x,
		             new_position.y - orig_position.y,
		             new_position.z - orig_position.z];

		// Move all selected points
		var selected_pts = viewer.selected_pts;
		for(var i=0; i<selected_pts.length; i++){
			
			var pt = selected_pts[i];
			pt.translate( delta[0], delta[1], delta[2] );

		}

	    viewer.updateStress();
		viewer.render();

	}

    // Set event listeners
	this.viewport.div.addEventListener("mousedown", this.startDrag);
	this.viewport.div.addEventListener("mouseup",   this.endDrag);
	// this.viewport.div.addEventListener("mousemove", this.cursorChange);
	
}

Racmacs.Viewer.prototype.exitDragMode = function(){

	console.log("Drag mode off");
	this.dragMode = false;

	// Trigger drag end event and dehighlight any buttons
	if(this.onDragOff){ this.onDragOff() }
	if(this.btns.toggleDragMode){ this.btns.toggleDragMode.dehighlight() }

    // Remove event listeners
	this.viewport.div.removeEventListener("mousedown", this.startDrag);
	this.viewport.div.removeEventListener("mouseup",   this.endDrag);
	// this.viewport.div.removeEventListener("mousemove", this.cursorChange);

}




