
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
    if(this.mapdims.dimensions <= 2){

        // For highly performant graphics
        if(this.performance_mode){

            // Change point scaling
            points.map( p => p.scaling = 0.2 );

            // Extract values
            var coords = points.map( p => p.coordsNoNA() );
            var size   = points.map( p => p.size*p.scaling );
            var shape  = points.map( function(p){
                var shape = p.shape.toLowerCase();
                if(shape == "circle")   return("circle filled")
                if(shape == "triangle") return("triangle filled")
                if(shape == "box")      return("square filled")
                if(shape == "egg")      return("egg filled")
                if(shape == "uglyegg")  return("uglyegg filled")
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
            var order = this.data.ptDrawingOrder();

            // Generate the point objects
            var glpoints = new R3JS.element.glpoints({
                coords : coords,
                size : size,
                shape : shape,
                visible : visible,
                dimensions : 2,
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

        var shape;
        for(var i=0; i<points.length; i++){

            if(points[i].shape.toLowerCase() == "circle"){ shape = "sphere" }
            if(points[i].shape.toLowerCase() == "box")   { shape = "cube" }
            var fillcolor    = points[i].getFillColorRGBA();
            var outlinecolor = points[i].getOutlineColorRGBA();

            // Set point properties
            var properties = {
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
                lwd : points[i].outlineWidth*0.2,
                visible: points[i].shown
            };

            var element = new R3JS.element.Point({
                coords : points[i].coords3,
                size : points[i].size,
                shape : shape,
                viewer: this,
                properties : properties
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
