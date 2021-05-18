

// GL line constructor
R3JS.element.constructors.text = function(
    plotobj,
    viewer
    ){


    // Apply any additional offset
    var plotdims = viewer.scene.plotdims;
    if(plotobj.properties.poffset){
        plotobj.position[0] = plotobj.position[0] + plotobj.properties.poffset[0]*plotdims.size[0]/plotdims.aspect[0];
        plotobj.position[1] = plotobj.position[1] + plotobj.properties.poffset[1]*plotdims.size[1]/plotdims.aspect[1];
        plotobj.position[2] = plotobj.position[2] + plotobj.properties.poffset[2]*plotdims.size[2]/plotdims.aspect[2];
    }

    // Create the object
    if(plotobj.rendering == "geometry"){
        
        var element = new R3JS.element.text({
            text   : plotobj.text[0],
            coords : plotobj.position,
            alignment : plotobj.alignment,
            offset     : plotobj.offset,
            properties : R3JS.Material(plotobj.properties)
        });
    
    } else {

        var element = new R3JS.element.htmltext({
            text   : plotobj.text,
            coords : plotobj.position,
            alignment : plotobj.alignment,
            offset     : plotobj.offset,
            properties : R3JS.Material(plotobj.properties)
        });

    }
    
    return(element);

}


// Make some html text
R3JS.element.htmltext = class htmltext extends R3JS.element.base {

    constructor(args){

        super();

    	// Set defaults
    	if(!args.style)      args.style      = [];
    	if(!args.alignment)  args.alignment  = [0, 0];
    	if(!args.offset)     args.offset     = [0, 0];
    	if(!args.properties) args.properties = {};

    	// Create text div
	    var textdiv = document.createElement( 'div' );
	    
	    // Define color as hex
	    if(args.properties.color){
	        textdiv.style.color = 'rgb('
	        +args.properties.color.r+','
	        +args.properties.color.g+','
	        +args.properties.color.b
	        +")";
	    } else {
	        textdiv.style.color = 'inherit';
	    }
	    
	    // Set other styles and content
	    textdiv.style.fontSize = args.size*100+"%";
	    textdiv.textContent    = args.text;
	    R3JS.apply_style(textdiv, args.style);

        // Add a non-selectable class
        textdiv.classList.add("not-selectable");
	    
	    // Create CSS text object
	    this.object = new THREE.CSS2DObject( textdiv );

	    // Set text object alignment
	    this.object.alignment = {
	        x: -50 + 50*args.alignment[0],
	        y: -50 - 50*args.alignment[1]
	    };

	    // Set text offset
	    textdiv.style.marginLeft = args.offset[0]+"px";
	    textdiv.style.marginTop  = args.offset[1]+"px";

	    // Set text object position
	    this.object.position.set(
	        args.coords[0],
	        args.coords[1],
	        args.coords[2]
	    );

    }

    show(){ this.object.element.hidden = false }
    hide(){ this.object.element.hidden = true  }
    setColor(color){
        if(color != "inherit") color = "#" + new THREE.Color(color).getHexString();
        this.object.element.style.color = color;
    }
    setStyle(property, value){
        this.object.element.style.setProperty(property, value);
    }
    setCoords(coords){
        this.object.position.fromArray(coords);
    }

}


// Make geometric text
R3JS.element.text = class htmltext extends R3JS.element.base {

    constructor(args){

        super();

        // Set defaults
        if(!args.alignment)  args.alignment  = [0, 0];
        if(!args.offset)     args.offset     = [0, 0];
        if(!args.properties) args.properties = {};

        // Adjust alignment
        args.alignment[0] = -args.alignment[0]/2 + 0.5;
        args.alignment[1] = -args.alignment[1]/2 + 0.5;

        // function make_text(string, pos, size, alignment, offset, color){

        var shapes    = R3JS.fonts.helvetiker.generateShapes( args.text, 1, 4 );
        var geometry  = new THREE.ShapeGeometry( shapes );
        var textShape = new THREE.BufferGeometry();
        textShape.fromGeometry( geometry );

        var color = new THREE.Color(
                args.properties.color.r, 
                args.properties.color.g, 
                args.properties.color.b
        );
        
        var matLite = new THREE.MeshBasicMaterial( {
            color: color,
            side: THREE.DoubleSide
        });
        matLite.opacity = args.properties.opacity;

        // Align text
        textShape.computeBoundingBox();
        var xMid = - 0.5 * ( textShape.boundingBox.max.x - textShape.boundingBox.min.x );
        var yMid = - 0.5 * ( textShape.boundingBox.max.y - textShape.boundingBox.min.y );
        textShape.translate( xMid*2*args.alignment[0], yMid*2*args.alignment[1], 0 );

        // Offset text
        if(args.offset){
            textShape.translate( args.offset[0], args.offset[1], 0 );
        }

        var text = new THREE.Mesh( textShape, matLite );
        text.position.set(args.coords[0], args.coords[1], args.coords[2]);

        this.object = text;
        text.element = this;

    }

}

