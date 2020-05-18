
// Add holder for events
Racmacs.App.prototype.onselect          = [];
Racmacs.App.prototype.ondeselect        = [];
Racmacs.Point.prototype.onselect        = [];
Racmacs.Point.prototype.ondeselect      = [];
Racmacs.Point.prototype.onhover         = [];
Racmacs.Point.prototype.ondehover       = [];
Racmacs.Point.prototype.onupdatedisplay = [];

Racmacs.App.prototype.onselect.push(
    function(viewer){

        viewer.graphics.ptStyles = viewer.graphics.plusSelected;
        viewer.updatePointStyles();

    }
);

Racmacs.App.prototype.ondeselect.push(
    function(viewer){
        
        // Set graphics mode
        viewer.graphics.ptStyles = viewer.graphics.noneSelected;
        viewer.updatePointStyles();

    }
);

// Set selection styles
Racmacs.App.prototype.graphics = {

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

Racmacs.App.prototype.graphics.ptStyles = Racmacs.App.prototype.graphics.noneSelected;

// Change background click event listener
Racmacs.App.prototype.clickBackground = function(){

    if(document.keydown.key !== "Shift"
       && document.keydown.key !== "Meta"
       && !this.dragMode
       && !this.viewport.mouse.moved){
        this.deselectAll();
    }

};

Racmacs.Point.prototype.click = function(e){

    if(!this.viewer.dragMode){
        if(!this.viewer.viewport.mouse || 
            !this.viewer.viewport.mouse.moved){
            this.select();
        }
        if(!e.shiftKey && !e.metaKey){
            this.viewer.deselectAll(this);
        }
    }

}


// Set prototypes
Racmacs.Point.prototype.hover = function(){
    
    if(this.shown){

        this.hovered = true;
        
        // Show a fill for transparent objects
        if(this.fillColor == "transparent"){
            if(this.element){
                this.element.setFillColor(this.outlineColor);
                this.element.setFillOpacity(0.3);
            }
        }

        this.updateDisplay();

        // Show the point info
        this.moveToTop();
        this.showInfo();

        // Run additional hover functions
        this.onhover.map( f => f(this) );

    }

}

Racmacs.Point.prototype.dehover = function(){
    
    this.hovered = false;

    // Hide the fill for transparent objects
    if(this.fillColor == "transparent"){
        if(this.element){
            this.element.setFillColor("#ffffff");
            this.element.setFillOpacity(0);
        }
    }

    this.updateDisplay();

    // Show the point info
    this.moveFromTop();
    this.hideInfo();

    // Run additional dehover functions
    this.ondehover.map( f => f(this) );


}


// Change background click event listener
Racmacs.App.prototype.deselectAll = function(except = null){

    let points_to_remove = this.selected_pts.slice();
    if(except !== null){
        let index = points_to_remove.indexOf(except);
        if(index !== -1) points_to_remove.splice(index, 1)
    }
    points_to_remove.map( p => p.deselect() );

}

// Add function to update styles of all points
Racmacs.App.prototype.updatePointStyles = function(){
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

        // Update point style
        this.updateDisplay();

        // Add to list of selected objects
        viewer.selected_pts.push(this);

        // Run events relating to points being selected
        if(viewer.selected_pts.length == 1){
            this.viewer.onselect.map( f => f(this.viewer) );
        }

        // Run select functions
        this.onselect.map( f => f(this) );

    }

}

Racmacs.Point.prototype.deselect = function(){

    if(this.selected){

        var viewer = this.viewer;

        // Toggle deselection
        this.selected = false;

        // Update the point style
        this.updateDisplay();

        // Remove from list of selected objects
        var index = viewer.selected_pts.indexOf(this);
        if (index > -1) {
          viewer.selected_pts.splice(index, 1);
        }

        // Run deselect functions
        this.ondeselect.map( f => f(this) );

        // Run events relating to points being deselected
        if(viewer.selected_pts.length == 0){    
            this.viewer.ondeselect.map( f => f(this.viewer) );
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

      // Run any additional on update display events
      this.onupdatedisplay.map( f => f(this) );

      this.viewer.sceneChange = true;
  
};










