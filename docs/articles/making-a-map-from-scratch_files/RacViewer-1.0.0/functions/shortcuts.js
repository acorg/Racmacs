
// function bind_shortcuts(viewport){

// 	// Set the exit all function
//     viewport.exit_all = function(){

//         this.deselect_all();
//         this.end_dragMode();
//         this.hide_connectionLines();
//         this.hide_errorLines();
//         this.removeBlobs();

//     }

//     // Add key event listeners
//     window.addEventListener('keypress', function(event){ 

//     	// End any rectangular selection
//     	viewport.end_rect_select(viewport);

//     	// If escape then deselect everything
//     	if(event.key == "Escape"){
//     		viewport.exit_all();
//     	}
        
//         // Select all points
//         if(event.key == "a" && event.metaKey){
//         	event.preventDefault();
//         	viewport.select_all();
//         }

//         // Deselect all points
//         if(event.key == "d" && event.metaKey){
//         	event.preventDefault();
//         	viewport.deselect_all();
//         }

//     });

// }

