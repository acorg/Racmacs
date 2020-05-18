
R3JS.Viewer.prototype.addMapButtons = function(
	buttons = [
		"toggleLockPointSize",
		"errorLines",
		"reflectMap",
		"scalePointsUp",
		"scalePointsDown",
		"downloadMap",
		"viewTable"
	]
){

	var viewer = this;

	// Create button to toggle whether point size is locked
	if(buttons.indexOf("toggleLockPointSize") > -1){
		this.addButton({
			name  : "toggleLockPointSize",
			title : "Lock point size when zooming",
			icon  : Racmacs.icons.locksize(),
			fn    : function(){
				viewer.toggleLockPointSize();
			}
		});
    }

	// Create button to reflect the map
	if(buttons.indexOf("reflectMap") > -1){
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
	}

	// Create button to scale points up
	if(buttons.indexOf("scalePointsUp") > -1){
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
	}

	// Create button to scale points down
	if(buttons.indexOf("scalePointsDown") > -1){
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
	}

	// Create button to download the map
	if(buttons.indexOf("downloadMap") > -1){
		this.addButton({
			name  : "downloadMap",
			title : "Download map file",
			icon  : Racmacs.icons.save(),
			fn    : function(e){
				viewer.saveMap();
			}
		});
	}

	// Create button to view the table
	if(buttons.indexOf("viewTable") > -1){
		this.addButton({
			name  : "viewTable",
			title : "View titer table",
			icon  : Racmacs.icons.table(),
			fn    : function(e){
				viewer.showTable();
			}
		});
	}

}



