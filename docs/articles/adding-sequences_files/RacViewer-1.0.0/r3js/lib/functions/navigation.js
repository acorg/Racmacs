
R3JS.Viewer.prototype.bindNavigation = function(){

    // Add viewport variables
    this.navigable = true;
    this.damper    = {};

    // Set bindings
    this.mouseMove        = this.rotateSceneWithInertia;
    this.mouseMoveMeta    = this.panScene;
    this.mouseScroll      = this.zoomScene;
    this.mouseScrollShift = this.rockScene;

    // Bind mouse events
    this.viewport.canvas.addEventListener("mousemove", function(event){ 

        var viewer   = this.viewport.viewer;
        var viewport = this.viewport;

        if(viewer.navigable){
            if(viewport.mouse.down && !viewport.dragObject){
                if(!viewport.mouse.event.metaKey && !viewport.mouse.event.shiftKey && viewport.touch.num <= 1){
                    viewer.mouseMove();
                } else if(viewport.mouse.event.metaKey){
                    viewer.mouseMoveMeta();
                }
            }
        }
        // if(this.viewport.mouse.down){
        //     this.viewport.viewer.mouseMove();
        // }

    });

    this.viewport.canvas.addEventListener("wheel", function(event){

        var viewer   = this.viewport.viewer;
        var viewport = this.viewport;

        if(viewer.navigable){
            if(viewport.mouse.scrollShift){
                viewer.mouseScrollShift();
            } else {
                viewer.mouseScroll();
            }
        }

    });
    // this.div.addEventListener("touchmove", function(){
    //     if(this.touch.num == 1){
    //         navMouseMove(this); 
    //     } else {
    //         navScroll(this);
    //     }
    // });

}


R3JS.Viewer.prototype.rotateSceneWithInertia = function(){

    var deltaX = this.viewport.mouse.deltaX;
    var deltaY = -this.viewport.mouse.deltaY;

    this.rotateSceneXY(deltaX, deltaY);

    if(this.rotationDamperTimeout){ 
        window.clearTimeout( this.rotationDamperTimeout );
    }
    this.rotationDamper( deltaX, deltaY );

}

R3JS.Viewer.prototype.rotateSceneXY = function( deltaX, deltaY ){

    this.sceneChange = true;
    this.scene.rotateOnAxis(new THREE.Vector3(0,1,0), deltaX );
    this.scene.rotateOnAxis(new THREE.Vector3(1,0,0), deltaY );
    if(this.scene.dynamic) this.scene.showhideDynamics(this.camera.camera);

}

R3JS.Viewer.prototype.rotationDamper = function(deltaX, deltaY){

    if(Math.abs(deltaX) > 0.001 || Math.abs(deltaY) > 0.001){

        deltaX = deltaX*0.85;
        deltaY = deltaY*0.85;
        this.rotateSceneXY(deltaX, deltaY);
        var viewer = this;
        this.rotationDamperTimeout = window.setTimeout(function(){
            if(!viewer.viewport.mouse.down){
                viewer.rotationDamper( deltaX, deltaY )
            }
        }, 10);

    }

}

R3JS.Viewer.prototype.zoomScene = function(){

    this.sceneChange = true;
    this.camera.zoom(Math.pow(1.01, this.viewport.mouse.scrollY));

}

R3JS.Viewer.prototype.panScene = function(){

    this.sceneChange = true;
    var panX = this.viewport.mouse.deltaX;
    var panY = this.viewport.mouse.deltaY;

    var plotHolder = this.scene.plotHolder;
    var plotPoints = this.plotPoints;

    var position = new THREE.Vector3(0, 0, 0);
    position.applyMatrix4(plotHolder.matrixWorld).project(this.camera.camera);
    position.x += panX;
    position.y += panY;
    var inverse_mat = new THREE.Matrix4();
    inverse_mat.getInverse(plotHolder.matrixWorld);
    position.unproject(this.camera.camera).applyMatrix4(inverse_mat);

    this.scene.panScene(position.toArray());
    this.scene.showhideDynamics(this.camera.camera);

}


R3JS.Viewer.prototype.rockScene = function(){
    
    this.sceneChange = true;
    var rotZ = this.viewport.mouse.scrollY;
    var plotHolder = this.scene.plotHolder;
    this.scene.rotateOnAxis(new THREE.Vector3(0,0,1), rotZ*0.01);
    this.scene.showhideDynamics(this.camera.camera);

    if(this.settings.rotateAroundMouse){

        // Rotate about mouse position
        var mouse = this.viewport.mouse;
        var scene_pos1 = new THREE.Vector3( mouse.x, mouse.y, 0 ).unproject( this.camera.camera );
        this.scene.plotHolder.updateMatrixWorld();
        this.scene.plotHolder.worldToLocal(scene_pos1);

        // Rotate vector
        var scene_pos2 = scene_pos1.clone().applyAxisAngle(new THREE.Vector3(0,0,1), rotZ*0.01);

        // Get difference in position
        var posdif = scene_pos1.sub(scene_pos2);
        this.scene.panScene(posdif.toArray());

    }

}






// function update_labels(viewport){
//     viewport.plotHolder.updateMatrixWorld();
//     for(var i=0; i<viewport.labels.length; i++){
//         var lab = viewport.labels[i];
//         // Negate any world rotation
//         var qrot = lab.parent.getWorldQuaternion();
//         lab.rotation.setFromQuaternion(qrot.conjugate());
//     }
// }

// // function rotateLocalAxes(viewport, axis, rotation){
// // 	var world_axis = axis.clone().applyQuaternion(viewport.plotHolder.quaternion);
// // 	viewport.plotHolder.rotateOnAxis(axis, rotation);
// // 	for(var i=0; i<viewport.clippingPlanes.length; i++){
// // 		var norm = viewport.clippingPlanes[i].normal;
// // 		norm.applyAxisAngle(world_axis, rotation);
// // 		viewport.clippingPlanes[i].set(norm, viewport.clippingPlanes[i].constant);
// // 	}
// // 	viewport.plotHolder.rotation.onChangeCallback();
// // }

// function rotatePlotHolder(viewport, rotX, rotY){
// 	viewport.scene.rotateSceneOnAxis(new THREE.Vector3(1,0,0), -rotY);
// 	viewport.scene.rotateSceneOnAxis(new THREE.Vector3(0,1,0), rotX);
// 	viewport.scene.showhideDynamics(viewport.camera);
// 	viewport.sceneChange = true;
// 	viewport.infoDiv.update();
// 	//update_labels(viewport);
// 	//viewport.transform.update(viewport);
// }

// function rotationInertia(viewport){
// 	if(!viewport.mouse.down && (Math.abs(viewport.damper.rotX) > 0.001 || Math.abs(viewport.damper.rotY) > 0.001)){
//         viewport.damper.rotX = viewport.damper.rotX*0.9;
// 		viewport.damper.rotY = viewport.damper.rotY*0.9;
//         rotatePlotHolder(viewport, viewport.damper.rotX*3, viewport.damper.rotY*3);
//         viewport.damper.timeout = window.setTimeout(function(){rotationInertia(viewport)}, 10);
//     }
// }

// function rotateClippingPlanes(viewport, axis, angle) {
// 	for(var i=0; i<viewport.clippingPlanes.length; i++){
// 		var norm = viewport.clippingPlanes[i].normal;
// 		norm.applyAxisAngle(axis, angle);
// 		viewport.clippingPlanes[i].set(norm, viewport.clippingPlanes[i].constant);
// 	}
// }

// function dampScroll(scrollDelta){
// 	if(scrollDelta < 0){ 
// 	  scrollDelta = -scrollDelta;
// 	  var n = 1;
// 	} else {
// 		var n = -1;
// 	}
//     scrollDelta += -6;
// 	return((1/(1+Math.pow(Math.E, -0.3*scrollDelta)))*n);
// }

// function navMouseMove(viewport){
// 	if(viewport.navigable){
// 	    if(viewport.mouse.down && !viewport.dragObject){
// 	      if(!viewport.mouse.event.metaKey && !viewport.mouse.event.shiftKey && viewport.touch.num <= 1){
// 	        viewport.mouseMove(viewport.mouse.deltaX, viewport.mouse.deltaY);
// 	      } else if(viewport.mouse.event.metaKey || viewport.touch.num == 3){
// 	        viewport.mouseMoveMeta(viewport.mouse.deltaX, viewport.mouse.deltaY);
// 	      }
// 	    }
//     }
// }

// function navScroll(viewport){
//     if(!viewport.keydown){
// 	    viewport.mouseScroll(viewport.mouse.scrollX*0.6, viewport.mouse.scrollY*0.6);
// 	} else if(viewport.keydown.key == "Shift"){
// 	    viewport.mouseScrollShift(viewport.mouse.scrollX*0.6, viewport.mouse.scrollY*0.6);
// 	} else if(viewport.keydown.key == "Meta"){
// 		viewport.mouseScrollMeta(viewport.mouse.scrollX*0.025, -viewport.mouse.scrollY*0.025);
// 	}
// }

// function bind_navigation(viewport){
    
//     // Add viewport variables
//     viewport.navigable = true;
//     viewport.damper    = {};

//     // Bind mouse events
//     viewport.addEventListener("mousemove", function(){ 
//     	navMouseMove(this); 
//     });
//     viewport.addEventListener("touchmove", function(){
//     	if(this.touch.num == 1){
//     	    navMouseMove(this); 
//     	} else {
//             navScroll(this);
//     	}
//     });
//     viewport.addEventListener("wheel", function(){
//     	navScroll(this);
//     });

    
//     viewport.rotateScene = function(rotX, rotY){
// 		var viewport = this;
// 		rotatePlotHolder(viewport, rotX*3, rotY*3);
// 		this.damper.rotX = rotX;
// 		this.damper.rotY = rotY;
// 		if(this.damper.timeout){ window.clearTimeout(this.damper.timeout) }
// 		this.damper.timeout = window.setTimeout(function(){rotationInertia(viewport)}, 20);
//     }

//     viewport.rockScene = function(rotY, rotZ){
//         var plotHolder = this.plotHolder;
// 		this.scene.rotateSceneOnAxis(new THREE.Vector3(0,0,1), rotZ*0.2);
// 		//rotateClippingPlanes(viewport, new THREE.Vector3(0,0,1), rotZ*0.2);
// 		//update_labels(this);
// 		this.scene.showhideDynamics(viewport.camera);
// 	    this.sceneChange = true;
// 	    this.infoDiv.update();
//     }

//     viewport.panScene = function(panX, panY){
//     	var plotHolder = this.scene.plotHolder;
// 		var plotPoints = this.plotPoints;

// 		var position = new THREE.Vector3(0, 0, 0);
// 	    position.applyMatrix4(plotHolder.matrixWorld).project(this.camera);
// 	    position.x += panX;
// 	    position.y += panY;
// 	    var inverse_mat = new THREE.Matrix4();
// 	    inverse_mat.getInverse(plotHolder.matrixWorld);
// 	    position.unproject(this.camera).applyMatrix4(inverse_mat);

// 		this.scene.panScene(position.toArray());
//         this.scene.showhideDynamics(viewport.camera);
//         this.sceneChange = true;
//         this.infoDiv.update();
		
//     } 

//     viewport.zoomScene = function(deltaX, deltaY){
//         this.camera.rezoom(deltaY);
//     	this.sceneChange = true;
//     	this.infoDiv.update();
//     };

//     viewport.mouseMove        = viewport.rotateScene;
//     viewport.mouseMoveMeta    = viewport.panScene;
//     viewport.mouseScroll      = viewport.zoomScene;
//     viewport.mouseScrollShift = viewport.rockScene;
//     viewport.mouseScrollMeta  = viewport.rotateScene;

//     // Create a little div to track rotation settings
//     viewport.transform = document.createElement("div");
//     viewport.transform.classList.add("transform-div");
//     viewport.transform.style.display = "none";
//     viewport.appendChild(viewport.transform);
//     viewport.transform.update = function(viewport){
//         var rotation = [
//           180*(viewport.plotHolder.rotation.x/Math.PI),
//           180*(viewport.plotHolder.rotation.y/Math.PI),
//           180*(viewport.plotHolder.rotation.z/Math.PI)
//         ];
//         this.innerHTML = rotation[0].toFixed(2)+", "+rotation[1].toFixed(2)+", "+rotation[2].toFixed(2);
//     }
    

// }

