
Racmacs.App.prototype.flipY = function(){
	this.plotgroup.flip("x", {x:this.xmid});
}

Racmacs.App.prototype.flipX = function(){
	if(this.flippedX){
		this.plotgroup.transform({
			flip : "y"
		});
		this.flippedX = false;
	} else {
		this.plotgroup.transform({
			flip : null
		});
		this.flippedX = true;
	}
}

Racmacs.App.prototype.onReflectMap = function(axis){
	if(axis == "x") this.flipX();
	if(axis == "y") this.flipY();
}

// Start plotter
Racmacs.Plotter = class RacPlotter extends Racmacs.App {

    // Constructor function
    constructor(container, settings = {}){

    	super(container, settings);

    	// Setup variables
    	this.selected_pts = [];
    	// this.graphics.ptStyles.deselected.opacity = 1;

    	// Setup data accessor
    	new Racmacs.Data(this);
    	document.body.style.fontFamily = "sans-serif, 'Arial'";

    	// Setup canvas
    	this.id                     = container.id;
    	this.container              = container;
    	this.container.style.height = null;

    	// Create a control div
    	this.controlspacer = document.createElement("div");
    	this.controlspacer.style.height  = "40px";
    	this.container.appendChild(this.controlspacer);

    	// Create a flex container
    	this.flexcontainer = document.createElement("div");
    	this.flexcontainer.style.display = "flex";
    	this.flexcontainer.style.position = "relative";
    	this.flexcontainer.style.maxHeight = "100%";
    	this.container.appendChild(this.flexcontainer);

    	this.viewportcontainer = document.createElement("div");
    	this.viewportcontainer.style.position  = "relative";
    	this.viewportcontainer.style.width     = "100%";	
    	this.viewportcontainer.style.border    = "solid 2px #eeeeee";
    	// this.viewportcontainer.style.maxHeight = "100%";	
    	this.flexcontainer.appendChild(this.viewportcontainer);
    	
    	this.controldiv = document.createElement("div");
    	this.controldiv.style.height       = "40px";
    	this.controldiv.style.width        = "100%";
    	this.controldiv.style.padding      = "10px";
    	this.controldiv.style.paddingRight = 0;
    	this.controldiv.style.boxSizing    = "border-box";
    	this.controldiv.style.position     = "absolute";
    	this.controldiv.style.top          = "-35px";
    	this.controldiv.style.textAlign    = "right";
    	this.controldiv.style.color        = "#aaa";
    	this.viewportcontainer.appendChild(this.controldiv);

    	this.viewportsizer = document.createElement("div");
    	this.viewportsizer.style.maxWidth   = "100%";
    	this.viewportcontainer.appendChild(this.viewportsizer);

    	this.viewportdiv = document.createElement("div");
    	this.viewportdiv.style.position = "absolute";
    	this.viewportdiv.style.top    = 0;
    	this.viewportdiv.style.bottom = 0;
    	this.viewportdiv.style.left   = 0;
    	this.viewportdiv.style.right  = 0;
    	this.viewportcontainer.appendChild(this.viewportdiv);

    	// Create viewport
    	this.viewport                = document.createElement("div");
    	this.viewport.style.height   = "100%";
    	this.viewport.style.width    = "100%";
    	this.viewportdiv.appendChild(this.viewport);

    	// Create a legend div
    	this.legend = document.createElement("div");
    	// this.legend.style.background = "#00ff00";
    	this.legend.style.flexGrow  = 1;
    	this.legend.style.minHeight = "100%";
    	this.legend.style.display = "flex";
    	this.legend.style.alignItems = "flex-end";
    	this.flexcontainer.appendChild(this.legend);

    	// Create an info div
    	this.infodiv = document.createElement("div");
    	this.infodiv.style.height = "40px";
    	this.infodiv.style.padding = "10px";
    	this.infodiv.style.boxSizing = "border-box";
    	this.container.appendChild(this.infodiv);

    	this.viewportcontainer.setAttribute("tabindex", 1);
    	this.viewportcontainer.style.outline = "none";
    	this.viewportcontainer.addEventListener('mouseup', function(e){
    		this.focus();
    	});
    	this.viewportcontainer.addEventListener('focus', function(e){
    		this.style.borderColor = "#bde7ef";
    	});
    	this.viewportcontainer.addEventListener('blur', function(e){
    		this.style.borderColor = "#eeeeee";
    	});

    	this.viewportcontainer.addEventListener('keyup', e => {
    		switch(e.key){
    			case "e":
    				this.toggleErrorLines();
    				break;
    		}
    	});

		// Add buttons
		this.btnHolder = this.controldiv;
		this.addMapButtons([
			"reflectMap",
			"scalePointsDown",
			"scalePointsUp",
			"downloadMap",
            "viewTable"
		]);

    	this.draw = SVG()
    	.addTo(this.viewport)
    	.size("100%", "100%")

    	// Hack a fix to keep panning within plot limits
    	this.draw.viewbox = function(x, y, width, height) {

    		var viewbox;
			
			// act as getter
			if (x == null) return new SVG.Box(this.attr('viewBox'))
			if (y == null){
				viewbox = [x.x, x.y, x.width, x.height];
			} else {
				viewbox = [x, y, width, height];
			}
    		
    		var x2 = viewbox[0] + viewbox[2];
    		var y2 = viewbox[1] + viewbox[3];

    		if(x2 > this.xlim[1]) viewbox[0] = viewbox[0] - (x2 - this.xlim[1])
    		if(y2 > this.ylim[1]) viewbox[1] = viewbox[1] - (y2 - this.ylim[1])
    		if(viewbox[0] < this.xlim[0]) viewbox[0] = this.xlim[0];
    		if(viewbox[1] < this.ylim[0]) viewbox[1] = this.ylim[0];

    	 	var viewboxval = viewbox[0]+' '+viewbox[1]+' '+viewbox[2]+' '+viewbox[3];

			// act as setter
			return this.attr({
				'viewBox': viewboxval
			});

	    }

    	// Add a zoom event listener
    	this.draw.panZoom();
    	this.draw.on("zoom", e => {
    		
    		// Keep the gridsize the same
    		let zoom = this.draw.zoom() / e.detail.level;
    		this.grid.attr({ 
			    'stroke-width': this.grid.attr('stroke-width')*zoom
			});
			this.errorlines.attr({ 
			    'stroke-width': this.errorlines.attr('stroke-width')*zoom
			});

    	});

    }

    load(mapdata, args){

    	// Load the data
    	this.data.load(mapdata);

    	// Add antigen and sera
    	this.addAntigensAndSera(mapdata, false);

    	var xlim = args.settings.xlim;
    	var ylim = args.settings.ylim;

    	var xrange = xlim[1] - xlim[0];
    	var yrange = ylim[1] - ylim[0];
    	this.aspect = xrange / yrange;
    	this.xlim = xlim;
    	this.ylim = ylim;
    	this.xmid = (xlim[0]+xlim[1])/2;
    	this.ymid = (ylim[0]+ylim[1])/2;
    	this.draw.xlim = xlim;
    	this.draw.ylim = ylim;

    	// Size the viewport
    	this.viewportsizer.style.paddingTop = (1/this.aspect*100)+"%";

    	var draw = this.draw;
    	draw.plotter = this;
    	draw.on("mouseup", e => {
    		if(!this.pointclicked){
    			this.deselectAll();
    		}
    		this.pointclicked = false;
    	});

    	// Size the svg viewbox
		draw.viewbox(
			xlim[0], 
			ylim[0], 
			xrange, 
			yrange
		);

		// Set the original viewbox
		this.oviewbox = draw.viewbox();

    	// Draw the grid
    	this.grid = this.draw.group();
    	let mar = 0;
    	let x = xlim[0]-mar;
    	while(x <= xlim[1]+mar){
    		this.grid.line(x, ylim[0]-mar, x, ylim[1]+mar);
    		x++;
    	}

    	let y = ylim[0]-mar;
    	while(y <= ylim[1]+mar){
    		this.grid.line(xlim[0]-mar, y, xlim[1]+mar, y);
    		y++;
    	}
    	this.grid.attr({ 
			'stroke': "#eeeeee", 
			'stroke-width': 0.02
		})

    	// this.points = [];
    	// this.pointsgroup = this.draw.group();
    	// this.hoverpoints = this.draw.group();
    	var drawing_order = this.data.ptDrawingOrder();

    	// Cycle through the points
    	this.plotgroup  = draw.group();
    	this.pointgroup = this.plotgroup.group();
    	for(var i = 0; i<drawing_order.length; i++){
    		
    		var n     = drawing_order[i];
    		var point = this.points[n];
    		if(point.coords_na) continue

    	    point.element = new Racmacs.svg.element(point);
    	    point.element.index = i;

    	}

    	// Add procrustes
    	if(args.procrustes !== null){

    		var pc_coords_x = [];
    		var pc_coords_y = [];
    		for(var i=0; i<args.procrustes.ag.length; i++){
    			var pccoords = this.data.transformCoords(args.procrustes.ag);
    			pc_coords_x.push(pccoords[i][0]);
    			pc_coords_y.push(pccoords[i][1]);
    		}
    		for(var i=0; i<args.procrustes.sr.length; i++){
    			var pccoords = this.data.transformCoords(args.procrustes.sr);
    			pc_coords_x.push(pccoords[i][0]);
    			pc_coords_y.push(pccoords[i][1]);
    		}
    		
    		for(var i=0; i<this.points.length; i++){

    			if(this.points[i].coords_na || pc_coords_x[i] === null){
    				
    				this.points[i].setOpacity(0.1);
    				this.points[i].transparency_fixed = true;

    			} else {

	    			var arrowhead_length = 0.3;
	    			var arrowhead_width = 0.25;

	    			var ptcoords = this.points[i].coords;
	    			var x1 = ptcoords[0];
	    		    var y1 = ptcoords[1];
	    		    var x2 = pc_coords_x[i];
	    		    var y2 = pc_coords_y[i];
	    		    var angle = Math.atan2(y2 - y1, x2 - x1);
	    		    var targetx = x2 - Math.cos(angle)*arrowhead_length;
	    		    var targety = y2 - Math.sin(angle)*arrowhead_length;
	    		    var linelength = Math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));

	    		    // Draw the arrow line
	    		    if(linelength > arrowhead_length){
		    			this.plotgroup.line(
		    				x1,
		    				y1,
		    				targetx,
		    				targety
		    			).attr({ 
							'stroke': "#000", 
							'stroke-width': 0.08 
			    		});
	    			}

	    			// Draw the arrow head
	    			this.plotgroup
	    			.polygon("0,0 0,1, 1,0.5")
	    			.size(arrowhead_length,arrowhead_width)
	    			.move(x2-arrowhead_length, y2-arrowhead_width/2)
	    			.rotate(180*(angle/Math.PI), x2, y2);

    			}

    		}
    	}

    	// Set panzoom
    	var plotter = this;

    	// Style legend
    	if(args.legend !== null){

    		var legend = document.createElement("div");
    		legend.style.verticalAlign = "bottom";
    		legend.style.padding = "12px";
    		this.legend.appendChild(legend);

    		for(var i=0; i<args.legend.legend.length; i++){
    			var legend_entry = document.createElement("div");
				legend.appendChild(legend_entry);
				legend_entry.style.height = "20px";
				legend_entry.style.display = "flex";
				legend_entry.style.alignItems = "center";
				legend_entry.style.marginBottom = "6px";
				legend_entry.style.paddingLeft = "6px";
				legend_entry.style.paddingRight = "6px";
				

				var legend_fill = document.createElement("div");
				legend_entry.appendChild(legend_fill);
				legend_fill.style.height = "20px";
				legend_fill.style.width  = "20px";
				legend_fill.style.background = args.legend.fill[i];
				legend_fill.style.marginRight = "10px";

				var legend_label = document.createElement("div");
				legend_entry.appendChild(legend_label);
				legend_label.style.fontSize = "16px";
				legend_label.style.whiteSpace = "nowrap";
				legend_label.innerHTML = args.legend.legend[i];

    		}

    	}

		// Setup for error lines
		this.errorlines = this.plotgroup.group();
		this.errorlines.attr({
			"stroke-width" : 0.025
		});

    	// Match up y coordinates with a flip
    	// this.flipX();

    	// var tablewindow = window.open("", "", "width=200,height=100");
    	// window.addEventListener("beforeunload", e => {
    	// 	tablewindow.close()
    	// }); 
    	// console.log(tablewindow);
    	// var tableholder = tablewindow.document.body
    	// this.container.style.height = "100%";
    	// this.container.innerHTML = "";
    	// this.container.parentElement.style.overflow = "scroll";
    	// new Racmacs.HItable(this, this.container);

    }

    resizePoints(val){
        this.points.map( point => {
        	point.setSize(point.size*val);
        	point.setOutlineWidth(point.outlineWidth*val);
        });
    }

    maxzoom(){

      var width = this.draw.node.clientWidth;
      var height = this.draw.node.clientHeight;
      var v = this.oviewbox;

      var zoomX = width / v.width;
      var zoomY = height / v.height;
      var zoom = Math.min(zoomX, zoomY);

      return zoom;

    }

    resize(width, height){
    	this.viewportsizer.style.maxWidth     = ((height-80)*this.aspect)+"px";
    	this.viewportcontainer.style.maxWidth = ((height-80)*this.aspect)+"px";
    	let maxzoom = this.maxzoom();
    	this.draw.panZoom({
    		zoomMin: maxzoom,
    		zoomMax: maxzoom * 20
    	});
    }

    addHoverInfo(div){
    	this.infodiv.appendChild(div);
    }

    removeHoverInfo(div){
    	this.infodiv.removeChild(div);
    }

};



Racmacs.svg = {};
Racmacs.svg.element = class SVGelement {

	constructor(point){

		var draw = point.viewer.pointgroup;
		var size = point.size*0.1;
		var attributes = {
		    'stroke-width' : point.outlineWidth/25
		};

		var pt;
		var scalefactor = 1;

		// CIRCLE
		if(point.shape == "CIRCLE"){
			pt = draw.circle(size);
		} else 

		// BOX
		if(point.shape == "BOX"){
			scalefactor = 0.8
			size = size;
			pt = draw.rect(size, size);
		} else 

		// TRIANGLE
		if(point.shape == "TRIANGLE"){
			scalefactor = 0.6666
			size = size*scalefactor
			pt = draw.polygon([
				[-size*Math.sin(0),           -size*Math.cos(0)],
				[-size*Math.sin(4*Math.PI/3), -size*Math.cos(4*Math.PI/3)],
				[-size*Math.sin(2*Math.PI/3), -size*Math.cos(2*Math.PI/3)]
			]);
			pt.cy = function(x){
			   	return y == null
			      ? this.y() + this.height() / 1.666666
			      : this.y(x - this.height() / 1.666666)
			}
		} else 

		// EGG
		if (point.shape == "EGG"){
			scalefactor = 0.8
			size = size*scalefactor;
			pt = draw.path('M50,-0.056C72.107,-0.056 88,37.893 88,60C88,82.107 70.392,100 50,100C29.608,100 12,82.107 12,60C12,37.893 27.893,-0.056 50,-0.056Z');
			pt.size(size);
		} else 

		// UGLYEGG
		if (point.shape == "UGLYEGG"){
			scalefactor = 0.8
			size = size*scalefactor;
			pt = draw.path('M0.5,1L1.002,0.797L0.9,0.153L0.5,0L0.102,0.153L0,0.797L0.5,1Z');
			pt.size(size);
		} 

		// UNRECOGNISED
		else {
			throw("Point shape '"+point.shape+"' not recognised");
		}

		pt.name        = point.name;
		pt.ptsize      = point.size;
		pt.coords      = [point.coords[0], point.coords[1]];
		pt.scalefactor = scalefactor;

		// this.pointsgroup.add(pt);
		// this.points.push(pt);

		// pt.highlight = function(){
		// 	if(!this.highlighted){
    	// 		this.highlighted = true;
    	// 		this.sib = this.next();
    	// 		this.front();
    	// 		this.attr({stroke : "red" });
    	// 		this.plotter.infodiv.innerHTML = this.name;
    	// 	}
		// }
		// pt.dehighlight = function(){
		// 	if(this.highlighted){
    	// 		this.highlighted = false;
    	// 		if(this.sib !== undefined){
    	// 			this.insertBefore(this.sib);
    	// 		}
    	// 		this.attr({ stroke : this.attributes.stroke });
    	// 		this.plotter.infodiv.innerHTML = "";
		// 	}
		// }

		pt
		.addClass("unselected")
		.center(pt.coords[0], pt.coords[1])
		.attr(attributes)
		.transform({ flip: 'y' })
		.on("mouseover", function(){
			this.point.hover();
		})
		.on("mouseout", function(){
			this.point.dehover();
		})
		.on("mouseup", function(e){
			this.point.click(e);
			this.point.viewer.pointclicked = true;
		});

		pt.attributes = attributes;
		pt.point      = point;
		this.pt       = pt;
		
		this.setFillOpacity(point.viewer.graphics.ptStyles.deselected.opacity);
		this.setOutlineOpacity(point.viewer.graphics.ptStyles.deselected.opacity);
		this.setFillColor(point.fillColor);
		this.setOutlineColor(point.outlineColor);

	}

	setSize(size){
		this.pt
		.size(size*this.pt.scalefactor*0.1)
		.center(this.pt.coords[0], this.pt.coords[1]);
	}

	setFillColor(col){
		this.fill = col;
		this.pt.attr({
			'fill' : col
		});
		if(this.fillOpacity != 1){
			this.setFillOpacity(this.fillOpacity);
		}
	}

	setOutlineColor(col){
		this.outline = col;
		this.pt.attr({
			'stroke' : col
		});
		if(this.outlineOpacity != 1){
			this.setOutlineOpacity(this.outlineOpacity);
		}
	}

	setOutlineWidth(val){
		this.pt.attr({
			'stroke-width' : val/25
		});
	}

	setFillOpacity(opacity){
		if(this.fill != 'transparent'){
			if(opacity == 0){
				this.pt.attr({
					'fill' : 'transparent'
				});
			} else if(opacity == 1){
				this.pt.attr({
					'fill' : this.fill
				});
			} else {
				let str = window.getComputedStyle(this.pt.node).fill;
				let rgb;
				if(str.substring(0,4) === "rgb("){
					rgb = str
						  .substring(4, str.length-1)
						  .split(", ");
				} else {
					rgb = str
						  .substring(5, str.length-1)
						  .split(", ");
				}
				this.pt.attr({
					'fill' : "rgba("+rgb[0]+", "+rgb[1]+", "+rgb[2]+", "+opacity+")"
				});
			}
			this.fillOpacity = opacity;
		}
	}

	setOutlineOpacity(opacity){
		if(this.outline != 'transparent'){
			if(opacity == 0){
				this.pt.attr({
					'stroke' : 'transparent'
				});
			} else if(opacity == 1){
				this.pt.attr({
					'stroke' : this.outline
				});
			} else {
				let str = window.getComputedStyle(this.pt.node).stroke;
				let rgb;
				if(str.substring(0,4) === "rgb("){
					rgb = str
						  .substring(4, str.length-1)
						  .split(", ");
				} else {
					rgb = str
						  .substring(5, str.length-1)
						  .split(", ");
				}
				this.pt.attr({
					'stroke' : "rgba("+rgb[0]+", "+rgb[1]+", "+rgb[2]+", "+opacity+")"
				});
			}
			this.outlineOpacity = opacity;
		}
	}

	setIndex(index){
		var pos = this.pt.position();
		var pointgroup = this.pt.point.viewer.pointgroup.node;
		if(index == pointgroup.children.length-1){
			this.pt.front()
		} else if(pos < index){
			pointgroup.insertBefore(this.pt.node, pointgroup.children[index+1]);
		} else if(pos > index){
			pointgroup.insertBefore(this.pt.node, pointgroup.children[index]);
		}
    }

}


// Function for fetching the error data
Racmacs.Point.prototype.showErrors = function(pt = null){

	if(!this.errorLinesShown){

		this.errorLinesShown = true;

		// Highlight connected points
		var connectedPoints;
		if(pt === null) connectedPoints = this.getConnectedPoints();
		else            connectedPoints = pt;

		connectedPoints.map( x => x.highlight() );

		// Get error data
		var errordata = this.getErrorData(pt);

		// Group lines
		this.errorlines = this.viewer.errorlines.group();

		var coords1;
		var coords2;
		for(var i=0; i<errordata.coords.length; i+=2){
			coords1 = errordata.coords[i];
			coords2 = errordata.coords[i+1];
			this.errorlines.line(
				[coords1[0], coords1[1], coords2[0], coords2[1]]
			)
			.attr({ 
			    'stroke': "rgb("+errordata.colors.r[i]*255+","+errordata.colors.g[i]*255+","+errordata.colors.b[i]*255+")"
			});
		}

	}

}

// Remove connection lines from a point object
Racmacs.Point.prototype.hideErrors = function(){

	if(this.errorLinesShown){

		this.errorLinesShown = false;
		this.errorlines.remove();
		this.errorlines = null;

		// Dehighlight connected points
		var connectedPoints = this.getConnectedPoints(); 
		connectedPoints.map( x => x.dehighlight() );

	}

}


