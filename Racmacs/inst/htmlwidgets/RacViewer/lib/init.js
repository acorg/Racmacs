
Racmacs = {};
Racmacs.utils = {};
Racmacs.Viewer = class RacViewer extends R3JS.Viewer {

    // Constructor function
    constructor(container, settings = {}){

        // Initiate the base R3JS viewer
        var r3jssettings = {
            rectangularSelection : true,
            startAnimation : false,
            initiate : false
        }
        super(container, r3jssettings);

        // Generate any placeholders
        if(settings.placeholder){
            
            var placeholder = document.createElement("div");
            placeholder.id  = "placeholder";
            
            var holderimg = document.createElement("img");
            holderimg.src = settings.placeholder;
            holderimg.id  = "placeholder-img";
            placeholder.appendChild(holderimg);

            var holderoverlay = document.createElement("div");
            holderoverlay.id = "placeholder-overlay";
            holderoverlay.innerHTML = "Click to activate viewer";
            placeholder.appendChild(holderoverlay);

            var viewer = this;
            placeholder.addEventListener("mouseup", function(){
                placeholder.style.display = "none";
                viewer.initiateWebGL();
            });

            this.wrapper.appendChild(placeholder);

        } else {

            this.initiateWebGL();

        }

        // Initiate the webgl
        //this.initiateWebGL();

    }

    // Function to intiate webgl components of viewer
    initiateWebGL(){

        // Set status as initiated
        this.initiated = true;

        // Initiate the r3js viewer but don't start the animation loop
        this.initiate(false);

        // Add a data object
        new Racmacs.Data(this);

        // Set defaults
        this.contentLoaded    = false;
        this.performance_mode = true;
        this.animated         = false;

        // Keep record of selected and animated points
        this.selected_pts = [];
        this.animated_points = [];

        // Keep browser record
        this.browsers = {};

        // Add grid holder
        this.gridholder = new THREE.Object3D();
        this.scene.scene.add(this.gridholder);

        // Add positional light
        var light       = new THREE.DirectionalLight(0xe0e0e0);
        light.position.set(-1,1,1).normalize();
        light.intensity = 1.0;
        this.scene.scene.add( light );

        // Add additional buttons to viewport
        this.viewport.addMapButtons();

        // Add stress and a stress div
        this.stress = new Racmacs.StressElement();
        this.stress.bindToViewport(this.viewport);

        // Add the HI table
        this.hitable = new Racmacs.HITable(this);

        // Setup control panel
        new Racmacs.ControlPanel(this);

        // Set a default title
        this.setTitle("Racmacs viewer");

        // Dispatch a viewer loaded event
        var viewer = this;
        window.dispatchEvent(
            new CustomEvent('racViewerLoaded', { detail : viewer })
        );

        // Start animation loop
        var viewer = this;
        function animate() {

            if(viewer.animated){
                if(viewer.animated_points.length > 0){
                    viewer.animated_points.map( x => x.stepToCoords() );
                    viewer.updateStress();
                    viewer.sceneChange = true;
                }
                if(viewer.raytraceNeeded || viewer.sceneChange || viewer.scene.sceneChange){
                    viewer.raytraceNeeded = false;
                    viewer.raytrace();
                }
                if(viewer.sceneChange || viewer.scene.sceneChange){
                    viewer.sceneChange = false;
                    viewer.scene.sceneChange = false;
                    viewer.render();
                }
            }
            requestAnimationFrame(animate);

        }
        animate();

        // Load map data if present
        if(this.mapData){
            this.loadMapData();
        }

    }

}

R3JS.Viewport.prototype.placeholderContent = "";

// function racViewer(
//     container, 
//     mapData, 
//     settings = {}
//     ){

//     // Settings
//     if(typeof(settings.controls) === "undefined")   { settings.controls   = true }
//     if(typeof(settings.selectable) === "undefined") { settings.selectable = true }

//     // Set your plotData variables
//     var plotData = {
//         aspect: [1,1,1],
//         scene: {
//             background: [1,1,1],
//             zoom: [1]
//         }
//     }

//     // Clear container and style it
//     container.innerHTML = null;

//     // Create overall container
//     var viewer = document.createElement( 'div' );
//     viewer.id = "viewer";
//     viewer.container = container;
//     container.appendChild(viewer);

//     // Create viewport
//     var viewport = generateViewport(plotData, viewer);
//     viewport.settings = settings;

//     // Bind the point prototype
//     viewport.Point = getPointConstructor();
    

    

//     // Add a map stress div
//     var stress_div = document.createElement( 'div' );
//     stress_div.id = "stress-div";
//     viewport.appendChild(stress_div);
//     viewport.stress = {
//         div   : stress_div,
//         value : null
//     };
//     viewport.stress.div.update = function(stress){
      
//       var map_stress_text = stress.toFixed(2);
//       if(viewport.relax_on){ map_stress_text = map_stress_text+"...running" }
//       this.innerHTML = map_stress_text;

//     };
//     viewport.stress.div.empty = function(){
      
//       this.innerHTML = "";

//     };

//     // Set defaults
//     viewport.agsr       = [];
//     viewport.geometries = {}
//     viewport.pixelratio = 1;

//     // Generate the scene from the plot data
//     addScene(viewport,    plotData);
//     addRenderer(viewport, plotData);
//     addCamera(viewport,   plotData);
//     viewport.scene.plotHolder.rotation.set(0,0,0);

//     // Update visibility of dynamic components
//     viewport.scene.showhideDynamics( viewport.camera );
    
//     // Bind event listeners
//     bind_events(viewport);
    
//     // Bind navigation functions
//     bind_navigation(viewport);



    
//     viewport.mouseScroll = viewport.zoomScene;

//     // Bind api functions
//     bind_api(container, viewport);
//     bind_racAPI(viewport);

//     // Bind highlight functions
//     bind_highlight_fns(viewport);
//     extend_highlight_fns(viewport);

//     // Bind raytracing
//     bind_mapRaytracing(viewport);

//     // Bind point movement
//     bind_point_movement(viewport);
    
//     // Bind graphical functions
//     bind_graphics(viewport);

//     // Bind batch run functions
//     bind_batchRunFunctions(viewport);

//     // Add general (r3js) buttons
//     addButtons(viewport);

//     // Add additional map buttons
//     addMapButtons(viewport);

//     // Bind functions to switch between dimension modes
//     bind_dimensions(viewport);

//     // Add toggles
//     addToggles(viewport);

//     // Bind animations
//     bind_animations(viewport);

//     // Set camera positions
//     viewport.ortho_camera.max_zoom = 100;
//     viewport.ortho_camera.min_zoom = 1;
//     viewport.ortho_camera.zoom_damper = 1;

//     viewport.ortho_camera.zoomSceneScale = function(deltaX, deltaY){

//         var start_zoom = this.scene.scale.x;
//         var zoom = this.camera.rezoom(deltaY);
//         var end_zoom = this.scene.scale.x;
        
//         for(var i=0; i<this.agsr.length; i++){
//             this.agsr[i].scalePoint(start_zoom/end_zoom);
//         }

//         this.sceneChange = true;
//         this.infoDiv.update();

//     };
    
//     viewport.persp_camera.max_zoom = 100;
//     viewport.persp_camera.min_zoom = 1;
//     viewport.persp_camera.zoom_damper = 1;
    
//     viewport.persp_camera.setDistance = function(){

//         // Set perspective camera distance
//         var fov = viewport.persp_camera.fov * ( Math.PI / 180 ); 
//         var start_zoom = Math.abs( viewport.scene.sphere.radius / Math.sin( fov / 2 ) )/0.9;
//         viewport.persp_camera.position.z = start_zoom;
//         viewport.persp_camera.updateProjectionMatrix();
//         this.start_zoom = start_zoom;

//     }

//     viewport.persp_camera.zoomSceneScale = function(deltaX, deltaY){
        
//         var start_zoom = this.camera.position.z;
//         var zoom = this.camera.rezoom(deltaY);
//         var end_zoom = this.camera.position.z;

//         for(var i=0; i<this.agsr.length; i++){
//             this.agsr[i].scalePoint(end_zoom/start_zoom);
//         }

//         this.sceneChange = true;
//         this.infoDiv.update();

//     };

//     // Add antigen sera info div
//     viewport.info_div = document.createElement("div");
//     viewport.info_div.id = "info-div";
//     viewport.appendChild(viewport.info_div);

//     // Add antigen selection info div
//     viewport.selection_info_div = document.createElement("div");
//     viewport.selection_info_div.id = "selection-info-panel";
//     viewport.selection_info_div.classList.add("popup-box");
//     viewport.appendChild(viewport.selection_info_div);
//     viewport.selection_info_div.update = function(){
//         this.innerHTML = "";
//         for(var i=0; i<viewport.selected_pts.length; i++){
//             var pt_div = document.createElement("div");
//             pt_div.innerHTML = viewport.selected_pts[i].name;
//             this.appendChild(pt_div);
//         }
//     }
//     viewport.selection_info_div.addEventListener("mousedown", function(e){ e.stopPropagation() });
//     viewport.selection_info_div.addEventListener("mouseup",   function(e){ e.stopPropagation() });
//     viewport.selection_info_div.addEventListener("mousemove", function(e){ e.stopPropagation() });
//     viewport.selection_info_div.style.display = "none";

//     viewport.toggle_selections = function(){
//         if(viewport.selection_info_div.style.display == "none"){
//             viewport.selection_info_div.style.display = "block";
//         } else {
//             viewport.selection_info_div.style.display = "none";
//         }
//     }

//     // Set notification and warning functions
//     viewport.notifications = {}
//     viewport.notifications.warning = function(x){ alert(x) }
//     viewport.notifications.error   = function(x){ alert(x) }
//     viewport.notifications.info    = function(x){ alert(x) }

//     // Bind shortcuts
//     bind_shortcuts(viewport);

//     // Bind relaxation functions
//     bind_relaxation(viewport);

//     // Bind procrustes functions
//     bind_procrustes(viewport);

//     // Bind grid functions
//     bind_gridFunctions(viewport)

//     // Bind connection lines
//     bind_connections(viewport);
    
//     // Bind drag functions
//     bindAgSrDrag(viewport)

//     // Add blob functions
//     bindBlobfunctions(viewport);

//     // Add loading functions
//     bind_loaders(viewport);

//     // Add a control panel if required
//     function inIframe() {
//         try {
//             return window.self !== window.top;
//         } catch (e) {
//             return true;
//         }
//     }
//     if(settings.controls){
//         if(!inIframe()){
//             add_controls(viewer);
//             viewport.selectable = true;
//         }
//     }
//     if(settings.selectable){
//         viewport.selectable = true;
//     }

//     bind_filters(viewport);

//     // Animate the scene
//     viewport.render();
//     viewport.animate = function() {
        
//         if(viewport.raytraceNeeded || viewport.sceneChange){
//             viewport.raytraceNeeded = false;
//             viewport.raytrace();
//         }
//         if(viewport.animate || viewport.sceneChange){
//             viewport.sceneChange = false;
//             viewport.render();
//         }
//         if(viewport.animated_points.length > 0){
//             for(var i=0; i<viewport.animated_points.length; i++){
//                 var pIndex = viewport.animated_points[i];
//                 viewport.points[pIndex].stepToCoords();
//             }
//             viewport.updateStress();
//         }
//         viewport.animationFrame = requestAnimationFrame(viewport.animate);

//     }
//     viewport.animate();

//     // Load in the mapData
//     viewport.load(mapData);
    
//     // Resize the camera
//     viewport.camera.resize();

//     // Dispatch a viewer loaded event
//     var racViewerLoaded_event = new CustomEvent('racViewerLoaded', { detail : viewport });
//     window.dispatchEvent(racViewerLoaded_event);

//     // Return the viewport object
//     return(viewport);

// }

