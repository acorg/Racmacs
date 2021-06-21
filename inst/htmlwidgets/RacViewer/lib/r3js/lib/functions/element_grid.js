
// Grid constructor
R3JS.element.constructors.grid = function(
    plotobj,
    scene
    ){

    // Make the object
    var element = new R3JS.element.grid({
    	x : plotobj.x,
        y : plotobj.y,
        z : plotobj.z,
        properties : plotobj.properties
    });
    
    // Return the object
    return(element);

}


// Sphere object
R3JS.element.grid = class Grid extends R3JS.element.base {

    // Object constructor
    constructor(args){

    	super();

        // Set default properties
        if(!args.properties){
            args.properties = {
                lwd : 1
            };
        }

	    var colors   = args.properties.color;
	    var material = R3JS.Material(args.properties);
	    
	    var vertex_cols = colors.r.length > 1;
	    if(vertex_cols){
	        material.color = new THREE.Color();
	        material.vertexColors = THREE.VertexColors;
	    }

	    var geo = new THREE.BufferGeometry();
	    for(var i=0; i<args.x.length; i++){
	        for(var j=0; j<args.x[0].length-1; j++){
	            if(!isNaN(args.z[i][j]) && 
	               !isNaN(args.z[i][j+1])){

	                var coords1 = [args.x[i][j], args.y[i][j], args.z[i][j]];
	                var coords2 = [args.x[i][j+1], args.y[i][j+1], args.z[i][j+1]];

	                geo.vertices.push(
	                    new THREE.Vector3(
	                        coords1[0],
	                        coords1[1],
	                        coords1[2]
	                    ),
	                    new THREE.Vector3(
	                        coords2[0],
	                        coords2[1],
	                        coords2[2]
	                    )
	                );

	                if(vertex_cols){
	                    var n1 = i*(args.x[0].length)+j;
	                    var n2 = i*(args.x[0].length)+(j+1);
	                    geo.colors.push(new THREE.Color(colors.r[n1],
	                                                    colors.g[n1],
	                                                    colors.b[n1]));
	                    geo.colors.push(new THREE.Color(colors.r[n2],
	                                                    colors.g[n2],
	                                                    colors.b[n2]));
	                }
	            }
	        }
	    }

	    for(var i=0; i<args.x[0].length; i++){
	        for(var j=0; j<args.x.length-1; j++){
	            if(!isNaN(args.z[j][i]) && 
	               !isNaN(args.z[j+1][i])){
	                var coords1 = [args.x[j][i], args.y[j][i], args.z[j][i]];
	                var coords2 = [args.x[j+1][i], args.y[j+1][i], args.z[j+1][i]];
	                geo.vertices.push(
	                    new THREE.Vector3(
	                        coords1[0],
	                        coords1[1],
	                        coords1[2]
	                    ),
	                    new THREE.Vector3(
	                        coords2[0],
	                        coords2[1],
	                        coords2[2]
	                    )
	                );
	                if(vertex_cols){
	                    var n1 = j*(args.x[0].length)+i;
	                    var n2 = (j+1)*(args.x[0].length)+i;
	                    geo.colors.push(new THREE.Color(colors.r[n1],
	                                                    colors.g[n1],
	                                                    colors.b[n1]));
	                    geo.colors.push(new THREE.Color(colors.r[n2],
	                                                    colors.g[n2],
	                                                    colors.b[n2]));
	                }
	            }
	        }
	    }

	    // Make the object
	    this.object = new THREE.LineSegments(geo, material, args.properties.lwd);
	    this.object.element = this;

	}

}








