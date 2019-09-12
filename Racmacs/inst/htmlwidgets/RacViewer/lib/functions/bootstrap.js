

Racmacs.BootstrapPanel = class ProcrustesPanel {

    constructor(viewer){

        // Create holder div
        this.div = document.createElement("div");
        this.div.classList.add("bootstrap-tab");

        this.checkbox = new Racmacs.utils.Checkbox({
            check_fn   : function(){ viewer.bootstrapOn()  },
            uncheck_fn : function(){ viewer.bootstrapOff() },
            text : "Show bootstrap on selection"
        });

        this.div.appendChild(this.checkbox.div);

        // var procrustesTable = new Racmacs.ProcrustesTable(viewer);
        // this.div.appendChild(procrustesTable.div);
        
        // var newProcrustesWell = new Racmacs.utils.InputWell({
        //     inputs: [
        //         { id: "optimization", value: 1, label : "Optimization number" },
        //     ],
        //     submit: "Calculate procrustes to file",
        //     fn : function(args){ viewer.onProcrustes(args) }
        // });
        // this.div.appendChild(newProcrustesWell.div);
        // newProcrustesWell.div.classList.add("shiny-element");

    }


}

Racmacs.Viewer.prototype.bootstrapOn = function(){

	this.bootstrap_shown = true;

}

Racmacs.Viewer.prototype.bootstrapOff = function(){

    this.bootstrap_shown = false;
	
}

Racmacs.Point.prototype.showBootstrap = function(){

    var bootstrapdata = this.viewer.data.bootstrap();
    var bootstrap_coords = bootstrapdata.data.map( x => x[this.type+"_coords"][this.typeIndex] );

    if(bootstrap_coords[0].length < 3){
	    for(var i=0; i<bootstrap_coords.length; i++){
	    	bootstrap_coords[i].push(0);
	    }
	}
    
    var bootstrap_coords_vector = [].concat(...bootstrap_coords);

    var colors = Array(bootstrap_coords.length*3).fill(0);

    if(this.type == "ag"){
	    for(var i=0; i<bootstrap_coords.length; i++){
	    	
	    	var ag_error = bootstrapdata.data[i].error.antigen_error[this.typeIndex];

	    	var red  = ag_error / 3;
			var blue = -ag_error / 3;
	    	
	    	if(red  > 1){ red  = 1 }
	    	if(blue > 1){ blue = 1 }
	    	if(red  < 0){ red  = 0 }
	    	if(blue < 0){ blue = 0 }

	    	colors[i*3]   = Math.pow(red, 0.35);
	    	colors[i*3+2] = Math.pow(blue, 0.35);

	    }
	}

    var geometry = new THREE.BufferGeometry();
    geometry.addAttribute( 'position', new THREE.Float32BufferAttribute( bootstrap_coords_vector, 3 ) );
    geometry.addAttribute( 'color', new THREE.Float32BufferAttribute( colors, 3 ) );

    var material = new THREE.PointsMaterial({ size: 2, vertexColors: THREE.VertexColors });
    var points = new THREE.Points( geometry, material );

    this.bootstrap_points = points;
    this.viewer.scene.add(points);

}

Racmacs.Point.prototype.hideBootstrap = function(){

	this.viewer.scene.remove(this.bootstrap_points);
	
}


// Racmacs.BootstrapTable = class ProcrustesTable extends Racmacs.TableList {

//     constructor(viewer){

//         // Generate skeleton
//         super({
//             title   : "Procrustes",
//             checkbox_check_fn : function(){},
//             checkbox_uncheck_fn : function(){
//                 viewer.removeProcrustes();
//             },
//             headers : ["Map", "Projection", "Antigens", "Sera"]
//         });

//         // Bind to viewer
//         viewer.procrustesTable = this;
//         this.viewer = viewer;

//         // Add additional divs
//         this.details_panel = this.addDiv("details-panel"); 
//         this.details_panel.classList.add("shiny-element");
        
//         this.description = document.createElement("div");
//         this.description.classList.add("description");
//         this.details_panel.appendChild(this.description);

//         this.scaling = document.createElement("div");
//         this.scaling.classList.add("scaling");
//         this.details_panel.appendChild(this.scaling);

//         this.translation = document.createElement("div");
//         this.translation.classList.add("translation");
//         this.details_panel.appendChild(this.translation);

//         this.agrmsd = document.createElement("div");
//         this.agrmsd.classList.add("agrmsd");
//         this.details_panel.appendChild(this.agrmsd);

//         this.srrmsd = document.createElement("div");
//         this.srrmsd.classList.add("srrmsd");
//         this.details_panel.appendChild(this.srrmsd);

//         this.rmsd = document.createElement("div");
//         this.rmsd.classList.add("rmsd");
//         this.details_panel.appendChild(this.rmsd);
        
//     }

//     addData(data){

//         var procrustesTable = this;
//         this.addRow({
//             content : [data.target_map, data.target_optimization_number, data.antigens, data.sera],
//             fn : function(){
//                 procrustesTable.viewer.showProcrustes(data);
//             }
//         });

//     }

// }

// Racmacs.Viewer.prototype.addProcrustesData = function(data){

//     if(this.procrustesTable){
//         for(var i=0; i<data.length; i++){
//             this.procrustesTable.addData(data[i]);
//         }
//     }

// }


// Racmacs.Viewer.prototype.showProcrustes = function(data){

//     // Remove any current procrustes
//     this.removeProcrustes();

//     // Update the procrustes table if present
//     if(this.procrustesTable){
        
//         this.procrustesTable.checkbox.check(false);
//         this.procrustesTable.checkbox.enable();

//         this.procrustesTable.description.innerHTML = data.description;
//         this.procrustesTable.scaling.innerHTML     = data.scaling;
//         this.procrustesTable.translation.innerHTML = data.translation;

//         if(data.data.ag_rmsd == "NaN"){
//             this.procrustesTable.agrmsd.innerHTML = "NA";
//         } else {
//             this.procrustesTable.agrmsd.innerHTML = data.data.ag_rmsd[0].toFixed(2);
//         }
//         if(data.data.sr_rmsd == "NaN"){
//             this.procrustesTable.srrmsd.innerHTML = "NA";
//         } else {
//             this.procrustesTable.srrmsd.innerHTML = data.data.sr_rmsd[0].toFixed(2);
//         }
//         this.procrustesTable.rmsd.innerHTML   = data.data.total_rmsd[0].toFixed(2);

//         this.procrustesTable.details_panel.style.display = null;

//     }
    
//     // Create the procrustes data
//     var ag_pc_coords = data.data.pc_coords.ag;
//     var sr_pc_coords = data.data.pc_coords.sr;
//     var ag_dists     = data.data.ag_dists;
//     var sr_dists     = data.data.sr_dists;

//     // Check data
//     if(this.antigens.length !== ag_pc_coords.length
//         || this.sera.length !== sr_pc_coords.length){
//         throw("Number of points does not match procrustes data");
//     }

//     // Set arrow coordinates
//     var arrow_coords = [];
//     for(var i=0; i<this.antigens.length; i++){
//         if(ag_pc_coords[i][0] !== "NA" 
//             && ag_pc_coords[i][1] !== "NA"){

//             if(ag_dists[i] > 0.01){
//                 arrow_coords.push([
//                     this.antigens[i].coords,
//                     ag_pc_coords[i]
//                 ]);
//             }

//         } else {

//             this.antigens[i].setOpacity(0.2);
//             this.antigens[i].transparency_fixed = true;

//         }
//     }

//     for(var i=0; i<this.sera.length; i++){
//         if(sr_pc_coords[i][0] !== "NA" 
//             && sr_pc_coords[i][1] !== "NA"){

//             if(sr_dists[i] > 0.01){
//                 arrow_coords.push([
//                     this.sera[i].coords,
//                     sr_pc_coords[i]
//                 ]);
//             }

//         } else {

//             this.sera[i].setOpacity(0.2);
//             this.sera[i].transparency_fixed = true;

//         }
//     }

//     // Make sure everything is 3D
//     arrow_coords = arrow_coords.map( function(x){ 
//         if(x[0].length === 2) x[0].push(0); 
//         if(x[1].length === 2) x[1].push(0); 
//         return(x)
//     });

//     // Add the arrows to the scene
//     this.procrustes = new this.mapElements.procrustes({
//         coords : arrow_coords,
//         viewer : this
//     });

//     this.scene.add(this.procrustes.object);

// }

// Racmacs.Viewer.prototype.removeProcrustes = function(){

//     if(this.procrustesTable){
//         this.procrustesTable.checkbox.uncheck(false);
//         this.procrustesTable.checkbox.disable();
//         this.procrustesTable.deselectAll();
//         this.procrustesTable.details_panel.style.display = "none";
//     }

//     if(this.procrustes){
//         this.scene.remove(this.procrustes.object);
//     }

//     this.points.map(function(p){ 
//         p.transparency_fixed = false;
//         p.updateDisplay()
//     });

// }










