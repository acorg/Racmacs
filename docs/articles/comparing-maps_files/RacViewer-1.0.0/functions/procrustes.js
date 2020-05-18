
Racmacs.ProcrustesPanel = class ProcrustesPanel {

    constructor(viewer){

        // Create holder div
        this.div = document.createElement("div");
        this.div.classList.add("procrustes-tab");

        var procrustesTable = new Racmacs.ProcrustesTable(viewer);
        this.div.appendChild(procrustesTable.div);
        
        var newProcrustesWell = new Racmacs.utils.InputWell({
            inputs: [
                { id: "optimization", value: 1, label : "Optimization number" },
            ],
            submit: "Calculate procrustes to file",
            fn : function(args){ viewer.onProcrustes(args) }
        });
        this.div.appendChild(newProcrustesWell.div);
        newProcrustesWell.div.classList.add("shiny-element");

    }


}


Racmacs.ProcrustesTable = class ProcrustesTable extends Racmacs.TableList {

    constructor(viewer){

        // Generate skeleton
        super({
            title   : "Procrustes",
            checkbox_check_fn : function(){},
            checkbox_uncheck_fn : function(){
                viewer.removeProcrustes();
            },
            headers : ["Map", "Projection", "Antigens", "Sera"]
        });

        // Bind to viewer
        viewer.procrustesTable = this;
        this.viewer = viewer;

        // Add additional divs
        this.details_panel = this.addDiv("details-panel"); 
        this.details_panel.classList.add("shiny-element");
        
        this.description = document.createElement("div");
        this.description.classList.add("description");
        this.details_panel.appendChild(this.description);

        this.scaling = document.createElement("div");
        this.scaling.classList.add("scaling");
        this.details_panel.appendChild(this.scaling);

        this.translation = document.createElement("div");
        this.translation.classList.add("translation");
        this.details_panel.appendChild(this.translation);

        this.agrmsd = document.createElement("div");
        this.agrmsd.classList.add("agrmsd");
        this.details_panel.appendChild(this.agrmsd);

        this.srrmsd = document.createElement("div");
        this.srrmsd.classList.add("srrmsd");
        this.details_panel.appendChild(this.srrmsd);

        this.rmsd = document.createElement("div");
        this.rmsd.classList.add("rmsd");
        this.details_panel.appendChild(this.rmsd);
        
    }

    addData(data){

        var procrustesTable = this;
        this.addRow({
            content : [data.target_map, data.target_optimization_number, data.antigens, data.sera],
            fn : function(){
                procrustesTable.viewer.showProcrustes(data);
            }
        });

    }

}

Racmacs.Viewer.prototype.addProcrustesData = function(data){

    if(this.procrustesTable){
        for(var i=0; i<data.length; i++){
            this.procrustesTable.addData(data[i]);
        }
    }

}


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
    var pc_data = [].concat(data.ag, data.sr);

    // Check data
    if(this.points.length !== pc_data.length){
        throw("Number of points does not match procrustes data");
    }

    // Convert plot to 3d if procrustes is to 3 dimensions
    if(this.scene.plotdims.dimensions == 2 && pc_data[0].length == 3){
        this.resetDims(3);
    };

    // Set arrow coordinates
    var arrow_coords = [];
    for(var i=0; i<this.points.length; i++){

        // Do not show procrustes arrows for na coordinates
        if(!this.points[i].coords_na){
        
            // Set coords
            var pc_coords = pc_data[i];
            var pt_coords = this.points[i].coords;

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
                while(pc_coords.length < 3) pc_coords.push(0);

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

    // Add the arrows to the scene
    this.procrustes = new this.mapElements.procrustes({
        coords : arrow_coords,
        size   : 4,
        properties : { lwd : 2 },
        viewer : this
    });

    this.scene.add(this.procrustes.object);

}







