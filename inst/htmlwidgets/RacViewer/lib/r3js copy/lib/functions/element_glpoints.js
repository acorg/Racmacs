
// GL line constructor
R3JS.element.constructors.glpoints = function(
    plotobj,
    scene
    ){

    // Generate the point object
    var glpoints = new R3JS.element.glpoints({
        coords : plotobj.position,
        size : plotobj.size,
        shape : plotobj.shape,
        properties : plotobj.properties,
        dimensions : plotobj.properties.dimensions,
        viewer : scene.viewer
    });

    // var element = glpoints.elements;

    return(glpoints);

}


// Make a thin line object
R3JS.element.glpoints = class GLPoints {

    constructor(args){

        var coords = args.coords;
        var viewport = args.viewer.viewport;
        var renderer = args.viewer.renderer;

        // Set default properties
        let colarray = Array(coords.length).fill(0);
        if(args.shape === undefined)              args.shape = Array(coords.length).fill("circle");
        if(args.properties === undefined)         args.properties = {};
        if(args.properties.color === undefined)   args.properties.color = {r:colarray,g:colarray,b:colarray};
        if(args.properties.visible === undefined) args.properties.visible = Array(coords.length).fill(1);
        if(args.properties.aspect === undefined)  args.properties.aspect = Array(coords.length).fill(1);

        // Set default order
        if(!args.order){ args.order = new Array(coords.length).fill(0).map((x,i) => i) }

        // Set variables
        var positions    = new Float32Array( coords.length * 3 );
        var fillColor    = new Float32Array( coords.length * 4 );
        var outlineColor = new Float32Array( coords.length * 4 );
        var outlineWidth = new Float32Array( coords.length );
        var sizes        = new Float32Array( coords.length );
        var aspect       = new Float32Array( coords.length );
        var shape        = new Float32Array( coords.length );
        var visible      = new Float32Array( coords.length );

        // Fill in info
        var n;
        var element_order = Array(args.order.length);
        for(var i=0; i<args.order.length; i++){

            n = args.order[i];
            element_order[n] = i;

            positions[i*3]   = coords[n][0];
            positions[i*3+1] = coords[n][1];
            positions[i*3+2] = coords[n][2];


            // Set color
            if(args.shape[n].charAt(0) == "b"){ 

                fillColor[i*4]   = args.properties.bgcolor.r[n];
                fillColor[i*4+1] = args.properties.bgcolor.g[n];
                fillColor[i*4+2] = args.properties.bgcolor.b[n];
                fillColor[i*4+3] = args.properties.bgcolor.a[n];

                outlineColor[i*4]   = args.properties.color.r[n];
                outlineColor[i*4+1] = args.properties.color.g[n];
                outlineColor[i*4+2] = args.properties.color.b[n];
                outlineColor[i*4+3] = args.properties.color.a[n];

                outlineWidth[i] = args.properties.outlinewidth[n];

            } else if(args.shape[n].charAt(0) == "o"){ 

                fillColor[i*4+3] = 0;
                
                outlineColor[i*4]   = args.properties.color.r[n];
                outlineColor[i*4+1] = args.properties.color.g[n];
                outlineColor[i*4+2] = args.properties.color.b[n];
                outlineColor[i*4+3] = 1;

                outlineWidth[i] = args.properties.outlinewidth[n];

            } else {

                fillColor[i*4]   = args.properties.color.r[n];
                fillColor[i*4+1] = args.properties.color.g[n];
                fillColor[i*4+2] = args.properties.color.b[n];
                fillColor[i*4+3] = args.properties.color.a[n];

                outlineWidth[i] = 0;

            }
            
            // Set shape
            if(args.shape[n] == "circle")    { shape[i] = 0 }
            if(args.shape[n] == "ocircle")   { shape[i] = 0 }
            if(args.shape[n] == "bcircle")   { shape[i] = 0 }
            if(args.shape[n] == "square")    { shape[i] = 1 }
            if(args.shape[n] == "osquare")   { shape[i] = 1 }
            if(args.shape[n] == "bsquare")   { shape[i] = 1 }
            if(args.shape[n] == "triangle")  { shape[i] = 2 }
            if(args.shape[n] == "otriangle") { shape[i] = 2 }
            if(args.shape[n] == "btriangle") { shape[i] = 2 }
            if(args.shape[n] == "egg")       { shape[i] = 3 }
            if(args.shape[n] == "oegg")      { shape[i] = 3 }
            if(args.shape[n] == "begg")      { shape[i] = 3 }
            if(args.shape[n] == "uglyegg")   { shape[i] = 4 }
            if(args.shape[n] == "ouglyegg")  { shape[i] = 4 }
            if(args.shape[n] == "buglyegg")  { shape[i] = 4 }

            sizes[i]   = args.size[n];
            visible[i] = args.properties.visible[n];
            aspect[i]  = args.properties.aspect[n];

        }

        // Create buffer geometry
        var geometry = new THREE.BufferGeometry();
        geometry.setAttribute( 'position',     new THREE.BufferAttribute( positions,    3 ) );
        geometry.setAttribute( 'fillColor',    new THREE.BufferAttribute( fillColor,    4 ) );
        geometry.setAttribute( 'outlineColor', new THREE.BufferAttribute( outlineColor, 4 ) );
        geometry.setAttribute( 'outlineWidth', new THREE.BufferAttribute( outlineWidth, 1 ) );
        geometry.setAttribute( 'size',         new THREE.BufferAttribute( sizes,        1 ) );
        geometry.setAttribute( 'aspect',       new THREE.BufferAttribute( aspect,       1 ) );
        geometry.setAttribute( 'shape',        new THREE.BufferAttribute( shape,        1 ) );
        geometry.setAttribute( 'visible',      new THREE.BufferAttribute( visible,      1 ) );

        // var texture = get_sprite_texture("ball");

        var vwidth  = viewport.getWidth();
        var vheight = viewport.getWidth();
        var pixelratio = renderer.getPixelRatio();

        // if(args.properties.dimensions == 3){
        //     var material = new THREE.ShaderMaterial( { 
        //         uniforms: { 
        //             scale:   { value: 2.0*pixelratio }, 
        //             opacity: { value: 1.0 }, 
        //             viewportWidth: { value: vwidth }, 
        //             viewportHeight: { value: vheight },
        //             viewportPixelRatio: { value: pixelratio },
        //             circleTexture: { value: texture }
        //         }, 
        //         vertexShader:   get_vertex_shader3D(),
        //         fragmentShader: get_fragment_shader3D(),
        //         alphaTest: 0.9,
        //         transparent: true,
        //         blending: THREE.NormalBlending
        //     } );
        // } else {
            var material = new THREE.ShaderMaterial( { 
                uniforms: { 
                    scale:   { value: 1.0 }, 
                    opacity: { value: 1.0 }, 
                    viewportWidth: { value: vwidth }, 
                    viewportHeight: { value: vheight },
                    viewportPixelRatio: { value: pixelratio }
                }, 
                vertexShader:   renderer.shaders.vertexShader,
                fragmentShader: renderer.shaders.fragmentShader,
                alphaTest: 0.9,
                transparent: true,
                blending: THREE.NormalBlending
            } );
        // }

        // Generate the points
        var points = new THREE.Points( geometry, material );
        this.object = points;

        // Add a resize event listener to the viewport
        viewport.onresize.push(
            function(){
                points.material.uniforms.viewportWidth.value = viewport.getWidth();
                points.material.uniforms.viewportHeight.value  = viewport.getHeight();
                points.material.uniforms.viewportPixelRatio.value = renderer.getPixelRatio();
            }
        );

        // args.camera.zoom_events.push(
        //     function(){
        //         points.material.uniforms.scale.value = 1 / args.camera.distance;
        //     }
        // );

        // Make individual elements
        this.ielements = [];
        for(var i=0; i<coords.length; i++){
            this.ielements.push(
                new R3JS.element.glpoint(
                    this.object,
                    element_order[i],
                    this
                )
            );
        }


    }

    elements(){
        return(this.ielements);
    }

    // Scale size of all points
    getSize(){
        return(this.object.material.uniforms.scale.value);
    }

    setSize(value){
        this.object.material.uniforms.scale.value = value;
    }

}


// Make a thin line object
R3JS.element.glpoint = class GLPoint extends R3JS.element.base {

    constructor(
            object,
            index,
            parent
        ){

        super();
        this.object = object;
        this.index = index;
        this.uuid = object.uuid+"-"+index;
        this.element = this;
        this.parent = parent;

        var pointobjcoords = this.object.geometry.attributes.position.array;
        this.coords = [
            pointobjcoords[this.index*3],
            pointobjcoords[this.index*3+1],
            pointobjcoords[this.index*3+2]
        ];
        this.size    = this.object.geometry.attributes.size.array[this.index];
        this.shape   = this.object.geometry.attributes.shape.array[this.index];
        this.aspect  = this.object.geometry.attributes.aspect.array[this.index];
        this.visible = this.object.geometry.attributes.visible.array[this.index];

    }

    // Setting size
    setSize(size){

        var pointsizes = this.object.geometry.attributes.size.array;
        this.object.geometry.attributes.size.needsUpdate = true;
        pointsizes[this.index] = size;
        this.size = size;

    }

    getSize(){

        this.size;

    }

    // Method to set coordinates
    setCoords(x, y, z){

        this.coords[0] = x;
        this.coords[1] = y;
        this.coords[2] = z;
        var position = this.object.geometry.attributes.position.array;
        this.object.geometry.attributes.position.needsUpdate = true;
        position[this.index*3]   = x;
        position[this.index*3+1] = y;
        position[this.index*3+2] = z;

    }

    // Method to set color
    setColor(color){

        color = new THREE.Color(color);    
        var fillCols = this.object.geometry.attributes.fillColor.array;
        this.object.geometry.attributes.fillColor.needsUpdate = true;
        fillCols[this.index*4]   = color.r;
        fillCols[this.index*4+1] = color.g;
        fillCols[this.index*4+2] = color.b;

    }

    // Method to set fill color
    setFillColor(color){

        this.setColor(color);

    }

    // Method to set outline color
    setOutlineColor(color){

        color = new THREE.Color(color);
        var outlineCols = this.object.geometry.attributes.outlineColor.array;
        this.object.geometry.attributes.outlineColor.needsUpdate = true;
        outlineCols[this.index*4]   = color.r;
        outlineCols[this.index*4+1] = color.g;
        outlineCols[this.index*4+2] = color.b;

    }

    // Set opacity
    setOpacity(opacity){

        this.setFillOpacity(opacity);
        this.setOutlineOpacity(opacity);

    }

    setFillOpacity(opacity){
        
        var fillCols = this.object.geometry.attributes.fillColor.array;
        this.object.geometry.attributes.fillColor.needsUpdate = true;
        fillCols[this.index*4+3] = opacity;
        
    }

    setOutlineOpacity(opacity){

        var outlineCols = this.object.geometry.attributes.outlineColor.array;
        this.object.geometry.attributes.outlineColor.needsUpdate = true;
        outlineCols[this.index*4+3] = opacity;

    }

    hide(){
        
        var visible = this.object.geometry.attributes.visible.array;
        this.object.geometry.attributes.visible.needsUpdate = true;
        visible[this.index] = 0;

    }

    show(){
        
        var visible = this.object.geometry.attributes.visible.array;
        this.object.geometry.attributes.visible.needsUpdate = true;
        visible[this.index] = 1;

    }

    // [1,2,3,x,4,5]
    
    setIndex(index){

        // Set values
        for(var name in this.object.geometry.attributes){
            
            var attribute = this.object.geometry.attributes[name];
            var size = attribute.itemSize;
            
            // Get the original value
            var orig = attribute.array.slice(this.index*size, this.index*size+size);

            // Shift all values above it down
            if(index < this.index){
              attribute.array.copyWithin(index*size+size, index*size, this.index*size)
            } else {
              attribute.array.copyWithin(this.index*size, this.index*size+size, index*size+size)
            }
            
            // Replace the original values at the top
            attribute.array.set(orig, index*size);

            // Set needs update
            attribute.needsUpdate = true;

        }

        // Correct all parent element references
        var parent_elements = this.parent.elements();
        for(var i=0; i<parent_elements.length; i++){
            if(parent_elements[i].index > this.index && parent_elements[i].index <= index){
                parent_elements[i].index--;
            } else if (parent_elements[i].index < this.index && parent_elements[i].index >= index){
                parent_elements[i].index++;
            }
        }

        // Reset the index
        this.index = index;

    }


    // Method for raycasting to this point
    raycast(raycaster, intersects){
        
        if(this.visible == 1){

            // 2D
            // Fetch ray and project into camera space [-1, 1] for x and y
            var ray = raycaster.ray.origin.clone().project(raycaster.camera);
            
            // Project coords into camera space [-1, 1] for x and y
            var coords = new THREE.Vector3()
                                  .fromArray(this.coords)
                                  .applyMatrix4(this.object.matrixWorld)
                                  .project(raycaster.camera);


            // // Project coords into camera space [-1, 1] for x and y
            // var coords = new THREE.Vector3()
            //                       .fromArray(this.coords)
            //                       .applyMatrix4(this.object.matrixWorld)
            //                       .project(raycaster.camera);

            // // 3D
            // var ray = raycaster.ray.direction.clone().project(raycaster.camera);
            
            // Correct distance for viewport aspect
            var aspect = raycaster.aspect;
            coords.x   = coords.x/aspect;
            ray.x      = ray.x/aspect;

            // Work out point radius
            var size       = this.size;
            var aspect     = this.aspect;
            var uniscale   = this.object.material.uniforms.scale.value;
            var pixelratio = this.object.material.uniforms.viewportPixelRatio.value;
            var ptRadius   = 0.025*size*uniscale;

            // Work out whether the point is intersected or not
            var ptIntersected;
            var p = { x:ray.x - coords.x, y: ray.y - coords.y };

            if(aspect > 1){ p.y = p.y*aspect }
            else          { p.x = p.x/aspect }

            if(this.shape == 1){
                
                // Square
                ptIntersected = p.x < ptRadius
                                && p.x > -ptRadius
                                && p.y < ptRadius
                                && p.y > -ptRadius

            } else if(this.shape == 2) {

                // Triangle
                var p1 = {x:0.8660254*ptRadius,  y:-0.5*ptRadius};
                var p2 = {x:-0.8660254*ptRadius, y:-0.5*ptRadius};
                var p3 = {x:0,                   y:1*ptRadius};
                
                var alpha = ((p2.y - p3.y)*(p.x - p3.x) + (p3.x - p2.x)*(p.y - p3.y)) /
                        ((p2.y - p3.y)*(p1.x - p3.x) + (p3.x - p2.x)*(p1.y - p3.y));
                var beta = ((p3.y - p1.y)*(p.x - p3.x) + (p1.x - p3.x)*(p.y - p3.y)) /
                       ((p2.y - p3.y)*(p1.x - p3.x) + (p3.x - p2.x)*(p1.y - p3.y));
                var gamma = 1.0 - alpha - beta;
                
                // if(alpha < 0 || beta < 0 || gamma < 0){
                //     discard;
                // }
                ptIntersected = alpha > 0 && beta > 0 && gamma > 0;

            } else {

                // Circle
                var dist2point = Math.sqrt(
                    ((p.x)*(p.x))
                    + (p.y)*(p.y)
                );
                ptIntersected = dist2point < ptRadius;

            }

            // If intersected then add to intersects
            if(ptIntersected){
                intersects.push({
                    object   : this,
                    distance : -this.index
                });
            }

        }
        
    }

    // Function to check whether point is within a selection rectangle
    withinRectangle(
        corner1,
        corner2,
        camera
    ){

        if(this.visible == 1){

            var projectedPosition = new THREE.Vector3()
                                             .fromArray(this.coords)
                                             .applyMatrix4(this.object.matrixWorld)
                                             .project(camera.camera);

            var aspect = camera.aspect;
            
            var size       = this.size;
            var uniscale   = this.object.material.uniforms.scale.value;
            var pixelratio = this.object.material.uniforms.viewportPixelRatio.value;
            var ptRadius   = (0.048*size*uniscale)/pixelratio;

            // var ptRadius = (this.object.material.uniforms.scale.value*0.0032*this.size)/
            //                (3*this.object.material.uniforms.viewportPixelRatio.value);

            return(projectedPosition.x + ptRadius/aspect > Math.min(corner1.x, corner2.x) &&
                   projectedPosition.x - ptRadius/aspect < Math.max(corner1.x, corner2.x) &&
                   projectedPosition.y + ptRadius > Math.min(corner1.y, corner2.y) &&
                   projectedPosition.y - ptRadius < Math.max(corner1.y, corner2.y));

        }

    }

}









