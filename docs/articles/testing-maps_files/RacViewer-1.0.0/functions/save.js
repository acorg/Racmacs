
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







