
R3JS.element.constructors.triangles = function(
    plotobj,
    plotdims
    ){

    // Make the object
    console.log(plotobj);
    var element = new R3JS.element.Triangles({
        vertices   : plotobj.vertices,
        properties : plotobj.properties
    });
    
    // Return the object
    return(element);

}

// Sphere object
R3JS.element.Triangles = class Triangles extends R3JS.element.base {

    // Object constructor
    constructor(args){

        // Set defaults
        if(args.properties === undefined)         args.properties           = {};
        if(args.properties.color === undefined)   args.properties.color     = {r:0,g:0,b:0,a:1};
        if(args.properties.opacity !== undefined) args.properties.color.a   = args.properties.opacity;

        super();

        // Make geometry
        var geometry = new THREE.Geometry();

        // Add vertices
        for(var i=0; i<args.vertices.length; i++){

            geometry.vertices.push(
                new THREE.Vector3(
                    args.vertices[i][0],// - object.position.x,
                    args.vertices[i][1],// - object.position.y,
                    args.vertices[i][2],// - object.position.z
                )
            );

            geometry.faces.push(
                new THREE.Face3( 
                    i*3, 
                    i*3 + 1, 
                    i*3 + 2
                )
            );

        }

        // Convert to buffer geometry
        var geometry = new THREE.BufferGeometry().fromGeometry( geometry );
        geometry.computeFaceNormals();
        geometry.computeVertexNormals();

        // Set fill material
        var material = R3JS.Material(args.properties);

        // Make fill object
        this.object = new THREE.Mesh(geometry, material);

    }

}

