

// Standard camera class
R3JS.Camera = class Camera {

	constructor(viewer){
		this.min_zoom     = 0.1;
		this.max_zoom     = 4;
		this.default_zoom = 2;
		this.viewer       = viewer;
	}

	// Set the zoom
	setZoom(zoom){
		var start_zoom = this.getZoom();
		this.setCameraZoom(zoom);
		var end_zoom = this.getZoom();
		this.viewer.dispatchEvent(
			"zoom",
			{ start_zoom : start_zoom, end_zoom : end_zoom }
		);
	}
	getZoom(){
		return(this.getCameraZoom());
	}

	// Reset the zoom
	resetZoom(){
		this.setZoom(this.default_zoom);
	}

	// Zooming the camera
	zoom(zoom){

		zoom = Math.pow(zoom, this.zoom_adjuster);
		var start_zoom = this.getZoom();
		var min_zoom = this.min_zoom;
		var max_zoom = this.max_zoom;

		if(start_zoom*zoom <= max_zoom 
			&& start_zoom*zoom >= min_zoom){
		    this.setZoom(start_zoom*zoom);
		} else if(start_zoom*zoom < min_zoom){
			this.setZoom(min_zoom);
		} else {
			this.setZoom(max_zoom);
		}

	}

	// Set the camera size
	setSize(width, height){

		this.aspect = width / height;
		this.camera.aspect = width / height;
		this.camera.updateProjectionMatrix();
		this.setZoom(this.getZoom());

	}

	// Initiate the camera in a viewer
	initiateInViewer(viewer){

		this.setSize(
			viewer.viewport.getWidth(), 
			viewer.viewport.getHeight()
		);

	}

	// Reset the default zoom
	setDefaultZoom(){
		this.default_zoom = this.getZoom();
	}

}


// Standard perspective camera for 3D
R3JS.PerspCamera = class PerspCamera extends R3JS.Camera {

	// Constructor function
	constructor(viewer){
		
		super(viewer);
		this.camera = new THREE.PerspectiveCamera( 45, 1, 0.1, 10000 );
		this.zoom_adjuster  = 1;

	}

	// Get the zoom
	getCameraZoom(){

		return(this.camera.position.z);

	}

	// Set the zoom
	setCameraZoom(zoom){

		this.camera.position.z = zoom;
		this.camera.updateProjectionMatrix();

	}

	zoomToLims(lims){

		let cam_z = this.camera.position.z;
		let a = this.camera.fov;
		let bsphere = new THREE.Sphere().setFromPoints(
			[
				new THREE.Vector3(lims.x[0], lims.y[0], lims.z[1]),
				new THREE.Vector3(lims.x[0], lims.y[1], lims.z[1]),
				new THREE.Vector3(lims.x[1], lims.y[0], lims.z[1]),
				new THREE.Vector3(lims.x[1], lims.y[1], lims.z[1]),
			],
			new THREE.Vector3(0,0,0)
		);
		let s = bsphere.radius*2;
		let d = (s/2) / Math.tan(a/2)
		this.setZoom(d);
		
	}

}


// Orthographic camera for 2D
R3JS.OrthoCamera = class OrthoCamera extends R3JS.Camera {

	// Constructor function
	constructor(viewer){

		super(viewer);
		
		this.camera = new THREE.OrthographicCamera();
        this.camera.near = -100;
        this.camera.far  = 100;
		this.zoom_adjuster  = 1;

	}

	// Get the zoom
	getCameraZoom(){

		return(this.distance);

	}

	// Set the zoom
	setCameraZoom(zoom){

		this.distance      = zoom;
		this.camera.left   = -this.distance*this.aspect/2;
		this.camera.right  = this.distance*this.aspect/2;
		this.camera.top    = this.distance/2;
		this.camera.bottom = -this.distance/2;
		this.camera.updateProjectionMatrix();

	}

	// Get frustrum
	frustrum(){
		return({
			left:   this.camera.left,
			right:  this.camera.right,
			top:    this.camera.top,
			bottom: this.camera.bottom,
		})
	}

	zoomToLims(lims){

		var frustrum = this.frustrum();
        var frustrum_xrange = frustrum.right - frustrum.left;
        var frustrum_yrange = frustrum.top - frustrum.bottom;

        var xrange = lims.x[1] - lims.x[0];
        var yrange = lims.y[1] - lims.y[0];
        
        var zoom = this.getZoom();
        var zoom_factor_x = (xrange)/frustrum_xrange;
        var zoom_factor_y = (yrange)/frustrum_yrange;
        var zoom_factor = Math.max(zoom_factor_x, zoom_factor_y);
        
        this.setZoom(zoom*zoom_factor);

	}

}

