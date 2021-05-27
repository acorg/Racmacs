
// Polygon constructor
R3JS.element.constructors.polygon = function(
    plotobj,
    plotdims
    ){

    // Make the object
    var element = new R3JS.element.polygon2D({
    	coords     : plotobj.position,
        properties : plotobj.properties
    });
    
    // Return the object
    return(element);

}

// Sphere object
R3JS.element.Polygon2d = class Polygon2d extends R3JS.element.base {

    // Object constructor
    constructor(args){

    	super();

        // Set defaults
        if(args.properties === undefined)              args.properties              = {};
        if(args.properties.fillcolor === undefined)    args.properties.fillcolor    = {r:0,g:0,b:0,a:0};
        if(args.properties.outlinecolor === undefined) {
            args.properties.outlinecolor = {
                r:Array(args.coords.length).fill(0),
                g:Array(args.coords.length).fill(0),
                b:Array(args.coords.length).fill(0),
                a:Array(args.coords.length).fill(1)
            };
        }
        if(args.properties.mat === undefined)          args.properties.mat = "basic";
        if(args.properties.transparent === undefined)  args.properties.transparent = true;

    	// Work out geometry for fill
        var shape = new THREE.Shape();
        shape.moveTo( args.coords[0][0], args.coords[0][1] );
	    for(var i=0; i<args.coords.length; i++){
	        shape.lineTo(args.coords[i][0], args.coords[i][1]);
	    }
            
        var shapegeo = new THREE.ShapeGeometry( shape );
        var fillgeometry = new THREE.BufferGeometry().fromGeometry( shapegeo );

        // Set fill material
        args.properties.color   = args.properties.fillcolor;
        args.properties.opacity = args.properties.fillcolor.a;
        var fillmaterial = R3JS.Material(args.properties);

        // Make fill object
        this.fill = new THREE.Mesh(fillgeometry, fillmaterial);

        // Make outline object
        args.properties.color    = args.properties.outlinecolor;
        args.properties.opacity  = args.properties.outlinecolor.a[0];
        args.properties.mat      = "line";
        args.properties.lwd      = 1;
        args.properties.segments = true;

        // Get segmented line coordinates
        var linecoords = [];
        for(var i=0; i<args.coords.length-1; i++){
        	linecoords.push(args.coords[i]);
        	linecoords.push(args.coords[i+1]);
        }
        linecoords.push(args.coords[args.coords.length-1], args.coords[0]);
        var outline = new R3JS.element.gllines_thin({
            coords     : linecoords,
            properties : args.properties,
            // viewport   : args.viewport
        });

        // Assign outline
        this.outline = outline.object;

        // Assign object
        this.object = new THREE.Object3D();
        this.object.add(this.fill);
        this.object.add(this.outline);
        this.fill.element = this;

    }
    
    setOutlineColor(color){
      this.outline.material.color.set(color);
    }

    setFillColor(color){
      this.fill.material.color.set(color);
    }

    setFillOpacity(opacity){
      this.fill.material.opacity = opacity;
    }

    setOutlineOpacity(opacity){
      this.outline.material.opacity = opacity; 
    }

    raycast(ray, intersected){
      this.fill.raycast(ray,intersected);
    }

    mergeGeometry(element){
      this.fill.geometry    = THREE.BufferGeometryUtils.mergeBufferGeometries([this.fill.geometry, element.fill.geometry]);
      this.outline.geometry = THREE.BufferGeometryUtils.mergeBufferGeometries([this.outline.geometry, element.outline.geometry]);
    }

    setSize(){
    }

}


// Sphere constructor
R3JS.element.constructors.polygon3d = function(
    plotobj,
    viewer
    ){

    // Make the object
    var element = new R3JS.element.Polygon3d({
        vertices   : plotobj.vertices,
        faces      : plotobj.faces,
        normals    : plotobj.normals,
        properties : plotobj.properties,
        aspect     : viewer.scene.plotdims.aspect
    });
    
    // Return the object
    return(element);

}


// Sphere object
R3JS.element.Polygon3d = class Polygon3d extends R3JS.element.base {

    // Object constructor
    constructor(args){

        super();

        // Set defaults
        args.properties = R3JS.DefaultProperties(args.properties, args.vertices.length);

        // Set variables
        var color    = new Float32Array( args.faces.length * 9 );
        var normal   = new Float32Array( args.faces.length * 9 );
        var position = new Float32Array( args.faces.length * 9 );

        // Set vertices
        for(var i=0; i<args.faces.length; i++){

            position[i*9]   = args.vertices[args.faces[i][0]][0];
            position[i*9+1] = args.vertices[args.faces[i][0]][1];
            position[i*9+2] = args.vertices[args.faces[i][0]][2];

            position[i*9+3] = args.vertices[args.faces[i][1]][0];
            position[i*9+4] = args.vertices[args.faces[i][1]][1];
            position[i*9+5] = args.vertices[args.faces[i][1]][2];

            position[i*9+6] = args.vertices[args.faces[i][2]][0];
            position[i*9+7] = args.vertices[args.faces[i][2]][1];
            position[i*9+8] = args.vertices[args.faces[i][2]][2];

        }

        // Set normals
        if(args.normals !== undefined){
            for(var i=0; i<args.faces.length; i++){

                normal[i*9]   = args.normals[args.faces[i][0]][0];
                normal[i*9+1] = args.normals[args.faces[i][0]][1];
                normal[i*9+2] = args.normals[args.faces[i][0]][2];

                normal[i*9+3] = args.normals[args.faces[i][1]][0];
                normal[i*9+4] = args.normals[args.faces[i][1]][1];
                normal[i*9+5] = args.normals[args.faces[i][1]][2];

                normal[i*9+6] = args.normals[args.faces[i][2]][0];
                normal[i*9+7] = args.normals[args.faces[i][2]][1];
                normal[i*9+8] = args.normals[args.faces[i][2]][2];

            }
        }

        // Set vertex colors
        for(var i=0; i<args.faces.length; i++){

            color[i*9]   = args.properties.color.r[args.faces[i][0]];
            color[i*9+1] = args.properties.color.g[args.faces[i][0]];
            color[i*9+2] = args.properties.color.b[args.faces[i][0]];

            color[i*9+3] = args.properties.color.r[args.faces[i][1]];
            color[i*9+4] = args.properties.color.g[args.faces[i][1]];
            color[i*9+5] = args.properties.color.b[args.faces[i][1]];

            color[i*9+6] = args.properties.color.r[args.faces[i][2]];
            color[i*9+7] = args.properties.color.g[args.faces[i][2]];
            color[i*9+8] = args.properties.color.b[args.faces[i][2]];

        }

        // Set fill geometry
        var fillgeometry = new THREE.BufferGeometry();
        fillgeometry.setAttribute( 'position', new THREE.BufferAttribute( position, 3 ) );
        fillgeometry.setAttribute( 'normal',   new THREE.BufferAttribute( normal,   3 ) );
        fillgeometry.setAttribute( 'color',    new THREE.BufferAttribute( color,    3 ) );

        // Set fill material
        var fillmaterial = R3JS.Material(args.properties);
        fillmaterial.vertexColors = THREE.VertexColors;
        fillmaterial.color = new THREE.Color();

        // Make fill object
        this.fill = new THREE.Mesh(fillgeometry, fillmaterial);

        // Make outline object
        if(args.outline){

            var outlinegeometry = new THREE.EdgesGeometry( fillgeometry );  
            
            // Set outline material
            args.properties.color    = args.properties.outlinecolor;
            args.properties.mat      = "line";
            args.properties.lwd      = 1;
            // args.properties.segments = true;

            var outlinematerial = R3JS.Material(args.properties);
            this.outline = new THREE.LineSegments(outlinegeometry, outlinematerial);

        } else {

            var outlinegeometry = new THREE.BufferGeometry();
            this.outline = new THREE.Mesh(outlinegeometry);

        }

        // Assign object
        this.object = new THREE.Object3D();
        this.object.add(this.fill);
        this.object.add(this.outline);
        this.fill.element = this;

    }

    setFillColor(color){
        this.fill.material.color.set(color);
    }

    setFillOpacity(opacity){
        this.fill.material.opacity = opacity;
    }

    setOutlineColor(color){
        this.outline.material.color.set(color);
    }

    setOutlineOpacity(opacity){
        this.outline.material.opacity = opacity;
    }

    raycast(ray, intersected){
        this.fill.raycast(ray,intersected);
    }

    setSize(){
    }

    breakupMesh(){
        this.object.remove(this.fill);
        this.fill = R3JS.utils.breakupMesh(this.fill);
        this.object.add(this.fill);
    }

}



