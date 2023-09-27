
// EVENTS
R3JS.Viewer.prototype.eventListeners.push({
	name : "point-selected",
	fn : function(e){
		let point  = e.detail.point;
		let viewer = e.detail.viewer;
		if(viewer.sequences){
			// Add a set timeout event so that other events don't have to wait
			// viewer.sequences.showLoading();
			window.setTimeout( 
				f => viewer.sequences.updateSequenceTableView(), 100
			);
		}
	}
});

R3JS.Viewer.prototype.eventListeners.push({
	name : "point-deselected",
	fn : function(e){
		let point  = e.detail.point;
		let viewer = e.detail.viewer;
		if(viewer.sequences){
			// Add a set timeout event so that other events don't have to wait
			// viewer.sequences.showLoading();
			window.setTimeout( 
				f => viewer.sequences.updateSequenceTableView(), 100
			);
		}
	}
});

R3JS.Viewer.prototype.eventListeners.push({
	name : "point-hovered",
	fn : function(e){
		let point  = e.detail.point;
		let viewer = e.detail.viewer;
		if(viewer.sequences && point.sequencerow !== null){
			viewer.sequences.highlightRow(point.sequencerow);
		}
	}
});

R3JS.Viewer.prototype.eventListeners.push({
	name : "point-dehovered",
	fn : function(e){
		let point  = e.detail.point;
		let viewer = e.detail.viewer;
		if(viewer.sequences && point.sequencerow !== null){
			viewer.sequences.dehighlightRow(point.sequencerow);
		}
	}
});

Racmacs.App.prototype.showSequences = function(){

	if(!this.sequenceswindow){
	    
		// Style the button
	    this.btns["viewSequences"].style.color = "#0eb5f7";

		var sequenceswindow = window.open("", "", "width=600,height=600");
	    window.addEventListener("beforeunload", e => {
	    	this.hideSequences();
	    });
	    sequenceswindow.addEventListener("beforeunload", e => {
	    	this.hideSequences();
	    });

	    // View the table
	    var holder = document.createElement("div");
	    holder.style.height   = "100vh";
	    holder.style.width    = "100vw";
	    holder.style.overflow = "scroll";
	    holder.style.position = "relative";

	    var holder2 = document.createElement("div");
	    holder.appendChild(holder2);

	    sequenceswindow.document.body.style.margin = 0;
	    sequenceswindow.document.body.style.height = "100vh";
	    sequenceswindow.document.body.style.width  = "100vw";
	    sequenceswindow.document.body.style.overflow = "hidden";
	    sequenceswindow.document.body.style.backgroundColor = "#fff";

	    // var style = document.createElement("style");
		// sequenceswindow.document.head.appendChild(style);
		// style.sheet.insertRule(".sequences-div div div:nth-child(2n) { background-color: #f6f8fa }", 0);

	    sequenceswindow.document.body.appendChild(holder);
		this.sequences = new Racmacs.SequenceTable(
			this, 
			holder2
		);
		this.sequenceswindow = sequenceswindow;

	} else {

		this.sequenceswindow.focus();

	}

}

Racmacs.App.prototype.hideSequences = function(){

	if(this.sequenceswindow){
		let sequenceswindow = this.sequenceswindow;
    	this.sequenceswindow = null;
		sequenceswindow.close();
	}

	this.sequences = null;
	this.btns["viewSequences"].style.color = null;

}





Racmacs.SequenceTable = class SequenceTable {

	constructor(viewer, container){

		this.viewer = viewer;

		this.div = document.createElement("div");
		container.appendChild(this.div);
		this.div.style.width  = "fit-content";
		this.div.style.minWidth = "100vw";
		this.div.style.minHeight = "100vh";
		this.div.style.boxSizing = "border-box";
		this.div.style.fontFamily = "sans-serif";

		this.positionsearch = document.createElement("input");
		this.positionsearch.style.height = "28px";
		this.positionsearch.style.fontSize = "12px";
		this.positionsearch.style.boxSizing = "border-box";
		this.positionsearch.style.borderStyle = "none";
		this.positionsearch.style.backgroundColor = "#222222";
		this.positionsearch.style.margin = 0;
		this.positionsearch.style.paddingLeft = "8px";
		this.positionsearch.style.paddingRight = "8px";
		this.positionsearch.style.color = "#ffffff";
		this.positionsearch.style.width = "100%";
		this.positionsearch.setAttribute("placeholder", "Specify position");
		this.div.appendChild(this.positionsearch);
		this.positionsearch.addEventListener("input", e => {
			this.updateSequenceTableView();
		});

		this.tablediv = document.createElement("div");
		this.tablediv.style.width = "fit-content";
		this.tablediv.style.overflow = "scroll";
		this.tablediv.style.fontSize = "12px";
		this.tablediv.style.whiteSpace = "nowrap";
		this.tablediv.classList.add("sequences-div");
		this.div.appendChild(this.tablediv);

		// Add mouse event listeners to table
        var noneSelected_deselected_opacity = this.viewer.styleset.selections.unhovered.unselected.opacity;
		var plusSelected_deselected_opacity = this.viewer.styleset.noselections.unhovered.unselected.opacity;

		this.tablediv.addEventListener("mouseenter", function(){
			viewer.styleset.noselections.unhovered.unselected.opacity = plusSelected_deselected_opacity;
            viewer.updatePointStyles();
        });
        this.tablediv.addEventListener("mouseleave", function(){
        	viewer.styleset.noselections.unhovered.unselected.opacity = noneSelected_deselected_opacity;
            viewer.updatePointStyles();
        });

        // Show the loading div
        this.loadingdiv = document.createElement("div");
        this.loadingdiv.innerHTML = "Loading sequences...";
        this.div.appendChild(this.loadingdiv);
        this.loadingdiv.style.position = "fixed";
        this.loadingdiv.style.top = "28px";
        this.loadingdiv.style.left = 0;
        this.loadingdiv.style.right = 0;
        this.loadingdiv.style.bottom = 0;
        this.loadingdiv.style.padding = "12px";
        this.loadingdiv.style.display = "none";
        this.loadingdiv.style.backgroundColor = "#fff";
        this.loadingdiv.style.color = "#666";

        // Populate the table
		this.showLoading();
        window.setTimeout( 
			f => this.populateTable(), 10
		);

	}

	populateTable(){

		// Clear row and cell records
		this.rows      = [];
		this.cells     = [];
		this.collabels = [];
		this.labels    = [];

		// Wipe any previous sequence rows
		this.viewer.points.map( p => p.sequencerow = null );

		// Assemble point and sequence data
		let points = [];
		let sequences = [];

		let ag_sequences = this.viewer.data.agSequences();
		let sr_sequences = this.viewer.data.srSequences();

		if(ag_sequences !== null){
			points    = points.concat(this.viewer.antigens);
			sequences = sequences.concat(ag_sequences);
		}

		if(sr_sequences !== null){
			points    = points.concat(this.viewer.sera);
			sequences = sequences.concat(sr_sequences);
		}

		this.points = points;
		this.sequences = sequences;

		// Cycle through and create antigen labels
		let color = new THREE.Color();
		let div;
		let row;

		let name_div = document.createElement("div");
		name_div.style.display = "inline-block";
		this.tablediv.appendChild(name_div);

		// Add a spacer div
		div = document.createElement("div");
		div.style.height = "38px";
		name_div.appendChild(div);

		points.map((p, i) => {
			
			div = document.createElement("div");
			div.style.whiteSpace = "nowrap";
			div.innerHTML = p.type.toUpperCase()+": "+p.name;
			div.style.border = "0.5px solid #dfe2e5";
		    div.style.height = "28px";
		    div.style.boxSizing = "border-box";
		    div.style.lineHeight = "28px";
		    div.style.textAlign = "left";
		    div.style.paddingLeft = "8px";
		    div.style.paddingRight = "8px";

		    div.addEventListener("mouseenter", e => p.hover());
			div.addEventListener("mouseleave", e => p.dehover());

		    this.labels.push(div);
			name_div.appendChild(div);
			p.sequencerow = i;

		});

		// Fix div width based on label content
		name_div.style.width = name_div.offsetWidth+"px";

		// Create position labels
		let seq_div = document.createElement("div");
		seq_div.style.display = "inline-block";
		this.tablediv.appendChild(seq_div);

		row = document.createElement("div");
		row.style.whiteSpace = "nowrap";
		seq_div.appendChild(row);

		sequences[0].map((aa, i) => {

			div = document.createElement("div");
			div.style.border = "0.5px solid #dfe2e5";
			div.style.width = "28px";
		    div.style.height = "38px";
		    div.style.display = "inline-block";
		    div.style.boxSizing = "border-box";
		    div.style.lineHeight = "28px";
		    div.style.textAlign = "center";
		    div.style.writingMode = "vertical-rl";
			div.innerHTML = i+1;

			this.collabels.push(div);
			row.appendChild(div);

		});

		// Show sequences
		sequences.map((seq, i) => {
			row = document.createElement("div");
			seq_div.appendChild(row);
			this.rows.push(row);
			let cellrow = [];

			seq.map((aa, j) => {
				color.setStyle(Racmacs.ColorAA(aa));
				div = document.createElement("div");
				div.style.border = "0.5px solid #dfe2e5";
				div.style.width = "28px";
			    div.style.height = "28px";
			    div.style.display = "inline-block";
			    div.style.boxSizing = "border-box";
			    div.style.lineHeight = "28px";
			    div.style.textAlign = "center";
			    div.style.backgroundColor = "#"+color.getHexString()+"80";
				div.innerHTML = aa;
				
				cellrow.push(div);
				row.appendChild(div);

			});

			this.cells.push(cellrow);

		});

		// Update the view
		this.updateSequenceTableView();

		// Hide loading
		this.hideLoading();

	}

	updateSequenceTableView(){

		// Parse the search value
		var searchval = this.positionsearch.value;
		var positions = [];
		var sequences;

		// Show and hide rows based on selected points
		const num_selected = this.viewer.selected_pts.length;
		this.points.map((p,i) => {
			if(p.selected && num_selected > 0) this.showRow(i)
			else                               this.hideRow(i)
		});

		if(searchval == ""){ 

			// Get sequences from relevant points
			sequences = [];
			this.points.map((p,i) => {
			    if(p.selected && num_selected > 0) sequences.push(this.sequences[i])
		    });

			// Only show positions where aas of selected strains differ
			var positions_shown = [];
			if (sequences.length > 0) {
				for(var i=0; i<sequences[0].length; i++){
					if(num_selected == 1){
						positions_shown.push(i+1)
					} else {
					    var unique_seq = [];
						sequences.map( s => { 
							if(s[i] != "." && unique_seq.indexOf(s[i]) === -1){
								unique_seq.push(s[i]);
							}
						});
						if(unique_seq.length > 1){
							positions_shown.push(i+1);
						}
					}
				}
			}
			
			// Show relevant positions
			this.showPositions(positions_shown);

		} else if(searchval.toLowerCase() == "b7"){
			this.showPositions([145, 155, 156, 158, 159, 189, 193]);
		} else {
			let pos = Number(searchval);
			if(!isNaN(pos)) this.showPositions([pos])
		}

		// Hide the loading info
		this.hideLoading();

	}

	showPositions(pos){

		// Show and hide column labels
		this.collabels.map((cell, i) => {
			if(pos.indexOf(i+1) === -1) cell.style.display = "none"
			else                        cell.style.display = "inline-block"
		});

		// Show and hide row cells
		this.cells.map( cellrow => {
			cellrow.map((cell, i) => {
				if(pos.indexOf(i+1) === -1) cell.style.display = "none"
				else                        cell.style.display = "inline-block"
			});
		});

	}

	highlightRow(row){
		this.labels[row].style.backgroundColor = "lightblue";
		this.rows[row].style.backgroundColor = "lightblue";
	}

	dehighlightRow(row){
		this.labels[row].style.backgroundColor = "";
		this.rows[row].style.backgroundColor = "";
	}

	hideRow(row){
		this.labels[row].style.display = "none";
		this.rows[row].style.display = "none";
	}

	showRow(row){
		this.labels[row].style.display = "";
		this.rows[row].style.display = "";
	}

	showLoading(){
		this.loadingdiv.style.display = "";
	}

	hideLoading(){
		this.loadingdiv.style.display = "none";
	}

}

Racmacs.ColorAA = function(aa){

	if(["G","A","S","T"].indexOf(aa) > -1)                     return("orange");
	if(["C","V","I","L","P","F","Y","M","W"].indexOf(aa) > -1) return("green");
	if(["N","Q","H"].indexOf(aa) > -1)                         return("magenta");
	if(["D","E"].indexOf(aa) > -1)                             return("red");
	if(["K", "R"].indexOf(aa) > -1)                            return("blue");
	if(["*", "X", "-", ".", ""].indexOf(aa) > -1)              return("#808080");
	// throw("amino acid '"aa+"' not recognised.");

}


// Function to color by sequence
Racmacs.Viewer.prototype.colorPointsBySequence = function(pos){
   
    // Add sequence legend
    if(!this.sequenceLegend){
        this.sequenceLegend = document.createElement("div");
        this.sequenceLegend.innerHTML = "legend";
        this.sequenceLegend.classList.add("sequence-legend");
        this.viewport.div.appendChild(this.sequenceLegend);
    }

    // Fire event
    if(pos == 0) {
        this.colorPointsByDefault();
        this.sequenceLegend.style.display = "none";
        return(null);
    }

    // Assemble point and sequence data
	let points = [];
	let sequences = [];
	let noseq_points = [];

	let ag_sequences = this.data.agSequences();
	let sr_sequences = this.data.srSequences();

	if(Math.max(...ag_sequences.map(x => x.length)) > 0){
		points    = points.concat(this.antigens);
		sequences = sequences.concat(ag_sequences);
	} else {
		noseq_points = noseq_points.concat(this.antigens);
	}

	if(Math.max(...sr_sequences.map(x => x.length)) > 0){
		points    = points.concat(this.sera);
		sequences = sequences.concat(sr_sequences);
	} else {
		noseq_points = noseq_points.concat(this.sera);
	}

    // Get the antigen sequences
    let aas = sequences.map(seq => seq[pos-1]);
    aas[1] = "-";
    let unique_aas = [];
    aas.map( aa => { if(unique_aas.indexOf(aa) === -1) unique_aas.push(aa) });

    // Set aa color mapping
    let aa_cols;
    unique_aas = unique_aas.filter(x => x != "-" && x != ".");
    if (unique_aas.length <= 8) {
    	aa_cols = Racmacs.utils.colorPalette.slice(0, unique_aas.length);
    } else {
	    aa_cols = unique_aas.map((aa, i) => new THREE.Color().setHSL(
	        i/(unique_aas.length + 1), 1, 0.5
	    ));
    }

    // Make missing aas grey
    let null_aa_col = new THREE.Color("#cccccc");
    aa_cols[unique_aas.indexOf(".")] = new THREE.Color("#cccccc");

    // Color points by aa
    aas.map((aa, i) => { 
    	if (aa == "-" || aa == ".") {
            var color =  null_aa_col;
    	} else {
            var color =  aa_cols[unique_aas.indexOf(aa)];
        }
        points[i].setFillColor("#"+color.getHexString());
    });

    noseq_points.map( p => {
        p.setFillColor("transparent");
        p.setOutlineColor("#000000");
    });

    // Populate legend
    this.sequenceLegend.innerHTML = "";

    var titlediv = document.createElement("div");
    titlediv.innerHTML = pos;
    titlediv.style.padding = "4px";
    this.sequenceLegend.appendChild(titlediv);
    
    var table = document.createElement("table");
    this.sequenceLegend.appendChild(table);

    unique_aas.map((aa, i) => {
        var color = aa_cols[unique_aas.indexOf(aa)];
        var row = document.createElement("tr");
        table.appendChild(row);
        var td = document.createElement("td");
        var coldiv = document.createElement("div");
        coldiv.style.width  = "14px";
        coldiv.style.height = "14px";
        coldiv.style.backgroundColor = "#"+color.getHexString();
        coldiv.style.border = "solid 1px #000000";
        td.appendChild(coldiv);
        row.appendChild(td);
        var td = document.createElement("td");
        td.innerHTML = aa;
        row.appendChild(td);
    });

    // Update any browsers
    if(this.browsers){
      if(this.browsers.antigens){
        this.browsers.antigens.order("default");
      }
      if(this.browsers.sera){
        this.browsers.sera.order("default");
      }
    }

    // Note that the viewport is colored by stress
    this.coloring = "sequence";
    
    // Render the viewport
    this.render();

    // Dispatch events
    this.dispatchEvent("point-coloring-changed", { coloring : "sequence" });

}





