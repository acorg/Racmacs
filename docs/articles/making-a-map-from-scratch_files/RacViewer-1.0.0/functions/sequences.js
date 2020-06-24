
// EVENTS
R3JS.Viewer.prototype.eventListeners.push({
	name : "point-selected",
	fn : function(e){
		let point  = e.detail.point;
		let viewer = e.detail.viewer;
		if(viewer.sequences){
			// Add a set timeout event so that other events don't have to wait
			window.setTimeout( 
				f => viewer.sequences.updateSequenceTableView(), 10
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
			window.setTimeout( 
				f => viewer.sequences.updateSequenceTableView(), 10
			);
		}
	}
});

R3JS.Viewer.prototype.eventListeners.push({
	name : "point-hovered",
	fn : function(e){
		let point  = e.detail.point;
		let viewer = e.detail.viewer;
		if(viewer.sequences){
			// Add a set timeout event so that other events don't have to wait
			window.setTimeout( 
				f => viewer.sequences.highlightRow(point.typeIndex), 10
			);
		}
	}
});

R3JS.Viewer.prototype.eventListeners.push({
	name : "point-dehovered",
	fn : function(e){
		let point  = e.detail.point;
		let viewer = e.detail.viewer;
		if(viewer.sequences){
			// Add a set timeout event so that other events don't have to wait
			window.setTimeout( 
				f => viewer.sequences.dehighlightRow(point.typeIndex), 10
			);
		}
	}
});

Racmacs.App.prototype.showSequences = function(){

	this.viewport.holder.style.left = "800px";
	this.viewport.onwindowresize();
	this.sequences = new Racmacs.SequenceTable(this);
	this.container.appendChild(this.sequences.div);

}

Racmacs.App.prototype.hideSequences = function(){
	


}

Racmacs.App.prototype.showSequences = function(){

	if(!this.sequenceswindow){
	    
		// Style the button
	    this.btns["viewSequences"].style.color = "#0eb5f7";

		var sequenceswindow = window.open("", "", "width=600,height=600");
	    window.addEventListener("beforeunload", e => {
	    	this.hideSequences()
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

	    var style = document.createElement("style");
		sequenceswindow.document.head.appendChild(style);
		style.sheet.insertRule(".sequences-div table tr:nth-child(2n) { background-color: #f6f8fa }", 0);

	    sequenceswindow.document.body.appendChild(holder);
		this.sequences = new Racmacs.SequenceTable(
			this, 
			holder2
		);
		this.sequenceswindow = sequenceswindow;

		// Size window to fit table, up to a point
		// var width  = holder2.scrollWidth + 100;
		// var height = holder2.scrollHeight + 30;
		// if(width  > 1000) width = 1000;
		// if(height > 800)  height = 800;
		// sequenceswindow.resizeTo(width, height);

	} else {

		this.sequenceswindow.focus();

	}

}

Racmacs.App.prototype.hideSequences = function(){

	if(this.sequenceswindow){
		this.sequenceswindow.close();
    	this.sequenceswindow = null;
	}

	this.sequences = null;
	this.btns["viewSequences"].style.color = null;

}





Racmacs.SequenceTable = class SequenceTable {

	constructor(viewer, container){

		this.viewer = viewer;

		this.div = document.createElement("div");
		container.appendChild(this.div);
		this.div.style.width  = "100%";
		this.div.style.boxSizing = "border-box";
		this.div.style.fontFamily = "sans-serif";
		this.div.classList.add("sequences-div");

		this.positionsearch = document.createElement("input");
		this.positionsearch.style.position = "absolute";
		this.positionsearch.style.top    = 0;
		this.positionsearch.style.left   = 0;
		this.positionsearch.style.right  = 0;
		this.positionsearch.style.height = "28px";
		this.positionsearch.style.fontSize = "16px";
		this.positionsearch.style.boxSizing = "border-box";
		this.positionsearch.style.borderStyle = "none";
		this.positionsearch.style.backgroundColor = "#222222";
		this.positionsearch.style.margin = 0;
		this.positionsearch.style.paddingLeft = "8px";
		this.positionsearch.style.paddingRight = "8px";
		this.positionsearch.style.color = "#ffffff";
		this.div.appendChild(this.positionsearch);
		this.positionsearch.addEventListener("input", e => {
			this.updateSequenceTableView();
		});

		this.tablediv = document.createElement("div");
		this.tablediv.style.position = "absolute";
		this.tablediv.style.top    = "28px";
		this.tablediv.style.left   = 0;
		this.tablediv.style.right  = 0;
		this.tablediv.style.bottom = 0;
		this.tablediv.style.overflow = "scroll";
		this.div.appendChild(this.tablediv);
		
		this.table = document.createElement("table");
		this.table.style.fontSize = "12px";
		this.table.style.tableLayout = "fixed";
		this.table.style.borderCollapse = "collapse";
		this.tablediv.appendChild(this.table);

		// Add mouse event listeners to table
        var noneSelected_deselected_opacity = viewer.graphics.noneSelected.deselected.opacity;
        var plusSelected_deselected_opacity = viewer.graphics.plusSelected.deselected.opacity;

		this.table.addEventListener("mouseenter", function(){
            viewer.graphics.noneSelected.deselected.opacity = plusSelected_deselected_opacity;
            viewer.updatePointStyles();
        });
        this.table.addEventListener("mouseleave", function(){
            viewer.graphics.noneSelected.deselected.opacity = noneSelected_deselected_opacity;
            viewer.updatePointStyles();
        });

		this.populateTable();

	}

	populateTable(){

		this.rows      = [];
		this.cells     = [];
		this.collabels = [];

		let color = new THREE.Color();
		this.table.innerHTML = "";
		let tr = document.createElement("tr");
		this.table.appendChild(tr);
		let td = document.createElement("td");
		td.style.border = "1px solid #dfe2e5";
		tr.appendChild(td);
		this.viewer.data.agSequences(0).map((aa, i) => {
			let td = document.createElement("td");
			td.style.padding = 0;
			td.style.border = "1px solid #dfe2e5";
			tr.appendChild(td);
			let div = document.createElement("div");
			div.style.width = "12px";
			div.style.float = "left";
			div.style.writingMode = "vertical-rl";
			div.style.padding = "8px";
			td.appendChild(div);
			div.innerHTML = i+1;
			this.collabels.push(td);
		});

		this.viewer.antigens.map((ag, i) => {
			let seq = this.viewer.data.agSequences(i);
			let tr = document.createElement("tr");
			tr.addEventListener("mouseenter",  e => ag.hover());
			tr.addEventListener("mouseleave", e => ag.dehover());
			this.rows.push(tr);
			
			let td = document.createElement("td");
			td.style.border = "1px solid #dfe2e5";
			tr.appendChild(td);
			td.innerHTML = ag.name;
			td.style.whiteSpace = "nowrap";
			td.style.padding = "8px";

			let row = [];
			this.cells.push(row);
			this.table.appendChild(tr);
			seq.map(aa => {
				let td = document.createElement("td");
				td.style.padding = 0;
				td.style.border = "1px solid #dfe2e5";
				tr.appendChild(td);
				td.style.textAlign = "center";
				td.style.padding = "8px";
				color.setStyle(Racmacs.ColorAA(aa));
				td.style.backgroundColor = "#"+color.getHexString()+"80";
				td.innerHTML = aa;
				row.push(td);
			});
		});

	}

	updateSequenceTableView(){

		// Parse the search value
		var searchval = this.positionsearch.value;
		var positions = [];
		var sequences;

		// Show and hide rows based on selected points
		const num_selected = this.viewer.selected_pts.length;
		this.viewer.antigens.map((p,i) => {
			if(p.selected || num_selected === 0) this.rows[i].style.display = ""
			else                                 this.rows[i].style.display = "none"
		});

		if(searchval == ""){ 

			// Get sequences from relevant points
			if(this.viewer.selected_pts.length == 0){
				sequences = this.viewer.data.agSequences();
			} else {
				sequences = [];
				this.viewer.selected_pts.map( p => {
					if(p.type == "ag") sequences.push(
						this.viewer.data.agSequences(p.typeIndex)
					)
				})
			}

			// Only show positions where aas of selected strains differ
			var positions_shown = [];
			for(var i=0; i<sequences[0].length; i++){
				if(num_selected == 1){
					positions_shown.push(i+1)
				} else {
				    var unique_seq = [];
					sequences.map( s => { 
						if(unique_seq.indexOf(s[i]) === -1){
							unique_seq.push(s[i]);
						}
					});
					if(unique_seq.length > 1){
						positions_shown.push(i+1);
					}
				}
			}
			
			// Show relevant positions
			this.showPositions(positions_shown);

		} else if(searchval.toLowerCase() == "b7"){
			this.showPositions([145, 155, 156, 158, 159, 189, 193]);
		} else {
			let pos = Number(searchval);
			if(!isNaN(pos)) this.showPositions([pos]);
		}

	}

	showPositions(pos){

		// Show and hide column labels
		this.collabels.map((cell, i) => {
			if(pos.indexOf(i+1) === -1) cell.style.display = "none"
			else                        cell.style.display = ""
		});

		// Show and hide row cells
		this.cells.map( cellrow => {
			cellrow.map((cell, i) => {
				if(pos.indexOf(i+1) === -1) cell.style.display = "none"
				else                        cell.style.display = ""
			});
		});

	}

	highlightRow(row){
		this.rows[row].style.backgroundColor = "lightblue";
	}

	dehighlightRow(row){
		this.rows[row].style.backgroundColor = "";
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


