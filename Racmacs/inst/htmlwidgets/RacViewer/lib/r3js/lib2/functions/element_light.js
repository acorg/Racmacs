
// Make a light source
R3JS.element.Light = class Light extends R3JS.element.base {

    constructor(args = {}){

        super();

        // Set defaults
        if(!args.intensity) args.intensity = 1.0;

        if(args.position){
        	var object       = new THREE.DirectionalLight(0xe0e0e0);
	        object.position.set(
	        	args.position[0],
	        	args.position[1],
	        	args.position[2]
	        ).normalize();
	        object.intensity = args.intensity;
        } else {
        	var object = new THREE.AmbientLight(0xe0e0e0);
        	object.intensity = args.intensity;
        }

        this.object = object;
        object.element = this;

    }

}
