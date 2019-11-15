

// function bind_api(container, viewport){
   
//     // Function for snapshot
//     viewport.getImgData = function(){
//         return(getImgData(this));
//     }
//     viewport.snapshot = function(filename){
//         saveImg(viewport, filename);
//     }

//     // Functions to rotate the scene
//     viewport.rotateSceneEuclidean = function(rotation){
//         viewport.scene.rotateSceneEuclidean(rotation);
//         viewport.scene.showhideDynamics( viewport.camera );
//         if(viewport.mouse.over){
//           viewport.raytrace();	
//         }
//         viewport.render();
//     }

//     viewport.zoom = function(zoom){
//     	viewport.camera.rezoom(zoom);
//     	if(viewport.mouse.over){
//           viewport.raytrace();	
//         }
//         viewport.render();
//     }

//     container.viewport = viewport;

// }

