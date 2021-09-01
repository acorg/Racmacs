
Racmacs.element = {};
Racmacs.element.Blob3d = class Blob3d extends R3JS.element.base {

    // Object constructor
    constructor(args){

    	super();
    	this.object = new THREE.Object3D();

    	// Create fill
    	var fillcolor = R3JS.utils.convertColor(args.fillcolor);
    	this.fill = new R3JS.element.Polygon3d({
            faces    : args.faces,
            vertices : args.vertices,
            normals  : args.normals,
            properties : {
                mat : "phong",
                transparent : true,
                color : {
                    r:fillcolor.r,
                    g:fillcolor.g,
                    b:fillcolor.b,
                    a:1
                }
            },
            viewport : args.viewport,
            wireframe : false
        });

    	// Create outline
    	var outlinecolor = R3JS.utils.convertColor(args.outlinecolor);
    	if (args.fillcolor == "transparent") {

	        this.fill.setOpacity(0);
    		this.outline = new R3JS.element.Polygon3d({
	            faces    : args.faces,
	            vertices : args.vertices,
	            normals  : args.normals,
	            properties : {
	                mat : "phong",
	                transparent : true,
	                color : {
	                    r:outlinecolor.r,
	                    g:outlinecolor.g,
	                    b:outlinecolor.b,
	                    a:0
	                }
	            },
	            viewport : args.viewport,
	            wireframe : true
	        });

    	} else {

    		var color = new THREE.Color(args.fillcolor);

    		this.outline = new R3JS.element.base();
    		this.outline.object = new THREE.Mesh(
    			new THREE.BufferGeometry()
    		);

	    }

	    // Link objects
        this.object.add(this.fill.object);
        this.object.add(this.outline.object);
        this.fill.object.element = this;
        this.outline.object.element = this;

    }

    setFillColor(color){
    	this.fill.setColor(color);
    }

    setOutlineColor(color){
    	this.outline.setColor(color);
    }

    setFillOpacity(opacity){
    	this.fill.setOpacity(opacity);
    }

    setOutlineOpacity(opacity){
    	this.outline.setOpacity(opacity);
    }

    raycast(ray, intersected){
        this.fill.raycast(ray,intersected);
    }

}

