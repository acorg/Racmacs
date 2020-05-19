
// GL line constructor
R3JS.element.constructors.glarrow = function(
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
    throw("GL arrow not made");

}


// Make an arrow object
R3JS.element.glarrow = class GLArrow extends R3JS.element.base {

    constructor(args){

        super();
        var viewport = args.viewer.viewport;

        // Set defaults
        if(!args.size) args.size = 2;
        if(typeof(args.size) !== "object") args.size = Array(args.coords.length).fill(args.size);
        
        if(!args.properties)        args.properties        = {};
        if(!args.properties.color)  args.properties.color  = {r:0, g:0, b:0};
        if(!args.properties.aspect) args.properties.aspect = 0.35;
        if(!args.properties.lwd)    args.properties.lwd    = 2;


        // Make the line component
        var line_coords = [].concat(...args.coords);
        this.line = new R3JS.element.gllines_fat({
            coords     : line_coords,
            properties : { 
                lwd   : args.properties.lwd,
                color : args.properties.color,
                segments : true
            },
            viewer : args.viewer
        });

        // Set double headed properties
        if(args.doubleheaded){

            if(typeof(args.doubleheaded) !== "object") args.doubleheaded = Array(args.coords.length).fill(args.doubleheaded);
            var doubleheaded = new Float32Array( line_coords.length*8 );
            for(var i=0; i<args.doubleheaded.length; i++){
                doubleheaded[i]   = Number(args.doubleheaded[i]);
                doubleheaded[i+1] = Number(args.doubleheaded[i]);
                doubleheaded[i+2] = Number(args.doubleheaded[i]);
                doubleheaded[i+3] = Number(args.doubleheaded[i]);
                doubleheaded[i+4] = Number(args.doubleheaded[i]);
                doubleheaded[i+5] = Number(args.doubleheaded[i]);
                doubleheaded[i+6] = Number(args.doubleheaded[i]);
                doubleheaded[i+7] = Number(args.doubleheaded[i]);
            }
            this.line.object.geometry.setAttribute('doubleHeaded', new THREE.BufferAttribute( doubleheaded, 1 ));

        }

        var arrowheadlength = new Float32Array( line_coords.length*8 );
        for(var i=0; i<args.size.length; i++){
            arrowheadlength[i]   = 0.02*args.size[i];
            arrowheadlength[i+1] = 0.02*args.size[i];
            arrowheadlength[i+2] = 0.02*args.size[i];
            arrowheadlength[i+3] = 0.02*args.size[i];
            arrowheadlength[i+4] = 0.02*args.size[i];
            arrowheadlength[i+5] = 0.02*args.size[i];
            arrowheadlength[i+6] = 0.02*args.size[i];
            arrowheadlength[i+7] = 0.02*args.size[i];
        }
        this.line.object.geometry.setAttribute('arrowheadlength', new THREE.BufferAttribute( arrowheadlength, 1 ));

        // Switch shaders to the arrow stem shader
        // (these won't render the parts of the line where the arrow head is)
        this.line.object.material.setValues({
            fragmentShader : R3JS.Shaders.FragmentShaderArrowStem,
            vertexShader   : R3JS.Shaders.VertexShaderArrowStem
        });

        // Set arrowhead coordinates and rotation
        var arrowhead_coords   = [];
        var arrowhead_rotation = [];

        for(var i=0; i<args.coords.length; i++){

            var rotation = -Math.PI/2 + Math.atan2(
                args.coords[i][1][1] - args.coords[i][0][1], 
                args.coords[i][1][0] - args.coords[i][0][0]
            );

            if(args.doubleheaded && args.doubleheaded[i]){

                arrowhead_rotation.push(rotation - Math.PI);
                arrowhead_rotation.push(rotation);
                arrowhead_coords.push(args.coords[i][0]);
                arrowhead_coords.push(args.coords[i][1]);

            } else {

                arrowhead_rotation.push(rotation);
                arrowhead_coords.push(args.coords[i][1]);

            }
        }
        
        // Set arrow rotation
        args.properties.rotation = arrowhead_rotation;
        
        // Make the arrow heads
        this.arrowhead = new R3JS.element.glarrowhead({
            coords     : arrowhead_coords,
            properties : args.properties,
            size       : args.size,
            viewer     : args.viewer
        });

        this.object = new THREE.Object3D();
        this.object.add(this.line.object);
        this.object.add(this.arrowhead.object);

        // Fire any resize event listeners (necessary for setting pixel ratio)
        viewport.onwindowresize();

    }

}


R3JS.element.glarrowhead = class GLArrowhead extends R3JS.element.base {

    constructor(args){

        super();

        // Set defaults
        if(!args.size)                    args.size = 1;
        if(!args.properties)              args.properties = {};
        if(!args.properties.color)        args.properties.color = { r:0, g:0, b:0, a:0 };
        if(!args.properties.fillcolor)    args.properties.fillcolor = args.properties.color;
        if(!args.properties.outlinecolor) args.properties.outlinecolor = args.properties.color;
        if(!args.properties.rotation)     args.properties.rotation = 0;
        if(!args.properties.outlinewidth) args.properties.outlinewidth = 0;
        if(!args.properties.visible)      args.properties.visible = 1;
        if(!args.properties.aspect)       args.properties.aspect  = 1;
        if(!args.properties.color.a)      args.properties.color.a = 1;

        // Make sure everything is the right length
        if(typeof(args.size) !== "object") args.size = Array(args.coords.length).fill(args.size);
        
        if(typeof(args.properties.fillcolor.r) !== "object"){
            args.properties.fillcolor.r = Array(args.coords.length).fill(args.properties.fillcolor.r);
            args.properties.fillcolor.g = Array(args.coords.length).fill(args.properties.fillcolor.g);
            args.properties.fillcolor.b = Array(args.coords.length).fill(args.properties.fillcolor.b);
        };
        if(typeof(args.properties.outlinecolor.r) !== "object"){
            args.properties.outlinecolor.r = Array(args.coords.length).fill(args.properties.outlinecolor.r);
            args.properties.outlinecolor.g = Array(args.coords.length).fill(args.properties.outlinecolor.g);
            args.properties.outlinecolor.b = Array(args.coords.length).fill(args.properties.outlinecolor.b);
        };

        if(typeof(args.properties.fillcolor.a)    !== "object") args.properties.fillcolor.a    = Array(args.coords.length).fill(args.properties.fillcolor.a);
        if(typeof(args.properties.outlinecolor.a) !== "object") args.properties.outlinecolor.a = Array(args.coords.length).fill(args.properties.outlinecolor.a);

        if(typeof(args.properties.rotation)     !== "object") args.properties.rotation     = Array(args.coords.length).fill(args.properties.rotation);
        if(typeof(args.properties.outlinewidth) !== "object") args.properties.outlinewidth = Array(args.coords.length).fill(args.properties.outlinewidth);
        if(typeof(args.properties.visible)      !== "object") args.properties.visible      = Array(args.coords.length).fill(args.properties.visible);
        if(typeof(args.properties.aspect)       !== "object") args.properties.aspect       = Array(args.coords.length).fill(args.properties.aspect);

        // Set variables
        var coords   = args.coords;
        var viewport = args.viewer.viewport;
        var renderer = args.viewer.renderer;
        var scene    = args.viewer.scene;

        // Set variables
        var positions    = new Float32Array( coords.length * 3 );
        var fillColor    = new Float32Array( coords.length * 4 );
        var outlineColor = new Float32Array( coords.length * 4 );
        var outlineWidth = new Float32Array( coords.length );
        var sizes        = new Float32Array( coords.length );
        var aspect       = new Float32Array( coords.length );
        var rotation     = new Float32Array( coords.length );
        var visible      = new Float32Array( coords.length );

        // Fill in info
        for(var i=0; i<coords.length; i++){

            positions[i*3]   = coords[i][0];
            positions[i*3+1] = coords[i][1];
            positions[i*3+2] = coords[i][2];

            // Set color
            fillColor[i*4]   = args.properties.fillcolor.r[i];
            fillColor[i*4+1] = args.properties.fillcolor.g[i];
            fillColor[i*4+2] = args.properties.fillcolor.b[i];
            fillColor[i*4+3] = args.properties.fillcolor.a[i];

            outlineColor[i*4]   = args.properties.outlinecolor.r[i];
            outlineColor[i*4+1] = args.properties.outlinecolor.g[i];
            outlineColor[i*4+2] = args.properties.outlinecolor.b[i];
            outlineColor[i*4+3] = args.properties.outlinecolor.a[i];

            outlineWidth[i] = args.properties.outlinewidth[i];
            
            sizes[i]    = args.size[i];
            visible[i]  = args.properties.visible[i];
            aspect[i]   = args.properties.aspect[i];
            rotation[i] = args.properties.rotation[i];

        }

        // Create buffer geometry
        var geometry = new THREE.BufferGeometry();
        geometry.setAttribute( 'position',     new THREE.BufferAttribute( positions,    3 ) );
        geometry.setAttribute( 'fillColor',    new THREE.BufferAttribute( fillColor,    4 ) );
        geometry.setAttribute( 'outlineColor', new THREE.BufferAttribute( outlineColor, 4 ) );
        geometry.setAttribute( 'outlineWidth', new THREE.BufferAttribute( outlineWidth, 1 ) );
        geometry.setAttribute( 'size',         new THREE.BufferAttribute( sizes,        1 ) );
        geometry.setAttribute( 'aspect',       new THREE.BufferAttribute( aspect,       1 ) );
        geometry.setAttribute( 'rotation',     new THREE.BufferAttribute( rotation,     1 ) );
        geometry.setAttribute( 'visible',      new THREE.BufferAttribute( visible,      1 ) );

        var vwidth  = viewport.getWidth();
        var vheight = viewport.getWidth();
        var pixelratio = renderer.getPixelRatio();

        var material = new THREE.ShaderMaterial( { 
            uniforms: { 
                scale:   { value: 1.0 }, 
                opacity: { value: 1.0 }, 
                viewportWidth: { value: vwidth }, 
                viewportHeight: { value: vheight },
                viewportPixelRatio: { value: pixelratio },
                sceneRotation: { value: scene.getRotation()[2] }
            }, 
            vertexShader:   R3JS.Shaders.VertexShaderArrowHead,
            fragmentShader: R3JS.Shaders.FragmentShaderArrowHead,
            transparent: true,
            blending: THREE.NormalBlending
        } );

        // Generate the points
        var points = new THREE.Points( geometry, material );
        this.object = points;

        // Add a resize event listener to the viewport
        viewport.onresize.push(
            function(){
                points.material.uniforms.viewportWidth.value      = viewport.getWidth();
                points.material.uniforms.viewportHeight.value     = viewport.getHeight();
                points.material.uniforms.viewportPixelRatio.value = renderer.getPixelRatio();
            }
        );

        scene.onrotate.push(
            function(){
                points.material.uniforms.sceneRotation.value = scene.getRotation()[2];
            }
        );

    }

}





// Make an arrow object
R3JS.element.glarrow3d = class GLArrow3d extends R3JS.element.base {

    constructor(args){

        super();
        var viewport = args.viewer.viewport;

        // Set defaults
        if(!args.size) args.size = 3;
        if(typeof(args.size) !== "object") args.size = Array(args.coords.length).fill(args.size);
        
        if(!args.properties)        args.properties        = {};
        if(!args.properties.color)  args.properties.color  = {r:0, g:0, b:0};
        if(!args.properties.aspect) args.properties.aspect = 0.35;
        if(!args.properties.lwd)    args.properties.lwd    = 3;


        // Make the line component
        var line_coords = [].concat(...args.coords);
        this.line = new R3JS.element.gllines_fat({
            coords     : line_coords,
            properties : { 
                lwd   : args.properties.lwd,
                color : args.properties.color,
                segments : true
            },
            viewer : args.viewer
        });

        // Set double headed properties
        if(args.doubleheaded){

            if(typeof(args.doubleheaded) !== "object") args.doubleheaded = Array(args.coords.length).fill(args.doubleheaded);
            var doubleheaded = new Float32Array( line_coords.length*8 );
            for(var i=0; i<args.doubleheaded.length; i++){
                doubleheaded[i]   = Number(args.doubleheaded[i]);
                doubleheaded[i+1] = Number(args.doubleheaded[i]);
                doubleheaded[i+2] = Number(args.doubleheaded[i]);
                doubleheaded[i+3] = Number(args.doubleheaded[i]);
                doubleheaded[i+4] = Number(args.doubleheaded[i]);
                doubleheaded[i+5] = Number(args.doubleheaded[i]);
                doubleheaded[i+6] = Number(args.doubleheaded[i]);
                doubleheaded[i+7] = Number(args.doubleheaded[i]);
            }
            this.line.object.geometry.setAttribute('doubleHeaded', new THREE.BufferAttribute( doubleheaded, 1 ));

        }

        var arrowheadlength = new Float32Array( line_coords.length*8 );
        for(var i=0; i<args.size.length; i++){
            arrowheadlength[i]   = 0.02*args.size[i];
            arrowheadlength[i+1] = 0.02*args.size[i];
            arrowheadlength[i+2] = 0.02*args.size[i];
            arrowheadlength[i+3] = 0.02*args.size[i];
            arrowheadlength[i+4] = 0.02*args.size[i];
            arrowheadlength[i+5] = 0.02*args.size[i];
            arrowheadlength[i+6] = 0.02*args.size[i];
            arrowheadlength[i+7] = 0.02*args.size[i];
        }
        this.line.object.geometry.setAttribute('arrowheadlength', new THREE.BufferAttribute( arrowheadlength, 1 ));

        // Switch shaders to the arrow stem shader
        // (these won't render the parts of the line where the arrow head is)
        this.line.object.material.setValues({
            fragmentShader : R3JS.Shaders.FragmentShaderArrowStem,
            vertexShader   : R3JS.Shaders.VertexShaderArrowStem
        });

        // // Set arrowhead coordinates and rotation
        // var arrowhead_coords   = [];
        // var arrowhead_rotation = [];

        // for(var i=0; i<args.coords.length; i++){

        //     var rotation = -Math.PI/2 + Math.atan2(
        //         args.coords[i][1][1] - args.coords[i][0][1], 
        //         args.coords[i][1][0] - args.coords[i][0][0]
        //     );

        //     if(args.doubleheaded && args.doubleheaded[i]){

        //         arrowhead_rotation.push(rotation - Math.PI);
        //         arrowhead_rotation.push(rotation);
        //         arrowhead_coords.push(args.coords[i][0]);
        //         arrowhead_coords.push(args.coords[i][1]);

        //     } else {

        //         arrowhead_rotation.push(rotation);
        //         arrowhead_coords.push(args.coords[i][1]);

        //     }
        // }
        
        // // Set arrow rotation
        // args.properties.rotation = arrowhead_rotation;
        
        // // Make the arrow heads
        // this.arrowhead = new R3JS.element.glarrowhead({
        //     coords     : arrowhead_coords,
        //     properties : args.properties,
        //     size       : 4,
        //     viewer     : args.viewer
        // });

        this.object = new THREE.Object3D();
        this.object.add(this.line.object);
        // this.object.add(this.arrowhead.object);

        // Fire any resize event listeners (necessary for setting pixel ratio)
        viewport.onwindowresize();

    }

}






