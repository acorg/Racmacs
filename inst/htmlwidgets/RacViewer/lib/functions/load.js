

Racmacs.Viewer.prototype.load = function(mapData, settings = {}, plotdata, placeholder){

    // Set map data and settings
    this.mapData     = mapData;
    this.mapSettings = settings;
    this.mapPlotdata = plotdata;
    
    // If initated load the map data
    if(this.initiated){
      this.loadMapData();
    }

}

Racmacs.Viewer.prototype.loadMapData = function(){

    var mapData  = this.mapData;
    var settings = this.mapSettings;
    var plotdata = this.mapPlotdata;

    this.clearDiagnostics();

    // Show or hide control panels
    if(settings.hide_control_panel || settings.hide_control_panel === undefined){
        this.controlpanel.hide();
    } else {
        this.controlpanel.show();
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
    this.hideTable();

    // Set the grid
    this.setGrid();

    // Add points to the plot
    this.addAgSrPoints();

    // Update the stress
    this.updateStress();

    // Update antigen and sera browsers
    this.browsers.antigens.populate();
    this.browsers.sera.populate();

    // Update filters
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

    // Populate the plot with any plotting data
    if(plotdata && plotdata.length){
        this.scene.populatePlot({
            plot: plotdata
        });
    }

    // Add any boostrap info
    var bootstrap = this.data.bootstrap();
    if(bootstrap !== undefined){
        this.showBootstrapPoints(bootstrap);
    }

    // Render the plot
    if(this.data.numProjections() > 0) {
        this.render();
    }

    // Fire any resize event listeners (necessary for setting pixel ratio)
    this.viewport.onwindowresize();

    // Set camera zoom
    var zoom = this.data.getViewerSetting("zoom")
    if(zoom === null){
        
        var xlim = this.data.xlim();
        var ylim = this.data.ylim();

        var scale = this.scene.getWorldScale();
        xlim = [xlim[0]*scale[0], xlim[1]*scale[0]];
        ylim = [ylim[0]*scale[1], ylim[1]*scale[1]];

        this.camera.zoomToLims({
            x : xlim,
            y : ylim
        });
        this.camera.setDefaultZoom();

    } else {

        this.camera.setZoom(zoom);
        this.camera.setDefaultZoom();

    }

    window.dispatchEvent(
        new CustomEvent('racViewerMapLoaded', { detail : this })
    );

    // this.resizePoints(0.1);
    // this.showErrorLines();
    // this.controlpanel.show();
    // this.controlpanel.tabset.showTab("browser");

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







