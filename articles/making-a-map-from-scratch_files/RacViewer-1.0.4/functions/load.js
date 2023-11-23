
// Main function to load new map data
Racmacs.Viewer.prototype.load = function(
    mapData,
    options = {},
    plotdata,
    light
    ){

    // Set default options
    if (options["grid.col"] === undefined) options["grid.col"] = "#cfcfcf";
    if (options["background.col"] === undefined) options["background.col"] = "#ffffff";
    if (options["point.opacity"] === undefined || options["point.opacity"] === null) {
        options["point.opacity"] = this.styleset.noselections.unhovered.unselected.opacity;
    };

    if(options.maintain_viewpoint){
        var selected_points = this.getSelectedPointIndices();
        var selected_projection = this.data.projection();
    }

    // Clear previous plots
    this.contentLoaded = false;
    this.data.clear();
    this.scene.empty();
    this.clearDiagnostics();
    this.clearBrowsers();
    this.clearAntigensAndSera();
    this.controlpanel.disableProjectionTabs();

    // Set viewer controls
    if(options["viewer.controls"] !== "hidden") this.controlpanel.show();
    if(options["viewer.controls"] === "optimizations") this.controlpanel.tabset.showTab("projections");
    if(options["viewer.controls"] === "diagnostics") this.controlpanel.tabset.showTab("diagnostics");

    // Plot new map data
    if(mapData === null) {

        this.setTitle("Racmacs viewer");
        this.viewport.showPlaceholder();
        this.controlpanel.disableContentLoadedTabs();

    } else {

        // Set map data and options
        this.mapPlotdata = plotdata;

        // Enable control panel options
        this.controlpanel.enableContentLoadedTabs();

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

        // Update viewer title
        this.setTitle(this.data.tableName());

        // Generate the antigen and sera objects
        this.addAntigensAndSera();

        // Set viewpoint
        if (this.data.numProjections() > 0) {

            // Get plot limits
            if (!options.xlim) var xlim = this.data.xlim();
            else               var xlim = options.xlim;
            if (!options.ylim) var ylim = this.data.ylim();
            else               var ylim = options.ylim;
            var zlim = this.data.zlim();

            // Set dims from map data
            if(!options.maintain_viewpoint){
                this.setDims({
                    xlim : xlim,
                    ylim : ylim,
                    zlim : zlim
                });
            }

        }

        // Load the hi table
        this.hideTable();

        // Set the grid
        if(options["grid.display"] !== "rotate"){
            this.setGrid(options);
        }

        // Add points to the plot
        if(this.data.numProjections() > 0) {
            this.addAgSrPoints();
        }

        // Update antigen and sera browsers
        this.browsers.antigens.populate();
        this.browsers.sera.populate();

        // Update filters
        this.filter.update();

        // Update list of projections
        this.projectionList.populate();

        // Reset the camera transformation
        if(!options.maintain_viewpoint){
            this.resetTransformation();
        }

        // Switch to the right projection
        if(mapData && this.data.numProjections() > 0){
            this.switchToProjection(this.data.projection());
        }

        // Populate the plot with any plotting data
        if(plotdata && plotdata.length){
            this.scene.populatePlot({
                plot: plotdata
            });
        }

        // Set the background color
        this.setBackground(options["background.col"]);

        // Lights
        this.scene.clearLights();

        if (!light || light.length === 0) {

            // Default lighting
            this.scene.addLight({
                position: [-1,1,1],
                lighttype: "directional",
                intensity: 1.0
            });

        } else {

            // Add specified lighting
            for(var i=0; i<light.length; i++){

                this.scene.addLight(light[i]);

            }

        }

        // Add any bootstrap info
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
        if(this.data.numProjections() > 0 && !options.maintain_viewpoint) {

            var zoom = this.data.getViewerSetting("zoom");
            if(zoom === null){

                var scale = this.scene.getWorldScale();
                xlim = [xlim[0]*scale[0], xlim[1]*scale[0]];
                ylim = [ylim[0]*scale[1], ylim[1]*scale[1]];
                zlim = [zlim[0]*scale[1], zlim[1]*scale[1]];

                var translation = [
                  (xlim[1] + xlim[0]) / 2,
                  (ylim[1] + ylim[0]) / 2,
                  (zlim[1] + zlim[0]) / 2
                ];

                // this.scene.setTranslation(translation);

                this.camera.zoomToLims({
                    x : xlim,
                    y : ylim,
                    z : zlim
                });
                this.camera.setDefaultZoom();

            } else {

                this.camera.setZoom(zoom);
                this.camera.setDefaultZoom();

            }

        }

        // Allow for any sequence data
        var ag_sequences = this.data.agSequences(0);
        if(ag_sequences !== null){
            this.colorpanel.showColorBySequence();
            this.btns["viewSequences"].style.display = "";
        } else {
            this.colorpanel.hideColorBySequence();
            this.btns["viewSequences"].style.display = "none";
        }

        // Allow for group data
        if (this.data.agGroupLevels() !== undefined || this.data.srGroupLevels() !== undefined) {

            // Show legend
            if (options.show_group_legend) {
                this.showLegend();
            } else {
                this.clearLegend();
            };

            this.colorpanel.showColorByGroup();

        } else {

            this.colorpanel.hideColorByGroup();

        }

        // Deal with viewer options
        if (options["point.opacity"] == "inherit") {
            this.antigens.map((ag, i) => ag.fillopacity = this.data.agFillOpacity(i));
            this.antigens.map((ag, i) => ag.outlineopacity = this.data.agOutlineOpacity(i));
            this.sera.map((sr, i) => sr.fillopacity = this.data.srFillOpacity(i));
            this.sera.map((sr, i) => sr.outlineopacity = this.data.srOutlineOpacity(i));
        } else {
            this.points.map(pt => {
                if (pt.fillColor != "transparent") {
                    pt.fillopacity = options["point.opacity"]
                } else {
                    pt.fillopacity = 0;
                }
            });
            this.points.map(pt => {
                if (pt.outlineColor != "transparent") {
                    pt.outlineopacity = options["point.opacity"]
                } else {
                    pt.outlineopacity = 0;
                }
            });
        }
        this.updatePointStyles();

        // Reselect any points
        if(options.maintain_viewpoint){
            this.selectByPointIndices(selected_points);
            this.switchToProjection(selected_projection);
        }

        // Run the function to toggle plot content that is shown dynamically based on scene rotation
        if(this.scene.dynamic) this.scene.showhideDynamics(this.camera.camera);

        // Set viewer toggles
        switch(options["show.names"]) {
          case true:
            this.showLabels("all");
            break;
          case "antigens":
            this.showLabels("antigens");
            break;
          case "sera":
            this.showLabels("sera");
            break;
        }
        if(options["show.connectionlines"])  this.showConnectionLines();
        if(options["show.errorlines"])       this.showErrorLines();
        if(options["show.titers"])           this.showTiters();

        // Update the viewer frustrum
        this.updateFrustrum();

        // Update the stress
        this.updateStress(this.data.stress());

        // Set viewpoint
        if(options.translation) this.scene.setTranslation(options.translation);
        if(options.rotation)    this.scene.setRotation(options.rotation);
        if(options.zoom)        this.camera.setZoom(options.zoom);

        // Note that content is now loaded
        this.contentLoaded = true;

        // Hack to resize points
        this.resizePoints(1.0);

    }

    // Dispatch the map loaded event
    window.dispatchEvent(
        new CustomEvent('racViewerMapLoaded', { detail : this })
    );


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







