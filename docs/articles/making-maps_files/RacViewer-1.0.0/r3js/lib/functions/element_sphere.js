
// Sphere constructor
R3JS.element.constructors.sphere = function(
    plotobj,
    plotdims
    ){

    // Make the object
    var element = new R3JS.element.sphere({
    	radius : plotobj.radius,
        coords : plotobj.position,
        properties : plotobj.properties
    });
    
    // Return the object
    return(element);

}


// Sphere object
R3JS.element.sphere = class Sphere extends R3JS.element.base {

    // Object constructor
    constructor(args){

        super();

        // Check arguments
        if(typeof(args.radius) === "undefined") {
            throw("Radius must be specified");
        }

        // Set default properties
        if(!args.properties){
            args.properties = {
                mat : "phong",
                color : [0,1,0]
            };
        }

        // Make geometry
        var geometry = new THREE.SphereBufferGeometry(args.radius, 32, 32);

        // Set material
        var material = R3JS.Material(args.properties);

        // Make object
        this.object  = new THREE.Mesh(geometry, material);
        this.object.element = this;
        
        // Set position
        this.object.position.set(
            args.coords[0],
            args.coords[1],
            args.coords[2]
        );

    }

}

