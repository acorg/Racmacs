
R3JS.Viewer.prototype.load = function(plotData){

    // Set lims and aspect
    this.setPlotDims({
        lims   : plotData.lims,
        aspect : plotData.aspect,
        dimensions : 3
    });

    // Populate the plot
    this.scene.populatePlot(plotData);

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

    // this.scene.elements[170].setColor("#ff0000");

    // this.renderer.setShaders(
    //     R3JS.Shaders.VertexShader2D,
    //     R3JS.Shaders.FragmentShader2D
    // );

    // this.camera.setZoom(1.25);

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

    // console.log(this.camera);

	// // Bind plot data
 //    this.plotData = plotData;

 //    // Generate the scene from the plot data
 //    addRenderer(this.viewport, plotData);
 //    addCamera(this.viewport,   plotData);
 //    addScene(this.viewport,    plotData);

 //    this.viewport.scene.render = function(){
 //        this.render();
 //    };

 //    // Add toggles
	// addToggles(this.viewport);


 //    if(!plotData.scene.zoom){ plotData.scene.zoom = [1] }
 //    this.viewport.camera.defaultZoom = plotData.scene.zoom[0];

 //    // Set camera limits
 //    if(plotData.camera){
 //        if(plotData.camera.min_zoom){
 //            this.viewport.camera.min_zoom = plotData.camera.min_zoom;
 //        }
 //        if(plotData.camera.max_zoom){
 //            this.viewport.camera.max_zoom = plotData.camera.max_zoom;
 //        }
 //    }

 //    // Rotate scene
 //    if(plotData.scene.rotation){
 //      this.scene.setRotationDegrees(plotData.scene.rotation);
 //    }
 //    if(plotData.scene.translation){
 //      this.scene.setTranslation(plotData.scene.translation);
 //    }

 //    // Zoom scene
 //    if(plotData.scene.zoom){
 //      this.viewport.camera.setZoom(plotData.scene.zoom[0]);
 //    } else {
 //      this.viewport.camera.setDistance();
 //      plotData.scene.zoom = [this.camera.getZoom()];
 //    }

 //    // Update visibility of dynamic components
 //    this.viewport.scene.showhideDynamics( this.viewport.camera );

 //    // Run any resize functions
 //    for(var i=0; i<this.viewport.onResize.length; i++){
 //        this.viewport.onResize[i]();
 //    }

}

