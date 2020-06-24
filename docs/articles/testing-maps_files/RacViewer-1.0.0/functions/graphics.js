
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
            var rel_stress = (stress - min_stress)/(max_stress - min_stress);
            points[i].setOutlineColor("black");
            var color = new THREE.Color(rel_stress, 0, 1-rel_stress);
            points[i].setFillColor("#"+color.getHexString());
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

// Function to color by sequence
Racmacs.Viewer.prototype.colorPointsBySequence = function(pos){
   
    // Add sequence legend
    if(!this.sequenceLegend){
        this.sequenceLegend = document.createElement("div");
        this.sequenceLegend.innerHTML = "legend";
        this.sequenceLegend.classList.add("sequence-legend");
        this.viewport.div.appendChild(this.sequenceLegend);
    }

    // Fire event
    if(pos == 0) {
        this.colorPointsByDefault();
        this.sequenceLegend.style.display = "none";
        return(null);
    }

    // Get the sequence position
    var points = this.points;

    // Get the antigen sequences
    let aas = this.antigens.map((p, i) => this.data.agSequences(i)[pos-1]);
    let unique_aas = [];
    aas.map( aa => { if(unique_aas.indexOf(aa) === -1) unique_aas.push(aa) });

    let aa_cols = unique_aas.map((aa, i) => new THREE.Color().setHSL(
        i/(unique_aas.length + 1), 1, 0.5
    ));

    aas.map((aa, i) => { 
        var color =  aa_cols[unique_aas.indexOf(aa)];
        points[i].setFillColor("#"+color.getHexString());
    });

    this.sera.map( serum => {
        serum.setFillColor("transparent");
        serum.setOutlineColor("#000000");
    });

    // Populate legend
    this.sequenceLegend.innerHTML = "";

    var titlediv = document.createElement("div");
    titlediv.innerHTML = pos;
    titlediv.style.padding = "4px";
    this.sequenceLegend.appendChild(titlediv);
    
    var table = document.createElement("table");
    this.sequenceLegend.appendChild(table);

    unique_aas.map((aa, i) => {
        var color = aa_cols[unique_aas.indexOf(aa)];
        var row = document.createElement("tr");
        table.appendChild(row);
        var td = document.createElement("td");
        var coldiv = document.createElement("div");
        coldiv.style.width  = "14px";
        coldiv.style.height = "14px";
        coldiv.style.backgroundColor = "#"+color.getHexString();
        coldiv.style.border = "solid 1px #000000";
        td.appendChild(coldiv);
        row.appendChild(td);
        var td = document.createElement("td");
        td.innerHTML = aa;
        row.appendChild(td);
    });

    // Work out aa colors
    // var max_stress;
    // var min_stress;

    // for(var obj=0; obj<2; obj++){
      
    //     if(obj == 0){ var points = this.antigens }
    //     if(obj == 1){ var points = this.sera     }

    //     for(var i=0; i<points.length; i++){
    //         var stress = points[i].calcMeanStress();
    //         if(stress > max_stress || i==0){ max_stress = stress }
    //         if(stress < min_stress || i==0){ min_stress = stress }
    //     }

    //     for(var i=0; i<points.length; i++){
    //         var stress = points[i].calcMeanStress();
    //         var rel_stress = (stress - min_stress)/(max_stress - min_stress);
    //         points[i].setOutlineColor("black");
    //         var color = new THREE.Color(rel_stress, 0, 1-rel_stress);
    //         points[i].setFillColor("#"+color.getHexString());
    //     }


    // }

    // Update any browsers
    if(this.browsers){
      if(this.browsers.antigens){
        this.browsers.antigens.order("default");
      }
      if(this.browsers.sera){
        this.browsers.sera.order("default");
      }
    }

    // Note that the viewport is colored by stress
    this.coloring = "sequence";
    
    // Render the viewport
    this.render();

    // Dispatch events
    this.dispatchEvent("point-coloring-changed", { coloring : "sequence" });

}


