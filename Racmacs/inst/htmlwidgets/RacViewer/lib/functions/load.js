
Racmacs.Viewer.prototype.load = function(mapData, settings = {}){

    this.clearDiagnostics();

    // Show or hide control panels
    if(settings.hide_control_panel){
        this.controlpanel.hide();
    }

    // Set the map data
    this.data.load(mapData);

    // Set projection controls
    if(this.data.numProjections() > 0) {
        this.controlpanel.enableProjectionTabs();
        this.viewport.hidePlaceholder();
        this.animated = true;
    } else {
        this.controlpanel.disableProjectionTabs();
        this.viewport.showPlaceholder();
        this.animated = false;
    }

    // Get current viewpoint
    if(settings.maintain_viewpoint){
        var translation = this.scene.getTranslation();
        var zoom        = this.camera.getZoom();
        var selected_points = this.getSelectedPointIndices();
    }

    // Note that content is now loaded
    this.contentLoaded = true;

    // Empty the scene
    this.scene.empty();

    // Update viewer title
    this.setTitle(this.data.tableName());

    // Generate the antigen and sera objects
    this.addAntigensAndSera();

    // Set dims from map data
    this.setDims();

    // Load the hi table
    this.hitable.reload();

    // Set the grid
    this.setGrid();

    // Add points to the plot
    this.addAgSrPoints();

    // Update the stress
    this.updateStress();

    // Fire any resize event listeners (necessary for setting pixel ratio)
    this.viewport.onwindowresize();

    // Update antigen and sera browsers
    this.browsers.antigens.populate();
    this.browsers.sera.populate();

    // Update filers
    this.filter.update();

    // Update list of projections
    this.projectionList.populate();

    // Reset the camera transformation
    this.resetTransformation();

    // Switch to the right projection
    if(mapData && this.data.numProjections() > 0){
        this.switchToProjection(this.data.projection());
    }

    // Return the original viewpoint
    if(settings.maintain_viewpoint){
        this.camera.setZoom(zoom);
        this.scene.setTranslation(translation);
        this.selectByPointIndices(selected_points);
    }

    // Render the plot
    if(this.data.numProjections() > 0) {
        this.render();
    }

}



Racmacs.LoadPanel = class LoadPanel {

    constructor(viewer){

        // Link to viewer
        this.viewer = viewer;
        viewer.loadpanel = this;

        // Add div
        this.div = document.createElement("div");
        this.div.classList.add("load-tab");
        this.div.classList.add("shiny-element");

        // Add load map button
        var loadmap = new Racmacs.utils.Button({
            label: "Load map",
            fn: function(){ viewer.onLoadMap() }
        });
        this.div.appendChild(loadmap.div);

        // Add load table button
        var loadtable = new Racmacs.utils.Button({
            label: "Load table",
            fn: function(){ viewer.onLoadTable() }
        });
        this.div.appendChild(loadtable.div);

    }

}







