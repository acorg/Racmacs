
Racmacs.Viewer.prototype.clearLegend = function(){

    if (this.group_legend) {
        this.viewport.div.removeChild(this.group_legend);
        this.group_legend = null;
    }

}

Racmacs.Viewer.prototype.showLegend = function(){

	// Create legend div
	this.group_legend = document.createElement("div");
	this.group_legend.style.position = "absolute";
	this.group_legend.style.bottom = "10px";
	this.group_legend.style.left = "10px";
	this.group_legend.style.background = "#ffffff";
	this.group_legend.style.border = "solid 1px #bbbbbb";
	this.group_legend.style.padding = "10px";
	this.group_legend.style.borderRadius = "4px";
	this.viewport.div.appendChild(this.group_legend);

    // Get antigen data
    var ag_group_values = this.data.agGroupValues();
    var ag_group_levels = this.data.agGroupLevels();
    var ag_group_fill = this.data.agGroupLevelFill();
    var ag_group_outline = this.data.agGroupLevelOutline();

    ag_group_levels.map((level, i) => {
        if (ag_group_values.indexOf(i) != -1) {

        	var entry = document.createElement("div");
        	if (i != 0) entry.style.marginTop = "6px";
        	
        	var point = document.createElement("div");
        	point.style.height = "16px";
        	point.style.width = "16px";
        	point.style.boxSizing = "border-box";
        	point.style.border = "solid 1.5px " + ag_group_outline[i];
        	point.style.borderRadius = "8px";
        	point.style.marginRight = "4px";
        	point.style.background = ag_group_fill[i];
        	point.style.display = "inline-block";
        	point.style.verticalAlign = "middle";
        	point.addEventListener("mouseup", e => {
        		var ags = [];
        		ag_group_values.map((x, j) => x == i && ags.push(j));
        		this.deselectAll();
        		this.selectAntigensByIndices(ags);
        	});

        	var label = document.createElement("div");
        	label.style.fontFamily = "sans-serif";
        	label.style.fontSize = "16px";
        	label.style.display = "inline-block";
        	label.style.verticalAlign = "middle";
        	label.innerHTML = level;

        	entry.appendChild(point);
        	entry.appendChild(label);
        	this.group_legend.appendChild(entry);

        }
    });

    // Set spacer
    var spacer = document.createElement("hr");
    spacer.style.border = "solid 0.5px #cccccc";
    spacer.style.width = "24px";
    spacer.style.margin = "10px";
    spacer.style.marginLeft = "0";
    this.group_legend.appendChild(spacer);

    // Get sera data
    var sr_group_values = this.data.srGroupValues();
    var sr_group_levels = this.data.srGroupLevels();
    var sr_group_fill = sr_group_levels.map((level, i) => this.data.srFill(sr_group_values.indexOf(i)));
    var sr_group_outline = sr_group_levels.map((level, i) => this.data.srOutline(sr_group_values.indexOf(i)));

    sr_group_levels.map((level, i) => {
    	if (sr_group_values.indexOf(i) != -1) {
    	
            var entry = document.createElement("div");
        	if (i != 0) entry.style.marginTop = "6px";
        	
        	var point = document.createElement("div");
        	point.style.height = "15px";
        	point.style.width = "15px";
        	point.style.boxSizing = "border-box";
        	point.style.border = "solid 1.5px " + sr_group_outline[i];
        	point.style.marginRight = "5px";
        	point.style.background = sr_group_fill[i];
        	point.style.display = "inline-block";
        	point.style.verticalAlign = "middle";
        	point.addEventListener("mouseup", e => {
        		var srs = [];
        		sr_group_values.map((x, j) => x == i && srs.push(j));
        		this.deselectAll();
        		this.selectSeraByIndices(srs);
        	});

        	var label = document.createElement("div");
        	label.style.fontFamily = "sans-serif";
        	label.style.fontSize = "16px";
        	label.style.display = "inline-block";
        	label.style.verticalAlign = "middle";
        	label.innerHTML = level;

        	entry.appendChild(point);
        	entry.appendChild(label);
        	this.group_legend.appendChild(entry);

        }
    });

}
