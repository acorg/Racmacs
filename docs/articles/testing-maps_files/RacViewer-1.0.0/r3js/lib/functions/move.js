
function bind_point_movement(viewport){

  // Set event listeners
  viewport.addEventListener("mousedown", function(){
  	if(viewport.intersected 
      && viewport.intersected[0].object 
      && viewport.intersected[0].object.material.draggable){
      viewport.navigable = false;
      viewport.dragObject = viewport.intersected[0].object;
      viewport.addEventListener("mousemove", dragpoint);
  	}
  });
  
  viewport.addEventListener("mouseup", function(){
    viewport.navigable = true;
    viewport.dragObject = null;
    viewport.removeEventListener("mousemove", dragpoint);
  });

  viewport.addEventListener("mousemove", function(){
  	if(viewport.intersected 
      && viewport.intersected[0].object 
      && viewport.intersected[0].object.material.draggable){
  		viewport.style.cursor = "move";
  	} else {
  		viewport.style.cursor = "default";
  	}
  });
  
  // Drag point function
  var dragpoint = function(){

    // Set variables    	
    var camera     = viewport.camera;
    var mouse      = viewport.mouse;
	  var plotPoints = viewport.mapPoints;
	  var dragObject = viewport.dragObject;
    
    // Store current point position
    var orig_position = dragObject.position.clone();
    var new_position  = dragObject.position.clone();
    
    // Project point position move to mouse and unproject back into scene
    new_position.applyMatrix4(dragObject.parent.matrixWorld).project(camera);
    new_position.x = mouse.x;
    new_position.y = mouse.y;
    var inverse_mat = new THREE.Matrix4();
    inverse_mat.getInverse(dragObject.parent.matrixWorld);
    new_position.unproject(camera).applyMatrix4(inverse_mat);
    
    // Work out how far the point has moved
    var delta = new THREE.Vector3(new_position.x - orig_position.x,
                                  new_position.y - orig_position.y,
                                  new_position.z - orig_position.z);

    // Move the point
    dragObject.translateX( delta.x );
    dragObject.translateY( delta.y );
    dragObject.translateZ( delta.z );

    if(dragObject.highlight){
      dragObject.highlight.translateX( delta.x );
      dragObject.highlight.translateY( delta.y );
      dragObject.highlight.translateZ( delta.z );
    }
    
    // Move grouped points
    if(dragObject.group){
    	for(var i=0; i<dragObject.group.length; i++){
    		var groupObject = dragObject.group[i];
    		if(groupObject.uuid != dragObject.uuid){

	    		groupObject.translateX( delta.x );
			    groupObject.translateY( delta.y );
			    groupObject.translateZ( delta.z );

			    if(groupObject.highlight){
			      groupObject.highlight.translateX( delta.x );
			      groupObject.highlight.translateY( delta.y );
			      groupObject.highlight.translateZ( delta.z );
			    }
			    
		    }
    	}
    }

  }

}



