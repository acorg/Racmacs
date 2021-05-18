
// EVENTS
R3JS.Viewer.prototype.eventListeners.push({
    name : "zoom",
    fn : function(e){
        let viewer = e.detail.viewer;
        if(viewer.onPointZoom){
            viewer.onPointZoom(
                e.detail.start_zoom, 
                e.detail.end_zoom
            );
        }
    }
});

Racmacs.Viewer.prototype.toggleLockPointSize = function(){

    if(this.pointSizeLocked){
        this.unlockPointSize();
    } else {
        this.lockPointSize();
    }

}

Racmacs.Viewer.prototype.lockPointSize = function(){

    this.pointSizeLocked = true;
    if(this.btns["toggleLockPointSize"]){
        this.btns["toggleLockPointSize"].updateIcon(Racmacs.icons.unlocksize());
    }

}

Racmacs.Viewer.prototype.unlockPointSize = function(){

    this.pointSizeLocked = false;
    if(this.btns["toggleLockPointSize"]){
        this.btns["toggleLockPointSize"].updateIcon(Racmacs.icons.locksize());
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

            // Change point scaling
            points.map( p => p.scaling = 0.2 );

            // Extract values
            var coords = points.map( p => p.coordsNoNA() );
            var size   = points.map( p => p.size*p.scaling );
            var shape  = points.map( function(p){
                var shape = p.shape.toLowerCase();
                if(shape == "circle")   return("bcircle")
                if(shape == "triangle") return("btriangle")
                if(shape == "box")      return("bsquare")
                if(shape == "egg")      return("begg")
                if(shape == "uglyegg")  return("buglyegg")
            });
            var fillcols    = points.map( p => p.getFillColorRGBA()    );
            var outlinecols = points.map( p => p.getOutlineColorRGBA() );
            var visible = points.map( function(p){
                if(p.na_coords || !p.shown){ return(false) }
                else                       { return(true)  }
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
                visible : visible,
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

            // Slightly different function for scaling up points but not changing outline width
            this.resizePoints = function(val){

                this.points.map( point => point.setSize(point.size*val) );
                this.render();

            }

            // Set function to run when zooming
            this.onPointZoom = function(start_zoom, end_zoom){
                if(this.pointSizeLocked){
                    if(start_zoom > 0){
                        this.scalePoints(start_zoom / end_zoom);
                    }
                }
            }

        }

    }

    // For 3D maps
    if(this.mapdims.dimensions == 3){

        if(this.svg){

            for(var i=0; i<points.length; i++){

                var fillcolor    = points[i].getFillColorRGBA();
                var outlinecolor = points[i].getOutlineColorRGBA();

                var element = new Racmacs.svgelement.Point({
                    coords : points[i].coords,
                    size : points[i].size,
                    shape : shape,
                    properties : {
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
                        lwd : points[i].outlineWidth,
                        visible: points[i].shown
                    }
                });

                // Add object to scene
                this.scene.add(element.object);

                // Add to point elements
                point_elements.push(element);

            }

        } else {

            var shape;
            for(var i=0; i<points.length; i++){

                if(points[i].shape.toLowerCase() == "circle"){ shape = "circle3d" }
                if(points[i].shape.toLowerCase() == "box")   { shape = "square3d" }
                var fillcolor    = points[i].getFillColorRGBA();
                var outlinecolor = points[i].getOutlineColorRGBA();

                var element = new R3JS.element.Point({
                    coords : points[i].coords,
                    size : points[i].size,
                    shape : shape,
                    viewer: this,
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
                        lwd : points[i].outlineWidth,
                        visible: points[i].shown
                    }
                });

                element.setFillOpacity(fillcolor[3]);
                element.setOutlineOpacity(outlinecolor[3]);

                // Add object to scene
                this.scene.add(element.object);

                // Add to point elements
                point_elements.push(element);

            }

        }

        // Set function to scale all point sizes up
        this.scalePoints = function(val){
            for(var i=0; i<point_elements.length; i++){
                point_elements[i].scale(val);
            }
            this.render();
        }
        this.resizePoints = this.scalePoints;

        // Set function to run when zooming
        this.onPointZoom = function(start_zoom, end_zoom){
            if(!this.pointSizeLocked){
                if(start_zoom > 0){
                    this.scalePoints(end_zoom / start_zoom);
                }
            }
        }

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


Racmacs.svgelement = {};
Racmacs.svgelement.Point = class SVGPoint extends R3JS.element.base {

    constructor(args){
        super();

        var svgns = "http://www.w3.org/2000/svg";
        var circle = document.createElementNS(svgns, 'circle');
        var stroke = 'rgba('+args.properties.outlinecolor.r*255+','+args.properties.outlinecolor.g*255+','+args.properties.outlinecolor.b*255+')';
        var fill = 'rgba('+args.properties.fillcolor.r*255+','+args.properties.fillcolor.g*255+','+args.properties.fillcolor.b*255+')';

        circle.setAttributeNS(null, 'cx', 0);
        circle.setAttributeNS(null, 'cy', 0);
        circle.setAttributeNS(null, 'r', args.size*2);
        circle.setAttributeNS(null, 'style', 'fill: url(#_Radial2); stroke: '+stroke+'; stroke-width: 0.1px;' );

        // Make object
        this.object  = new THREE.SVGObject(circle);
        this.object.element = this;

        
        
        // Set position
        this.object.position.set(
            args.coords[0],
            args.coords[1],
            args.coords[2]
        );

    }

    setOutlineColor(color){

    }

    setFillOpacity(color){

    }

    setOutlineOpacity(color){

    }

}
