
R3JS.Viewport.prototype.addMapButtons = function(){

	var viewer = this.viewer;

	// Create button to show viewer info
	this.addButton({
		name  : "toggleLockPointSize",
		title : "Lock point size when zooming",
		icon  : Racmacs.icons.locksize(),
		fn    : function(){
			viewer.toggleLockPointSize();
		}
	});

	// Create button to reflect the map
	this.addButton({
		name  : "reflectMap",
		title : "Reflect map",
		icon  : Racmacs.icons.flip(),
		fn    : function(e){
			if(e.shiftKey){
				viewer.onReflectMap("x");
			} else {
				viewer.onReflectMap("y");
			}
		}
	}, 0);

	// Create button to scale points up
	this.addButton({
		name  : "scalePointsUp",
		title : "Increase point size",
		icon  : Racmacs.icons.scaleup(),
		fn    : function(e){
			if(e.shiftKey){
				viewer.setGridLineWidth(
					viewer.getGridLineWidth()*1.2
				);
			} else {
				viewer.resizePoints(1.2);
			}
		}
	}, 0);

	// Create button to scale points down
	this.addButton({
		name  : "scalePointsDown",
		title : "Decrease point size",
		icon  : Racmacs.icons.scaledown(),
		fn    : function(e){
			if(e.shiftKey){
				viewer.setGridLineWidth(
					viewer.getGridLineWidth()/1.2
				);
			} else {
				viewer.resizePoints(0.8);
			}
		}
	}, 0);

	// Create button to scale points down
	this.addButton({
		name  : "downloadMap",
		title : "Download map file",
		icon  : Racmacs.icons.save(),
		fn    : function(e){
			viewer.saveMap();
		}
	});

}



