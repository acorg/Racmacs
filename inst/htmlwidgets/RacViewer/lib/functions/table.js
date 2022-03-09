
R3JS.Viewer.prototype.eventListeners.push({
    name : "point-display-updated",
    fn : function(e){
    	let point = e.detail.point;
        let viewer = point.viewer;
        if(point.cell){
			if(point.selected || point.hovered){
		        point.cell.style.backgroundColor      = "#ccc";
				point.cellgroup.style.backgroundColor = "#d7f0f4";
				if(point.titercells){
					point.titercells.map( cell => {
						cell.style.backgroundColor = "#d7f0f4";
					});
				}
			} else {
				point.cell.style.backgroundColor      = "#eee";
				point.cellgroup.style.backgroundColor = null;
				if(point.titercells){
					point.titercells.map( cell => {
						cell.style.backgroundColor = null;
					});
				}
			}
		}
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "point-included",
    fn : function(e){
        let point  = e.detail.point;
        let viewer = point.viewer;
        let titers = point.titers();
        if (point.titercells) {
        	point.titercells.map( (cell, i) => cell.innerHTML = titers[i] );
        }
        if (viewer.hitable) {
	        viewer.hitable.logtiters = viewer.data.logtable();
	        viewer.hitable.colbases  = viewer.data.colbases();
			viewer.hitable.styleHighestTiters();
	    }
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "point-excluded",
    fn : function(e){
        let point  = e.detail.point;
        let viewer = point.viewer;
        if (point.titercells) {
        	point.titercells.map( cell => cell.innerHTML = "*" );
        }
        if (viewer.hitable) {
	        viewer.hitable.logtiters = viewer.data.logtable();
		    viewer.hitable.colbases  = viewer.data.colbases();
			viewer.hitable.styleHighestTiters();
		}
    }
});

Racmacs.App.prototype.showTable = function(){

	if(!this.hitablewindow){
	    
		// Style the button
	    this.btns["viewTable"].style.color = "#0eb5f7";

		var tablewindow = window.open("", "", "width=600,height=600");
	    window.addEventListener("beforeunload", e => {
	    	this.hideTable()
	    });
	    tablewindow.addEventListener("beforeunload", e => {
	    	this.hideTable();
	    });

	    // View the table
	    var holder = document.createElement("div");
	    holder.style.height   = "100vh";
	    holder.style.width    = "100vw";
	    holder.style.overflow = "scroll";
	    holder.style.position = "relative";

	    var holder2 = document.createElement("div");
	    holder.appendChild(holder2);

	    tablewindow.document.body.style.margin = 0;
	    tablewindow.document.body.style.height = "100vh";
	    tablewindow.document.body.style.width  = "100vw";
	    tablewindow.document.body.style.overflow = "hidden";
	    tablewindow.document.body.style.backgroundColor = "#fff";
	    tablewindow.document.body.appendChild(holder);
		this.hitable = new Racmacs.HItable(
			this, 
			holder2,
			{	
				fixHeaders : true,
				styles : {
					background_color : "#fff"
				}
			}
		);
		this.hitablewindow = tablewindow;

		// Size window to fit table, up to a point
		var width  = holder2.scrollWidth + 100;
		var height = holder2.scrollHeight + 30;
		if(width  > 1000) width = 1000;
		if(height > 800)  height = 800;
		tablewindow.resizeTo(width, height);

	} else {

		this.hitablewindow.focus();

	}

}

Racmacs.App.prototype.hideTable = function(){

	if(this.hitablewindow){
		this.hitablewindow.close();
    	this.hitablewindow = null;
	}

	this.hitable       = null;
	this.btns["viewTable"].style.color = null;

}

// Set the table object class
Racmacs.HItable = class HItable {

	constructor(viewer, container, args = {}){

		// Set defaults
		if(args.fixHeaders === undefined)              args.fixHeaders = false;
		if(args.styles === undefined)                  args.styles = {};
		if(args.styles.label_color === undefined)      args.styles.label_color = "#eee";
		if(args.styles.cell_hover_color === undefined) args.styles.cell_hover_color = "#3ad3ea";
		if(args.styles.background_color === undefined) args.styles.background_color = "#fff";

		// Add css rules
		var style = document.createElement("style");
		document.head.appendChild(style);
		style.sheet.insertRule(`
			.hitable tr:nth-child(2n) {
				background-color: #f6f8fa;
			}
		`);

		this.styles = args.styles;
		

		// Bind the table to the viewer and container div
		viewer.hitable = this;
		this.viewer = viewer;
		this.container = container;
		this.container.style.overflow = "scroll";

		// Set some variables for convenience
		this.logtiters = viewer.data.logtable();
		this.colbases  = viewer.data.colbases();

		// Create the table
		this.makeTable(viewer.antigens.length, viewer.sera.length);
		this.table.classList.add("hitable");
		this.div = document.createElement("div");
		this.div.appendChild(this.table);
		this.container.appendChild(this.div);
		this.container.style.overflow = "scroll";

		// Set some styles
		this.cellwidth = 45;

		// Style table
		this.table.setAttribute(
			"style", 
			`
			border-collapse      : collapse;
			font-family          : sans-serif, "Arial";
			font-size            : 70%;
			table-layout         : fixed;
			margin-bottom        : 20px;
			-webkit-touch-callout: none;
		      -webkit-user-select: none;
		       -khtml-user-select: none;
		         -moz-user-select: none;
		          -ms-user-select: none;
		              user-select: none;
			`
		);

		this.table.addEventListener("mouseup", e => {
			viewer.deselectAll();
		});

		var noneSelected_deselected_opacity = viewer.styleset.noselections.unhovered.unselected.opacity;
		var plusSelected_deselected_opacity = viewer.styleset.selections.unhovered.unselected.opacity;

        // container.addEventListener("mouseenter", function(){
        //     viewer.graphics.noneSelected.deselected.opacity = plusSelected_deselected_opacity;
        //     viewer.updatePointStyles();
        // });
        // container.addEventListener("mouseleave", function(){
        //     viewer.graphics.noneSelected.deselected.opacity = noneSelected_deselected_opacity;
        //     viewer.updatePointStyles();
        // });

		// Style cells
		this.cells.map( cell => {
			cell.style.border  = "solid #ccc 1px" 
			cell.style.padding = "6px";
			cell.style.cursor  = "default";
		});

		// Style row labels
		viewer.antigens.map( (antigen, i) => {
			var cell = this.getRowLabel(i);
			cell.style.whiteSpace   = "nowrap";
            // cell.style.color                     = antigen.getPrimaryColor();
            cell.style.borderRight = "solid 8px "+antigen.getPrimaryColor();
            cell.style.backgroundColor = this.styles.label_color;
		})

		// Add Serum labels
		viewer.sera.map( (sera, i) => {
			var cell       = this.getColLabel(i);
			cell.innerHTML = sera.name;
			// if(i==1) cell.innerHTML = sera.name + " a really long extension";
			sera.cell      = cell.parentElement;
			sera.cellgroup = this.getColGroup(i);
		});

		// Add Antigen labels
		viewer.antigens.map( (antigen, i) => {
			var cell = this.getRowLabel(i);
			cell.innerHTML    = antigen.name;
			antigen.cell      = cell;
			antigen.cellgroup = this.getRowGroup(i);
		});

		// Add titers
		var titers = viewer.data.titertable;
		viewer.sera.map( (sera, j) => {
			sera.titercells = [];
			viewer.antigens.map( (antigen, i) => {
				var cell = this.getCell(i,j);
				cell.innerHTML = titers[i][j];
				cell.style.minWidth = this.cellwidth+"px";
				cell.style.maxWidth = this.cellwidth+"px";
				cell.style.width    = this.cellwidth+"px";
				cell.style.boxSizing = "border-box";
				sera.titercells.push(cell);
			});
		});

		// Add antigen cell event listeners
		viewer.antigens.map( (antigen, i) => {
			var cell = this.getRowLabel(i);
			antigen.titercells = viewer.sera.map( (serum, j) => this.getCell(i,j));
			// cell.addEventListener("mouseenter", e => {
			// 	antigen.hover();
			// });
			// cell.addEventListener("mouseleave", e => {
			// 	antigen.dehover();
			// });
			cell.addEventListener("mouseup", e => {
				if (e.altKey) {
					antigen.toggleIncluded();
				} else {
				    antigen.click(e);
			    }
				e.stopPropagation();
			});
		});

		// Add sera cell event listeners
		viewer.sera.map( (sera, i) => {
			var cell = this.getColLabel(i);
			// cell.parentElement.addEventListener("mouseenter", e => {
			// 	sera.hover();
			// });
			// cell.parentElement.addEventListener("mouseleave", e => {
			// 	sera.dehover();
			// });
			cell.parentElement.addEventListener("mouseup", e => {
				if (e.altKey) {
					sera.toggleIncluded();
				} else {
				    sera.click(e);
			    }
				e.stopPropagation();
			});
		});

		// Add titer cell event listeners
		viewer.sera.map( (sera, j) => {
			viewer.antigens.map( (antigen, i) => {
				var cell = this.getCell(i,j);
				cell.addEventListener("mouseenter", e => {
					// cell.style.outline = "solid 1px blue";
					// antigen.hover();
					// sera.hover();
					// cell.style.backgroundColor = this.styles.cell_hover_color;
					// cell.color                 = cell.style.color;
					// cell.style.color           = "#000";
					// if(viewer.errorLinesShown){
					// 	viewer.points.map( p => p.hideErrors() );
					// 	antigen.showErrors([sera]);
					// }
				});
				cell.addEventListener("mouseleave", e => {
					// antigen.dehover();
					// sera.dehover();
					// cell.style.outline = "none";
					// cell.style.backgroundColor = null;
					// cell.style.color           = cell.color;
					// if(viewer.errorLinesShown){
					// 	viewer.points.map( p => p.showErrors() );
					// }
				});
				cell.addEventListener("mouseup", e => {

					if (e.altKey) {

						if (viewer.data.titertable[i][j] == "*") {
							viewer.data.restoreTiter(i, j);
						} else {
						    viewer.data.setTiter(i, j, "*");
						}

						cell.innerHTML = viewer.data.titertable[i][j];
						this.logtiters = viewer.data.logtable();
		                this.colbases  = viewer.data.colbases();
						this.styleHighestTiters();
						viewer.dispatchEvent("titer-changed", { 
			                agnum  : i,
			                srnum  : j,
			                titer  : "*",
			                viewer : viewer
			            });

					} else if (e.shiftKey) {

						cell.innerHTML = "";

						var input = document.createElement("input");
						input.value = viewer.data.titertable[i][j];
						input.style.width = "100%";
						input.style.fontSize = "inherit";
						input.style.fontFamily = "inherit";
						input.style.fontWeight = "inherit";
						input.style.borderStyle = "none";
						input.style.padding = 0;
						input.style.margin = 0;
						input.style.outline = "none";
						input.style.backgroundColor = "transparent";
						cell.style.outline = "solid 2px red";
						cell.appendChild(input);
						input.focus();
						input.addEventListener("blur", e => {
							cell.innerHTML = viewer.data.titertable[i][j];
							cell.style.outline = "none";
						});
						input.addEventListener("change", e => {
							viewer.data.setTiter(i, j, input.value);
							this.logtiters = viewer.data.logtable();
			                this.colbases  = viewer.data.colbases();
							this.styleHighestTiters();
							input.blur();
							cell.innerHTML = viewer.data.titertable[i][j];
							cell.style.outline = "none";
							viewer.dispatchEvent("titer-changed", { 
				                agnum  : i,
				                srnum  : j,
				                titer  : input.value,
				                viewer : viewer
				            });
						});

					}

				});
			});
		});

		// Style topleft cell
		this.getTopLeft().style.borderStyle = "none";

		// Style titer cells
		this.styleTiterCells({ 
			color:"#666" 
		});

		// Style highest in col
		this.styleHighestTiters();

		// Style row labels
		var labelwidths = [];
		viewer.antigens.map( (antigen, i) => {
			var cell = this.getRowLabel(i);
			cell.parentElement.style.padding = 0;
			cell.style.padding = "6px";
			cell.style.paddingRight = "12px";
			cell.parentElement.style.boxSizing = "border-box";
			labelwidths.push(cell.innerHTML.length*9);
		});
		var maxlabelwidth = Math.max(...labelwidths) + 10;

		// Style column headers
		var widths = [];
		viewer.sera.map( (serum, i) => {
			var cell = this.getColLabel(i);
            cell.style.paddingLeft  = "15px";
            cell.style.whiteSpace   = "nowrap";
            cell.style.padding      = cell.parentElement.parentElement.style.padding;
            cell.style.boxSizing    = "border-box";
            cell.parentElement.parentElement.style.padding = 0;
			widths.push(cell.innerHTML.length*9);
		});
		var maxwidth = Math.max(...widths) + 30;

		this.maxlabelwidth = maxlabelwidth;
		this.maxwidth      = maxwidth;

		viewer.sera.map( (serum, i) => {
			var cell = this.getColLabel(i);
            var cellheight = maxwidth * Math.cos(Math.PI/4);
            var cellwidth  = this.cellwidth;
            var angle      = Math.PI/4;

            // cell.parentElement.parentElement.style.backgroundColor = "#fff";
            cell.parentElement.parentElement.style.borderTop   = "none";
            cell.parentElement.parentElement.style.borderLeft  = "none";
            cell.parentElement.parentElement.style.borderRight = "none";
            cell.parentElement.parentElement.style.height        = cellheight+"px";
            cell.parentElement.parentElement.style.width         = cellwidth+"px";
            cell.parentElement.parentElement.style.minWidth      = cellwidth+"px";
            cell.parentElement.parentElement.style.maxWidth      = cellwidth+"px";
            cell.parentElement.parentElement.style.position      = "relative";
            cell.parentElement.parentElement.style.verticalAlign = "bottom";
            cell.parentElement.parentElement.style.padding       = 0;
            cell.parentElement.parentElement.style.lineHeight    = "0.8";

            cell.parentElement.style.position    = "relative";
            cell.parentElement.style.top         = "0px";
            cell.parentElement.style.left        = (cellheight*Math.tan(angle)/2)+"px";
            cell.parentElement.style.height      = "100%";
            cell.parentElement.style.transform   = "skew(-45deg,0deg)";
            cell.parentElement.style.overflow    = "visible";
            cell.parentElement.style.border      = "1px solid #ccc";
            cell.parentElement.style.borderBottom = "solid 8px "+serum.getPrimaryColor();
            cell.parentElement.style.zIndex       = 20;
            cell.parentElement.style.backgroundColor = this.styles.label_color;

            cell.style.position   = "absolute";
            cell.style.display    = "inline-block";
            cell.style.textAlign  = "left";
            cell.style.whiteSpace = "nowrap";
            cell.style.width      = maxwidth+"px";
            cell.style.height     = cellwidth+"px";
            cell.style.boxSizing  = "border-box";
            cell.style.transform  = "skew(45deg,0deg) rotate(315deg)";
            cell.style.bottom     = (8-(cellwidth/Math.cos(angle))/2+(maxwidth/2)*Math.cos(angle))+"px";
            cell.style.left       = -(8+cellheight*Math.cos(angle) - cellwidth)+"px";

		});

		// Style first row
		this.table.children[1].style.backgroundColor = "transparent";

		// Style background
		this.body.style.backgroundColor = "#fff"

		if(args.fixHeaders){
			this.fixHeaders();
		}

	}

	makeTable(nrow, ncol){
		
		this.table = document.createElement("table");
		this.cells = [];
		this.nrow  = nrow;
		this.ncol  = ncol;

		// Make colgroups
		this.colgroup = document.createElement("colgroup");
		this.table.appendChild(this.colgroup);
		for(var j=0; j<=ncol; j++){
			this.colgroup.appendChild(document.createElement("col"));
		}

		// Make cells
		this.head = document.createElement("thead");
		this.body = document.createElement("tbody");
		this.table.appendChild(this.head);
		this.table.appendChild(this.body);

		var row, cell;
		for(var i=0; i<=nrow; i++){
			row = document.createElement("tr");
			if(i == 0) this.head.appendChild(row);
			else       this.body.appendChild(row);
			for(var j=0; j<=ncol; j++){
				cell = document.createElement("td");
				this.cells.push(cell);
				row.appendChild(cell);
			}
		}

		// Add divs for row labels
		for(var i=0; i<nrow; i++){
			this.body.children[i].children[0].appendChild(
				document.createElement("div")
			);
		}

		// Add divs for column labels
		for(var j=0; j<=ncol; j++){
			this.head.children[0].children[j].appendChild(
				document.createElement("div")
			);
			this.head.children[0].children[j].appendChild(
				document.createElement("div")
			);
			this.head.children[0].children[j].children[0].appendChild(
				document.createElement("span")
			);
		}

	}

	getColGroup(col){
		return(this.colgroup.children[col+1]);
	}

	getRowGroup(row){
		return(this.body.children[row]);
	}

	getColLabel(col){
		return(this.head.children[0].children[col+1].children[0].children[0]);
	}

	getRowLabel(row){
		return(this.body.children[row].children[0].children[0]);
	}

	getCell(row, col){
		return(this.body.children[row].children[col+1]);
	}

	getTopLeft(){
		return(this.head.children[0].children[0]);
	}

	styleTiterCells(styles){
		for(var i=0; i<this.nrow; i++){
			for(var j=0; j<this.ncol; j++){
				var cell = this.getCell(i,j);
				for(var s in styles){
					cell.style[s] = styles[s];
				}
			}
		}
	}

	styleHighestTiters(){
		for(var i=0; i<this.nrow; i++){
			for(var j=0; j<this.ncol; j++){
				var cell = this.getCell(i,j);
				if(this.logtiters[i][j] >= this.colbases[j]){
					cell.style.fontWeight = "bolder";
					cell.style.color = "#000000";
				} else {
					cell.style.fontWeight = "normal";
					cell.style.color = "#666666";
				}
			}
		}
	}

	fixHeaders(){

		var viewer        = this.viewer;
		var maxlabelwidth = this.maxlabelwidth;
		var maxwidth      = this.maxwidth;
		
		// Fix position of first row
		this.table.style.marginLeft = (maxlabelwidth-12)+"px";
		viewer.antigens.map( (antigen, i) => {
			var cell = this.getRowLabel(i);
			cell.parentElement.style.width = maxlabelwidth+"px";
			cell.parentElement.style.position = "absolute";
			cell.parentElement.style.left = "0"; 
		});

		// Fix position of column
		this.headertable = document.createElement("table");
		this.headertable.appendChild(this.table.children[1]);
		this.headertable.setAttribute("style", this.table.getAttribute("style"));
		this.headertable.style.marginBottom = 0;
		this.headertable.style.marginLeft = (maxlabelwidth-12)+"px";
		this.table.parentElement.insertBefore(this.headertable, this.table);
		this.headertable.style.position = "fixed";
		this.headertable.style.left = "0px";
		this.headertable.style.top = "0px";

		var bodyholder = document.createElement("div");
		// this.div.style.position = "relative";
		this.container.style.overflow = null;
		this.container.parentElement.style.overflowY = "scroll";
		this.div.style.overflow = "scroll";
		this.div.appendChild(bodyholder);
		bodyholder.appendChild(this.table);
		
		this.table.style.marginLeft = (maxlabelwidth - 2)+"px";
		this.table.style.marginTop = (this.headertable.offsetHeight-2)+"px";
		this.table.parentElement.parentElement.addEventListener("scroll", e => {
			var parent = this.table.parentElement.parentElement;
			if(parent.scrollLeft < 0){ parent.scrollLeft = 0 }
			this.headertable.style.left = -parent.scrollLeft+"px";
		});
		this.headertable.addEventListener("wheel", e => {
			this.table.parentElement.parentElement.scrollBy(e.deltaX, 0);
		});

		// this.container.parentElement.addEventListener("scroll", e => {
		// 	var parent = this.container.parentElement;
		// 	if(parent.scrollTop < 0){ parent.scrollTop = 0 }
		// });

		// Add a div to mask the top left corner
		var topleftmask = document.createElement("div");
		topleftmask.style.position = "fixed";
		topleftmask.style.top      = 0;
		topleftmask.style.left     = (Math.cos(45)*this.headertable.offsetHeight-2)+"px";
		topleftmask.style.width    = maxlabelwidth+"px";
		topleftmask.style.height   = this.headertable.offsetHeight+"px";
		topleftmask.style.backgroundColor = "#ffffff";
		topleftmask.style.borderRight  = "solid 1px #ccc";
		topleftmask.style.borderBottom = "solid 1px #ccc";
		topleftmask.style.boxSizing    = "border-box";
		topleftmask.style.zIndex = 100;
		topleftmask.style.transform   = "skew(-45deg,0deg)";
		this.table.parentElement.appendChild(topleftmask);

		var topleftmask = document.createElement("div");
		topleftmask.style.position = "fixed";
		topleftmask.style.top      = 0;
		topleftmask.style.width    = maxlabelwidth+"px";
		topleftmask.style.height   = this.headertable.offsetHeight+"px";
		topleftmask.style.backgroundColor = "#ffffff";
		topleftmask.style.zIndex = 90;
		this.table.parentElement.appendChild(topleftmask);

		for(var i=1; i<this.body.children.length; i++){
			var spacer = document.createElement("td");
			spacer.style.width    = maxwidth+"px";
			spacer.style.minWidth = maxwidth+"px";
			spacer.style.maxWidth = maxwidth+"px";
			spacer.style.backgroundColor = this.styles.background_color;
			this.body.children[i].appendChild(spacer);
		}

	}

}

