
R3JS.Viewer.prototype.load = function(plotData){

    // Hide the placeholder
    this.viewport.hidePlaceholder();
    this.contentLoaded = true;

    // Set lims and aspect
    this.setPlotDims({
        lims   : plotData.lims,
        aspect : plotData.aspect,
        dimensions : 3
    });

    // Populate the plot
    this.scene.populatePlot(plotData);

    // Link elements to the viewer
    this.scene.elements.map(element => {
        element.viewer = this;
    });

    // Add any toggles
    this.addToggles();
	
    // Lights
    this.scene.clearLights();

    if(!plotData.light){

        // Default lighting
        this.scene.addLight({
            position: [-1,1,1]
        });

    } else {

        // Add specified lighting
        for(var i=0; i<plotData.light.length; i++){

            this.scene.addLight({
                position: plotData.light[i].position
            });

        }

    }

    // Reset transformation
    this.resetTransformation();

    // Fire any resize event listeners
    this.viewport.onwindowresize();

    // Render the plot
    if(plotData.scene){
        if(plotData.scene.translation) this.scene.setTranslation(plotData.scene.translation)
        if(plotData.scene.rotation)    this.scene.setRotation(plotData.scene.rotation)
        if(plotData.scene.zoom)        this.camera.setZoom(plotData.scene.zoom)
    }

    this.render();

    // Dispatch a plot loaded event
    window.dispatchEvent(
        new CustomEvent('r3jsPlotLoaded', { detail : this })
    );

}

