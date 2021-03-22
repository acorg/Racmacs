
R3JS.element.constructors.triangles = function(
    plotobj,
    plotdims
    ){

    // Make the object
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

        // Add vertex colors
        for(var i=0; i<geometry.faces.length; i++){
            geometry.faces[i].vertexColors[0] = new THREE.Color(
                args.properties.color.r[i*3],
                args.properties.color.g[i*3],
                args.properties.color.b[i*3]
            );
            geometry.faces[i].vertexColors[1] = new THREE.Color(
                args.properties.color.r[i*3+1],
                args.properties.color.g[i*3+1],
                args.properties.color.b[i*3+1]
            );
            geometry.faces[i].vertexColors[2] = new THREE.Color(
                args.properties.color.r[i*3+2],
                args.properties.color.g[i*3+2],
                args.properties.color.b[i*3+2]
            );
        }

        // Convert to buffer geometry
        var geometry = new THREE.BufferGeometry().fromGeometry( geometry );
        geometry.computeFaceNormals();
        geometry.computeVertexNormals();

        // Set fill material
        var material = R3JS.Material(args.properties);
        material.vertexColors = THREE.VertexColors;
        material.color = new THREE.Color();

        // Make fill object
        this.object = new THREE.Mesh(geometry, material);

    }

}

