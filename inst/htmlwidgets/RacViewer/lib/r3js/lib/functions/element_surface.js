
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

        // Set default properties
        if(!args.properties){
            args.properties = {
                mat : "phong",
                color : [0,1,0]
            };
        }

        var nrow = args.x.length;
        var ncol = args.x[0].length;

        // Set object geometry
        var geo = new THREE.PlaneGeometry(5, 5, ncol-1, nrow-1);
        var material = R3JS.Material(args.properties);

        // Color surface by vertices if more than one color supplied
        var surface_cols = args.properties.color;
        if(surface_cols.r.length > 1){
            for(var i=0; i<geo.faces.length; i++){
                geo.faces[i].vertexColors[0] = new THREE.Color(
                    surface_cols.r[geo.faces[i].a],
                    surface_cols.g[geo.faces[i].a],
                    surface_cols.b[geo.faces[i].a]
                );
                geo.faces[i].vertexColors[1] = new THREE.Color(
                    surface_cols.r[geo.faces[i].b],
                    surface_cols.g[geo.faces[i].b],
                    surface_cols.b[geo.faces[i].b]
                );
                geo.faces[i].vertexColors[2] = new THREE.Color(
                    surface_cols.r[geo.faces[i].c],
                    surface_cols.g[geo.faces[i].c],
                    surface_cols.b[geo.faces[i].c]
                );
            }
            material.vertexColors = THREE.VertexColors;
            material.color = new THREE.Color();
        }


        // Set vertices
        var n = 0;
        var nas = [];
        for(var i=args.x.length - 1; i >= 0; i--){
            for(var j=0; j<args.x[0].length; j++){
                if(!isNaN(args.z[i][j])){
                    var coords = [args.x[i][j], args.y[i][j], args.z[i][j]];
                    geo.vertices[n].set(
                        coords[0],
                        coords[1],
                        coords[2]
                    )
                } else {
                    geo.vertices[n].set(
                        null,
                        null,
                        null
                    );
                    nas.push(n);
                };
                n++;
            }
        }

        // Remove faces with nas
        var i=0
        while(i<geo.faces.length){
            var face = geo.faces[i];
            if(nas.indexOf(face.a) != -1 || 
               nas.indexOf(face.b) != -1 || 
               nas.indexOf(face.c) != -1){
                geo.faces.splice(i,1);
            } else {
                i++;
            }
        }

        // Calculate normals
        geo.computeVertexNormals();

        // Make object
        var object = new THREE.Mesh(geo, material);
        this.object = object;
        this.object.element = this;

    }

}





