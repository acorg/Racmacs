
// EVENTS
Racmacs.App.prototype.onselect.push(
	function(viewer){
		if(viewer.errorLinesShown){
            viewer.hideErrorLines();
            viewer.showErrorLines();
        }
        if(viewer.connectionLinesShown){
            viewer.hideConnectionLines();
            viewer.showConnectionLines();
        }
	}
);

Racmacs.App.prototype.ondeselect.push(
	function(viewer){
		if(viewer.errorLinesShown){
            viewer.hideErrorLines();
            viewer.showErrorLines();
        }
        if(viewer.connectionLinesShown){
            viewer.hideConnectionLines();
            viewer.showConnectionLines();
        }
	}
);

Racmacs.Point.prototype.onselect.push(
	function(point){
		if(point.viewer.errorLinesShown)      { point.showErrors()      }
		if(point.viewer.connectionLinesShown) { point.showConnections() }
	}
);

Racmacs.Point.prototype.ondeselect.push(
	function(point){
		if(point.viewer.errorLinesShown)      { point.hideErrors()      }
	    if(point.viewer.connectionLinesShown) { point.hideConnections() }
	}
);

// CONNECTION LINES
Racmacs.App.prototype.toggleConnectionLines = function(){

	if(!this.connectionLinesShown){
		this.showConnectionLines();
	} else {
		this.hideConnectionLines();
	}

}

Racmacs.App.prototype.showConnectionLines = function(){

	this.connectionLinesShown = true;
	if(this.btns.toggleConnectionLines){ this.btns.toggleConnectionLines.highlight() }

	if(this.selected_pts.length == 0){
		var points = this.antigens;
	} else {
		var points = this.selected_pts;
	}
	for(var i=0; i<points.length; i++){
		points[i].showConnections();
	}

}

Racmacs.App.prototype.hideConnectionLines = function(){

	this.connectionLinesShown = false;
	if(this.btns.toggleConnectionLines){ this.btns.toggleConnectionLines.dehighlight() }

	for(var i=0; i<this.points.length; i++){
		this.points[i].hideConnections();
	}

}

// Add connection lines to a point object
Racmacs.Point.prototype.showConnections = function(){

	if(!this.connectionLinesShown){

		this.connectionLinesShown = true;

		// Highlight connected points
		var connectedPoints = this.getConnectedPoints();
		connectedPoints.map( p => p.highlight() );

		// Get connection data
		var connectiondata = this.getConnectionData();

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
	            lwd : 1,
	            segments : true
			},
			viewer : this.viewer
		});

		this.viewer.scene.add(this.connectionlines.object);

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
		
		data.coords[i*2]   = this.coords;
		data.coords[i*2+1] = connectedPoints[i].coords;

	}

	// Return the coordinates
	return(data)

}

// Update connection lines from a point object
Racmacs.Point.prototype.updateConnectionLines = function(){

	if(this.connectionLinesShown){

		var connectiondata = this.getConnectionData();
		this.connectionlines.setCoords(connectiondata.coords);

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

Racmacs.App.prototype.hideErrorLines = function(){

	this.errorLinesShown = false;
	if(this.btns.toggleErrorLines){ this.btns.toggleErrorLines.dehighlight() }

	for(var i=0; i<this.points.length; i++){
		this.points[i].hideErrors();
	}

}


// Add connection lines to a point object
Racmacs.Point.prototype.showErrors = function(){

	if(!this.errorLinesShown){

		this.errorLinesShown = true;

		// Highlight connected points
		var connectedPoints = this.getConnectedPoints();
		connectedPoints.map( x => x.highlight() );

		// Get error data
		var errordata = this.getErrorData();

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
	            lwd : 1,
	            segments : true
			},
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
		var table_dist = from.tableDistTo(to);
		var titer      = from.titerTo(to);
		var map_dist   = from.mapDistTo(to);
		
		// Get the error
		var residual = (map_dist - table_dist);
		if(map_dist > table_dist && titer.charAt(0) == "<"){
		    residual = 0;
		}

		// Deal with greater thans
		if(titer.charAt(0) == ">"){
			residual = map_dist;
		}

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

	if(this.errorLinesShown){

		var data = this.getErrorData();
		this.errorlines.setCoords(data.coords);
		this.errorlines.setColor(data.colors);

	}

}
