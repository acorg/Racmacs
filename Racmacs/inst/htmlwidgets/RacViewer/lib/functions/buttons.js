
R3JS.Viewport.prototype.addMapButtons = function(){

	var viewer = this.viewer;

	// Create button to show viewer info
	this.addButton({
		name  : "toggleLockPointSize",
		title : "Lock point size when zooming",
		icon  : Racmacs.icons.locksize(),
		fn    : function(){
			viewer.toggleLockPointSize();
		}
	});

	// Create button to scale points up
	this.addButton({
		name  : "reflectMap",
		title : "Reflect map",
		icon  : Racmacs.icons.flip(),
		fn    : function(e){
			if(e.shiftKey){
				viewer.onReflectMap("x");
			} else {
				viewer.onReflectMap("y");
			}
		}
	}, 0);

	// Create button to scale points up
	this.addButton({
		name  : "scalePointsUp",
		title : "Increase point size",
		icon  : Racmacs.icons.scaleup(),
		fn    : function(e){
			if(e.shiftKey){
				viewer.setGridLineWidth(
					viewer.getGridLineWidth()*1.2
				);
			} else {
				viewer.scalePoints(1.2);
			}
		}
	}, 0);

	// Create button to scale points down
	this.addButton({
		name  : "scalePointsDown",
		title : "Decrease point size",
		icon  : Racmacs.icons.scaledown(),
		fn    : function(e){
			if(e.shiftKey){
				viewer.setGridLineWidth(
					viewer.getGridLineWidth()/1.2
				);
			} else {
				viewer.scalePoints(0.8);
			}
		}
	}, 0);

}


// function addMapButtons(viewport){

// 	// Redefine the center scene button
// 	viewport.btns.centerScene.event = function(){
        
//         viewport.updateSceneSphere();
// 		viewport.camera.setDistance();
//         viewport.scene.plotPoints.position.copy(viewport.scene.sphere.center.clone().negate());

// 	}

// 	// Button for toggling whether points are scaled when you zoom
// 	viewport.toggle_zoom_points_on_scroll = function(){
// 	    if(viewport.zoomPointsOnScroll){
// 	        viewport.zoomPointsOnScroll = false;
// 	        viewport.btns.scale_scroll_btn.updateSymbol(icon_unlocksize());
// 	    } else {
// 	        viewport.zoomPointsOnScroll = true;
// 	        viewport.btns.scale_scroll_btn.updateSymbol(icon_locksize());
// 	    }
// 	}
    
//     // Copy selection
//     viewport.copy_div = document.createElement("div");
// 	viewport.copy_div.style.display = "none";
// 	viewport.appendChild(viewport.copy_div);
// 	viewport.btns.copy_selection = viewport.btns.createButton("Copy selection to clipboard",
// 	                                                          icon_copy(),
// 	                                                          function(){

// 	                                                          	// Clear the copy div
// 	                                                          	viewport.copy_div.innerHTML = "";

// 	                                                          	// Get selected points
// 	                                                          	var selected_points = viewport.api.getSelectedPoints();

// 	                                                          	// Get antigen names
// 	                                                          	var ag_names = viewport.api.antigen_names();
// 	                                                          	for(var i=0; i<selected_points.antigens.length; i++){
// 	                                                          		viewport.copy_div.innerHTML += ag_names[selected_points.antigens[i]] + "<br/>";
// 	                                                          	}

// 	                                                          	// Get sera names
// 	                                                          	var sr_names = viewport.api.sera_names();
// 	                                                          	for(var i=0; i<selected_points.sera.length; i++){
// 	                                                          		viewport.copy_div.innerHTML += sr_names[selected_points.sera[i]] + "<br/>";
// 	                                                          	}

// 	                                                          	// Copy the content
// 	                                                          	viewport.copy_div.style.display = "inline-block";
// 																var range = document.createRange();
// 																range.selectNode(viewport.copy_div);
// 																window.getSelection().removeAllRanges();
// 																window.getSelection().addRange(range);
// 																document.execCommand("copy");
// 																viewport.copy_div.style.display = "none";

// 	                                                          });
// 	viewport.btns.appendChild(viewport.btns.copy_selection);
	    
// 	viewport.btns.scale_scroll_btn = viewport.btns.createButton("Fix point size when zooming",
// 	                                                            icon_unlocksize(),
// 	                                                            viewport.toggle_zoom_points_on_scroll);
// 	viewport.btns.appendChild(viewport.btns.scale_scroll_btn);

// 	// Button to scale points larger
// 	viewport.btns.scalePtsUp_btn = viewport.btns.createButton("Scale points larger",
// 	                                                          icon_scaleup(),
// 	                                                          function(){ viewport.scalePoints(1.1) });
// 	viewport.btns.appendChild(viewport.btns.scalePtsUp_btn);

// 	// Button to scale points smaller
// 	viewport.btns.scalePtsUp_btn = viewport.btns.createButton("Scale points smaller",
// 	                                                          icon_scaledown(),
// 	                                                          function(){ viewport.scalePoints(1/1.1) });
// 	viewport.btns.appendChild(viewport.btns.scalePtsUp_btn);

// 	// Function to flip the map
// 	viewport.onFlip = function(){};
// 	viewport.flip = function(){
        
//         var normal = new THREE.Vector3(1,0,0);
//         this.scene.plotHolder.worldToLocal(normal);

//         for(var i=0; i<this.points.length; i++){
//         	this.points[i].coordsVector.reflect(normal);
//         	this.points[i].setPosition(
//         		this.points[i].coordsVector.x,
//         		this.points[i].coordsVector.y,
//         		this.points[i].coordsVector.z
//         	);
//         }
//         this.scene.plotPoints.position.reflect(normal);
// 	    this.onFlip();

// 	}
// 	viewport.btns.reflectMap = viewport.btns.createButton("Reflect map",
// 	                                                      icon_flip(),
// 	                                                      function(){ viewport.flip() });
// 	viewport.btns.appendChild(viewport.btns.reflectMap);

// }

