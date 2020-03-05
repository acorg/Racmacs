
// CONNECTION LINES
// General viewer toggling
Racmacs.Viewer.prototype.toggleConnectionLines = function(){

	if(!this.connectionLinesShown){
		this.showConnectionLines();
	} else {
		this.hideConnectionLines();
	}

}

Racmacs.Viewer.prototype.showConnectionLines = function(){

	console.log("Connection Lines On");
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

Racmacs.Viewer.prototype.hideConnectionLines = function(){

	console.log("Connection Lines Off");
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
Racmacs.Viewer.prototype.toggleErrorLines = function(){

	if(!this.errorLinesShown){
		this.showErrorLines();
	} else {
		this.hideErrorLines();
	}

}

Racmacs.Viewer.prototype.showErrorLines = function(){

	console.log("Error Lines On");
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

Racmacs.Viewer.prototype.hideErrorLines = function(){

	console.log("Error Lines Off");
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
Racmacs.Point.prototype.getErrorData = function(){

	// Get connected points
	var connectedPoints = this.getConnectedPoints();

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
		var error_vector = new THREE.Vector3().subVectors(
			from.coordsVector, 
			to.coordsVector
		);
	  	error_vector.setLength(residual/2);

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

		// Update the coordinate data
		data.coords[i*4]   = from.coordsVector.toArray();
		data.coords[i*4+1] = from.coordsVector.clone().sub(error_vector).toArray();
		data.coords[i*4+2] = to.coordsVector.toArray();
		data.coords[i*4+3] = to.coordsVector.clone().add(error_vector).toArray();

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


// function bind_connections(viewport){

//     // Set variables
// 	viewport.connectionLines = false;
// 	viewport.errorLines      = false;
// 	var connectionLines      = [];

// 	// Showing and hiding connection lines
// 	viewport.show_connectionLines = function(){

// 		// Get the objects to show connections on, if points
// 	    // are selected show on the selected points, if no 
// 	    // points selected, show on all points
// 	    var selected_objects = this.selected_pts;
// 	    if(selected_objects.length > 0){

// 	    	var connectionObjects = [];
// 		    for(var i=0; i<selected_objects.length; i++){
// 		        connectionObjects.push(this.points[selected_objects[i]]);
// 		    }

// 	    } else {

// 	    	connectionObjects = this.points;
	    	
// 	    }

// 	    // Check that the number of objects is not too large
// 	    if(this.points.length > 2000){
// 	    	this.notifications.error("Cannot show connection lines for so many points");
// 	    	return(null);
// 	    }

// 	    // Update error lines buffer
// 	    this.updateConnectionLinesBuffer();
        
//         // Trigger any associated events
// 		if(viewport.onConnectionsOn){ viewport.onConnectionsOn() }
// 		if(viewport.errorLines)     { viewport.hide_errorLines() }
	    
// 	    // Mark as on
// 	    viewport.connectionLines = true;

// 	    // Show any connection lines
// 	    for(var i=0; i<connectionObjects.length; i++){
// 		    connectionObjects[i].showConnections();
// 	    }

// 	    // Render scene
// 	    viewport.render();

// 	};

// 	viewport.hide_connectionLines = function(){

// 		if(viewport.connectionLines){
        
// 	        // Trigger any associated events
// 			if(viewport.onConnectionsOff){ viewport.onConnectionsOff() }
// 		    viewport.connectionLines = false;

// 		    // Hide connections on any selected points
// 		    for(var i=0; i<viewport.points.length; i++){
// 		        viewport.points[i].hideConnections();
// 		    }

// 		    // Render scene
// 		    viewport.render();

// 	    }

// 	};
	
// 	viewport.toggle_connectionLines = function(){
// 	  if(viewport.connectionLines){
// 	    viewport.hide_connectionLines();
// 	  } else{
// 	    viewport.show_connectionLines();
// 	  }
// 	};
    

//     // For drawing connections from a point
//     viewport.Point.prototype.showConnections = function(){

//     	this.connectionLines = true;
        
//         if(this.type == "ag"){
//         	var partners = viewport.sera;
//         } else {
//         	var partners = viewport.antigens;
//         }

//         var connections = this.getConnections();
//         for(var i=0; i<connections.length; i++){
//             updateConnectionLine(this, partners[connections[i]]);
//             partners[connections[i]].highlight();
//         }

//     }
    
//     // For removing connections from a point
//     viewport.Point.prototype.hideConnections = function(){

//     	this.connectionLines = false;
    	
//         if(this.type == "ag"){
//         	var partners = viewport.sera;
//         } else {
//         	var partners = viewport.antigens;
//         }

//         var connections = this.getConnections();
//         for(var i=0; i<connections.length; i++){
//         	hideConnectionLine(this, partners[connections[i]]);
//             partners[connections[i]].dehighlight();
//         }

//     }

//     viewport.Point.prototype.updateConnections = function(
//     	updatePartners = true
//     	){
        
//         if(this.type == "ag"){
//         	var partners = viewport.sera;
//         } else {
//         	var partners = viewport.antigens;
//         }
// 	    var connections = this.getConnections();

//         // Update connections on this object
//         if(this.connectionLines){
// 	        for(var i=0; i<connections.length; i++){
// 	            updateConnectionLine(this, partners[connections[i]]);
// 	        }
//         }

        
//         // Update connections on partners
//         if(updatePartners){

//         	for(var i=0; i<connections.length; i++){
//         		partners[connections[i]].updateConnections(updatePartners = false);
// 	        }

//         }

//     }

  
//     // Drawing the connection line
// 	updateConnectionLine = function(from, to){
      	
//       	if(!to.coords_na){

// 			var col         = to.getPrimaryColor();
//             var from_coords = from.coords;
// 			var to_coords   = to.coords;

// 			// Draw line
// 			var connectionLines = viewport.geometries.connectionLines;
// 	        connectionLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 ]     = from_coords[0];
// 	        connectionLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 1 ] = from_coords[1];
// 	        connectionLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 2 ] = from_coords[2];

// 	        connectionLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 3 ] = to_coords[0];
// 	        connectionLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 4 ] = to_coords[1];
// 	        connectionLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 5 ] = to_coords[2];
// 	        connectionLines.geometry.attributes.position.needsUpdate = true;

// 	    }
	
// 	};

// 	// Hiding a connection line
// 	hideConnectionLine = function(from, to){

//         // Hide line
// 		var connectionLines = viewport.geometries.connectionLines;
//         connectionLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 ]     = null;
//         connectionLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 1 ] = null;
//         connectionLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 2 ] = null;

//         connectionLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 3 ] = null;
//         connectionLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 4 ] = null;
//         connectionLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 5 ] = null;
//         connectionLines.geometry.attributes.position.needsUpdate = true;

// 	}

	


// 	// For drawing connections from a point
//     viewport.Point.prototype.showErrors = function(){

//     	this.errorLines = true;
        
//         if(this.type == "ag"){
//         	var partners = viewport.sera;
//         } else {
//         	var partners = viewport.antigens;
//         }

//         var connections = this.getConnections();
//         for(var i=0; i<connections.length; i++){

//         	var errorData = calculate_errorLineData(this, partners[connections[i]]);
//             updateErrorLine(this, partners[connections[i]], errorData);
//             partners[connections[i]].highlight();

//         }

//     }

//     // For removing errors from a point
//     viewport.Point.prototype.hideErrors = function(){

//     	this.errorLines = false;
    	
//         if(this.type == "ag"){
//         	var partners = viewport.sera;
//         } else {
//         	var partners = viewport.antigens;
//         }

//         var connections = this.getConnections();
//         for(var i=0; i<connections.length; i++){
        	
//             // Remove the error line to and from the partner if the 
//             // partner does not have error lines shown
//         	if(!partners[connections[i]].errorLines){
//         	    hideErrorLine(this, partners[connections[i]]);
//         		hideErrorLine(partners[connections[i]], this);
//         	}

//         	// Dehighlight the partner by 1
//             partners[connections[i]].dehighlight();

//         }

//     }

//     viewport.Point.prototype.updateErrors = function(){

//     	if(this.type == "ag"){
//         	var partners = viewport.sera;
//         } else {
//         	var partners = viewport.antigens;
//         }

//         // Update errors on this object
//         var connections = this.getConnections();    
//         for(var i=0; i<connections.length; i++){
//         	var errorData = calculate_errorLineData(this, partners[connections[i]]);
//             updateErrorLine(this, partners[connections[i]], errorData);
//         }

//     }


// 	// Showing and hiding error lines
// 	viewport.toggle_errorLines = function(){
// 	  if(viewport.errorLines){
// 	    viewport.hide_errorLines();
// 	  } else{
// 	    viewport.show_errorLines();
// 	  }
// 	  viewport.render();
// 	}

// 	viewport.show_errorLines = function(){

// 		// Get the objects to show connections on, if points
// 	    // are selected show on the selected points, if no 
// 	    // points selected, show on all points
// 	    var selected_objects = this.selected_pts;
// 	    if(selected_objects.length > 0){

// 	    	var connectionObjects = [];
// 		    for(var i=0; i<selected_objects.length; i++){
// 		        connectionObjects.push(this.points[selected_objects[i]]);
// 		    }

// 	    } else {

// 	    	connectionObjects = this.points;
	    	
// 	    }

// 	    // Check that the number of objects is not too large
// 	    if(this.points.length > 2000){
// 	    	this.notifications.error("Cannot show error lines for so many points");
// 	    	return(null);
// 	    }

// 	    // Update error lines buffer
// 	    this.updateErrorLinesBuffer();

// 	    // Toggle error line on
// 	    this.errorLines = true;

// 	    // Trigger any associated functions
// 		if(this.onErrorsOn)      { this.onErrorsOn()           }
// 		if(this.connectionLines) { this.hide_connectionLines() }
        
//         // Show the errors on all the connectionPoints
// 	    for(var i=0; i<connectionObjects.length; i++){
// 	        connectionObjects[i].showErrors();
// 	    }

// 	    // Render the scene
// 	    this.render();

// 	};

// 	viewport.hide_errorLines = function(){
		
// 		if(viewport.errorLines){

// 	        // Toggle error line off
// 		    viewport.errorLines = false;

// 		    // Trigger any associated functions
// 			if(viewport.onErrorsOff){ viewport.onErrorsOff() }

// 			// Hide any error lines
// 		    for(var i=0; i<viewport.points.length; i++){
// 		        viewport.points[i].hideErrors();
// 		    }

// 		    // Render the scene
// 		    viewport.render();

// 	    }

// 	};

// 	// Add geometry buffer for error lines
// 	viewport.updateErrorLinesBuffer = function(){

// 		// Remove any existing buffer from plot
// 		if(this.geometries.errorLines){
// 			this.scene.plotPoints.remove(this.geometries.errorLines);
// 		}
        
//         var geometry  = new THREE.BufferGeometry();
//         var positions = new Float32Array( viewport.points.length * viewport.points.length * 2 * 3 );
//         var colors    = new Float32Array( viewport.points.length * viewport.points.length * 2 * 3 );
//         var visible   = new Float32Array( viewport.points.length * viewport.points.length * 2 );
        
//         geometry.addAttribute( 'position', new THREE.BufferAttribute( positions, 3 ) );
//         geometry.addAttribute( 'color',    new THREE.BufferAttribute( colors, 3 ) );
//         geometry.addAttribute( 'visible',  new THREE.BufferAttribute( visible, 1 ) );
	    
// 	    var material = new THREE.LineBasicMaterial({ 
// 	    	linewidth : 2,
// 	    	vertexColors: THREE.VertexColors
// 	    });
// 	    // var material = new THREE.ShaderMaterial( {
//      //        vertexShader:   get_lineVertex_shader(),
//      //        fragmentShader: get_lineFragment_shader()
//      //    } );

//         this.geometries.errorLines = new THREE.LineSegments(geometry, material);
// 	    this.geometries.errorLines.frustumCulled  = false;

// 	    // Add the new buffer to the scene
// 	    this.scene.plotPoints.add(this.geometries.errorLines);
		
// 	}

// 	// Drawing the connection line
// 	updateErrorLine = function(from, to, errorLineData){
      	
//       	if(!to.coords_na){

// 			var errorLines = viewport.geometries.errorLines;

// 			// Update the lines on the from point
// 	        errorLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 ]     = errorLineData.line1[0][0];
// 	        errorLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 1 ] = errorLineData.line1[0][1];
// 	        errorLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 2 ] = errorLineData.line1[0][2];

// 	        errorLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 3 ] = errorLineData.line1[1][0];
// 	        errorLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 4 ] = errorLineData.line1[1][1];
// 	        errorLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 5 ] = errorLineData.line1[1][2];

// 	        // Update the lines on the to point
// 	        errorLines.geometry.attributes.position.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 ]     = errorLineData.line2[0][0];
// 	        errorLines.geometry.attributes.position.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 + 1 ] = errorLineData.line2[0][1];
// 	        errorLines.geometry.attributes.position.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 + 2 ] = errorLineData.line2[0][2];

// 	        errorLines.geometry.attributes.position.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 + 3 ] = errorLineData.line2[1][0];
// 	        errorLines.geometry.attributes.position.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 + 4 ] = errorLineData.line2[1][1];
// 	        errorLines.geometry.attributes.position.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 + 5 ] = errorLineData.line2[1][2];
	        
// 	        errorLines.geometry.attributes.position.needsUpdate = true;


// 	        // Update the colors on the from point
// 	        errorLines.geometry.attributes.color.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 ]     = errorLineData.color[0];
// 	        errorLines.geometry.attributes.color.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 1 ] = errorLineData.color[1];
// 	        errorLines.geometry.attributes.color.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 2 ] = errorLineData.color[2];

// 	        errorLines.geometry.attributes.color.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 3 ] = errorLineData.color[0];
// 	        errorLines.geometry.attributes.color.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 4 ] = errorLineData.color[1];
// 	        errorLines.geometry.attributes.color.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 5 ] = errorLineData.color[2];

// 	        // Update the colors on the to point
// 	        errorLines.geometry.attributes.color.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 ]     = errorLineData.color[0];
// 	        errorLines.geometry.attributes.color.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 + 1 ] = errorLineData.color[1];
// 	        errorLines.geometry.attributes.color.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 + 2 ] = errorLineData.color[2];

// 	        errorLines.geometry.attributes.color.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 + 3 ] = errorLineData.color[0];
// 	        errorLines.geometry.attributes.color.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 + 4 ] = errorLineData.color[1];
// 	        errorLines.geometry.attributes.color.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 + 5 ] = errorLineData.color[2];
	        
// 	        errorLines.geometry.attributes.color.needsUpdate = true;


// 	        // // Update the visibility on the from point
// 	        // errorLines.geometry.attributes.visible.array[ viewport.points.length*from.pIndex*2 + to.pIndex*2     ] = 1;
// 	        // errorLines.geometry.attributes.visible.array[ viewport.points.length*from.pIndex*2 + to.pIndex*2 + 1 ] = 1;

// 	        // // Update the visibility on the to point
// 	        // errorLines.geometry.attributes.visible.array[ viewport.points.length*to.pIndex*2 + from.pIndex*2     ] = 1;
// 	        // errorLines.geometry.attributes.visible.array[ viewport.points.length*to.pIndex*2 + from.pIndex*2 + 1 ] = 1;

// 	        // errorLines.geometry.attributes.visible.needsUpdate = true;

// 	    }
	
// 	};

// 	// Hiding a connection line
// 	hideErrorLine = function(from, to){

//         // Hide line
// 		var errorLines = viewport.geometries.errorLines

//         // // Update the visibility on the from point
//         // errorLines.geometry.attributes.visible.array[ viewport.points.length*from.pIndex*2 + to.pIndex*2     ] = 0;
//         // errorLines.geometry.attributes.visible.array[ viewport.points.length*from.pIndex*2 + to.pIndex*2 + 1 ] = 0;

//         // // Update the visibility on the to point
//         // errorLines.geometry.attributes.visible.array[ viewport.points.length*to.pIndex*2 + from.pIndex*2     ] = 0;
//         // errorLines.geometry.attributes.visible.array[ viewport.points.length*to.pIndex*2 + from.pIndex*2 + 1 ] = 0;

//         // errorLines.geometry.attributes.visible.needsUpdate = true;

//         // Update the lines on the from point
//         errorLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 ]     = null;
//         errorLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 1 ] = null;
//         errorLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 2 ] = null;

//         errorLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 3 ] = null;
//         errorLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 4 ] = null;
//         errorLines.geometry.attributes.position.array[ viewport.points.length*from.pIndex*3*2 + to.pIndex*3*2 + 5 ] = null;

//         // Update the lines on the to point
//         errorLines.geometry.attributes.position.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 ]     = null;
//         errorLines.geometry.attributes.position.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 + 1 ] = null;
//         errorLines.geometry.attributes.position.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 + 2 ] = null;

//         errorLines.geometry.attributes.position.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 + 3 ] = null;
//         errorLines.geometry.attributes.position.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 + 4 ] = null;
//         errorLines.geometry.attributes.position.array[ viewport.points.length*to.pIndex*3*2 + from.pIndex*3*2 + 5 ] = null;
        
//         errorLines.geometry.attributes.position.needsUpdate = true;

// 	}



// 	// Add geometry buffer for connection lines
// 	viewport.updateConnectionLinesBuffer = function(){

// 		// Remove any existing buffer from plot
// 		if(this.geometries.connectionLines){
// 			this.scene.plotPoints.remove(this.geometries.connectionLines);
// 		}
        
//         var geometry  = new THREE.BufferGeometry();
//         var positions = new Float32Array( viewport.points.length * viewport.points.length * 3 * 2 );
//         geometry.addAttribute( 'position', new THREE.BufferAttribute( positions, 3 ) );

//         var material = new THREE.LineBasicMaterial({
//         	color : "#000000",
//         	linewidth : 2
//         });
//         material.transparent = true;
//         material.opacity = 0.2;

// 	    this.geometries.connectionLines = new THREE.LineSegments(geometry, material);
// 	    this.geometries.connectionLines.frustumCulled = false;
//         // this.geometries.connectionLines.renderOrder = -100;

// 	    // Add the new buffer to the scene
// 	    this.scene.plotPoints.add(this.geometries.connectionLines);
		
// 	}
    


// 	calculate_errorLineData = function(from, to){

// 		// Work out whether point is too close or far away
// 		var table_dist = from.tableDistTo(to);
// 		var titer      = from.titerTo(to);
// 		var map_dist   = from.mapDistTo(to);
		
// 		// Get the error
// 		var residual = (map_dist - table_dist);
// 		if(map_dist > table_dist && titer.charAt(0) == "<"){
// 		    residual = 0;
// 		}

// 		// Deal with greater thans
// 		if(titer.charAt(0) == ">"){
// 			residual = map_dist;
// 		}

// 		// Calculate the error vector
// 		var error_vector = new THREE.Vector3().subVectors(
// 			from.coordsVector, 
// 			to.coordsVector
// 		);
// 	  	error_vector.setLength(residual/2);

// 	  	// Work out the color
// 		var col;
// 		if(residual < 0){ col = [1,0,0] }
// 		else            { col = [0,0,1] }

// 		// Return the data
// 		return({
// 			line1 : [from.coordsVector.toArray(), from.coordsVector.clone().sub(error_vector).toArray()],
// 			line2 : [to.coordsVector.toArray(), to.coordsVector.clone().add(error_vector).toArray()],
// 			color : col
// 		})

// 	}

// }
