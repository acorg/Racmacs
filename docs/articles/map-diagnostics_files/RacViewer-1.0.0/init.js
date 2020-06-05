
if(typeof Racmacs === "undefined"){
    Racmacs = {};
}

Racmacs.utils = {};
Racmacs.App = class RacApp extends R3JS.Viewer {
    constructor(container, settings = {}){
        super(container, settings);
    }
}

Racmacs.Viewer = class RacViewer extends Racmacs.App {

    // Constructor function
    constructor(container, settings = {}){

        // Initiate the base R3JS viewer
        var r3jssettings = {
            rectangularSelection : true,
            startAnimation : false,
            initiate : false
        }
        super(container, r3jssettings);
        container.viewer = this;

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
        this.addMapButtons();

        // Add the function to popout a new version of the viewer
        this.viewport.popOutViewer = function(){
            
            // Fetch the container
            var viewer    = this.viewer;
            var container = this.viewer.container;
            var viewerdiv = container.children[0];
            var data = document.querySelectorAll('[data-for='+container.id+']');

            // Popout a new window
            // var popout = window.open("", "", "height=800,width=800");
            var popout = window.open("", "", "height=800,width=800");

            // Copy style and scripts
            popout.document.write(
                `<head>` +
                document.head.innerHTML + 
                `</head>` +
                `<body style='margin:0'></body>`
            );

            // When the other document is ready move the viewer across
            var switchpopout = function(){
                if(popout.document.body === null){
                    window.setTimeout(switchpopout, 100);
                } else {
                    container.style.backgroundColor = "#fafafa";
                    popout.document.body.appendChild(viewerdiv);
                    viewer.viewport.onwindowresize();
                }
            }
            switchpopout();
            
            // Link resize events
            popout.onresize = function(){
                viewer.viewport.onwindowresize();
            }

            // Add an event to switch back to the main viewer on window close
            popout.onbeforeunload = function(){
                container.appendChild(viewerdiv);
                viewer.viewport.onwindowresize();
            }

        }

        // Add stress and a stress div
        this.stress = new Racmacs.StressElement();
        this.stress.bindToViewport(this.viewport);

        // Setup control panel
        new Racmacs.ControlPanel(this);

        // Add focus listener for viewport to capture keystrokes
        let holder = this.viewport.holder;
        holder.setAttribute("tabindex", 1);
        holder.style.outline = "none";
        holder.style.border = "solid 4px #eeeeee";
        holder.addEventListener('mouseup', function(e){
            this.focus();
        });
        holder.addEventListener('focus', function(e){
            this.style.border = "solid 4px #bde7ef";
        });
        holder.addEventListener('blur', function(e){
            this.style.border = "solid 4px #eeeeee";
        });

        // Add focus if this is a standalone page
        if(this.fullpage()){
            holder.focus(); 
        }

        // Add keystroke shortcuts
        holder.addEventListener('keyup', e => {
            switch(e.key){
                case "e":
                    this.toggleErrorLines();
                    break;
                case "c":
                    this.toggleConnectionLines();
                    break;
                case "=":
                    this.resizePoints(1.2);
                    break;
                case "-":
                    this.resizePoints(0.8);
                    break;
                case "m":
                    this.toggleDragMode();
                    break;
                case "f":
                    this.toggleLockPointSize();
                    break;
                case "r":
                    this.resetTransformation();
                    break;
                case "Escape":
                    this.deselectAll();
                    break;
            }
        });

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


