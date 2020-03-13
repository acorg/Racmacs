
// Setup object
R3JS = {};
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

        // Create viewport
        this.viewport = new R3JS.Viewport(this);

        // Initiate the viewer
        if(settings.initiate){ 
            this.initiate( settings.startAnimation );
        }

    }

    // Function to initiate webgl
    initiate(startAnimation = true){

        // Create scene
        this.scene = new R3JS.Scene();
        this.scene.setBackgroundColor({
            r : 1,
            g : 1,
            b : 1
        })
        this.scene.viewer = this;

        // Bind scene rotation events
        var viewer = this;
        this.scene.onrotate.push(function(){
            var rotation = viewer.scene.getRotation();
            viewer.viewport.transform_info.rotation.x.value = rotation[0].toFixed(4);
            viewer.viewport.transform_info.rotation.y.value = rotation[1].toFixed(4);
            viewer.viewport.transform_info.rotation.z.value = rotation[2].toFixed(4);
        });

        this.scene.ontranslate.push(function(){
            var translation = viewer.scene.getTranslation();
            viewer.viewport.transform_info.translation.x.value = translation[0].toFixed(4);
            viewer.viewport.transform_info.translation.y.value = translation[1].toFixed(4);
            viewer.viewport.transform_info.translation.z.value = translation[2].toFixed(4);
        });

        // Create renderer and append to dom
        this.renderer = new R3JS.Renderer();
        this.renderer.attachToViewport(this.viewport);
        this.renderer.setSize(
            this.viewport.width,
            this.viewport.height
        );

        // Create cameras
        this.perspcamera = new R3JS.PerspCamera();
        this.orthocamera = new R3JS.OrthoCamera();
        this.camera = this.perspcamera;

        // Add zoom events
        this.camera.zoom_events.push(function(){
            var zoom = viewer.camera.getZoom();
            viewer.viewport.transform_info.zoom.input.value = zoom.toFixed(4);
        });

        // Add raytracer
        this.raytracer = new R3JS.Raytracer();

        // Bind navigation
        this.bindNavigation();

        // Add rectangular selection
        if(this.settings.rectangularSelection){
            this.addRectangleSelection();
        }

        // Start animation loop
        if(startAnimation){
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

    getAspect(){
        return(this.viewport.getAspect());
    }

    
    
    // // Set render function
    // this.render = function(){};

    // // Bind event listeners
    // bind_events(this.viewport);

    // // Bind navigation functions
    // bind_navigation(this.viewport);

    // // Bind api functions
    // bind_api(container, this.viewport);

    // // Bind highlight functions
    // bind_highlight_fns(this.viewport);

    // // Bind raytracing
    // bind_raytracing(this.viewport);

    // // Add buttons
    // addButtons(this.viewport);

    // // Animate the scene
    // this.render();
    // function animate() {

    //     if(this.scene){
    //         if(this.raytraceNeeded || this.sceneChange){
    //             this.raytraceNeeded = false;
    //             this.raytrace();
    //         }
    //         if(this.animate || this.sceneChange){
    //             this.sceneChange = false;
    //             this.render();
    //         }
    //     }
    //     requestAnimationFrame(animate);

    // }

    // // Start the animation
    // animate();

    // // Dispatch viewer loaded event
    // var r3jsViewerLoaded_event = new CustomEvent('r3jsViewerLoaded', { detail : viewport });
    // window.dispatchEvent(r3jsViewerLoaded_event);

}

