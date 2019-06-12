
// Method to add antigens and sera to a plot
Racmacs.Viewer.prototype.addAntigensAndSera = function(mapData){

    // Fetch variables
    var table = this.data.table();

    // Create a transposed array (for getting serum titers)
    var ttable = [];
    var nAntigens = this.data.numAntigens();
    var nSera     = this.data.numSera();
    var i;

    for(i = 0; i < nSera; i++){
        ttable.push([]);
    };

    for(i = 0; i < nAntigens; i++){
        for(var j = 0; j < nSera; j++){
            ttable[j].push(table[i][j]);
        };
    };

    // Create points
    var pIndex = 0;
    var ptObjects = [];

    // antigens
    var agObjects = [];
    for(var i=0; i<nAntigens; i++){

        var ag = new Racmacs.Point({
            type          : "ag",
            name          : this.data.agNames(i),
            titers        : table[i],
            coords        : this.data.agCoords(i),
            size          : this.data.agSize(i),
            fillColor     : this.data.agFill(i),
            outlineColor  : this.data.agOutline(i),
            outlineWidth  : this.data.agOutlineWidth(i),
            aspect        : this.data.agAspect(i),
            shape         : this.data.agShape(i),
            drawing_order : this.data.agDrawingOrder(i),
            typeIndex     : i,
            pIndex        : pIndex
        });
        ag.viewer = this;
        agObjects.push(ag);
        ptObjects.push(ag);
        pIndex++;

    }

    // sera
    var srObjects = [];
    for(var i=0; i<nSera; i++){

        var sr = new Racmacs.Point({
            type          : "sr",
            name          : this.data.srNames(i),
            titers        : ttable[i],
            coords        : this.data.srCoords(i),
            size          : this.data.srSize(i),
            fillColor     : this.data.srFill(i),
            outlineColor  : this.data.srOutline(i),
            outlineWidth  : this.data.srOutlineWidth(i),
            aspect        : this.data.srAspect(i),
            shape         : this.data.srShape(i),
            drawing_order : this.data.srDrawingOrder(i),
            typeIndex     : i,
            pIndex        : pIndex
        });
        sr.colbase = this.data.colbases(i);
        sr.viewer  = this;
        srObjects.push(sr);
        ptObjects.push(sr);
        pIndex++;

    }

    // Attach to the viewport
    this.antigens = agObjects;
    this.sera     = srObjects;
    this.points   = ptObjects;

    // Update stress
    for(var i=0; i<this.sera.length; i++){
        this.sera[i].updateStress();
    }

}



// Set the point class for antigens and sera
Racmacs.Point = class Point {

    constructor(args){

        // Calculate coords vector
        var coords3 = args.coords;
        if(coords3.length < 3){ coords3.push(0) }
        var coordsVector = new THREE.Vector3();

        // Deal with na coords
        if(isNaN(args.coords[0])){
            this.coords_na = true;
            coordsVector.fromArray([0,0,0]);
        } else {
            this.coords_na = false;
            coordsVector.fromArray(coords3);
        }
        
        // Set properties
        this.type          = args.type;
        this.name          = args.name;
        this.titers        = args.titers;
        this.logTiters     = getLogTiters(this.titers);
        this.coords        = args.coords;
        this.coordsVector  = coordsVector;
        this.size          = args.size;
        this.fillColor     = args.fillColor;
        this.outlineColor  = args.outlineColor;
        this.outlineWidth  = args.outlineWidth;
        this.aspect        = args.aspect;
        this.shape         = args.shape;
        this.drawing_order = args.drawing_order;
        this.typeIndex     = args.typeIndex;
        this.pIndex        = args.pIndex;

        this.selected     = false;
        this.hovered      = false;
        this.highlighted  = 0;
        this.rayTraceable = true;
        this.opacity      = 1;

        this.stress   = 0;
        this.stresses = new Float32Array(new Array(args.titers.length).fill(0));

        // Add a browser record
        this.browserRecord = new Racmacs.BrowserRecord(this);

    }

    // Function to bind a plot element
    bindElement(element){

        this.element  = element;
        element.point = this;
        var point = this;
        element.hover = function(){
            point.hover();
        }
        element.dehover = function(){
            point.dehover();
        }
        element.click = function(){
            point.click();
        }
        element.rectangleSelect = function(){
            point.select();
        }
        this.updateDisplay();

    }

    // Coordinates without NA
    coordsNoNA(){
        if(this.coords_na){ return([0,0,0] )    }
        else              { return(this.coords) }
    }

    // Show point information
    showInfo(){
        
        this.infoDiv = document.createElement("div");
        this.infoDiv.innerHTML = this.name;

        if(this.viewer.coloring == "stress"){
            this.infoDiv.innerHTML += ", Stress : "+this.stress.toFixed(2);
            this.infoDiv.innerHTML += ", Mean stress : "+this.calcMeanStress().toFixed(2);
        }
        
        this.viewer.viewport.hover_info.add(this.infoDiv);

    }

    // Hide point information
    hideInfo(){

        this.viewer.viewport.hover_info.remove(this.infoDiv);
        this.infoDiv = null;
        
    }

    // Get the main color of the point
    getPrimaryColor(){

        if(this.fillColor != "transparent"){
            return(this.fillColor);
        } else {
            return(this.outlineColor);
        }

    }

    // Set the point shape
    setShape(shape){
        
        this.shape = shape;
        this.element.setShape(shape);

    }

    // Set the point size
    setSize(size){
        
        this.size = size;
        this.element.setSize(size);

    }

    // Scale the point
    scale(scaling){
        
        this.size = this.size*scaling;
        this.element.setSize(this.size);

    }

    // Hide and show
    hide(){
        this.element.hide();
    }

    show(){
        this.element.show();
    }

    // Set the point position
    setPosition(x, y, z){
        
        // Remove blobs if shown
        if(this.blob){
            this.removeBlob();
        }
        
        if(isNaN(x) || isNaN(y) || isNaN(z)){
            this.coords_na = true;
            x = 0;
            y = 0;
            z = 0;
        }

        // Update the coordinate vector
        this.coordsVector.x = x;
        this.coordsVector.y = y;
        this.coordsVector.z = z;

        // Update the coordinates array
        this.coords = this.coordsVector.toArray();

        // Update the point stress
        this.updateStress();
        
        // Move the point geometry
        this.element.setCoords(x, y, z);

        // Update any connections or error lines
        if(this.connectionLinesShown){
            this.updateConnectionLines();
        }
        if(this.errorLinesShown){
            this.updateErrorLines();
        }

    }

    // Set point opacity
    setOpacity(opacity){
        
        if(!this.transparency_fixed){
            
            this.opacity = opacity;

            if(this.fillColor != "transparent"){
                this.element.setFillOpacity(opacity);
            }

            if(this.outlineColor != "transparent"){
                this.element.setOutlineOpacity(opacity);
            }

            if(this.blobObject){
                this.blobObject.setOpacity(opacity);
            }

        }

    }

    // Set point aspect
    setAspect(aspect){
        
        this.aspect = aspect;
        this.element.setAspect(aspect);

    }

    // Set point outline width
    setOutlineWidth(outlineWidth){
        
        this.outlineWidth = outlineWidth;
        this.element.setOutlineWidth(outlineWidth);

    }

    // Get fill color as rgb array
    getFillColorRGBA(){
        if(this.fillColor == "transparent"){
            var col = "#ffffff";
        } else {
            var col = this.fillColor;
        }
        var rgb = new THREE.Color(col).toArray();
        if(this.fillColor == "transparent"){
            rgb.push(0);
        } else {
            rgb.push(this.opacity);
        }
        return(rgb);
    }

    // Get outline color as rgb array
    getOutlineColorRGBA(){
        if(this.outlineColor == "transparent"){
            var col = "#ffffff";
        } else {
            var col = this.outlineColor;
        }
        var rgb = new THREE.Color(col).toArray();
        if(this.outlineColor == "transparent"){
            rgb.push(0);
        } else {
            rgb.push(this.opacity);
        }
        return(rgb);
    }

    // Get outline color as rgb array
    getPrimaryColorRGBA(){
        var color = this.getPrimaryColor();
        if(color == "transparent"){
            var col = "#ffffff";
        } else {
            var col = this.outlineColor;
        }
        var rgb = new THREE.Color(col).toArray();
        if(color == "transparent"){
            rgb.push(0);
        } else {
            rgb.push(this.opacity);
        }
        return(rgb);
    }

    // Set point fill color
    setFillColor(col){
        
        if(!this.coloring_fixed){
            
            this.fillColor = col;

            if(col == "transparent"){
                // If color is transparent
                this.element.setFillOpacity(0);
                this.element.setFillColor("#ffffff");
            } else {
                // If color is not transparent
                this.element.setFillOpacity(this.opacity);
                this.element.setFillColor(col);
            }

            // Update the color of the browser record
            if(this.browserRecord){
                this.browserRecord.updateColor();
            }

            this.updateDisplay();
        }

    }

    // Set a temporary outline color
    setOutlineColorTemp(col){
        this.element.setOutlineColor(col);
    };

    // Restore the normal outline color
    restoreOutlineColor(){
        this.element.setOutlineColor(this.outlineColor);
    };

    // Set the point outline color
    setOutlineColor(col){
        
        if(!this.coloring_fixed){
            
            this.outlineColor = col;

            if(col == "transparent"){
                // If color is transparent
                this.element.setOutlineOpacity(0);
                this.element.setOutlineColor("#ffffff");
            } else {
                // If color is not transparent
                this.element.setOutlineOpacity(this.opacity);
                this.element.setOutlineColor(col);
            }

            // Update the color of the browser record
            if(this.browserRecord){
                this.browserRecord.updateColor();
            }

            this.updateDisplay();
        }

    }

    // Get the titer to another point
    titerTo(to){

        return(this.titers[to.typeIndex]);

    }

    // Get the log titer to another point
    logTiterTo(to){

        return(this.logTiters[to.typeIndex]);

    }
    
    // Get the map distance to another point
    mapDistTo(to){
        
        return(this.coordsVector.distanceTo(to.coordsVector));

    }

    // Get the table distance to another point
    tableDistTo(to){
        
        var logTiter = this.logTiterTo(to);
        if(this.type == "ag"){
            return(calc_table_dist(logTiter, to.colbase));
        } else {
            return(calc_table_dist(logTiter, this.colbase));
        }

    }

    // Calculate the point stress
    calcStress(){

        if(this.type == "ag"){
            var partners = this.viewer.sera;
        } else {
            var partners = this.viewer.antigens;
        }
        
        var stress = 0;
        for(var i=0; i<partners.length; i++){
            
            // Update the stress to the corresponding point
            stress += this.calcStressTo(partners[i]);

        }
        return(stress);

    }

    // Calculate the mean stress for this point
    calcMeanStress(){

        // var connections = this.getConnections();
        var num_detectable = 0;
        for(var i=0; i<this.titers.length; i++){
            if(this.titers[i].charAt(0) != "<"
               && this.titers[i].charAt(0) != "*"){
                num_detectable++;
            }
        }
        return(this.stress / num_detectable);

    }

    // Calculate the stress to another point
    calcStressTo(to){

        var tableDist = this.tableDistTo(to);
        var mapDist   = this.mapDistTo(to);
        var titer     = this.titers[to.typeIndex];
        
        // Deal with NA coordinates and NaN table distances
        if(this.coords_na || to.coords_na){

            return(0);

        } else {

            return(calc_stress(
                tableDist,
                mapDist,
                titer
            ));

        }

    }
    
    // Update the stored stress to another point
    updateStressTo(to){

        // Record the start stress
        var last_stress = this.stresses[to.typeIndex];

        // Calculate the stress
        var stress = this.calcStressTo(to);

        // Update the stress on the partner
        to.stresses[this.typeIndex] = stress;
        to.stress += stress - last_stress;
        
        // Update the stress on this point
        this.stresses[to.typeIndex] = stress;
        this.stress += stress - last_stress;

    }
    
    // Update the stress of this point
    updateStress(){

        if(this.type == "ag"){
            var partners = this.viewer.sera;
        } else {
            var partners = this.viewer.antigens;
        }

        for(var i=0; i<partners.length; i++){
            
            // Update the stress to the corresponding point
            this.updateStressTo(partners[i]);

        }

    }
 
    // Translate the point
    translate(x, y, z){

        // Update the position of the point in the viewer
        this.setPosition(
            this.coordsVector.x + x,
            this.coordsVector.y + y,
            this.coordsVector.z + z
        );

    }

    // Get connections from this point
    getConnections(){
        
        var titers = this.titers;
        var connections = [];
        for(var i=0; i<titers.length; i++){
            if(titers[i] != "*"){
                connections.push(i);
            }
        }
        return(connections);

    }

    getConnectedPoints(updateCache = false){

        if(!this.connectedPoints || updateCache == true){


            if(this.type == "ag"){
                var partners = this.viewer.sera;
            } else {
                var partners = this.viewer.antigens;
            }

            var connections = this.getConnections();
            this.connectedPoints = Array(connections.length);
            for(var i=0; i<connections.length; i++){
                
                this.connectedPoints[i] = partners[connections[i]];

            }

        }

        return(this.connectedPoints);

    }

}









// function getPointConstructor(){

    // // Add Point prototype
    // Point = function(
    //     type,
    //     name,
    //     cluster,
    //     titers,
    //     coords,
    //     size,
    //     fillColor,
    //     outlineColor,
    //     outlineWidth,
    //     aspect,
    //     shape,
    //     drawing_order,
    //     typeIndex,
    //     pIndex
    // ){

    //     // Calculate coords vector
    //     var coords3 = coords;
    //     if(coords3.length < 3){ coords.push(0) }
    //     var coordsVector = new THREE.Vector3().fromArray(coords3);

    //     // Set na coords
    //     if(isNaN(coords[0])){
    //         this.coords_na = true;
    //     } else {
    //         this.coords_na = false;
    //     }
        
    //     // Set properties
    //     this.type          = type;
    //     this.name          = name;
    //     this.cluster       = cluster;
    //     this.titers        = titers;
    //     this.logTiters     = getLogTiters(titers);
    //     this.coords        = coords;
    //     this.coordsVector  = coordsVector;
    //     this.size          = size;
    //     this.fillColor     = fillColor;
    //     this.outlineColor  = outlineColor;
    //     this.outlineWidth  = outlineWidth;
    //     this.aspect        = aspect;
    //     this.shape         = shape;
    //     this.drawing_order = drawing_order;
    //     this.typeIndex     = typeIndex;
    //     this.pIndex        = pIndex;

    //     this.selected     = false;
    //     this.hovered      = false;
    //     this.highlighted  = 0;
    //     this.rayTraceable = true;
    //     this.opacity      = 1;

    //     this.stress   = 0;
    //     this.stresses = new Float32Array(new Array(titers.length).fill(0));

    // }

    // Point.prototype.showInfo = function(){
        
    //     this.infoDiv = document.createElement("div");
    //     this.infoDiv.innerHTML = this.name;
    //     this.infoDiv.innerHTML += ", Stress : "+this.stress.toFixed(2);
    //     this.infoDiv.innerHTML += ", Mean stress : "+this.calcMeanStress().toFixed(2);

    //     if(this.procrustes){
    //         this.infoDiv.innerHTML += ", Procrustes distance : "+this.procrustes.dist.toFixed(2);
    //     }
        
    //     viewport.info_div.appendChild(this.infoDiv);

    // }

    // Point.prototype.hideInfo = function(){

    //     viewport.info_div.removeChild(this.infoDiv);
    //     this.infoDiv = null;
        
    // }

    // Point.prototype.getPrimaryColor = function(){

    //     if(this.fillColor != "transparent"){
    //         return(this.fillColor);
    //     } else {
    //         return(this.outlineColor);
    //     }

    // }

    // Point.prototype.setShape = function(shape){
        
    //     this.shape = shape;
    //     this.setPointGeoShape(shape);

    // }

    // Point.prototype.setSize = function(size){
        
    //     this.size = size;
    //     this.setPointGeoSize(size);

    // }

    // Point.prototype.scale = function(scaling){
        
    //     this.size = this.size*scaling;
    //     this.setPointGeoSize(this.size);

    // }

    // Point.prototype.setPosition = function(x, y, z){
        
    //     // Remove blobs if shown
    //     if(this.blob){
    //         this.removeBlob();
    //     }

    //     // Remove procrustes if shown
    //     if(this.arrow){
    //         this.removeArrow();
    //     }
        
    //     if(isNaN(x) || isNaN(y) || isNaN(z)){
    //         this.coords_na = true;
    //         x = 0;
    //         y = 0;
    //         z = 0;
    //     }

    //     // Update the coordinate vector
    //     this.coordsVector.x = x;
    //     this.coordsVector.y = y;
    //     this.coordsVector.z = z;

    //     // Update the coordinates array
    //     this.coords = this.coordsVector.toArray();

    //     // Update the point stress
    //     this.updateStress();
        
    //     // Move the point geometry
    //     this.setPointGeoPosition(x, y, z);

    //     // Update any connections or error lines
    //     if(viewport.connectionLines){
    //         this.updateConnections();
    //     }
    //     if(viewport.errorLines){
    //         this.updateErrors();
    //     }

    // }

    // Point.prototype.setOpacity = function(opacity){
        
    //     if(!this.transparency_fixed){
            
    //         this.setPointGeoOpacity(opacity);
    //         this.opacity = opacity;

    //         if(this.blobObject){
    //             this.blobObject.setOpacity(opacity);
    //         }

    //     }

    // }

    // Point.prototype.setAspect = function(aspect){
        
    //     this.aspect = aspect;
    //     this.setPointGeoAspect(aspect);

    // }

    // Point.prototype.setOutlineWidth = function(outlineWidth){
        
    //     this.outlineWidth = outlineWidth;
    //     this.setPointGeoOutlineWidth(outlineWidth);

    // }

    // Point.prototype.setFillColor = function(col){
        
    //     if(!this.coloring_fixed){
            
    //         this.fillColor = col;

    //         if(col == "transparent"){
    //             // If color is transparent
    //             this.setPointGeoFill2Transparent();
    //             this.setPointGeoFillColor("#ffffff");
    //         } else {
    //             // If color is not transparent
    //             this.setPointGeoFill2NonTransparent();
    //             this.setPointGeoFillColor(col);
    //         }

    //         // Update the color of the browser record
    //         if(this.browserRecord){
    //             this.browserRecord.updateColor();
    //         }

    //         // Update any blobs
    //         if(this.blob){
    //             this.setBlobGeoFillCol(this.fillColor);
    //         }

    //         this.updateDisplay();
    //     }

    // }

    // Point.prototype.setOutlineColorTemp = function(col){
    //     this.setPointGeoOutlineColor(col);
    // };

    // Point.prototype.restoreOutlineColor = function(){
    //     this.setPointGeoOutlineColor(this.outlineColor);
    // };

    // Point.prototype.setOutlineColor = function(col){
        
    //     if(!this.coloring_fixed){
            
    //         this.outlineColor = col;

    //         if(col == "transparent"){
    //             // If color is transparent
    //             this.setPointGeoOutline2Transparent();
    //             this.setPointGeoOutlineColor("#ffffff");
    //         } else {
    //             // If color is not transparent
    //             this.setPointGeoOutline2NonTransparent();
    //             this.setPointGeoOutlineColor(col);
    //         }

    //         // Update the color of the browser record
    //         if(this.browserRecord){
    //             this.browserRecord.updateColor();
    //         }

    //         // Update any blobs
    //         if(this.blob){
    //             this.setBlobGeoOutlineCol(this.outlineColor);
    //         }

    //         this.updateDisplay();
    //     }

    // }

    // Point.prototype.titerTo = function(to){

    //     return(this.titers[to.typeIndex]);

    // }

    // Point.prototype.logTiterTo = function(to){

    //     return(this.logTiters[to.typeIndex]);

    // }
    
    // Point.prototype.mapDistTo = function(to){
        
    //     return(this.coordsVector.distanceTo(to.coordsVector));

    // }

    // Point.prototype.tableDistTo = function(to){
        
    //     var logTiter = this.logTiterTo(to);
    //     if(this.type == "ag"){
    //         return(calc_table_dist(logTiter, to.colbase));
    //     } else {
    //         return(calc_table_dist(logTiter, this.colbase));
    //     }

    // }

    // Point.prototype.calcStress = function(){

    //     if(this.type == "ag"){
    //         var partners = viewport.sera;
    //     } else {
    //         var partners = viewport.antigens;
    //     }
        
    //     var stress = 0;
    //     for(var i=0; i<partners.length; i++){
            
    //         // Update the stress to the corresponding point
    //         stress += this.calcStressTo(partners[i]);

    //     }
    //     return(stress);

    // }

    // Point.prototype.calcMeanStress = function(){

    //     // var connections = this.getConnections();
    //     var num_detectable = 0;
    //     for(var i=0; i<this.titers.length; i++){
    //         if(this.titers[i].charAt(0) != "<"
    //            && this.titers[i].charAt(0) != "*"){
    //             num_detectable++;
    //         }
    //     }
    //     return(this.stress / num_detectable);

    // }

    // Point.prototype.calcStressTo = function(to){

    //     var tableDist = this.tableDistTo(to);
    //     var mapDist   = this.mapDistTo(to);
    //     var titer     = this.titers[to.typeIndex];
        
    //     // Deal with NA coordinates
    //     if(this.coords_na || to.coords_na){
    //         return(0);
    //     } else {

    //         return(calc_stress(
    //             tableDist,
    //             mapDist,
    //             titer
    //         ));

    //     }

    // }
    
    // Point.prototype.updateStressTo = function(to){

    //     // Record the start stress
    //     var last_stress = this.stresses[to.typeIndex];

    //     // Calculate the stress
    //     var stress = this.calcStressTo(to);

    //     // Update the stress on the partner
    //     to.stresses[this.typeIndex] = stress;
    //     to.stress += stress - last_stress;
        
    //     // Update the stress on this point
    //     this.stresses[to.typeIndex] = stress;
    //     this.stress += stress - last_stress;

    // }
    
    // Point.prototype.updateStress = function(){

    //     if(this.type == "ag"){
    //         var partners = viewport.sera;
    //     } else {
    //         var partners = viewport.antigens;
    //     }

    //     for(var i=0; i<partners.length; i++){
            
    //         // Update the stress to the corresponding point
    //         this.updateStressTo(partners[i]);

    //     }

    // }
 
    // // This is a generic function for translating a point
    // Point.prototype.translate = function(x, y, z){

    //     // Update the position of the point in the viewer
    //     this.setPosition(
    //         this.coordsVector.x + x,
    //         this.coordsVector.y + y,
    //         this.coordsVector.z + z
    //     );

    // }

    // Point.prototype.getConnections  = function(){
        
    //     var titers = this.titers;
    //     var connections = [];
    //     for(var i=0; i<titers.length; i++){
    //         if(titers[i] != "*"){
    //             connections.push(i);
    //         }
    //     }
    //     return(connections);

    // }

//     return(Point);

// }








function add_agsr(viewport, mapData){

    var Point = viewport.Point;
    Point.prototype.viewport = viewport;

    // Set defaults
    if(!mapData.ag_drawing_order){ mapData.ag_drawing_order = new Array(mapData.ag_names.length).fill(0) }
    if(!mapData.sr_drawing_order){ mapData.sr_drawing_order = new Array(mapData.sr_names.length).fill(0) }

    // Create a transposed array (for getting serum titers)
    var ttable = [];
    var nAntigens = mapData.table.length;
    var nSera     = mapData.table[0].length;
    var i;

    for(i = 0; i < nSera; i++){
        ttable.push([]);
    };

    for(i = 0; i < nAntigens; i++){
        for(var j = 0; j < nSera; j++){
            ttable[j].push(mapData.table[i][j]);
        };
    };

    // Create points
    var pIndex = 0;
    var ptObjects = [];
    viewport.pointVectors = [];

    // antigens
    var agObjects = [];
    for(var i=0; i<mapData.ag_names.length; i++){

        var ag = new Point(
            type          = "ag",
            name          = mapData.ag_names[i],
            cluster       = mapData.ag_clusters[i],
            titers        = mapData.table[i],
            coords        = mapData.ag_coords[i],
            size          = mapData.ag_size[i],
            fillColor     = mapData.ag_cols_fill[i],
            outlineColor  = mapData.ag_cols_outline[i],
            outlineWidth  = mapData.ag_outline_width[i],
            aspect        = mapData.ag_aspect[i],
            shape         = mapData.ag_shape[i],
            drawing_order = mapData.ag_drawing_order[i],
            typeIndex     = i,
            pIndex        = pIndex
        );
        agObjects.push(ag);
        ptObjects.push(ag);
        viewport.pointVectors.push(ag.coordsVector);
        pIndex++;

    }

    // sera
    var srObjects = [];
    for(var i=0; i<mapData.sr_names.length; i++){

        var sr = new Point(
            type          = "sr",
            name          = mapData.sr_names[i],
            cluster       = mapData.sr_clusters[i],
            titers        = ttable[i],
            coords        = mapData.sr_coords[i],
            size          = mapData.sr_size[i],
            fillColor     = mapData.sr_cols_fill[i],
            outlineColor  = mapData.sr_cols_outline[i],
            outlineWidth  = mapData.sr_outline_width[i],
            aspect        = mapData.sr_aspect[i],
            shape         = mapData.sr_shape[i],
            drawing_order = mapData.sr_drawing_order[i],
            typeIndex     = i,
            pIndex        = pIndex
        );
        srObjects.push(sr);
        ptObjects.push(sr);
        viewport.pointVectors.push(sr.coordsVector);
        pIndex++;

    }
    
    // Attach to the viewport
    viewport.antigens = agObjects;
    viewport.sera     = srObjects;
    viewport.points   = ptObjects;


    // Bind function to set colbases
    viewport.setColbases = function(colbases){
        
        for(var i=0; i<this.sera.length; i++){
            this.sera[i].colbase = colbases[i];
        }

    }

    // Set the column bases
    viewport.setColbases(mapData.colbases);
    
    // Bind function to restore point defaults
    viewport.setPointDefaults = function(){
        
        for(var i=0; i<this.points.length; i++){
            var point = this.points[i];
            point.setShape(point.shape);
            point.setPosition(point.coords[0], point.coords[1], point.coords[2]);
            point.setFillColor(point.fillColor);
            point.setOutlineColor(point.outlineColor);
            point.setOutlineWidth(point.outlineWidth);
            point.setSize(point.size);
            point.setOpacity(1);
            point.setAspect(point.aspect);
        }

    }

    // Function to update the map data based on the points
    viewport.updateMapData = function(
        update_coords = true
        ){

        for(var i=0; i<this.antigens.length; i++){

            if(update_coords){
                this.mapData.ag_coords[i] = this.antigens[i].coords.slice(0, this.dimensions);
            }

        }

        for(var i=0; i<this.sera.length; i++){

            if(update_coords){
                this.mapData.sr_coords[i] = this.sera[i].coords.slice(0, this.dimensions);
            }

        }

    }
        
    // Bind function to update the scene sphere
    viewport.updateSceneSphere = function(){

        // Set the bounding sphere
        var spherePoints = [];
        for(var i=0; i<this.points.length; i++){
            if(!this.points[i].coords_na){
                spherePoints.push(this.points[i].coordsVector);
            }
        }
        this.scene.sphere = new THREE.Sphere().setFromPoints(spherePoints);

    }
 
}




