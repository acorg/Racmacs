
// 2D arrow constructor
R3JS.element.constructors.arrow2d = function(
    plotobj,
    scene
    ){

    // // Setup object
    // if(plotobj.properties.lwd > 1){
    //     var element = new R3JS.element.gllines_fat({
    //         coords : plotobj.position,
    //         properties : plotobj.properties,
    //         viewport : scene.viewer.viewport
    //     });
    // } else {
    //     var element = new R3JS.element.gllines_thin({
    //         coords : plotobj.position,
    //         properties : plotobj.properties
    //     });
    // }
    // return(element);
    throw("Arrow not made");

}


// Make a 2D arrow object
R3JS.element.arrow2d = class arrow2d extends R3JS.element.base {

    constructor(args){

    	super();
    	var geometry = R3JS.Geometries.line2d({
    		from : args.coords[0],
			to   : args.coords[1],
		    lwd  : args.properties.lwd,
		    arrow : {
				headlength : 0.5,
				headwidth  : 0.25
			}
    	});

    	var material = R3JS.Material(args.properties);

    	this.object = new THREE.Mesh(geometry, material);

    }

}




// 3D arrow constructor
R3JS.element.constructors.arrow3d = function(
    plotobj,
    scene
    ){

    // // Setup object
    // if(plotobj.properties.lwd > 1){
    //     var element = new R3JS.element.gllines_fat({
    //         coords : plotobj.position,
    //         properties : plotobj.properties,
    //         viewport : scene.viewer.viewport
    //     });
    // } else {
    //     var element = new R3JS.element.gllines_thin({
    //         coords : plotobj.position,
    //         properties : plotobj.properties
    //     });
    // }
    // return(element);
    throw("Arrow not made");

}


// Make a 2D arrow object
R3JS.element.arrow3d = class arrow3d extends R3JS.element.base {

    constructor(args){

        // Set defaults
        if(!args.properties)       args.properties = {};
        if(!args.properties.lwd)   args.properties.lwd = 0.1;
        if(!args.properties.mat)   args.properties.mat = "lambert";
        if(!args.properties.color) args.properties.color = {r:0.2, g:0.2, b:0.2};

        super();
        var geometry = R3JS.Geometries.line3d({
            from : args.coords[0],
            to   : args.coords[1],
            lwd  : args.properties.lwd,
            arrow : {
                headlength : 0.5,
                headwidth  : 0.25
            }
        });

        var material = R3JS.Material(args.properties);
        this.object = new THREE.Mesh(geometry, material);

    }

}


// Make a 2D arrow object
R3JS.element.arrows3d = class arrows3d {

    constructor(args){

        this.elements = [];
        this.object = new THREE.Object3D();

        for(var i=0; i<args.coords.length; i++){

            var arrowargs = Object.assign({}, args);
            arrowargs.coords = args.coords[i];
            var arrow = new R3JS.element.arrow3d(arrowargs);
            this.elements.push(arrow);
            this.object.add(arrow.object);

        }

    }

}


