
// Defaults for functions that will send data to the shiny session when initialised
Racmacs.Viewer.prototype.onLoadMap             = function(){ console.log("Map loading") }
Racmacs.Viewer.prototype.onLoadTable           = function(){ console.log("Table loading") }
Racmacs.Viewer.prototype.onSaveMap             = function(){ console.log("Save map") }
Racmacs.Viewer.prototype.onSaveTable           = function(){ console.log("Save table") }
Racmacs.Viewer.prototype.onSaveCoords          = function(){ console.log("Save coords") }
Racmacs.Viewer.prototype.onLoadPointStyles     = function(){ console.log("Loading point styles") }
Racmacs.Viewer.prototype.onRelaxMap            = function(){ console.log("Relax map") }
Racmacs.Viewer.prototype.onRelaxMapOneStep     = function(){ console.log("Relax map one step") }
Racmacs.Viewer.prototype.onRandomizeMap        = function(){ console.log("Randomize map") }
Racmacs.Viewer.prototype.onProjectionChange    = function(projection){}
Racmacs.Viewer.prototype.onCoordsChange        = function(){}
Racmacs.Viewer.prototype.onOrientProjections   = function(){ console.log("Orient projections") }
Racmacs.Viewer.prototype.onRemoveOptimizations = function(){ console.log("Remove optimizations") }
Racmacs.Viewer.prototype.onRunOptimizations    = function(args){ console.log(args) }
Racmacs.Viewer.prototype.onMoveTrappedPoints   = function(){ console.log("Find trapped points") }
Racmacs.Viewer.prototype.onCheckHemisphering   = function(){ console.log("Check hemisphering") }
Racmacs.Viewer.prototype.onAddStressBlobs      = function(args){ console.log(args) }
Racmacs.Viewer.prototype.onProcrustes          = function(args){ console.log(args) }
Racmacs.Viewer.prototype.onReflectMap          = function(axis){ console.log(axis) }


// Fetching coordinates
Racmacs.Viewer.prototype.getAntigenCoords = function(){

    var ag_coords;
    if(this.mapdims.dimensions == 2) ag_coords = this.antigens.map( p => [p.coords[0], p.coords[1]] );
    if(this.mapdims.dimensions == 3) ag_coords = this.antigens.map( p => p.coords );
    return(ag_coords);

}

Racmacs.Viewer.prototype.getSeraCoords = function(){

    var sr_coords;
    if(this.mapdims.dimensions == 2) sr_coords = this.sera.map( p => [p.coords[0], p.coords[1]] );
    if(this.mapdims.dimensions == 3) sr_coords = this.sera.map( p => p.coords );
    return(sr_coords);

}

Racmacs.Viewer.prototype.setCoords = function(data){

    for(var i=0; i<data.antigens.length; i++){
        if(data.antigens[i].length == 2){ data.antigens[i].push(0) }
        this.antigens[i].setPosition(data.antigens[i][0], data.antigens[i][1], data.antigens[i][2]);
    }

    for(var i=0; i<data.sera.length; i++){
        if(data.sera[i].length == 2){ data.sera[i].push(0) }
        this.sera[i].setPosition(data.sera[i][0], data.sera[i][1], data.sera[i][2]);
    }

    this.render();

}


Racmacs.Viewer.prototype.getSelectedPointIndices = function(){

    var antigens = [];
    var sera = [];

    for(var i=0; i<this.selected_pts.length; i++){

        if(this.selected_pts[i].type == "ag"){
            antigens.push(this.selected_pts[i].typeIndex);
        } else {
            sera.push(this.selected_pts[i].typeIndex);
        }

    }
    
    return({
        antigens : antigens,
        sera     : sera
    });

}

Racmacs.Viewer.prototype.selectByPointIndices = function(indices){

    for(var i=0; i<indices.antigens.length; i++){

        var index = indices.antigens[i];
        this.antigens[index].select();

    }
    
    for(var i=0; i<indices.sera.length; i++){

        var index = indices.sera[i];
        this.sera[index].select();

    }
    
}

Racmacs.Viewer.prototype.reflect = function(axis){

    // this.scene.reflect(axis);

    // Adjust the transformation
    var t1 = this.data.transformation();
    var t2 = [1,0,0,-1];
    this.data.setTransformation(Racmacs.utils.matrixMultiply(t1, t2));

    // Reset the point coordinates
    for(var i=0; i<this.points.length; i++){
        this.points[i].resetPosition();
    }

    // Rerender the scene
    this.render();

}
