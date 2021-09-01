
Racmacs.Viewer.prototype.colorPointsByDefault = function(){

    // Fire event
    this.dispatchEvent("point-coloring-changed", { coloring : "default" });

    var points = this.points;
    for(var i=0; i<points.length; i++){

        if(points[i].type == "ag"){
            
            points[i].setFillColor(this.data.agFill(points[i].typeIndex));
            points[i].setOutlineColor(this.data.agOutline(points[i].typeIndex));

        } else {

            points[i].setFillColor(this.data.srFill(points[i].typeIndex));
            points[i].setOutlineColor(this.data.srOutline(points[i].typeIndex));

        }

        points[i].updateDisplay();

    }

    // Update any browsers
    if(this.browsers){
      if(this.browsers.antigens){
        this.browsers.antigens.order("default");
      }
      if(this.browsers.sera){
        this.browsers.sera.order("default");
      }
    }

    // Note that the viewport is colored by default
    this.coloring = "default";
    
    // Render the viewport
    this.render();

}

Racmacs.Viewer.prototype.colorPointsByStress = function(){
    
    // Fire event
    this.dispatchEvent("point-coloring-changed", { coloring : "stress" });

    // Get maximum and minimum stress
    var max_stress;
    var min_stress;

    for(var obj=0; obj<2; obj++){
      
        if(obj == 0){ var points = this.antigens }
        if(obj == 1){ var points = this.sera     }

        for(var i=0; i<points.length; i++){
            var stress = points[i].calcMeanStress();
            if(stress > max_stress || i==0){ max_stress = stress }
            if(stress < min_stress || i==0){ min_stress = stress }
        }

        for(var i=0; i<points.length; i++){
            var stress = points[i].calcMeanStress();
            var rel_stress = (stress - min_stress) / (max_stress - min_stress);
            points[i].setOutlineColor("black");
            var color = new THREE.Color(rel_stress, 0, 1 - rel_stress);
            points[i].setFillColor("#" + color.getHexString());
        }


    }

    // Update any browsers
    if(this.browsers){
      if(this.browsers.antigens){
        this.browsers.antigens.order("stress");
      }
      if(this.browsers.sera){
        this.browsers.sera.order("stress");
      }
    }

    // Note that the viewport is colored by stress
    this.coloring = "stress";
    
    // Render the viewport
    this.render();

}

// Event for showing and hiding the legend
R3JS.Viewer.prototype.eventListeners.push({
    name : "point-coloring-changed",
    fn : function(e){
        let viewer = e.detail.viewer;
        if(viewer.sequenceLegend){
            if(e.detail.coloring == "sequence"){
                viewer.sequenceLegend.style.display = "";
            } else {
                viewer.sequenceLegend.style.display = "none";
            }
        }
    }
});

