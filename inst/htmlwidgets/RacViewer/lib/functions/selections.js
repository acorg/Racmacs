
// Set selection styles
Racmacs.Viewer.prototype.graphics = {

  noneSelected : {
    selected         : {
        opacity : 1.0,
        outlineColor : "#ff0066"
    },
    selected_hover   : {
        opacity : 0.8
    },
    deselected       : {
        // opacity : 0.6
        opacity : 0.8
    },
    deselected_hover : {
        opacity : 1.0
    }
  },

  plusSelected : {
    selected         : {
        opacity : 1.0,
        outlineColor : "#ff0066"
    },
    selected_hover   : {
        opacity : 0.8
    },
    deselected       : {
        opacity : 0.2
    },
    deselected_hover : {
        opacity : 0.6
    }
  }

};

Racmacs.Viewer.prototype.graphics.ptStyles = Racmacs.Viewer.prototype.graphics.noneSelected;

// Change background click event listener
Racmacs.Viewer.prototype.clickBackground = function(){

    if(document.keydown.key !== "Shift"
       && document.keydown.key !== "Meta"
       && !this.dragMode
       && !this.viewport.mouse.moved){
        this.deselectAll();
    }

};

Racmacs.Point.prototype.click = function(){

    if(!this.viewer.dragMode){
        if(document.keydown.key !== "Shift"
           && document.keydown.key !== "Meta"){
            this.viewer.deselectAll();
        }
        if(!this.viewer.viewport.mouse.moved){
            this.select();
        }
    }

}


// Set prototypes
Racmacs.Point.prototype.hover = function(){
    
    if(this.shown){

        this.hovered = true;
        
        // Show a fill for transparent objects
        if(this.fillColor == "transparent"){
            this.element.setFillColor(this.outlineColor);
            this.element.setFillOpacity(0.3);
        }

        this.updateDisplay();

        // Show the point info
        this.showInfo();

        this.moveToTop();

    }

}

Racmacs.Point.prototype.dehover = function(){
    
    this.hovered = false;

    // Hide the fill for transparent objects
    if(this.fillColor == "transparent"){
        this.element.setFillColor("#ffffff");
        this.element.setFillOpacity(0);
    }

    this.updateDisplay();

    // Show the point info
    this.hideInfo();

    this.moveFromTop();

}


// Change background click event listener
Racmacs.Viewer.prototype.deselectAll = function(){

    while(this.selected_pts.length > 0){
        this.selected_pts[0].deselect();
    }

}

// Add function to update styles of all points
Racmacs.Viewer.prototype.updatePointStyles = function(){
    if(this.points){
        for(var i=0; i<this.points.length; i++){
            this.points[i].updateDisplay();
        }
    }
}    



Racmacs.Point.prototype.toggleSelection = function(){
    if(this.selected){
        this.deselect();
    } else {
        this.select();
    }
}

Racmacs.Point.prototype.select = function(){

    if(this.shown && !this.selected){

        var viewer = this.viewer;
        
        // Toggle selection
        this.selected = true;

        // Add to list of selected objects
        viewer.selected_pts.push(this);
        
        // Set graphics mode
        viewer.graphics.ptStyles = viewer.graphics.plusSelected;

        // Enable drag mode
        if(viewer.btns.toggleDragMode){ viewer.btns.toggleDragMode.enable() }

        // Show point connections
        if(viewer.connectionLinesShown){ this.showConnections(); }
        if(viewer.errorLinesShown)     { this.showErrors();      }

        // Update point style
        this.updateDisplay();

        if(viewer.selected_pts.length == 1){

            // Show error lines
            if(viewer.errorLinesShown){
                viewer.hideErrorLines();
                viewer.showErrorLines();
            }

            // Show connection lines
            if(viewer.connectionLinesShown){
                viewer.hideConnectionLines();
                viewer.showConnectionLines();
            }

            // Mark all points
            viewer.updatePointStyles();

            // Hide all other blobs
            viewer.points.map( point => point.hideBlob() );

        }        

        // Show this blob
        this.showBlob();

        // Show bootstrap
        this.showBootstrapPoints();
        this.showBootstrapContours();

        // Mark browser record
        if(this.browserRecord){
            this.browserRecord.select();
        }

    }

}

Racmacs.Point.prototype.deselect = function(){

    if(this.selected){

        var viewer = this.viewer;

        // Toggle deselection
        this.selected = false;

        // Remove from list of selected objects
        var index = viewer.selected_pts.indexOf(this);
        if (index > -1) {
          viewer.selected_pts.splice(index, 1);
        }

        // If not points now selected
        if(viewer.selected_pts.length == 0){
            
            // Set graphics mode
            viewer.graphics.ptStyles = viewer.graphics.noneSelected;

            // Disable drag buttons
            if(viewer.btns.toggleDragMode){ viewer.btns.toggleDragMode.disable() }

        }

        // Hide point connections
        if(viewer.connectionLinesShown){ this.hideConnections(); }
        if(viewer.errorLinesShown)     { this.hideErrors();      }

        // Mark all points if graphics mode has changed
        if(viewer.selected_pts.length == 0){
            if(viewer.connectionLinesShown){ 
                viewer.hideConnectionLines();
                viewer.showConnectionLines();
            }
            if(viewer.errorLinesShown)     { 
                viewer.hideErrorLines();
                viewer.showErrorLines();
            }

            // Show all blobs
            viewer.points.map( point => point.showBlob() );

            viewer.updatePointStyles();
        }

        // Hide bootstrap
        this.hideBootstrapPoints();
        this.hideBootstrapContours();

        // Mark browser record
        if(this.browserRecord){
            this.browserRecord.deselect();
        }

    }

}

Racmacs.Point.prototype.highlight = function(){

    this.highlighted++;
    this.updateDisplay();

}
Racmacs.Point.prototype.dehighlight = function(){
    
    if(this.highlighted > 0){
        this.highlighted--;
        this.updateDisplay();
    }

}

Racmacs.Point.prototype.updateDisplay = function(){
  
      var selectionMat = this.viewer.graphics.ptStyles;

      if(this.coords_na){
        this.hide();
      }

      if(this.selected || this.hovered){
        this.setOutlineColorTemp(selectionMat.selected.outlineColor);
      } else {
        this.restoreOutlineColor();
      }
      
      if(this.selected || this.highlighted > 0){
        
        if(this.hovered){
            this.setOpacity(selectionMat.selected_hover.opacity);
        } else {
            this.setOpacity(selectionMat.selected.opacity);
        }

      } else {
        
        if(this.hovered){
            this.setOpacity(selectionMat.deselected_hover.opacity);
        } else {
            this.setOpacity(selectionMat.deselected.opacity);
        }

      }

      this.viewer.sceneChange = true;
  
};












// function extend_highlight_fns(viewport){


//     // Set your selection materials
//     viewport.graphics = {

//       noneSelected : {
//         selected         : {
//             opacity : 1.0
//         },
//         selected_hover   : {
//             opacity : 0.8
//         },
//         deselected       : {
//             //opacity : 0.6
//             opacity : 0.9
//         },
//         deselected_hover : {
//             opacity : 1.0
//         }
//       },

//       plusSelected : {
//         selected         : {
//             opacity : 1.0,
//             outlineColor : "#ff0066"
//         },
//         selected_hover   : {
//             opacity : 0.8
//         },
//         deselected       : {
//             opacity : 0.2
//         },
//         deselected_hover : {
//             opacity : 0.6
//         }
//       }

//     };
//     viewport.graphics.ptStyles = viewport.graphics.noneSelected;



//     // Set prototypes
//     viewport.Point.prototype.hover = function(){
        
//         this.hovered = true;
        
//         // Show a fill for transparent objects
//         if(this.fillColor == "transparent"){
//             this.setPointGeoFill2NonTransparent();
//             this.setPointGeoFillColor(this.outlineColor);
//             this.setPointGeoFillOpacity(0.3);
//         }

//         this.updateDisplay();

//         // Show the point info
//         this.showInfo();

//     }

//     viewport.Point.prototype.dehover = function(){
        
//         this.hovered = false;

//         // Hide the fill for transparent objects
//         if(this.fillColor == "transparent"){
//             this.setPointGeoFill2NonTransparent();
//             this.setPointGeoFillColor("#ffffff");
//             this.setPointGeoFillOpacity(0);
//         }

//         this.updateDisplay();

//         // Show the point info
//         this.hideInfo();

//     }

//     viewport.Point.prototype.toggleSelection = function(){
//         if(this.selected){
//             this.deselect();
//         } else {
//             this.select();
//         }
//     }
    
//     viewport.Point.prototype.select = function(){

//         if(!this.selected){

//             // Toggle selection
//             this.selected = true;

//             // Add to list of selected objects
//             viewport.selected_pts.push(this.pIndex);
            
//             // Set graphics mode
//             viewport.graphics.ptStyles = viewport.graphics.plusSelected;

//             // Show point connections
//             if(viewport.connectionLines){ this.showConnections(); }
//             if(viewport.errorLines)     { this.showErrors();      }

//             if(viewport.selected_pts.length == 1){

//                 // Show error lines
//                 if(viewport.errorLines){
//                     viewport.hide_errorLines();
//                     viewport.show_errorLines();
//                 }

//                 // Show connection lines
//                 if(viewport.connectionLines){
//                     viewport.hide_connectionLines();
//                     viewport.show_connectionLines();
//                 }

//                 // Mark all points
//                 viewport.mark_points();

//             }

//             // Mark browser record
//             if(this.browserRecord){
//                 this.browserRecord.select();
//             }

//         }

//     }

//     viewport.Point.prototype.deselect = function(){

//         if(this.selected){

//             // Toggle deselection
//             this.selected = false;

//             // Remove from list of selected objects
//             var index = viewport.selected_pts.indexOf(this.pIndex);
//             if (index > -1) {
//               viewport.selected_pts.splice(index, 1);
//             }

//             // Set graphics mode
//             if(viewport.selected_pts.length == 0){
//                 viewport.graphics.ptStyles = viewport.graphics.noneSelected;
//             }

//             // Hide point connections
//             if(viewport.connectionLines){ this.hideConnections(); }
//             if(viewport.errorLines)     { this.hideErrors();      }

//             // Mark all points if graphics mode has changed
//             if(viewport.selected_pts.length == 0){
//                 if(viewport.connectionLines){ 
//                     viewport.hide_connectionLines();
//                     viewport.show_connectionLines();
//                 }
//                 if(viewport.errorLines)     { 
//                     viewport.hide_errorLines();
//                     viewport.show_errorLines();
//                 }
//                 viewport.mark_points();
//             }

//             // Mark browser record
//             if(this.browserRecord){
//                 this.browserRecord.deselect();
//             }

//         }

//     }
    
//     viewport.Point.prototype.highlight = function(){

//         this.highlighted++;
//         this.updateDisplay();

//     }
//     viewport.Point.prototype.dehighlight = function(){
        
//         if(this.highlighted > 0){
//             this.highlighted--;
//             this.updateDisplay();
//         }

//     }

//     viewport.Point.prototype.updateDisplay = function(){
      
//           var selectionMat = viewport.graphics.ptStyles;

//           if(this.selected){
//             this.setOutlineColorTemp(selectionMat.selected.outlineColor);
//           } else {
//             this.restoreOutlineColor();
//           }
          
//           if(this.selected || this.highlighted > 0){
            
//             if(this.hovered){
//                 this.setOpacity(selectionMat.selected_hover.opacity);
//             } else {
//                 this.setOpacity(selectionMat.selected.opacity);
//             }

//           } else {
            
//             if(this.hovered){
//                 this.setOpacity(selectionMat.deselected_hover.opacity);
//             } else {
//                 this.setOpacity(selectionMat.deselected.opacity);
//             }

//           }
      
//     };


//     viewport.mark_points = function(){
//         if(viewport.points){
//             for(var i=0; i<viewport.points.length; i++){
//                 viewport.points[i].updateDisplay();
//             }
//         }
//     }    


//     // Add selection event listeners
//     viewport.selected_pts = [];

//     viewport.addEventListener("mousedown", function(){
        
//         // Record the mouse down position
//         this.mouse.downPosition = {
//             x : this.mouse.x,
//             y : this.mouse.y
//         }

//     	if(viewport.intersected_points){
//     	    viewport.mouse.intersected = viewport.intersected_points[0];
//     	} else {
//     		viewport.mouse.intersected = null;
//     	}

//         this.mouse.moved = false;

//     });

//     viewport.addEventListener("mousemove", function(){
        
//         // Work out how far the mouse has moved
//         if(this.mouse.downPosition){
//             var mouseMoveDist = Math.sqrt(
//                 Math.pow(this.mouse.downPosition.x - this.mouse.x, 2) 
//                 + Math.pow(this.mouse.downPosition.y - this.mouse.y, 2)
//             );
            
//             // If moved greater than a certain distance then record as moved
//             if(mouseMoveDist > 0.01){
//                 this.mouse.moved = true;
//             }
//         }
        
//         // Remove intersections
//     	viewport.mouse.intersected = null;

//     });

//     viewport.addEventListener("mouseup", function(){

//         if(!this.mouse.moved
//             && !this.intersected_points){
//             this.deselectAll();
//         }

//         if(this.intersected_points 
//             && this.navigable 
//             && !this.mouse.moved){

//             // Deselect other points if shift key not pressed and an unselected
//             // point is selected
//             if(!this.mouse.event.shiftKey && !this.mouse.event.metaKey){

//                 this.deselectAll();

//             }
            
//             // Select the points
//             for(var i=0; i<this.intersected_points.length; i++){
                
//                 if(this.mouse.event.metaKey){
//                     this.points[this.intersected_points[i]].toggleSelection();
//                 } else {
//                     this.points[this.intersected_points[i]].select();
//                 }

//             }

//         }

//     });

    

//     // Selection functions
//     viewport.selectAg = function(num){ viewport.ags[num].select() }
//     viewport.selectSr = function(num){ viewport.sr[num].select()  }
    
//     viewport.deselectAg = function(num){ viewport.ags[num].deselect() }
//     viewport.deselectSr = function(num){ viewport.sr[num].deselect()  }

//     viewport.select_all = function(){

//         for(var i=0; i<this.points.length; i++){
//             viewport.points[i].select();
//         }
//         viewport.mark_points();

//     }

//     viewport.deselectAll = function(){

//         while(viewport.selected_pts.length > 0){
//         	viewport.points[viewport.selected_pts[0]].deselect();
//         }
//         viewport.mark_points();

//     }

//     viewport.getSelectedAgSr = function(){

//     	var selected_ags = [];
//         var selected_sr  = [];

//         for(var i=0; i<viewport.selected_pts.length; i++){
//         	if(viewport.selected_pts[i].type == "ag"){
//         		selected_ags.push(viewport.selected_pts[i].num);
//         	}
//         	if(viewport.selected_pts[i].type == "sr"){
//         	    selected_sr.push(viewport.selected_pts[i].num);
//             }
//         }

//     	return({
//             ags: selected_ags,
//             sr:  selected_sr
//     	});

//     }



//     // Rectangle selections ----------
//     // Add rectangular selection div
//     var selectRect = document.createElement( 'div' );
//     selectRect.style.display = "none";
//     selectRect.style.backgroundColor = "rgba(0,0,255,0.1)";
//     selectRect.style.border = "solid 1px rgba(0,0,255,0.2)";
//     selectRect.style.position = "absolute";
//     viewport.appendChild(selectRect);
//     viewport.selectRect = selectRect;

//     // Bind event listeners
//     viewport.addEventListener('mousedown', start_rect_select);
//     viewport.addEventListener('mouseup', function(){
//         this.make_rect_selection();
//     });

//     // Selection rectangle functions
// 	function start_rect_select(){
// 		if(this.keydown && this.keydown.key == "Shift"){
// 		  	this.addEventListener('mousemove', rect_select);
// 			this.downmouse = this.mouse.clone();
// 			this.selectRectMode = true;
// 		}
// 	}

// 	viewport.end_rect_select = function(viewport){
// 		viewport.selectRect.style.display = "none";
// 	    viewport.removeEventListener('mousemove', rect_select);
// 	    viewport.selectRectMode = false;
// 	    viewport.mark_points();
// 	}

// 	function rect_select(){
	    
// 		var mouse = this.mouse;
// 		var downmouse = this.downmouse;
// 		var viewport = this;
// 		mouse.down = true;
// 		var left_point   = Math.min(mouse.x, downmouse.x);
// 	    var right_point  = Math.max(mouse.x, downmouse.x);
// 	    var bottom_point = Math.min(mouse.y, downmouse.y);
// 	    var top_point    = Math.max(mouse.y, downmouse.y);
// 	    var selectRect = this.selectRect;
// 	    selectRect.style.top  = ((1-(top_point+1)/2)*viewport.clientHeight)+"px";
// 	    selectRect.style.left = (((left_point+1)/2)*viewport.clientWidth)+"px";
// 	    selectRect.style.width  = (((right_point - left_point)/2)*viewport.clientWidth)+"px";
// 	    selectRect.style.height = (((top_point - bottom_point)/2)*viewport.clientHeight)+"px";
// 	    selectRect.style.display = "";
		
// 	}


// }
















