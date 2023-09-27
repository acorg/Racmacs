
Racmacs.Viewer.prototype.showProcrustes = function(data){

    // Remove any current procrustes
    this.removeProcrustes();

    // Update the procrustes table if present
    if(this.procrustesTable){
        
        this.procrustesTable.checkbox.check(false);
        this.procrustesTable.checkbox.enable();

        this.procrustesTable.description.innerHTML = data.description;
        this.procrustesTable.scaling.innerHTML     = data.scaling;
        this.procrustesTable.translation.innerHTML = data.translation;

        if(data.data.ag_rmsd == "NaN"){
            this.procrustesTable.agrmsd.innerHTML = "NA";
        } else {
            this.procrustesTable.agrmsd.innerHTML = data.data.ag_rmsd.toFixed(2);
        }
        if(data.data.sr_rmsd == "NaN"){
            this.procrustesTable.srrmsd.innerHTML = "NA";
        } else {
            this.procrustesTable.srrmsd.innerHTML = data.data.sr_rmsd.toFixed(2);
        }
        this.procrustesTable.rmsd.innerHTML   = data.data.total_rmsd.toFixed(2);

        this.procrustesTable.details_panel.style.display = null;

    }
    
    // Create the procrustes data
    var ag_dists     = data.data.ag_dists;
    var sr_dists     = data.data.sr_dists;

    // if(this.data.transformation()){
    //     var t = this.data.transformation();
    //     for(var i=0; i<ag_pc_coords.length; i++){
    //         var coords = ag_pc_coords[i].slice();
    //         ag_pc_coords[i] = [
    //             coords[0]*t[0] + coords[1]*t[2],
    //             coords[0]*t[1] + coords[1]*t[3]
    //         ];
    //     }
        
    //     for(var i=0; i<sr_pc_coords.length; i++){
    //         var coords = sr_pc_coords[i].slice();
    //         sr_pc_coords[i] = [
    //             coords[0]*t[0] + coords[1]*t[2],
    //             coords[0]*t[1] + coords[1]*t[3]
    //         ];
    //     }
    // }

}

Racmacs.Viewer.prototype.removeProcrustes = function(){

    if(this.procrustesTable){
        this.procrustesTable.checkbox.uncheck(false);
        this.procrustesTable.checkbox.disable();
        this.procrustesTable.deselectAll();
        this.procrustesTable.details_panel.style.display = "none";
    }

    if(this.procrustes){
        this.scene.remove(this.procrustes.object);
    }

    this.points.map(function(p){ 
        p.transparency_fixed = false;
        p.updateDisplay()
    });

}


Racmacs.Viewer.prototype.addProcrustesToBaseCoords = function(data){

    // Remove any current procrustes data
    this.removeProcrustes();

    // Fetch the data
    if (data.pt_coords) {
        var pc_data = data.pt_coords;
    } else {
        var pc_data = [].concat(data.ag_coords, data.sr_coords);
    }

    // Check data
    if(this.points.length !== pc_data.length){
        throw("Number of points does not match procrustes data");
    }

    // Convert plot to 3d if procrustes is to 3 dimensions
    if(this.scene.plotdims.dimensions == 2 && data.dim == 3){
        this.resetDims(3);
    };

    // Set arrow coordinates
    var arrow_coords = [];
    for(var i=0; i<this.points.length; i++){

        // Do not show procrustes arrows for na coordinates
        if(!this.points[i].coords_na){
        
            // Set coords
            var pc_coords = pc_data[i];
            var pt_coords = this.points[i].coords3;

            // Plot the arrow
            if(pc_coords[0] !== "NA" && pc_coords[0] !== null){

                // Apply any map transformation
                pc_coords = Racmacs.utils.transformTranslateCoords(
                    pc_coords,
                    this.data.transformation(),
                    this.data.translation()
                );

                // Round pc coords to 8 decimal places
                pc_coords = pc_coords.map( p => Math.round(p*100000000)/100000000 );
                pt_coords = pt_coords.map( p => Math.round(p*100000000)/100000000 );

                // Set to 3D
                while(pc_coords.length < 3) pc_coords.push(0.01);

                // Get distances
                pc_vector = new THREE.Vector3().fromArray(pc_coords);
                pt_vector = new THREE.Vector3().fromArray(pt_coords);
                var pt_dist = pc_vector.distanceTo(pt_vector);
                
                arrow_coords.push([
                    pt_coords,
                    pc_coords
                ]);

            } else {

                this.points[i].setOpacity(0.2);
                this.points[i].transparency_fixed = true;

            }

        }

    }

    var arrowheadend;
    var arrowheadlength;
    var arrowlinewidth;

    if (this.data.dimensions() == 3) {
        arrowlinewidth = 0.1;
        arrowheadlength = 0.35;
    } else {
        arrowlinewidth = 1.5;
        arrowheadlength = 0.25;
    }

    if(this.data.dimensions() == 3 && data.dim == 2) {
        arrowheadend    = "circle";
        arrowheadlength = 0.15;
    } else {
        arrowheadend    = "arrow";
    }


    // Add the arrows to the scene
    this.procrustes = new this.mapElements.procrustes({
        coords : arrow_coords,
        size   : 2.5,
        properties : {
            lwd : arrowlinewidth, 
            arrowheadend : arrowheadend,
            arrowheadlength : arrowheadlength
        },
        viewer : this
    });

    this.scene.add(this.procrustes.object);

}







