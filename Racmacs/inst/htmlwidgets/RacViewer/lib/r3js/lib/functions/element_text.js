

// GL line constructor
R3JS.element.constructors.text = function(
    plotobj,
    scene
    ){


    // Apply any additional offset
    var plotdims = scene.plotdims;
    if(plotobj.properties.poffset){
        plotobj.position[0] = plotobj.position[0] + plotobj.properties.poffset[0]*plotdims.size[0]/plotdims.aspect[0];
        plotobj.position[1] = plotobj.position[1] + plotobj.properties.poffset[1]*plotdims.size[1]/plotdims.aspect[1];
        plotobj.position[2] = plotobj.position[2] + plotobj.properties.poffset[2]*plotdims.size[2]/plotdims.aspect[2];
    }

    // Create the object
    var element = new R3JS.element.htmltext({
    	text   : plotobj.text,
        coords : plotobj.position,
        alignment : plotobj.alignment,
        offest     : plotobj.offset,
        properties : R3JS.Material(plotobj.properties)
    });
    
    return(element);

}


// Make a thin line object
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

}


// function make_textobject(object){

//     if(object.normalise){
//         object.position = normalise_coords(object.position,
//                                            object.lims,
//                                            object.aspect);
//     }
//     if(object.properties.poffset){
//         object.position[0] = object.position[0] + object.properties.poffset[0];
//         object.position[1] = object.position[1] + object.properties.poffset[1];
//         object.position[2] = object.position[2] + object.properties.poffset[2];
//     }
    
//     if(object.rendering == "geometry"){
//         object.alignment[0] = -object.alignment[0]/2 + 0.5;
//         object.alignment[1] = -object.alignment[1]/2 + 0.5;
        
//         if(object.normalise){
//             object.offset[0] = object.offset[0]*0.025;
//             object.offset[1] = object.offset[1]*0.025;
//             object.size = object.size*0.025
//         }
//         var textobject = make_text(object.text,
//                                    object.position,
//                                    object.size,
//                                    object.alignment,
//                                    object.offset,
//                                    object.properties.color);
//         object.scene.labels.push(textobject);
//     }
//     if(object.rendering == "html"){
//         var textobject = make_htmltext(object);
//     }
//     return(textobject);

// }

// function make_htmltext(object){


//     // Create text div
//     var textdiv     = document.createElement( 'div' );
    
//     // Define color as hex
//     if(object.properties.color.red){
//         var color = new THREE.Color(
//                 object.properties.color.red, 
//                 object.properties.color.green, 
//                 object.properties.color.blue
//         );
//         textdiv.style.color = '#'+color.getHexString();
//     } else {
//         textdiv.style.color = 'inherit';
//     }
    
//     // Set other styles and content
//     textdiv.style.fontSize = object.size*100+"%";
//     textdiv.textContent = object.text;
//     apply_style(textdiv, object.style);
    
//     // Create CSS text object
//     var textobject = new THREE.CSS2DObject( textdiv );

//     // Set text object alignment
//     textobject.alignment = {
//         x: -50 + 50*object.alignment[0],
//         y: -50 - 50*object.alignment[1]
//     };

//     // Set text offset
//     textdiv.style.marginLeft = object.offset[0]+"px";
//     textdiv.style.marginTop  = object.offset[1]+"px";

//     // Set text object position
//     textobject.position.set(
//         object.position[0],
//         object.position[1],
//         object.position[2]
//     );

//     return(textobject);

// }

// function make_text(string, pos, size, alignment, offset, color){

//     var shapes    = font.generateShapes( string, size, 4 );
//     var geometry  = new THREE.ShapeGeometry( shapes );
//     var textShape = new THREE.BufferGeometry();
//     textShape.fromGeometry( geometry );

//     if(color && color.red){
//         color = new THREE.Color(
//             color.red, 
//             color.green, 
//             color.blue
//         );
//     } else {
//         color = new THREE.Color("#000000");
//     }
//     var matLite = new THREE.MeshBasicMaterial( {
//         color: color,
//         side: THREE.DoubleSide
//     } );

//     // Align text
//     textShape.computeBoundingBox();
//     xMid = - 0.5 * ( textShape.boundingBox.max.x - textShape.boundingBox.min.x );
//     yMid = - 0.5 * ( textShape.boundingBox.max.y - textShape.boundingBox.min.y );
//     textShape.translate( xMid*2*alignment[0], yMid*2*alignment[1], 0 );

//     // Offset text
//     if(offset){
//         textShape.translate( offset[0], offset[1], 0 );
//     }

//     var text = new THREE.Mesh( textShape, matLite )
//     text.position.set(pos[0], pos[1], pos[2])
//     return(text);

// }

