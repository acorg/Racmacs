

Racmacs.Viewer.prototype.toggleLockPointSize = function(){

    if(this.pointSizeLocked){
        this.unlockPointSize();
    } else {
        this.lockPointSize();
    }

}

Racmacs.Viewer.prototype.lockPointSize = function(){

    this.pointSizeLocked = true;
    if(this.viewport.btns["toggleLockPointSize"]){
        this.viewport.btns["toggleLockPointSize"].updateIcon(Racmacs.icons.unlocksize());
    }

}

Racmacs.Viewer.prototype.unlockPointSize = function(){

    this.pointSizeLocked = false;
    if(this.viewport.btns["toggleLockPointSize"]){
        this.viewport.btns["toggleLockPointSize"].updateIcon(Racmacs.icons.locksize());
    }

}


Racmacs.Viewer.prototype.addAgSrPoints = function(){

    // Set the points
    var points = this.points;
    var point_elements = [];

    // Empty the scene
    this.scene.empty();

    // For 2D maps
    if(this.mapdims.dimensions == 2){

        // For highly performant graphics
        if(this.performance_mode){


            // Extract values
            var coords = points.map( p => p.coordsNoNA() );
            var size   = points.map( p => p.size / 10 );
            var shape  = points.map( function(p){
                var shape = p.shape.toLowerCase();
                if(shape == "circle")  return("bcircle")
                if(shape == "box")     return("bsquare")
                if(shape == "egg")     return("begg")
                if(shape == "uglyegg") return("buglyegg")
            });
            var fillcols    = points.map( p => p.getFillColorRGBA()    );
            var outlinecols = points.map( p => p.getOutlineColorRGBA() );
            var visible = points.map( function(p){
                if(p.na_coords){ return(false) }
                else           { return(true)  }
            });

            // Set properties
            var properties = {
                color : {
                    r : outlinecols.map( x => x[0] ),
                    g : outlinecols.map( x => x[1] ),
                    b : outlinecols.map( x => x[2] ),
                    a : outlinecols.map( x => x[3] )
                },
                bgcolor : {
                    r : fillcols.map( x => x[0] ),
                    g : fillcols.map( x => x[1] ),
                    b : fillcols.map( x => x[2] ),
                    a : fillcols.map( x => x[3] )
                },
                outlinewidth : points.map( p => p.outlineWidth ),
                opacity : points.map( p => p.opacity ),
                aspect  : points.map( p => p.aspect ),
                visible : visible
            }

            // Plot points by drawing order
            // var order = Array(points.length).fill(0).map((x,i) => i);
            // order.sort(function(a,b){
            //   return(points[a].drawing_order - points[b].drawing_order);
            // });
            // var order = [];
            // for(var i=this.data.data.c.p.d.length-1; i>=0; i--){
            //     order.push(this.data.data.c.p.d[i]);
            // }
            var order = this.data.ptDrawingOrder();

            // Generate the point objects
            var glpoints = new R3JS.element.glpoints({
                coords : coords,
                size : size,
                shape : shape,
                dimensions : this.mapdims.dimensions,
                properties : properties,
                viewer : this.scene.viewer,
                order : order
            });

            // Add object to scene
            this.scene.add(glpoints.object);

            // Set point elements
            point_elements = glpoints.elements();

            // Set function to scale all point sizes up
            this.scalePoints = function(val){
                glpoints.setSize(glpoints.getSize()*val);
                this.render();
            }

            // Add event to camera to scale points on zoom
            var viewer = this;
            this.camera.onzoom = function(start_zoom, end_zoom){
                
                if(viewer.pointSizeLocked){
                    viewer.scalePoints(start_zoom / end_zoom);
                }

            };

        }

    }

    // For 3D maps
    if(this.mapdims.dimensions == 3){

        var shape;
        for(var i=0; i<points.length; i++){

            if(points[i].shape.toLowerCase() == "circle"){ shape = "circle3d" }
            if(points[i].shape.toLowerCase() == "box")   { shape = "square3d" }
            var fillcolor    = points[i].getFillColorRGBA();
            var outlinecolor = points[i].getOutlineColorRGBA();

            var element = new R3JS.element.Point({
                coords : points[i].coords,
                size : points[i].size/2.5,
                shape : shape,
                properties : {
                    mat : "lambert",
                    fillcolor : {
                        r : fillcolor[0],
                        g : fillcolor[1],
                        b : fillcolor[2]
                    },
                    outlinecolor : {
                        r : outlinecolor[0],
                        g : outlinecolor[1],
                        b : outlinecolor[2]
                    },
                    transparent : true,
                    lwd : points[i].outlineWidth
                }
            });

            element.setFillOpacity(fillcolor[3]);
            element.setOutlineOpacity(outlinecolor[3]);

            // Add object to scene
            this.scene.add(element.object);

            // Add to point elements
            point_elements.push(element);

        }

        // Set function to scale all point sizes up
        this.scalePoints = function(val){
            for(var i=0; i<point_elements.length; i++){
                point_elements[i].scale(val);
            }
            this.render();
        }

        // Add event to camera to scale points on zoom
        var viewer = this;
        this.camera.onzoom = function(start_zoom, end_zoom){
            
            if(!viewer.pointSizeLocked){
                viewer.scalePoints(end_zoom / start_zoom);
            }

        };

    }

    // Add the points as elements to the scene in the drawing order
    this.scene.addElements(point_elements);
    this.scene.addSelectableElements(point_elements);

    // Bind the elements to the points
    for(var i=0; i<points.length; i++){
        points[i].bindElement(point_elements[i]);
        points[i].pointElement = point_elements[i];
    }

}


// function generate_agsr_points(viewport, performance_mode){

//     // Set the points
//     var points = viewport.points;
//     viewport.pixelratio = window.devicePixelRatio;

//     // Work out the plotting order
//     var order    = [];
//     for (var i = 0; i < points.length; i++) {
//         order.push(i);
//     }
//     order.sort(function(a,b){
//       return(points[a].drawing_order - points[b].drawing_order);
//     })

//     // Empty the selectable objects
//     viewport.scene.selectable_objects = [];

//     // For highly performant graphics
//     if(performance_mode){
        
//         // Plot map data
//         var positions    = new Float32Array( points.length * 3 );
//         var fillColor    = new Float32Array( points.length * 4 );
//         var outlineColor = new Float32Array( points.length * 4 );
//         var outlineWidth = new Float32Array( points.length );
//         var sizes        = new Float32Array( points.length );
//         var aspect       = new Float32Array( points.length );
//         var shape        = new Float32Array( points.length );
//         var pIndex       = new Float32Array( points.length );
//         var visible      = new Float32Array( points.length );

//         var vertex = new THREE.Vector3();
//         var color  = new THREE.Color();
//         var alpha;

//         // Add the point order information
//         for ( var i = 0; i < order.length; i ++ ) {

//             var n     = order[i];
//             pIndex[i] = n;

//             // Record plot index
//             points[n].plotIndex = i;

//             // Make points visible by default
//             visible[i] = 1;

//         }

//         // Create buffer geometry
//         var geometry = new THREE.BufferGeometry();
//         geometry.addAttribute( 'position',     new THREE.BufferAttribute( positions,    3 ) );
//         geometry.addAttribute( 'fillColor',    new THREE.BufferAttribute( fillColor,    4 ) );
//         geometry.addAttribute( 'outlineColor', new THREE.BufferAttribute( outlineColor, 4 ) );
//         geometry.addAttribute( 'outlineWidth', new THREE.BufferAttribute( outlineWidth, 1 ) );
//         geometry.addAttribute( 'size',         new THREE.BufferAttribute( sizes,        1 ) );
//         geometry.addAttribute( 'aspect',       new THREE.BufferAttribute( aspect,       1 ) );
//         geometry.addAttribute( 'shape',        new THREE.BufferAttribute( shape,        1 ) );
//         geometry.addAttribute( 'pIndex',       new THREE.BufferAttribute( pIndex,       1 ) );
//         geometry.addAttribute( 'visible',      new THREE.BufferAttribute( visible,      1 ) );

//         // Create the material
//         var viewport_size = viewport.renderer.getSize();

//         if(viewport.dimensions == 2){
//             var material = new THREE.ShaderMaterial( {
//                 uniforms: {
//                     scale:   { value: 3.0*window.devicePixelRatio },
//                     opacity: { value: 1.0 },
//                     viewportWidth:      { value: viewport_size.width  }, 
//                     viewportHeight:     { value: viewport_size.height },
//                     viewportPixelRatio: { value: window.devicePixelRatio }
//                 },
//                 vertexShader:   get_vertex_shader2D(),
//                 fragmentShader: get_fragment_shader2D(),
//                 alphaTest: 0.9,
//                 transparent: true,
//                 blending: THREE.NormalBlending,
//             } );
//         } else {

//             var material = new THREE.ShaderMaterial( {
//                 uniforms: {
//                     scale:   { value: 3.0*window.devicePixelRatio },
//                     opacity: { value: 1.0 },
//                     innerHeight: { value: viewport_size.height },
//                     circleTexture: { value: new THREE.TextureLoader().load( "lib/textures/sprites/ball.png" ) }
//                 },
//                 vertexShader:   get_vertex_shader3D(),
//                 fragmentShader: get_fragment_shader3D(),
//                 alphaTest: 0.9,
//                 transparent: true,
//                 blending: THREE.NormalBlending,
//             } );
//         }

//         // Generate the points
//         var pointGeos = new THREE.Points( geometry, material );
//         pointGeos.frustumCulled = false;

//     }

//     // For less performant (but 3D nicer looking) graphics
//     else {

//         var pointGeos = new THREE.Group();

//         // Add all the point information
//         for ( var i = 0; i < order.length; i ++ ) {

//             var n     = order[i];

//             // Record plot index
//             points[n].plotIndex = i;

//             // Generate the point object
//             pointObject  = new THREE.Object3D();
//             pointGeos.add(pointObject);

//             pointFill    = new THREE.Mesh( 
//                 new THREE.BufferGeometry(), 
//                 new THREE.MeshLambertMaterial({
//                     transparent : true
//                 })
//             );
//             pointObject.add(pointFill);

//             pointOutline = new THREE.Mesh( 
//                 new THREE.BufferGeometry(), 
//                 new THREE.MeshLambertMaterial({
//                     transparent : true
//                 })
//             );
//             pointObject.add(pointOutline);

//             // Add some properties
//             pointObject.pIndex = n;
            
//             // Add the fill to the selectable objects
//             viewport.scene.selectable_objects.push(pointFill);

//         }

//     }

//     // Return the point geometries
//     return(pointGeos);

// }
