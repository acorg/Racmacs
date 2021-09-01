
// Surface constructor
R3JS.element.constructors.surface = function(
    plotobj,
    plotdims
    ){

    // Make the object
    var element = new R3JS.element.surface({
    	x : plotobj.x,
        y : plotobj.y,
        z : plotobj.z,
        properties : plotobj.properties
    });
    
    // Return the object
    return(element);

}


// Sphere object
R3JS.element.surface = class Surface extends R3JS.element.base {

    // Object constructor
    constructor(args){

        super();

        // Calculate number of vertices
        var nx = args.x.length;
        var ny = args.x[0].length;
        var nverts = nx*ny;
        var positions = new Float32Array( nverts * 3 );
        var colors    = new Float32Array( nverts * 3 );

        // Set defaults
        // args.properties = R3JS.DefaultProperties(args.properties, nx*ny);

        // Set object geometry
        var material = R3JS.Material(args.properties);

        var rcol = args.properties.color.r;
        var gcol = args.properties.color.g;
        var bcol = args.properties.color.b;

        // Cycle through and set positions and colors
        var i=0;
        for (var x=0; x<nx; x++) {
            for (var y=0; y<ny; y++) {
                positions[i*3 + 0] = args.x[x][y];
                positions[i*3 + 1] = args.y[x][y];
                positions[i*3 + 2] = args.z[x][y];
                colors[i*3 + 0] = rcol[x][y];
                colors[i*3 + 1] = gcol[x][y];
                colors[i*3 + 2] = bcol[x][y];
                args.x[x][y] = i;
                i++;
            }
        }

        var indices = [];
        for (var x=0; x<(nx - 1); x++) {
            for (var y=0; y<(ny - 1); y++) {

                indices.push(
                    args.x[x][y],
                    args.x[x+1][y],
                    args.x[x][y+1]
                );

                indices.push(
                    args.x[x][y+1],
                    args.x[x+1][y],
                    args.x[x+1][y+1]
                );

            }
        }

        // Create buffer geometry
        var geometry = new THREE.BufferGeometry();
        geometry.setIndex( indices );
        geometry.setAttribute( 'position', new THREE.BufferAttribute( positions, 3 ));
        geometry.setAttribute( 'color',    new THREE.BufferAttribute( colors,    3 ));
        geometry.computeVertexNormals();

        material.vertexColors = THREE.VertexColors;
        material.color = new THREE.Color();

        // Make object
        var object = new THREE.Mesh(geometry, material);
        this.object = object;
        this.object.element = this;

    }

}





