

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
            var size   = points.map( p => p.size );
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

            // Slightly different function for scaling up points but not changing outline width
            this.resizePoints = function(val){

                this.points.map( point => point.setSize(point.size*val) );
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
                size : points[i].size / 10,
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
        this.resizePoints = this.scalePoints;

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



