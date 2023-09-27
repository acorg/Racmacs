
// Remove antigens and sera from plot
Racmacs.App.prototype.clearAntigensAndSera = function(){

    this.antigens = [];
    this.sera     = [];
    this.points   = [];

}

// Method to add antigens and sera to a plot
Racmacs.App.prototype.addAntigensAndSera = function(mapData){

    // Create a transposed array (for getting serum titers)
    var nAntigens = this.data.numAntigens();
    var nSera     = this.data.numSera();
    var i;

    // Create points
    this.antigens = [];
    this.sera     = [];
    this.points   = [];

    // antigens
    var ag_group_levels = this.data.agGroupLevels();
    for(var i=0; i<nAntigens; i++){

        var ag = new Racmacs.Antigen({
            name          : this.data.agNames(i),
            coords        : this.data.agCoords(i),
            size          : this.data.agSize(i),
            fillColor     : this.data.agFill(i),
            outlineColor  : this.data.agOutline(i),
            outlineWidth  : this.data.agOutlineWidth(i),
            aspect        : this.data.agAspect(i),
            shape         : this.data.agShape(i),
            shown         : this.data.agShown(i),
            drawing_order : this.data.agDrawingOrder(i),
            group         : this.data.agGroupValues(i),
            group_levels  : ag_group_levels,
            typeIndex     : i,
            pIndex        : i,
            viewer        : this
        });
        ag.partners = this.sera;
        this.antigens.push(ag);
        this.points.push(ag);

    }

    // sera
    var sr_group_levels = this.data.srGroupLevels();
    for(var i=0; i<nSera; i++){

        var sr = new Racmacs.Serum({
            type          : "sr",
            name          : this.data.srNames(i),
            coords        : this.data.srCoords(i),
            size          : this.data.srSize(i),
            fillColor     : this.data.srFill(i),
            outlineColor  : this.data.srOutline(i),
            outlineWidth  : this.data.srOutlineWidth(i),
            aspect        : this.data.srAspect(i),
            shape         : this.data.srShape(i),
            shown         : this.data.srShown(i),
            drawing_order : this.data.srDrawingOrder(i),
            group         : this.data.srGroupValues(i),
            group_levels  : sr_group_levels,
            typeIndex     : i,
            pIndex        : i + nAntigens,
            viewer        : this
        });
        sr.partners = this.antigens;
        this.sera.push(sr);
        this.points.push(sr);

    }

}



// Set the point class for antigens and sera
Racmacs.Point = class Point {

    constructor(args){

        // Set properties
        this.viewer        = args.viewer;

        this.name          = args.name;
        this.size          = args.size;
        this.fillColor     = args.fillColor;
        this.outlineColor  = args.outlineColor;
        this.outlineWidth  = args.outlineWidth;
        this.aspect        = args.aspect;
        this.shape         = args.shape;
        this.shown         = args.shown;
        this.group         = args.group;
        this.drawing_order = args.drawing_order;
        this.typeIndex     = args.typeIndex;
        this.pIndex        = args.pIndex;

        this.selected       = false;
        this.hovered        = false;
        this.highlighted    = 0;
        this.rayTraceable   = true;
        this.fillopacity    = 1;
        this.outlineopacity = 1;
        this.scaling        = 1;
        this.included       = true;

        // Expand short shape descriptions
        if (this.shape == "C") this.shape = "CIRCLE";
        if (this.shape == "B") this.shape = "BOX";
        if (this.shape == "T") this.shape = "TRIANGLE";
        if (this.shape == "E") this.shape = "EGG";
        if (this.shape == "U") this.shape = "UGLYEGG";

        if (args.group_levels != undefined) {
            this.groupvalue = args.group_levels[args.group];
        }


        this.coords_na = args.coords === null || isNaN(args.coords[0]) || args.coords[0] === null;
        if(this.coords_na){
            this.coords3 = [0,0,0];
            this.shown = false;
        } else {
            this.coords3 = args.coords.slice();
            while(this.coords3.length < 3){ this.coords3.push(0) }
        }


        // Add a browser record
        if(Racmacs.BrowserRecord){
            this.browserRecord = new Racmacs.BrowserRecord(this);
        }

        // Calculate coords vector
        if(typeof(THREE) !== "undefined"){
            this.coordsVector  = new THREE.Vector3().fromArray(this.coords3);
        }


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
        element.click = function(event){
            point.click(event);
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
            return(this.coords3);
        }
    }

    // Coordinates without NA
    coordsNoNA(){
        if(this.coords_na){ return([0,0,0] )    }
        else              { return(this.coords3) }
    }

    // Show point information
    showInfo(){
        
        if (this.shown) {
            this.infoDiv = document.createElement("div");
            this.infoDiv.innerHTML = this.name;

            if(this.viewer.coloring == "stress"){
                this.infoDiv.innerHTML += ", Stress : "+this.stressval.toFixed(2);
                this.infoDiv.innerHTML += ", Mean stress : "+this.meanstress.toFixed(2);
            }
            
            this.viewer.addHoverInfo(this.infoDiv);
        }

    }

    // Hide point information
    hideInfo(){

        this.viewer.removeHoverInfo(this.infoDiv);
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

    getPrimaryColorHex(){

        var col = this.getPrimaryColor();
        col = this.viewer.map_color(col);
        return new THREE.Color(col).getHexString();

    }

    getSecondaryColor(){

        if(this.outlineColor == "transparent" || this.fillColor == "transparent"){
            return("#ffffff");
        } else {
            return(this.outlineColor);
        }

    }

    // Set the point shape
    setShape(shape){
        
        this.shape = shape;
        if(this.element){
            this.element.setShape(shape);
        }

    }

    // Set the point size
    setSize(size){
        
        this.size = size;
        if(this.element){
            this.element.setSize(size*this.scaling);
        }

    }

    getSize(size){
        
        this.size;

    }

    // Scale the point
    scale(scaling){
        
        this.size = this.size*scaling;
        if(this.element){
            this.element.setSize(this.size);
        }

    }

    // Hide and show
    hide(fire_handler){
        if(!this.coords_na && this.shown){
            this.hideElement();
            this.shown = false
        }
    }

    show(fire_handler){
        if(!this.coords_na && !this.shown){
            this.showElement();
            this.shown = true
        }
    }

    hideElement(){
        if(this.element){
            this.element.hide();
            this.viewer.sceneChange = true;
        }
    }

    showElement(){
        if(this.element){
            this.element.show();
            this.viewer.sceneChange = true;
        }
    }

    // Set the point position
    setPosition(to, dispatch = true){

        while (to.length < 3) to.push(0);

        // Set from and to
        var from = [
            this.coordsVector.x,
            this.coordsVector.y,
            this.coordsVector.z,
        ];

        // Remove blobs if shown
        if(this.blob){
            this.removeBlob();
        }

        if(isNaN(to[0]) || isNaN(to[1]) || isNaN(to[2])){
            this.coords_na = true;
            this.shown = false;
            to[0] = 0;
            to[1] = 0;
            to[2] = 0;
        }

        // Update the coordinate vector
        this.coordsVector.x = to[0];
        this.coordsVector.y = to[1];
        this.coordsVector.z = to[2];

        // Update the coordinates array
        this.coords3 = this.coordsVector.toArray();
        
        // Move the point geometry
        if(this.element){
            this.element.setCoords(to[0], to[1], to[2]);
        }

        // Update any connections or error lines
        if (dispatch) {
            this.viewer.dispatchEvent("point-moved", {
                point : this,
                from  : from,
                to    : to
            });
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
        
        if(this.element && !this.transparency_fixed){

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

    restoreOpacity(opacity){

        if(this.element && !this.transparency_fixed){
            this.element.setFillOpacity(this.fillopacity);
            this.element.setOutlineOpacity(this.outlineopacity);
        }

    }

    // Set point aspect
    setAspect(aspect){
        
        this.aspect = aspect;
        if(this.element){
            this.element.setAspect(aspect);
        }

    }

    // Set point outline width
    setOutlineWidth(outlineWidth){
        
        this.outlineWidth = outlineWidth;
        if(this.element){
            this.element.setOutlineWidth(outlineWidth);
        }

    }

    // Get fill color as rgb array
    getFillColorRGBA(){
        if(this.fillColor == "transparent"){
            var col = "#ffffff";
        } else {
            var col = this.viewer.map_color(this.fillColor);
        }
        var rgb = new THREE.Color(col).toArray();
        if(this.fillColor == "transparent"){
            rgb.push(0);
        } else {
            rgb.push(this.fillopacity);
        }
        return(rgb);
    }

    // Get outline color as rgb array
    getOutlineColorRGBA(){
        if(this.outlineColor == "transparent"){
            var col = "#ffffff";
        } else {
            var col = this.viewer.map_color(this.outlineColor);
        }
        var rgb = new THREE.Color(col).toArray();
        if(this.outlineColor == "transparent"){
            rgb.push(0);
        } else {
            rgb.push(this.outlineopacity);
        }
        return(rgb);
    }

    // Get outline color as rgb array
    getPrimaryColorRGBA(){
        var color = this.getPrimaryColor();
        if(color == "transparent"){
            var col = "#ffffff";
        } else {
            var col = this.viewer.map_color(color);
        }
        var rgb = new THREE.Color(col).toArray();
        if(color == "transparent"){
            rgb.push(0);
        } else {
            rgb.push(this.fillopacity);
        }
        return(rgb);
    }

    // Set point fill color
    setFillColor(col){

        if(!this.coloring_fixed){
            
            this.fillColor = col;

            if(this.element){
                if(col == "transparent"){
                    // If color is transparent
                    this.element.setFillOpacity(0);
                    this.element.setFillColor("#ffffff");
                    this.fillopacity = 0;
                } else {
                    // If color is not transparent
                    if (this.fillopacity == 0) this.fillopacity = this.viewer.styleset.noselections.unhovered.unselected.opacity;
                    this.element.setFillOpacity(this.fillopacity);
                    this.element.setFillColor(col);
                }
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
        if(this.element){
            this.element.setOutlineColor(col);
        }
    };

    // Restore the normal outline color
    restoreOutlineColor(){
        if(this.element){
            this.element.setOutlineColor(this.outlineColor);
        }
    };

    // Set the point outline color
    setOutlineColor(col){
        
        if(!this.coloring_fixed && this.element){
            
            this.outlineColor = col;

            if(col == "transparent"){
                // If color is transparent
                this.element.setOutlineOpacity(0);
                this.element.setOutlineColor("#ffffff");
                this.outlineopacity = 0;
            } else {
                // If color is not transparent
                this.element.setOutlineOpacity(this.outlineopacity);
                this.element.setOutlineColor(col);
            }

            // Update the color of the browser record
            if(this.browserRecord){
                this.browserRecord.updateColor();
            }

            this.updateDisplay();
        }

    }
    
    // Get the map distance to another point
    mapDistTo(to){

        return(
            Math.sqrt(
                (this.coords3[0] - to.coords3[0])*(this.coords3[0] - to.coords3[0]) +
                (this.coords3[1] - to.coords3[1])*(this.coords3[1] - to.coords3[1]) +
                (this.coords3[2] - to.coords3[2])*(this.coords3[2] - to.coords3[2])
            )
        );

    }

    // Calculate the mean stress for this point
    calcMeanStress(){

        if (this.coords_na) return(NaN);
        var num_detectable = 0;
        var stress = 0;
        for(var i=0; i<this.partners.length; i++){
            if(this.titerTo(this.partners[i]).charAt(0) != "<"
               && this.titerTo(this.partners[i]).charAt(0) != "*"
               && this.titerTo(this.partners[i]).charAt(0) != "."
               && !this.partners[i].coords_na){
                num_detectable++;
                stress += this.stressTo(this.partners[i]);
            }
        }
        this.stressval = stress;
        this.meanstress = stress / num_detectable;
        return(this.meanstress);

    }
 
    // Translate the point
    translate(x, y, z){

        // Update the position of the point in the viewer
        this.setPosition([
            this.coordsVector.x + x,
            this.coordsVector.y + y,
            this.coordsVector.z + z
        ]);

    }

    // Get connections from this point
    getConnectedPoints(){

        var connected_points = [];
        for (var i = 0; i < this.partners.length; i++) {
            if (this.titerTo(this.partners[i]) != "*" && this.partners[i] != "*" && this.partners[i].shown) {
                connected_points.push(this.partners[i]);
            }
        }
        return(connected_points);

    }

    // Get the point drawing order
    drawingOrder(){
        return(this.viewer.data.ptDrawingOrder().indexOf(this.pIndex));
    }

    // Bring the point to the top
    moveToTop(){
        
        if(this.element && this.element.setIndex !== undefined){
            this.element.setIndex(this.viewer.points.length-1);
        }

    }

    moveFromTop(){
        
        if(this.element && this.element.setIndex !== undefined){
            this.element.setIndex(this.drawingOrder());
        }

    }

    // Get titer type to
    titerTypeTo(to){ 
        return(
            Racmacs.utils.titerType(
                this.titerTo(to)
            )
        );
    }

    // Get residual error
    residualErrorTo(to){
        return(
            Racmacs.utils.ptResidual(
                this.mapDistTo(to),
                this.tableDistTo(to),
                this.titerTypeTo(to),
                this.viewer.data.dilutionstepsize_cache
            )
        );
    }

    // Get stress to
    stressTo(to){
        return(
            Racmacs.utils.ptStress(
                this.mapDistTo(to),
                this.tableDistTo(to),
                this.titerTypeTo(to),
                this.viewer.data.dilutionstepsize_cache
            )
        );
    }

    // Get overall stress
    stress(){
        var stress = 0;
        for (var i=0; i<this.partners.length; i++) {
            stress += this.stressTo(this.partners[i]);
        }
        return(stress);
    }

    // Get detectable titer stress
    stress_detectable(){
        var stress = 0;
        for (var i=0; i<this.partners.length; i++) {
            if (this.titerTypeTo(this.partners[i]) == 1) {
                stress += this.stressTo(this.partners[i]);
            }
        }
        return(stress);
    }

    // Toggle whether the point is included or not
    toggleIncluded() {

        if (this.included) {
            this.excludePoint();
        } else {
            this.includePoint();
        }

    }

    // Include a point
    includePoint() {

        if (!this.included) {

            this.viewer.data.includePoint(this.type, this.typeIndex);
            this.included = true;
            this.shown = true;
            this.element.show();
            this.viewer.render();
            this.viewer.dispatchEvent("point-included", { 
                point : this 
            });
            this.viewer.updateStress();

        }

    }

    // Exclude a point
    excludePoint() {

        if (!this.excluded) {

            this.viewer.data.excludePoint(this.type, this.typeIndex);
            this.included = false;
            this.shown = false;
            this.element.hide();
            this.viewer.render();
            this.viewer.dispatchEvent("point-excluded", { 
                point : this 
            });
            this.viewer.updateStress();

        }

    }


}


// Antigen class
Racmacs.Antigen = class Antigen extends Racmacs.Point {

    // Constructor function
    constructor(args) {

        super(args);
        this.type = "ag";

    }

    // Get the titers to another point
    titers(){
        return(this.viewer.data.titertable[this.typeIndex]);
    }
    titerTo(to){ 
        return(this.viewer.data.titertable[this.typeIndex][to.typeIndex]);
    }
    logTiterTo(to){ 
        return(this.viewer.data.logtitertable[this.typeIndex][to.typeIndex]);
    }
    tableDistTo(to){
        return(this.viewer.data.tableDist(this.typeIndex, to.typeIndex));
    }

}


// Antigen class
Racmacs.Serum = class Serum extends Racmacs.Point {

    // Constructor function
    constructor(args) {

        super(args);
        this.type = "sr";

    }

    // Get the titers to another point
    titers(){
        return(this.viewer.data.titertable.map(row => row[this.typeIndex]));
    }
    titerTo(to){ 
        return(this.viewer.data.titertable[to.typeIndex][this.typeIndex]);
    }
    logTiterTo(to){ 
        return(this.viewer.data.logtitertable[to.typeIndex][this.typeIndex]);
    }
    tableDistTo(to){
        return(this.viewer.data.tableDist(to.typeIndex, this.typeIndex));
    }

    // Get the column base
    colbase(){
        return(this.viewer.data.colbases(this.typeIndex));
    }


}


