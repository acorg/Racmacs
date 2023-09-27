
// Show all hemisphering information
Racmacs.Viewer.prototype.showHemisphering = function(data){

	this.hemisphering_shown = true;
	this.points.map( (x,i) => x.showHemisphering(data[i]) );
	this.render();

}

// Hide all hemisphering information
Racmacs.Viewer.prototype.hideHemisphering = function(){

	this.hemisphering_shown = false;
	this.points.map( x => x.hideHemisphering() );
	this.render();

}

// Show any hemisphering information associated with a point
Racmacs.Point.prototype.showHemisphering = function(data){

	// Remove previous hemisphering information
	this.hideHemisphering();

	// Add hemisphering data if found
	if(data.length > 0){

		// Setup to receive info you will pass to plot the arrows
		var coords = [];
		var doubleheaded = [];
		var color = { r:[], g:[], b:[], a:[] };

		// Cycle through the hemisphering information
		for(var i=0; i<data.length; i++){

			let from = this.coords3;
			let to   = data[i].coords;
			while (to.length < 3)   to.push(0);

			coords.push([from, to]);
			doubleheaded.push( data[i].diagnosis == "hemisphering" || data[i].diagnosis == "hemisphering-trapped" );

			// Define double-headedness and color of arrows based on diagnosis
			if (data[i].diagnosis == "trapped" || data[i].diagnosis == "hemisphering-trapped") {
				color.r.push(1); color.g.push(0); color.b.push(0); color.a.push(1);
				color.r.push(1); color.g.push(0); color.b.push(0); color.a.push(1);
			} else {
				color.r.push(0); color.g.push(0); color.b.push(0); color.a.push(1);
				color.r.push(0); color.g.push(0); color.b.push(0); color.a.push(1);
			}

		}

		// Create the actual object you will add to the scene
		this.hemisphering = new this.viewer.mapElements.procrustes({
	        coords       : coords,
	        size         : 3,
	        doubleheaded : doubleheaded,
	        properties : { 
	            lwd : 2,
	            color: color
	        },
	        viewer : this.viewer
	    });

		// Add the object to the scene
		this.viewer.scene.add(this.hemisphering.object);

	}

}

// Hide hemisphering information associated with a point
Racmacs.Point.prototype.hideHemisphering = function(){
	
	if(this.hemisphering){
		this.viewer.scene.remove(this.hemisphering.object);
		this.hemisphering = null;
	}

}

