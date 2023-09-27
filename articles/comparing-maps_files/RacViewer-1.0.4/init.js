
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
            initiate : true
        }
        super(container, r3jssettings);
        container.viewer = this;

        // Set a placeholder image
        let placeholder = Racmacs.icons.logo();
        placeholder.style.maxWidth  = "100%";
        placeholder.style.maxHeight = "100%";
        placeholder.style.opacity = 0.2;
        this.viewport.setPlaceholder(
            placeholder, "#fff"
        );

        // Add a data object
        new Racmacs.Data(this);

        // Set defaults
        this.contentLoaded    = false;
        this.performance_mode = true;
        this.animated         = false;
        this.setDefaultStyleset();

        // Keep record of selected and animated points
        this.selected_pts = [];
        this.animated_points = [];

        // Keep browser record
        this.browsers = {};

        // Add grid holder
        this.gridholder = new THREE.Object3D();
        this.scene.scene.add(this.gridholder);

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
                case "t":
                    this.toggleTiters();
                    break;
                case "n":
                    this.toggleLabels();
                    break;
                case "Escape":
                    this.exitDragMode();
                    this.hideErrorLines();
                    this.hideConnectionLines();
                    this.hideTiters();
                    this.deselectAll();
                    break;
            }
        });

        // Add events for clipping points outside camera frustrum
        this.addEventListener("zoom", e => {
            this.updateFrustrum();
        });

        this.addEventListener("rotate", e => {
            this.updateFrustrum();
        });

        this.addEventListener("translate", e => {
            this.updateFrustrum();
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
                    viewer.pointsMoved = true;
                    viewer.sceneChange = true;
                }
                if(viewer.optimizing) {
                    viewer.stepOptimizer();
                    viewer.pointsMoved = true;
                    viewer.sceneChange = true;
                }
                if(viewer.raytraceNeeded || viewer.sceneChange || viewer.scene.sceneChange){
                    viewer.raytraceNeeded = false;
                    viewer.raytrace();
                }
                if(viewer.pointsMoved) {
                    viewer.updateFrustrum();
                }
                if(viewer.sceneChange || viewer.scene.sceneChange){
                    viewer.sceneChange = false;
                    viewer.scene.sceneChange = false;
                    viewer.pointsMoved = false;
                    viewer.render();
                }
            }
            requestAnimationFrame(animate);

        }
        animate();

    }

};

// Check if viewer is full screen or not
Racmacs.Viewer.prototype.isFullScreen = function() {
    return(
        this.container.offsetHeight == window.innerHeight &&
        this.container.offsetWidth == window.innerWidth
    );
}

// Reset the scroll focus function
Racmacs.Viewer.prototype.scrollFocus = function() {  
    return this.isFullScreen() || this.viewport.holder.matches(':focus');
};

// Update the viewport frustrum
Racmacs.Viewer.prototype.updateFrustrum = function() {

    if (this.camera && this.camera.frustrum && this.mapdims && this.mapdims.dimensions) {

        var pvec = new THREE.Vector3();
        var frustrum = this.camera.frustrum();
        var frustrum_height = frustrum.top - frustrum.bottom;
        var matworld = this.scene.plotPoints.matrixWorld;
        var inverse_matworld = this.scene.plotPoints.matrixWorld.clone().invert();
        
        if (this.points) {
            this.points.map(p => {

                if (p.element && p.element.radius) {

                    var radius = p.element.radius() - 0.01;
                    pvec.fromArray(p.coords3)
                    .applyMatrix4(matworld)
                    .project(this.camera.camera);

                    if (pvec.x + radius < -1) {

                        pvec.x = -1;
                        if (pvec.y > 1) {
                            // Top left
                            pvec.y = 1;
                            pvec.unproject(this.camera.camera).applyMatrix4(inverse_matworld);
                            p.element.setCoords(pvec.x, pvec.y, pvec.z);
                            p.element.setShape(5);
                            p.element.setRotation(0.785);
                        } else if (pvec.y < -1) {
                            // Bottom left
                            pvec.y = -1;
                            pvec.unproject(this.camera.camera).applyMatrix4(inverse_matworld);
                            p.element.setCoords(pvec.x, pvec.y, pvec.z);
                            p.element.setShape(5);
                            p.element.setRotation(2.356);
                        } else {
                            // Left
                            pvec.unproject(this.camera.camera).applyMatrix4(inverse_matworld);
                            p.element.setCoords(pvec.x, pvec.y, pvec.z);
                            p.element.setShape(5);
                            p.element.setRotation(1.57);
                        }

                    } else if (pvec.x - radius > 1) {
                        
                        pvec.x = 1;
                        if (pvec.y > 1) {
                            // Top right
                            pvec.y = 1;
                            pvec.unproject(this.camera.camera).applyMatrix4(inverse_matworld);
                            p.element.setCoords(pvec.x, pvec.y, pvec.z);
                            p.element.setShape(5);
                            p.element.setRotation(-0.785);
                        } else if (pvec.y < -1) {
                            // Bottom right
                            pvec.y = -1;
                            pvec.unproject(this.camera.camera).applyMatrix4(inverse_matworld);
                            p.element.setCoords(pvec.x, pvec.y, pvec.z);
                            p.element.setShape(5);
                            p.element.setRotation(-2.356);
                        } else {
                            // Right
                            pvec.unproject(this.camera.camera).applyMatrix4(inverse_matworld);
                            p.element.setCoords(pvec.x, pvec.y, pvec.z);
                            p.element.setShape(5);
                            p.element.setRotation(-1.57);
                        }

                    } else if (pvec.y - radius > 1) {
                        // Top
                        pvec.y = 1;
                        pvec.unproject(this.camera.camera).applyMatrix4(inverse_matworld);
                        p.element.setCoords(pvec.x, pvec.y, pvec.z);
                        p.element.setShape(5);
                        p.element.setRotation(0);
                    } else if (pvec.y + radius < -1) {
                        // Bottom
                        pvec.y = -1;
                        pvec.unproject(this.camera.camera).applyMatrix4(inverse_matworld);
                        p.element.setCoords(pvec.x, pvec.y, pvec.z);
                        p.element.setShape(5);
                        p.element.setRotation(-3.14);
                    } else {
                        
                        // Restore coords
                        p.element.setCoords(p.coords3[0], p.coords3[1], p.coords3[2]);

                        // Restore shape
                        switch(p.shape) {
                          case "CIRCLE":
                            p.element.setShape(0);
                            break;
                          case "BOX":
                            p.element.setShape(1);
                            break;
                          case "TRIANGLE":
                            p.element.setShape(2);
                            break;
                          case "EGG":
                            p.element.setShape(3);
                            break;
                          case "UGLYEGG":
                            p.element.setShape(4);
                            break;
                          default:
                            p.element.setShape(0);
                        };

                        // Restore rotation
                        p.element.setRotation(0);

                    }
                }
            });
        }

    }
}

