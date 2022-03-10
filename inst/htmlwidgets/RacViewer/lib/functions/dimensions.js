

// Set plot lims
Racmacs.Viewer.prototype.setPlotDims = function(plotdims){

    // Set scene lims
    this.scene.setPlotDims(plotdims);
    this.gridholder.scale.copy(
        this.scene.plotPoints.scale
    );
    // this.scene.plotPoints.scale.set(1,1,1);

    if(plotdims.dimensions <= 2){

        // Rebind navigation
        this.mouseMove = this.panScene;

        // Set camera
        this.camera = this.orthocamera;
        this.unlockPointSize();
        this.renderer.setShaders(
            R3JS.Shaders.VertexShader2D,
            R3JS.Shaders.FragmentShader2D
        );

        // Set default opacity of points
        this.setDefaultStyleset(2);

    } else {

        // Rebind navigation
        this.mouseMove = this.rotateSceneWithInertia;

        // Set camera
        this.camera = this.perspcamera;
        this.lockPointSize();

        if(!this.svg){
            this.renderer.setShaders(
                R3JS.Shaders.VertexShader3D,
                R3JS.Shaders.FragmentShader2D
            );
        }

        // Make any stylesheet changes based on the dimension change
        this.setDefaultStyleset(3);
        
    }

}

Racmacs.Viewer.prototype.setDims = function(
    mapdims = {}
){

    // Clear map dims
    this.mapdims = mapdims;

    // Set dimensions
    if(this.mapdims.dimensions === undefined){
        this.mapdims.dimensions = this.data.dimensions();
    }

    // Fetch non na coordinates without nas
    var coords   = [];
    for(var i=0; i<this.points.length; i++){
        if(!this.points[i].coords_na){
        	coords.push(this.points[i].coords3);
        }
    }
    var x_coords = coords.map( p => p[0] );
    var y_coords = coords.map( p => p[1] );
    var z_coords = coords.map( p => p[2] );

    // Set map limits
    this.mapdims.lims = [
        [Math.min(...x_coords), Math.max(...x_coords)],
        [Math.min(...y_coords), Math.max(...y_coords)],
        [Math.min(...z_coords), Math.max(...z_coords)]
    ];

    if (mapdims.xlim) this.mapdims.lims[0] = mapdims.xlim;
    if (mapdims.ylim) this.mapdims.lims[1] = mapdims.ylim;
    if (mapdims.zlim) this.mapdims.lims[2] = mapdims.zlim;

    // Work out map lims and aspect
    if(this.mapdims.dimensions <= 2) {

        // Set map limits
        this.mapdims.lims[2] = [-1, 1];

        // Set to rotate around mouse
        this.settings.rotateAroundMouse = true;

        // Set 2D plotting elements
        this.mapElements = this.mapElements2D;
        
    } else {

        // Set to not rotate around mouse
        this.settings.rotateAroundMouse = false;

        // Set 3D plotting elements
        this.mapElements = this.mapElements3D;

    }

    // Set map size in each axis
    this.mapdims.size = [
        (this.mapdims.lims[0][1] - this.mapdims.lims[0][0]),
        (this.mapdims.lims[1][1] - this.mapdims.lims[1][0]),
        (this.mapdims.lims[2][1] - this.mapdims.lims[2][0])
    ];

    // Set map aspect
    this.mapdims.aspect = [1, 1, 1];

    // Set midpoints
    this.mapdims.midpoints = [
        (this.mapdims.lims[0][0] + this.mapdims.lims[0][1]) / 2,
        (this.mapdims.lims[1][0] + this.mapdims.lims[1][1]) / 2,
        (this.mapdims.lims[2][0] + this.mapdims.lims[2][1]) / 2
    ];

    // Set bounding sphere
    this.mapdims.sphere = new THREE.Sphere().setFromPoints([
        new THREE.Vector3().fromArray([this.mapdims.lims[0][0], this.mapdims.lims[1][0], this.mapdims.lims[2][0]]),
        new THREE.Vector3().fromArray([this.mapdims.lims[0][0], this.mapdims.lims[1][0], this.mapdims.lims[2][1]]),
        new THREE.Vector3().fromArray([this.mapdims.lims[0][0], this.mapdims.lims[1][1], this.mapdims.lims[2][0]]),
        new THREE.Vector3().fromArray([this.mapdims.lims[0][0], this.mapdims.lims[1][1], this.mapdims.lims[2][1]]),
        new THREE.Vector3().fromArray([this.mapdims.lims[0][1], this.mapdims.lims[1][0], this.mapdims.lims[2][0]]),
        new THREE.Vector3().fromArray([this.mapdims.lims[0][1], this.mapdims.lims[1][0], this.mapdims.lims[2][1]]),
        new THREE.Vector3().fromArray([this.mapdims.lims[0][1], this.mapdims.lims[1][1], this.mapdims.lims[2][0]]),
        new THREE.Vector3().fromArray([this.mapdims.lims[0][1], this.mapdims.lims[1][1], this.mapdims.lims[2][1]])
        ],
        new THREE.Vector3().fromArray(this.mapdims.midpoints)
    );

    // Set the plot dims
    this.setPlotDims({
        lims       : this.mapdims.lims,
        aspect     : this.mapdims.aspect,
        dimensions : this.mapdims.dimensions
    });

}

// Map element functions for 2D maps
Racmacs.Viewer.prototype.mapElements2D = {
    procrustes : R3JS.element.glarrow
};

// Map element functions for 3D maps
Racmacs.Viewer.prototype.mapElements3D = {
    procrustes : R3JS.element.arrows3d
};



Racmacs.Viewer.prototype.resetDims = function(dims){

    // Empty the scene
    this.scene.empty();

    // Set dims from map data
    this.setDims({
        dimensions : dims
    });

    // Set the grid
    this.setGrid();

    // Add points to the plot
    this.addAgSrPoints();

    // Fire any resize event listeners (necessary for setting pixel ratio)
    this.viewport.onwindowresize();

    // Update filters
    this.filter.update();

    // Render the plot
    this.render();

    // Reset the camera transformation
    this.resetTransformation();

}







