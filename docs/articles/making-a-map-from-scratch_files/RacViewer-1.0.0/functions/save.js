
Racmacs.SavePanel = class SavePanel {

	constructor(viewer){

		// Link to viewer
		this.viewer = viewer;
		viewer.savepanel = this;

		this.div = document.createElement("div");
		this.div.classList.add("load-tab");
        this.div.classList.add("shiny-element");

		// Add save map button
        var savemap = new Racmacs.utils.Button({
            label: "Save map",
            fn: function(){ viewer.onSaveMap() }
        });
        this.div.appendChild(savemap.div);

        // Add save table button
        var savetable = new Racmacs.utils.Button({
            label: "Save table",
            fn: function(){ viewer.onSaveTable() }
        });
        this.div.appendChild(savetable.div);

        // Add save coords button
        var savecoords = new Racmacs.utils.Button({
            label: "Save coords",
            fn: function(){ viewer.onSaveCoords() }
        });
        this.div.appendChild(savecoords.div);

	}

}


Racmacs.App.prototype.saveMap = function(){

    var data     = this.data.outputAce();
    var filename = this.data.tableName();
    if(filename === "") filename = "map"
    filename += ".ace";
    var blob = new Blob([data], {type: 'text/ace'});

    if(window.navigator.msSaveOrOpenBlob) {
        window.navigator.msSaveBlob(blob, filename);
    }
    else{
        var elem = window.document.createElement('a');
        elem.href = window.URL.createObjectURL(blob);
        elem.download = filename;        
        document.body.appendChild(elem);
        elem.click();        
        document.body.removeChild(elem);
    }

}





