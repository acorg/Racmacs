


Racmacs.HITable = class HITable {

	constructor(viewer){

		// Bind to viewer
		viewer.hitable = this
		this.viewer = viewer;

		// Make the div
		this.div = document.createElement("div");
		this.div.style.display = "none";
		this.div.classList.add("hitable-holder");
		viewer.viewport.holder.appendChild(this.div);

		// Make the table
		this.table = document.createElement("table");
		this.div.appendChild(this.table);

	}

	show(){

		this.div.style.display = null;

	}

	hide(){

		this.div.style.display = "none";

	}

	reload(args){

		var antigens = this.viewer.antigens;
		var sera     = this.viewer.sera;

		this.rownames  = Array(antigens.length);
		this.colnames  = Array(sera.length);
		this.cells     = Array(antigens.length).fill();
		this.cells     = this.cells.map( x => Array(sera.length) );
		this.cols      = Array(sera.length);

		// Construct the table
		this.table.innerHTML = null;
		var colgroup = document.createElement("colgroup");
		this.table.appendChild(colgroup);

		for(var i = -1; i<sera.length; i++){

			var col = document.createElement("col");
			colgroup.appendChild(col);
			if( i >= 0 ) this.cols[i] = col;

		}

		for(var i = -1; i<antigens.length; i++){
			
			var row = document.createElement("tr");
			this.table.appendChild(row);

			for(var j = -1; j<sera.length; j++){

				var cell = document.createElement("td");
				row.appendChild(cell);

				if(i == -1 && j > -1) this.colnames[j] = cell;
				if(j == -1 && i > -1) this.rownames[i] = cell;
				if(j > -1 && i > -1)  this.cells[i][j] = cell;

			}

		}

		// Fill in the values
		for(var i=0; i<antigens.length; i++){
			this.rownames[i].innerHTML = antigens[i].name;
		}

		for(var i=0; i<sera.length; i++){
			this.colnames[i].innerHTML = sera[i].name;
		}

		for(var i=0; i<antigens.length; i++){
			for(var j=0; j<sera.length; j++){
				this.cells[i][j].innerHTML = antigens[i].titers[j];
			}
		}

	}

}

Racmacs.HItablePanel = class HItablePanel {

	constructor(viewer){

		// Link to viewer
		this.viewer = viewer;
		viewer.hiTablePanel = this;

		this.div = document.createElement("div");

		// var btn = document.createElement("div");
		// btn.innerHTML = "popout";
		// this.div.appendChild(btn);

		// btn.addEventListener("mouseup", function(){

		// 	var win = window.open("", "Table", {
		// 		height : "80%",
		// 		width : "80%",
		// 		status : 0,
		// 		menubar : 0,
		// 		toolbar : 0
		// 	}, false);

		// 	win.document.body.appendChild(viewer.hitable.div);
			
		// 	var style = document.createElement('style');
		// 	style.type = 'text/css';
		// 	style.appendChild(document.createTextNode(Racmacs.styles.hitable));

		// 	win.document.head.appendChild(style);

		// });

	}

}


Racmacs.Viewer.prototype.showTable = function(){

	this.hitable.show();

}


Racmacs.Viewer.prototype.hideTable = function(){

	this.hitable.hide();

}


Racmacs.styles = {
	hitable : `


.hitable-holder {

	position: absolute;
	left: 0;
	right: 0;
	bottom: 0;
	top: 0;
	overflow: scroll;
	font-family: sans-serif;

}

/* General table */
.hitable-holder table {

	table-layout: fixed;

}

.hitable-holder table, 
.hitable-holder th, 
.hitable-holder td {

	border-collapse: collapse;
  	border: 1px solid hsl(211, 10%, 94%);
	font-size: 60%;

}

.hitable-holder tr:nth-child(even) {

	background-color: hsl(211, 100%, 98%);

}

/* Row names and col names */
.hitable-holder td:first-child,
.hitable-holder tr:first-child {

	font-weight: bolder;
	background-color: hsl(211, 10%, 97%);

}

/* Col names */
.hitable-holder tr:first-child td {

	word-break: break-all;
	/*transform: 
		translate(25px, 51px)
    	rotate(315deg);*/

}

/* Row names */
.hitable-holder td:first-child {

	max-width: 100%;

}

.hitable-holder tr:nth-child(even) td:first-child {

	background-color: hsl(211, 10%, 95%);

}

/* Cells */
.hitable-holder td {

    min-width: 50px;
	max-width: 50px;
	overflow-x: hidden;
	padding: 4px;

}

.hitable-holder td:hover {

	background-color: hsl(211, 10%, 90%);

}



	`
};

