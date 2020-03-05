
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
		var noneSelected_deselected_opacity = viewer.graphics.noneSelected.deselected.opacity;
        var plusSelected_deselected_opacity = viewer.graphics.plusSelected.deselected.opacity;

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

	}

}

Racmacs.Viewer.prototype.showHemisphering = function(){

	if(this.data.hemisphering() !== null){

		this.hemisphering_shown = true;
		this.points.map( x => x.showHemisphering() );
		this.render();

		if(this.hemispheringTable){
			this.hemispheringTable.checkbox.check(false);
		}

	} else {
		console.warn('No hemisphering data to show for projection '+this.mapData.projection);
	}

}

Racmacs.Viewer.prototype.hideHemisphering = function(){

	this.hemisphering_shown = false;
	this.points.map( x => x.hideHemisphering() );
	this.render();

	if(this.hemispheringTable){
		this.hemispheringTable.checkbox.uncheck(false);
	}

}

Racmacs.Viewer.prototype.removeHemispheringData = function(){
	
	// Hide hemisphering
	this.hideHemisphering();

	// Remove hemisphering data from points
	for(var i=0; i<this.points.length; i++){
		this.points[i].removeHemispheringData();
	}

	// Remove hemisphering data from table
	if(this.hemispheringTable){ 
        this.hemispheringTable.clear();
        this.hemispheringTable.showPlaceholder();
    }

}

Racmacs.Viewer.prototype.addHemispheringData = function(data){

	// Remove any existing hemisphering data
	this.removeHemispheringData();

	// Add hemisphering data to the points
	for(var i=0; i<data.length; i++){
		if(data[i].type == "antigen"){
			this.antigens[data[i].num - 1].addHemispheringData(data[i]);
			if(this.antigens[data[i].num - 1].name !== data[i].name){
				throw("Names don't match");
			}
		}
		if(data[i].type == "serum"){
			this.sera[data[i].num - 1].addHemispheringData(data[i]);
			if(this.sera[data[i].num - 1].name !== data[i].name){
				throw("Names don't match");
			}
		}
	}

	// Add hemisphering data to the table
	if(this.hemispheringTable){

		var viewer = this;
		this.hemispheringTable.hidePlaceholder();
		
		for(var i=0; i<data.length; i++){
			this.hemispheringTable.checkbox.enable();
			this.hemispheringTable.addRow({
				content : [
					data[i].type,
					data[i].name,
					data[i].num,
					data[i].diagnosis
				],
				hoverfn : function(){
					if(this.data.type == "antigen"){
						viewer.antigens[this.data.num - 1].hover();
						if(!viewer.hemisphering_shown){
							viewer.antigens[this.data.num - 1].showHemisphering();
						}
					}
					if(this.data.type == "serum"){
						viewer.sera[this.data.num - 1].hover();
						if(!viewer.hemisphering_shown){
							viewer.sera[this.data.num - 1].showHemisphering();
						}
					}
				},
				dehoverfn : function(){
					if(this.data.type == "antigen"){
						viewer.antigens[this.data.num - 1].dehover();
						if(!viewer.hemisphering_shown){
							viewer.antigens[this.data.num - 1].hideHemisphering();
						}
					}
					if(this.data.type == "serum"){
						viewer.sera[this.data.num - 1].dehover();
						if(!viewer.hemisphering_shown){
							viewer.sera[this.data.num - 1].hideHemisphering();
						}
					}
				},
				data : data[i]
			});
		}
	}

}

Racmacs.Point.prototype.removeHemispheringData = function(){
	
	if(this.hemisphering){
		this.viewer.scene.remove(this.hemisphering.object);
		this.hemisphering = null;
	}

}

Racmacs.Point.prototype.addHemispheringData = function(data){

	this.removeHemispheringData();

	var from = this.coords;
	var to = [0,0,1];

	to[0] = data.coords1;
	to[1] = data.coords2;
	if(data.coords3) to[2] = data.coords3;

	this.hemisphering = new R3JS.element.glarrow({
		coords : [[from, to]],
		doubleheaded : data.diagnosis === "hemisphering",
		viewer : this.viewer
	});

	this.viewer.scene.add(this.hemisphering.object);
	this.hemisphering.hide();


}

Racmacs.Point.prototype.showHemisphering = function(){
	if(this.hemisphering){
		this.hemisphering.show();
	}
}

Racmacs.Point.prototype.hideHemisphering = function(){
	if(this.hemisphering){
		this.hemisphering.hide();
	}
}






