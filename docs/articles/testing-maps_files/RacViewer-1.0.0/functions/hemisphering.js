
Racmacs.HemispheringTable = class HemispheringTable extends Racmacs.TableList {

	constructor(viewer){

		// Set up table
		super({
			title   : "Hemisphering / trapped points",
			headers : ["Type", "Name", "Num", "Diagnosis"],
			checkbox_check_fn   : function(){ 
				viewer.showHemisphering()
			},
			checkbox_uncheck_fn : function(){
				viewer.hideHemisphering()
			},
			selectable : false
		});

		// Link to viewer
		this.viewer = viewer;
		viewer.hemispheringTable = this;

		// Add event list
		var noneSelected_deselected_opacity = viewer.styleset.noselections.unhovered.unselected.opacity;
        var plusSelected_deselected_opacity = viewer.styleset.selections.unhovered.unselected.opacity;

        var hemispheringTable = this;
		this.tableHolder.addEventListener("mouseenter", function(){
			if(hemispheringTable.rows.length > 0){
	            viewer.graphics.noneSelected.deselected.opacity = plusSelected_deselected_opacity;
	            viewer.updatePointStyles();
        	}
        });
        this.tableHolder.addEventListener("mouseleave", function(){
        	if(hemispheringTable.rows.length > 0){
	            viewer.graphics.noneSelected.deselected.opacity = noneSelected_deselected_opacity;
	            viewer.updatePointStyles();
	        }
        });

        // Start with checkbox unchecked and disabled by default
        this.checkbox.uncheck(false);
        this.checkbox.disable();

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

			let from = this.coords;
			let to   = data[i].coords;

			while (from.length < 3) from.push(0);
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
	        size         : 4,
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

