
// Make a light source
R3JS.element.Light = class Light extends R3JS.element.base {

    constructor(args = {}){

        super();

        // Set defaults
        if(!args.intensity) args.intensity = 1.0;
        if(!args.color) {
            args.color = 0xe0e0e0;
        } else {
            args.color = new THREE.Color(args.color.r[0], args.color.g[0], args.color.b[0]);
        }

        if(args.lighttype == "directional"){
        	var object = new THREE.DirectionalLight(args.color);
	        object.position.set(
	        	args.position[0],
	        	args.position[1],
	        	args.position[2]
	        ).normalize();
        } else if(args.lighttype == "point") {
            var object = new THREE.PointLight(args.color);
            object.position.set(
                args.position[0],
                args.position[1],
                args.position[2]
            );
        } else {
        	var object = new THREE.AmbientLight(args.color);
        }

        // Set light intensity
	    object.intensity = args.intensity;

        this.object = object;
        object.element = this;

    }

}
