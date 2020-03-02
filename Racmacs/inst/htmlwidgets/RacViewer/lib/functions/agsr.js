
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
        while(coords3.length < 3){ coords3.push(0) }
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
        this.logTiters     = Racmacs.utils.getLogTiters(this.titers);
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

    // Coordinates
    getPosition(){
        if(this.coords_na){
            return([NaN,NaN,NaN]);
        } else {
            return(this.coords);
        }
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

    getSize(size){
        
        this.size;

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

    // Reset the point position based on map data
    resetPosition(){

        if(this.type == "ag"){
            var position = this.viewer.data.agCoords(this.typeIndex);
        } else {
            var position = this.viewer.data.srCoords(this.typeIndex);
        }
        this.setPosition(position[0], position[1], 0);

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
            var col = color;
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
            var tabledist = Racmacs.utils.calc_table_dist(logTiter, to.colbase);
        } else {
            var tabledist = Racmacs.utils.calc_table_dist(logTiter, this.colbase);
        }
        return(tabledist);

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

            var stress = Racmacs.utils.calc_stress(
                tableDist,
                mapDist,
                titer
            );
            return(stress);

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

    // Get the point drawing order
    drawingOrder(){
        return(this.viewer.data.ptDrawingOrder().indexOf(this.pIndex));
    }

    // Bring the point to the top
    moveToTop(){
        
        if(this.viewer.mapdims.dimensions == 2){
            if(this.element.setIndex !== undefined){
                this.element.setIndex(this.element.parent.elements().length-1);
            }
        }

    }

    moveFromTop(){
        
        if(this.viewer.mapdims.dimensions == 2){
            if(this.element.setIndex !== undefined){
                this.element.setIndex(this.drawingOrder());
            }
        }

    }

}








