
Racmacs.Viewer.prototype.showHemisphering = function(){

	this.hemisphering_shown = true;
	this.points.map( x => x.showHemisphering() );
	this.render();

}

Racmacs.Viewer.prototype.hideHemisphering = function(){

	this.hemisphering_shown = false;
	this.points.map( x => x.hideHemisphering() );
	this.render();

}

Racmacs.Point.prototype.hideHemisphering = function(){
	
	if(this.hemisphering){
		this.viewer.scene.remove(this.hemisphering.object);
		this.hemisphering = null;
	}

}

Racmacs.Point.prototype.showHemisphering = function(){

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






