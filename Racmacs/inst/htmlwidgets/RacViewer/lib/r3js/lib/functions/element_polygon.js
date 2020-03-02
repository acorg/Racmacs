
// Sphere constructor
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


// Sphere object
R3JS.element.Polygon3d = class Polygon3d extends R3JS.element.base {

    // Object constructor
    constructor(args){

        super();

        // Make geometry
        var geometry = new THREE.Geometry();

        // Add vertices
        for(var i=0; i<args.vertices.length; i++){
            geometry.vertices.push(
                new THREE.Vector3(
                    args.vertices[i][0],// - object.position.x,
                    args.vertices[i][1],// - object.position.y,
                    args.vertices[i][2]// - object.position.z
                )
            );
        }

        // Add faces
        for(var i=0; i<args.faces.length; i++){
            geometry.faces.push(
                new THREE.Face3( 
                    args.faces[i][2]-1, 
                    args.faces[i][1]-1, 
                    args.faces[i][0]-1
                )
            );
        }

        // Merge vertices and compute normals
        geometry.mergeVertices();
        geometry.computeVertexNormals();
        geometry.computeFaceNormals();

        // Convert to buffer geometry
        var fillgeometry = new THREE.BufferGeometry().fromGeometry( geometry );

        // Set fill material
        args.properties.color   = args.properties.fillcolor;
        args.properties.opacity = args.properties.fillcolor.a;
        var fillmaterial = R3JS.Material(args.properties);

        // Make fill object
        this.fill = new THREE.Mesh(fillgeometry, fillmaterial);

        // Set outline material
        args.properties.color    = args.properties.outlinecolor;
        args.properties.mat      = "line";
        args.properties.lwd      = 1;
        // args.properties.segments = true;
        var outlinematerial = R3JS.Material(args.properties);

        // Make outline object
        if(args.outline){
            var outlinegeometry = new THREE.EdgesGeometry( fillgeometry );  
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

}

//     function convertBlob2D(object, blob){

//         var fill    = object.children[0];
//         var outline = object.children[1];

//         // Work out geometry
//         for(var i=0; i<blob.length; i++){
//             var blobShape = new THREE.Shape();
//             blobShape.moveTo( blob[i].x[0]-object.position.x, blob[i].y[0]-object.position.y );
//             for(var j=0; j<blob[i].x.length; j++){
//                 blobShape.lineTo(blob[i].x[j]-object.position.x, blob[i].y[j]-object.position.y);
//             }
            
//             var blobshapegeo = new THREE.ShapeGeometry( blobShape );
//             var blobgeo      = new THREE.BufferGeometry().fromGeometry( blobshapegeo );
//         }
        
//         var bloboutlinegeo = convert2Outline(blobshapegeo.vertices, 0.1);
//         bloboutlinegeo     = new THREE.BufferGeometry().fromGeometry( bloboutlinegeo );

//         object.rotation.z = 0;

//         fill.geometry    = blobgeo;
//         outline.geometry = bloboutlinegeo;

//     }



