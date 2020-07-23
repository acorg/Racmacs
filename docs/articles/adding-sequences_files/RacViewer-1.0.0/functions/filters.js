
Racmacs.Filter = class Filter {

	constructor(viewer){

		this.viewer = viewer;
		viewer.filter = this;
		this.filterOpts = {};

		// Create div
		this.div = document.createElement( 'div' );

		// Add options box
		this.options = document.createElement("div");
		this.div.appendChild(this.options);

	}

	update(){

        // Get variables
		var pt_objects = this.viewer.points;
		var filterBox  = this.options;
		var viewer     = this.viewer;
		var filterOpts = this.filterOpts;

		// Clear the options box
		filterBox.innerHTML = "";

		// ag/sr options
		var agsrOptHolder = document.createElement("div");
		filterOpts.agsr = [];
		agsrOptHolder.classList.add("filter-opt-col");
		filterBox.appendChild(agsrOptHolder);
		var agsrOptTitle = document.createElement("div");
		agsrOptTitle.innerHTML = "Type";
		agsrOptTitle.classList.add("filter-opt-title");
		agsrOptHolder.appendChild(agsrOptTitle);
		for(var i=0; i<2; i++){
			if(i==0){ 
				var name = "Antigens";
				var type = "ag";
			}
			if(i==1){ 
				var name = "Sera";
				var type = "sr";
			}
			var agsrOptBox = new Racmacs.utils.Checkbox({
				text  : name,
				value : type,
				uncheck_fn : function(){ viewer.filter_selection() },
				check_fn   : function(){ viewer.filter_selection() }
		    });
		    filterOpts.agsr.push(agsrOptBox.checkbox);
		    agsrOptHolder.appendChild(agsrOptBox.div);
		}

	}

}


Racmacs.Viewer.prototype.filter_selection = function(){

	var filterOpts = this.filter.filterOpts;

    // Get antigen sera selections
    var agsrOpts = [];
    for(var i=0; i<filterOpts.agsr.length; i++){
    	if(filterOpts.agsr[i].checked){
    		agsrOpts.push(filterOpts.agsr[i].value);
    	}
    }

    // Filter selections
    var objects = this.points;
    var deselected_objects = [];
    
    selectionVars = [];
    selectionOpts = [];
    selectionOpts.push(agsrOpts);
    selectionVars.push("type");
    // selectionOpts.push(clusterOpts);
    // selectionVars.push("cluster");
    
    for(var j=0; j<selectionOpts.length; j++){
    	var opts = selectionOpts[j];
    	var vars = selectionVars[j];
	    if(opts.length > 0){
	    	for(var i=0; i<objects.length; i++){
	    		if(opts.indexOf(objects[i][vars]) == -1){
	    			deselected_objects.push(i);
	    		}
	    	}
	    }
    }

    for(var i=0; i<objects.length; i++){
		if(deselected_objects.indexOf(i) != -1){
            objects[i].deselect();
		} else {
			objects[i].select();
		}
	}

    // Deselect all if nothing selected
    if(agsrOpts.length == 0){
    	this.deselectAll();
    }
    
    // Mark all the points
    this.updatePointStyles();

}



