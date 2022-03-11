

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
            },
            hoverfn : function(){
                // viewer.procrustesToProjection(this.num);
            }
          });
          
        }

    }

    selectProjection(num){

        // Add selected marker to new row
        this.selectRow(num, false);

    }

    updateStress(num, stress){

        if(this.rows[num]) {
            this.rows[num].childNodes[0].innerHTML = stress;
        }

    }

}


Racmacs.Viewer.prototype.switchToProjection = function(num){

    // Fire the onprojectionswitch event
    this.onProjectionChange(num);
    if(this.data.numProjections() == 0) return(null);

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
        while(coords.length < 3){ coords.push(0) }
        this.antigens[i].setPosition([coords[0], coords[1], coords[2]]);
    }

    // Move sera point coordinates
    for(var i=0; i<this.sera.length; i++){
        var coords = this.data.srCoords(i);
        while(coords.length < 3){ coords.push(0) }
        this.sera[i].setPosition([coords[0], coords[1], coords[2]]);
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

    // Remove diagnostics
    this.removeBlobs();
    this.hideHemisphering();
    this.removeProcrustes();

    // Render viewer
    this.render();

    // Update stress
    this.updateStress(this.data.stress());

}


Racmacs.Viewer.prototype.procrustesToProjection = function(num){

    this.addProcrustesToBaseCoords({
        pt_coords : this.data.transformedCoords(num)
    });

}




