

Racmacs.ProjectionsPanel = class ProjectionTab {

    constructor(viewer){
        
        // Create holder div
        this.div = document.createElement("div");
        this.div.classList.add("projections-tab");

        // Create buttons div
        this.buttons = document.createElement("div");
        this.buttons.classList.add("buttons-div");
        this.buttons.classList.add("shiny-element");
        this.div.appendChild(this.buttons);

        // Add the align projections button
        var alignProjectionsBtn = new Racmacs.utils.Button({
            label : "Align optimizations",
            fn : function(){ viewer.onOrientProjections() }
        });
        this.buttons.appendChild(alignProjectionsBtn.div);

        // Add the remove projections button
        var removeOptimizationsBtn = new Racmacs.utils.Button({
            label : "Remove optimizations",
            fn : function(){ viewer.onRemoveOptimizations() }
        });
        this.buttons.appendChild(removeOptimizationsBtn.div);

        // Create projections table
        var projectionTable = new Racmacs.ProjectionTable(viewer);
        this.div.appendChild(projectionTable.div);

        // Add a make projections panel
        this.optimcontrols = document.createElement("div");
        this.optimcontrols.classList.add("optim-controls");
        this.div.appendChild(this.optimcontrols);
        this.optimcontrols.classList.add("shiny-element");

        var newProjectionWell = new Racmacs.utils.InputWell({
            inputs: [
                { id: "numruns",     value: 100,    label : "Number of optimizations" },
                { id: "mincolbasis", value: "none", label : "Minimum column basis" },
                { id: "numdims",     value: 2,      label : "Number of dimensions" }
            ],
            submit: "Run optimizations",
            fn : function(args){ viewer.onRunOptimizations(args) }
        });
        this.optimcontrols.appendChild(newProjectionWell.div);

    }


}


Racmacs.ProjectionTable = class ProjectionTable extends Racmacs.TableList {

    constructor(viewer){

        // Make the table
        super({
            headers : ["Stress", "Min col basis", "Dimensions"]
        });

        // Bind to viewer
        this.viewer = viewer;
        viewer.projectionList = this;

    }

    populate(){

        // Get variables
        var viewer = this.viewer;
        var data   = this.viewer.data;
        var numprojections = data.numProjections();

        // Clear current content
        this.clear();
        
        // Populate list
        for(var i=0; i<numprojections; i++) {

          // Make the row
          var row = this.addRow({
            content : [
                data.stress(i).toFixed(2),
                data.minColBasis(i),
                data.dimensions(i)
            ],
            fn : function(){
                viewer.switchToProjection(this.num);
            }
          });
          
        }

    }

    selectProjection(num){

        // Add selected marker to new row
        this.selectRow(num, false);

    }

}


Racmacs.Viewer.prototype.switchToProjection = function(num){

    // Fire the onprojectionswitch event
    this.onProjectionChange(num);

    // Check num
    if(num > this.data.numProjections()){
        throw("Map has only "+this.data.numProjections()+" optimizations");
    }

    // Get last number of dimensions
    var lastdim = this.data.dimensions();

    // Update the projection num
    this.data.setProjection(num);

    // Move antigen point coordinates
    for(var i=0; i<this.antigens.length; i++){
        var coords = this.data.agCoords(i);
        if(coords.length == 2){ coords.push(0) }
        this.antigens[i].setPosition(coords[0], coords[1], coords[2])
    }

    // Move sera point coordinates
    for(var i=0; i<this.sera.length; i++){
        var coords = this.data.srCoords(i);
        if(coords.length == 2){ coords.push(0) }
        this.sera[i].setPosition(coords[0], coords[1], coords[2])
    }

    // Change dimensions if necessary
    var newdim = this.data.dimensions();
    if(lastdim !== newdim){

        // Get current zoom, rotation and panning
        var zoom        = this.camera.getZoom();
        var rotation    = this.scene.getRotation();
        var translation = this.scene.getTranslation();

        // Empty the scene
        this.scene.empty();

        // Set the viewer dimensions
        this.setDims();

        // Reset the grid
        this.setGrid();

        // Add in new elements
        this.addAgSrPoints();

        // Match zoom, rotation and panning
        this.camera.initiateInViewer(this);
        this.camera.setZoom(zoom);
        this.scene.setRotation([0, 0, rotation[2]]);
        this.scene.setTranslation([translation[0], translation[1], null]);

        // Fire any resize event listeners (necessary for setting pixel ratio)
        this.viewport.onwindowresize();


    }

    // Select any runs on the projections list
    if(this.projectionList){
        this.projectionList.selectProjection(num);
    }

    // Update diagnostic data
    // Remove blobs
    this.removeBlobs();
    if(this.blobTable){ this.blobTable.clear() }

    // Remove hemisphering data
    this.removeHemispheringData();

    // Remove procrustes
    this.removeProcrustes();
    if(this.procrustesTable){ this.procrustesTable.clear() }

    // Add new diagnostic info
    var stress_blobs = this.data.stressBlobs();
    if(stress_blobs !== null){
        for(var i=0; i<stress_blobs.length; i++){
            this.addBlobs(stress_blobs[i]);
        }
    }

    var hemisphering = this.data.hemisphering();
    if(hemisphering !== null){
        this.hemispheringTable.hidePlaceholder();
        this.addHemispheringData(hemisphering);
    }

    // // Add procrustes info
    // var procrustes = this.data.procrustes();
    // if(procrustes !== null){

    //     this.addProcrustesData(procrustes);

    // }


    // Render viewer
    this.render();

    // Update stress
    this.updateStress();

}


