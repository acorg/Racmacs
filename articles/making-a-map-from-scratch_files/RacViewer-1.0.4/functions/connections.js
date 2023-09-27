
// EVENTS
R3JS.Viewer.prototype.eventListeners.push({
	name : "point-moved",
	fn : function(e){

		let point = e.detail.point;
		point.updateConnectionLines();
		point.updateErrorLines();
		point.updateTiterLabels();
		point.updatePointLabel();

	}
});

R3JS.Viewer.prototype.eventListeners.push({
	name : "point-selected",
	fn : function(e){

		let point  = e.detail.point;
		let viewer = point.viewer;
		
		viewer.updateErrorLines();

        if(viewer.connectionLinesShown){
            viewer.hideConnectionLines();
            viewer.showConnectionLines();
        }
        if(viewer.titersShown){
            viewer.hideTiters();
            viewer.showTiters();
        }
        if(viewer.labelsShown){
            viewer.hideLabels();
            viewer.showLabels();
        }

	}
});

R3JS.Viewer.prototype.eventListeners.push({
	name : "point-deselected",
	fn : function(e){
		let point  = e.detail.point;
		let viewer = point.viewer;
		if(viewer.errorLinesShown){
		    viewer.hideErrorLines();
            viewer.showErrorLines();
        }
        if(viewer.connectionLinesShown){
            viewer.hideConnectionLines();
            viewer.showConnectionLines();
        }
        if(viewer.titersShown){
            viewer.hideTiters();
            viewer.showTiters();
        }
        if(viewer.labelsShown){
            viewer.hideLabels();
            viewer.showLabels();
        }
	}
});

R3JS.Viewer.prototype.eventListeners.push({
	name : "point-included",
	fn : function(e){

		let point  = e.detail.point;
		let viewer = point.viewer;
		
		viewer.updateErrorLines();

        if(viewer.connectionLinesShown){
            viewer.hideConnectionLines();
            viewer.showConnectionLines();
        }
        if(viewer.titersShown){
            viewer.hideTiters();
            viewer.showTiters();
        }
        if(viewer.labelsShown){
            viewer.hideLabels();
            viewer.showLabels();
        }

	}
});

R3JS.Viewer.prototype.eventListeners.push({
	name : "point-excluded",
	fn : function(e){
		let point  = e.detail.point;
		let viewer = point.viewer;
		if(viewer.errorLinesShown){
		    viewer.hideErrorLines();
            viewer.showErrorLines();
        }
        if(viewer.connectionLinesShown){
            viewer.hideConnectionLines();
            viewer.showConnectionLines();
        }
        if(viewer.titersShown){
            viewer.hideTiters();
            viewer.showTiters();
        }
        if(viewer.labelsShown){
            viewer.hideLabels();
            viewer.showLabels();
        }
	}
});


R3JS.Viewer.prototype.eventListeners.push({
	name : "points-randomized",
	fn : function(e){
		let viewer  = e.detail.viewer;
		if(viewer.errorLinesShown){
		    viewer.hideErrorLines();
            viewer.showErrorLines();
        }
        if(viewer.connectionLinesShown){
            viewer.hideConnectionLines();
            viewer.showConnectionLines();
        }
        if(viewer.titersShown){
            viewer.hideTiters();
            viewer.showTiters();
        }
        if(viewer.labelsShown){
            viewer.hideLabels();
            viewer.showLabels();
        }
	}
});


R3JS.Viewer.prototype.eventListeners.push({
	name : "titer-changed",
	fn : function(e){
		let viewer = e.detail.viewer;
		if(viewer.errorLinesShown){
		    viewer.hideErrorLines();
            viewer.showErrorLines();
        }
        if(viewer.connectionLinesShown){
            viewer.hideConnectionLines();
            viewer.showConnectionLines();
        }
        if(viewer.titersShown){
            viewer.hideTiters();
            viewer.showTiters();
        }
	}
});


R3JS.Viewer.prototype.eventListeners.push({
	name : "ag-reactivity-changed",
	fn : function(e){
		let viewer = e.detail.point.viewer;
		if(viewer.errorLinesShown){
		    viewer.hideErrorLines();
            viewer.showErrorLines();
        }
	}
});

// CONNECTION LINES
Racmacs.App.prototype.toggleConnectionLines = function(){

	if(!this.connectionLinesShown){
		this.showConnectionLines();
	} else {
		this.hideConnectionLines();
	}

}

Racmacs.App.prototype.showConnectionLines = function(){

	this.hideErrorLines();
	if(!this.connectionLinesShown){
		this.connectionLinesShown = true;
		if(this.btns.toggleConnectionLines){ 
			this.btns.toggleConnectionLines.highlight();
		}

		if(this.selected_pts.length == 0){
			var points = this.antigens;
		} else {
			var points = this.selected_pts;
		}
		for(var i=0; i<points.length; i++){
			points[i].showConnections();
		}
	}

}

Racmacs.App.prototype.hideConnectionLines = function(){

	if(this.connectionLinesShown){
		this.connectionLinesShown = false;
		if(this.btns.toggleConnectionLines){ this.btns.toggleConnectionLines.dehighlight() }

		for(var i=0; i<this.points.length; i++){
			this.points[i].hideConnections();
		}
	}

}

// Add connection lines to a point object
Racmacs.Point.prototype.showConnections = function(){

	if(!this.connectionLinesShown && this.shown){

		this.connectionLinesShown = true;

		// Highlight connected points
		var connectedPoints = this.getConnectedPoints();
		connectedPoints.map( p => p.highlight() );

		// Get connection data
		var connectiondata = this.getConnectionData();

		// Render lines above points for 2d maps
		if (this.viewer.getPlotDims() === 2) {
			connectiondata.coords.map( x => x[2] = 0.01 );
		}

		// Make the line element
		this.connectionlines = new R3JS.element.gllines_fat({
			coords : connectiondata.coords,
			properties : {
				color : {
					r : Array(connectiondata.coords.length).fill(0),
					g : Array(connectiondata.coords.length).fill(0),
					b : Array(connectiondata.coords.length).fill(0)
				},
				mat : "line",
	            lwd : 1
			},
			segments : true,
			viewer : this.viewer
		});

		this.viewer.scene.add(
			this.connectionlines.object
		);

	}

}

// Remove connection lines from a point object
Racmacs.Point.prototype.hideConnections = function(){

	if(this.connectionLinesShown){

		this.connectionLinesShown = false;
		this.viewer.scene.remove(this.connectionlines.object);
		this.connectionlines = null;

		// Get connected points
		var connectedPoints = this.getConnectedPoints();
		connectedPoints.map( p => p.dehighlight() );

	}

}

Racmacs.Point.prototype.getConnectionData = function(){
		
	// Get connected points
	var connectedPoints = this.getConnectedPoints();

	// Get coordinates for the lines
	var data = {
		coords : Array(connectedPoints.length * 2)
	};

	for(var i=0; i<connectedPoints.length; i++){
		
		data.coords[i*2]   = this.coords3;
		data.coords[i*2+1] = connectedPoints[i].coords3;

	}

	// Return the coordinates
	return(data)

}

// Update connection lines from a point object
Racmacs.Point.prototype.updateConnectionLines = function(){

	if (this.connectionLinesShown){

		var connectiondata = this.getConnectionData();
		if (this.viewer.getPlotDims() === 2) {
			connectiondata.coords.map( x => x[2] = 0.01 );
		}
		this.connectionlines.setCoords(connectiondata.coords);

	} else {

		this.partners.map( p => {
			if (p.connectionLinesShown) p.updateConnectionLines();
		});

	}

}

// ERROR LINES
// General viewer toggling
Racmacs.App.prototype.toggleErrorLines = function(){

	if(!this.errorLinesShown){
		this.showErrorLines();
	} else {
		this.hideErrorLines();
	}

}

Racmacs.App.prototype.showErrorLines = function(){

	this.hideConnectionLines();
    if(!this.errorLinesShown){
		this.errorLinesShown = true;
		if(this.btns.toggleErrorLines){ this.btns.toggleErrorLines.highlight() }

		if(this.selected_pts.length == 0){
			var points = this.antigens;
		} else {
			var points = this.selected_pts;
		}
		for(var i=0; i<points.length; i++){
			points[i].showErrors();
		}
	}

}

Racmacs.App.prototype.hideErrorLines = function(){

	if(this.errorLinesShown){
		this.errorLinesShown = false;
		if(this.btns.toggleErrorLines){ this.btns.toggleErrorLines.dehighlight() }

		for(var i=0; i<this.points.length; i++){
			this.points[i].hideErrors();
		}
	}

}

Racmacs.App.prototype.updateErrorLines = function(){

	if (this.errorLinesShown) {
		this.hideErrorLines();
		this.showErrorLines();
	}

}


// Add connection lines to a point object
Racmacs.Point.prototype.showErrors = function(){

	if(!this.errorLinesShown && this.shown){

		this.errorLinesShown = true;

		// Highlight connected points
		var connectedPoints = this.getConnectedPoints();
		connectedPoints.map( x => x.highlight() );

		// Get error data
		var errordata = this.getErrorData();

		// Render lines above points for 2d maps
		if (this.viewer.getPlotDims() === 2) {
			errordata.coords.map( x => x[2] = 0.01 );
		}

		// Make the line element
		this.errorlines = new R3JS.element.gllines_fat({
			coords : errordata.coords,
			properties : {
				color : {
					r : errordata.colors.r,
					g : errordata.colors.g,
					b : errordata.colors.b
				},
				mat : "line",
	            lwd : 1
			},
			segments : true,
			viewer : this.viewer
		});

		// Add the line element to the scene
		this.viewer.scene.add(this.errorlines.object);

	}

}

// Remove connection lines from a point object
Racmacs.Point.prototype.hideErrors = function(){

	if(this.errorLinesShown){

		this.errorLinesShown = false;
		this.viewer.scene.remove(this.errorlines.object);
		this.errorlines = null;

		// Dehighlight connected points
		var connectedPoints = this.getConnectedPoints();
		connectedPoints.map( x => x.dehighlight() );

	}

}


// Function for fetching the error data
Racmacs.Point.prototype.getErrorData = function(pt = null){

	// Get connected points
	var connectedPoints
	if(pt === null) connectedPoints = this.getConnectedPoints();
	else            connectedPoints = pt;

	// Make coordinate array
	var data = {
		coords : Array(connectedPoints.length * 4),
		colors : {
			r : Array(connectedPoints.length * 4).fill(0),
			g : Array(connectedPoints.length * 4).fill(0),
			b : Array(connectedPoints.length * 4).fill(0)
		}
	}

	// Work through connected points
	for(var i=0; i<connectedPoints.length; i++){

		var from = this;
		var to = connectedPoints[i];

		// Work out whether point is too close or far away
		var residual = this.residualErrorTo(to);

		// Calculate the error vector
		var error_vector = [
		  from.coords3[0] - to.coords3[0],
		  from.coords3[1] - to.coords3[1],
		  from.coords3[2] - to.coords3[2]
		];

		// Normalise it and set to the residual length / 2
		var error_length = Math.sqrt(
			error_vector[0]*error_vector[0] + 
			error_vector[1]*error_vector[1] +
			error_vector[2]*error_vector[2]
		);

		error_vector[0] *= residual/error_length/2;
		error_vector[1] *= residual/error_length/2;
		error_vector[2] *= residual/error_length/2;

	  	// Update the color data
		if(residual < 0){ 
			data.colors.r[i*4]   = 1;
			data.colors.r[i*4+1] = 1;
			data.colors.r[i*4+2] = 1;
			data.colors.r[i*4+3] = 1;
		}
		else { 
			data.colors.b[i*4]   = 1;
			data.colors.b[i*4+1] = 1;
			data.colors.b[i*4+2] = 1;
			data.colors.b[i*4+3] = 1;
		}

		var fromTo = [
		    from.coords3[0] - error_vector[0],
		    from.coords3[1] - error_vector[1],
		    from.coords3[2] - error_vector[2]
	    ];

	    var toTo = [
		    to.coords3[0] + error_vector[0],
		    to.coords3[1] + error_vector[1],
		    to.coords3[2] + error_vector[2]
	    ];

		// Update the coordinate data
		data.coords[i*4]   = from.coords3;
		data.coords[i*4+1] = fromTo;
		data.coords[i*4+2] = to.coords3;
		data.coords[i*4+3] = toTo;

	}

	// Return colors and coordinates
	return(data);

}


// Remove connection lines from a point object
Racmacs.Point.prototype.updateErrorLines = function(){

	if (this.errorLinesShown) {

		var data = this.getErrorData();
		if (this.viewer.getPlotDims() === 2) {
			data.coords.map( x => x[2] = 0.01 );
		}
		this.errorlines.setCoords(data.coords);
		this.errorlines.setColor(data.colors);

	} else {

		this.partners.map( p => {
			if (p.errorLinesShown) p.updateErrorLines();
		});

	}

}


// TITER LABELS
Racmacs.App.prototype.toggleTiters = function(){

	if (!this.titersShown) {
		this.showTiters();
	} else {
		this.hideTiters();
	}

}

Racmacs.App.prototype.showTiters = function(){
	
	if (!this.connectionLinesShown && !this.errorLinesShown) {
	    this.showConnectionLines();
	}

	if (!this.titersShown) {
		this.titersShown = true;
		if(this.btns.toggleTiters){ this.btns.toggleTiters.highlight() }

		if(this.selected_pts.length == 0){
			var points = this.antigens;
		} else {
			var points = this.selected_pts;
		}
		for(var i=0; i<points.length; i++){
			points[i].showTiters();
		}
	}

}

Racmacs.App.prototype.hideTiters = function(){

	this.hideConnectionLines();

	if(this.titersShown){
		this.titersShown = false;
		if(this.btns.toggleTiters){ this.btns.toggleTiters.dehighlight() }

		for(var i=0; i<this.points.length; i++){
			this.points[i].hideTiters();
		}
	}

}

R3JS.Viewer.prototype.eventListeners.push({
    name : "point-hovered",
    fn : function(e){
    	let point = e.detail.point;
    	if(point.linkedtiterlabels){
    		point.linkedtiterlabels.map( t => {
    			t.setColor("red");
    		});
    	}
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "point-dehovered",
    fn : function(e){
    	let point = e.detail.point;
    	if(point.linkedtiterlabels){
    		point.linkedtiterlabels.map( t => {
    			t.setColor("inherit");
    		});
    	}
    }
});

// Add titers to a point object
Racmacs.Point.prototype.showTiters = function(){

	if(!this.titersShown && this.shown){

		this.titersShown = true;
		this.titerlabels = [];

		// Highlight connected points
		var connectedPoints = this.getConnectedPoints();
		connectedPoints.map( p => p.highlight() );

		// Show colbasis if a sera
		if(this.type == "sr"){
			var element = new R3JS.element.htmltext({
	            text   : "*"+Math.round(Math.pow(2, this.colbase())*10),
	            coords : this.coords3,
	        });
	        element.setStyle("font-size", "12px");
	        element.setStyle("font-weight", "bolder");
	        element.setStyle("background", "#ffffff");
	        element.from = this;
	        element.to   = this;
	        this.viewer.scene.add(element.object);
	        this.titerlabels.push(element);
		}

		// Show titers to connected points
		connectedPoints.map( p => {
			var element = new R3JS.element.htmltext({
	            text   : this.titerTo(p),
	            coords : [
	            	(this.coords3[0] + p.coords3[0])/2,
	            	(this.coords3[1] + p.coords3[1])/2,
	            	(this.coords3[2] + p.coords3[2])/2,
	            ],
	            // alignment : plotobj.alignment,
	            // offset     : plotobj.offset,
	            // properties : R3JS.Material(plotobj.properties)
	        });
	        element.setStyle("font-size", "10px");
	        element.setStyle("background", "#ffffff");
	        element.from = this;
	        element.to = p;
	        this.viewer.scene.add(element.object);
	        this.titerlabels.push(element);
		});

	}

}

// Remove titers from a point object
Racmacs.Point.prototype.hideTiters = function(){

	if(this.titersShown){

		this.titersShown = false;
		this.titerlabels.map(label => {
			this.viewer.scene.remove(label.object);
		});
		this.titerlabels = null;

		// Get connected points
		var connectedPoints = this.getConnectedPoints();
		connectedPoints.map( p => p.dehighlight() );

	}

}

// Update titers from an object
Racmacs.Point.prototype.updateTiterLabels = function(){

	if(this.titersShown){

		this.linkedtiterlabels.map( label => {
			label.setCoords([
				(label.from.coords3[0] + label.to.coords3[0])/2,
            	(label.from.coords3[1] + label.to.coords3[1])/2,
            	(label.from.coords3[2] + label.to.coords3[2])/2,
			]);
		});

	}

}


// POINT LABELS
Racmacs.App.prototype.toggleLabels = function(category){

	if(!this.labelsShown){
		this.showLabels(category);
	} else {
		this.hideLabels();
	}

}

Racmacs.App.prototype.showLabels = function(category){
	
	if(!this.labelsShown){

		// Highlight button
		this.labelsShown = true;
		if(this.btns.toggleLabels){ this.btns.toggleLabels.highlight() }

		// Work out which points to label
	    if (category === undefined) { 
	    	if (this.labelcategory === undefined) {
	    		category = "all";
	    	} else {
	    		category = this.labelcategory;
	    	}
	    } else {
	    	this.labelcategory = category;
	    }

		// Set default points
		var points;
		if(category === "all")      points = this.points;
		if(category === "antigens") points = this.antigens;
		if(category === "sera")     points = this.sera;
		points.map(p => p.showLabel());

	}

}

Racmacs.App.prototype.hideLabels = function(){

	if(this.labelsShown){

		this.labelsShown = false;
		if(this.btns.toggleLabels){ this.btns.toggleLabels.dehighlight() }

		for(var i=0; i<this.points.length; i++){
			this.points[i].hideLabel();
		}

	}

}

// Add name label to a point object
Racmacs.Point.prototype.showLabel = function(){

	if(!this.labelShown && this.shown &&
		(this.selected || this.viewer.selected_pts.length == 0)){

		this.labelShown = true;
		this.namelabel = null;

		// Show label
		var element = new R3JS.element.htmltext({
            text   : this.name,
            coords : this.coords3
        });
        element.setStyle("font-size", "12px");
		this.namelabel = element;

		// Add to scene
		this.viewer.scene.add(element.object);

	}

}

// Remove label from a point object
Racmacs.Point.prototype.hideLabel = function(){

	if(this.labelShown){

		this.labelShown = false;
		this.viewer.scene.remove(this.namelabel.object);
		this.namelabel = null;

	}

}

// Update label from an object
Racmacs.Point.prototype.updatePointLabel = function(){

	if(this.labelShown){

		this.namelabel.setCoords(this.coords3);

	}

}

