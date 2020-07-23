
// Setup object
if(typeof R3JS === "undefined") R3JS = {};

R3JS.Viewer = class R3JSviewer {

    // Constructor function
    constructor(container, settings = {
        startAnimation : true,
        initiate : true
    }){

        // Set settings
        this.settings = settings;

        // Set variables
        this.sceneChange    = false;
        this.raytraceNeeded = false;
        this.name           = "r3js viewer";

        // Set the container
        this.container = container;
        container.viewer = this;

        // Create viewport
        this.viewport = new R3JS.Viewport(this);

        // Bind event listeners
        this.bindEventListeners();

        // Initiate the viewer
        if(settings.initiate){ 
            this.initiate( settings.startAnimation );
        }

    }

    // Function to initiate webgl
    initiate(startAnimation = true){

        // Create scene
        this.scene = new R3JS.Scene(this);
        this.scene.setBackgroundColor({
            r : 1,
            g : 1,
            b : 1
        })

        // Create renderer and append to dom
        this.renderer = new R3JS.Renderer();
        this.renderer.attachToViewport(this.viewport);
        this.renderer.setSize(
            this.viewport.width,
            this.viewport.height
        );

        // Create cameras
        this.perspcamera = new R3JS.PerspCamera(this);
        this.orthocamera = new R3JS.OrthoCamera(this);
        this.camera      = this.perspcamera;

        // Add raytracer
        this.raytracer = new R3JS.Raytracer();

        // Bind navigation
        this.bindNavigation();

        // Add rectangular selection
        if(this.settings.rectangularSelection){
            this.addRectangleSelection();
        }

        // Start animation loop
        var viewer = this;
        function animate() {

            if(viewer.raytraceNeeded || viewer.sceneChange || viewer.scene.sceneChange){
                viewer.raytraceNeeded = false;
                viewer.raytrace();
            }
            if(viewer.sceneChange || viewer.scene.sceneChange){
                viewer.sceneChange = false;
                viewer.scene.sceneChange = false;
                viewer.render();
            }
            requestAnimationFrame(animate);

        }
        animate();

    }

    // Render function
    render(){
        this.renderer.render(
            this.scene, 
            this.camera
        );
    }

    // Raytrace function
    raytrace(){
        this.raytracer.raytrace(
            this,
            this.scene,
            this.camera,
            this.viewport.mouse
        )
    }

    // Rest transformation
    resetTransformation(){
        this.sceneChange = true;
        this.scene.resetTransformation();
        this.camera.resetZoom();
        this.scene.showhideDynamics(this.camera.camera);
    }

    // Set plot lims
    setPlotDims(plotdims){

        // Set scene lims
        this.scene.setPlotDims(plotdims);

        // Rebind navigation depending upon 2D or 3D plot
        //this.navigation_bind(plotdims.dimensions);

        // Set camera
        if(plotdims.dimensions == 2){
            this.camera = this.orthocamera;
            this.renderer.setShaders(
                R3JS.Shaders.VertexShader2D,
                R3JS.Shaders.FragmentShader2D
            );
        } else {
            this.camera = this.perspcamera;
            this.renderer.setShaders(
                R3JS.Shaders.VertexShader3D,
                R3JS.Shaders.FragmentShader2D
            );
        }

    }

    // Return aspect ratio
    getAspect(){
        return(this.viewport.getAspect());
    }

    // Check if this is part of a page or the whole page
    fullpage(){
        return(
            this.container.offsetHeight == document.body.offsetHeight &&
            this.container.offsetWidth  == document.body.offsetWidth
        )
    }

    // For dispatching custom events
    dispatchEvent(name, detail){
        detail.viewer = this;
        let event = new CustomEvent(name, {
            detail: detail
        });
        this.container.dispatchEvent(event);
    }

    addEventListener(name, fn){
        this.container.addEventListener(name, fn);
    }

    bindEventListeners(){
        for(var i=0; i<this.eventListeners.length; i++){
            this.addEventListener(
                this.eventListeners[i].name, 
                this.eventListeners[i].fn
            );
        }
    }

}

R3JS.Viewer.prototype.eventListeners = [];

