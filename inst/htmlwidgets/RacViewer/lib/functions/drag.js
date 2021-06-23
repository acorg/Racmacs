
R3JS.Viewer.prototype.eventListeners.push({
    name : "points-selected",
    fn : function(e){
    	let viewer = e.detail.viewer;
        viewer.btns.toggleDragMode.enable();
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "points-deselected",
    fn : function(e){
    	let viewer = e.detail.viewer;
        viewer.btns.toggleDragMode.disable()
    }
});


Racmacs.Viewer.prototype.dragMode = false;

Racmacs.Viewer.prototype.toggleDragMode = function(){

	if(this.dragMode){
    	this.exitDragMode();
    } else {
    	this.enterDragMode();
    }

}

Racmacs.DragPanel = class DragPanel {

    constructor(viewer){

        this.div = document.createElement("div");
	    this.div.id = "drag-controls";

	    // var header = document.createElement("div");
	    // header.id = "drag-header";
	    // header.innerHTML = "Moving points";
	    // this.div.appendChild(header);

	    var buttons = document.createElement("div");
        this.div.appendChild(buttons);

        var accept = new Racmacs.utils.Button({
        	label:"Accept",
        	fn: function(){ viewer.exitDragMode(true) }
        });
        accept.div.classList.add("accept-btn");
        buttons.appendChild(accept.div);

        var cancel = new Racmacs.utils.Button({
        	label:"Reset",
        	fn: function(){ viewer.exitDragMode(false) }
        });
        cancel.div.style.marginLeft = "6px";
        cancel.div.classList.add("cancel-btn");
        buttons.appendChild(cancel.div);

    }

    show(){
    	this.div.style.display = "block";
    }

    hide(){
    	this.div.style.display = "none";
    }

}

Racmacs.Viewer.prototype.enterDragMode = function(){

	// Check some points have been selected
	if(this.selected_pts.length == 0){
		alert("First select some points to move");
		return(null);
	}

	// Trigger drag event and highlight any buttons
	this.dragMode = true;
    if(this.onDragOn){ this.onDragOn() }
    if(this.btns.toggleDragMode){ this.btns.toggleDragMode.highlight() }
    if(this.btns.relaxMap){ this.btns.relaxMap.disable() }

    // Show the drag mode div
    if(!this.dragpanel){
	    this.dragpanel = new Racmacs.DragPanel(this);
	    this.viewport.div.appendChild(this.dragpanel.div);
    }
    this.dragpanel.show();

    // Keep a record of the starting coords for all points
    for(var i=0; i<this.selected_pts.length; i++){
    	this.selected_pts[i].dragStartPosition = this.selected_pts[i].getPosition();
    }

    // Keep a record of the starting stress
    this.dragStartStress = this.stress.value;

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
		inverse_mat.copy(scene.plotPoints.matrixWorld).invert();
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

Racmacs.Viewer.prototype.exitDragMode = function(accept = false){

	if (this.dragMode) {
	    this.dragMode = false;

	    // Trigger drag end event and dehighlight any buttons
		if(this.onDragOff){ this.onDragOff() }
		if(this.btns.toggleDragMode){ this.btns.toggleDragMode.dehighlight() }
		if(this.btns.relaxMap){ this.btns.relaxMap.enable() }

		// Remove event listeners
		this.viewport.div.removeEventListener("mousedown", this.startDrag);
		this.viewport.div.removeEventListener("mouseup",   this.endDrag);

		// Hide the drag panel
		this.dragpanel.hide();

		if(accept){
	        
			// Accepted ----

	        // Trigger events
		    this.onCoordsChange();
		    this.data.updateCoords();

		} else {
			
			// Cancelled ----

			// Restore points to their original positions
			for(var i=0; i<this.selected_pts.length; i++){
				var orig_position = this.selected_pts[i].dragStartPosition;
				this.selected_pts[i].setPosition([
					orig_position[0],
					orig_position[1],
					orig_position[2]
				]);
			}

			// Restore original stress
		    this.updateStress(this.dragStartStress);

		};

		// Update the stress
		this.render();
	}

}
