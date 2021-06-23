
// Defaults for functions that will send data to the shiny session when initialised
Racmacs.App.prototype.onLoadMap               = function(){ console.log("Map loading") }
Racmacs.App.prototype.onLoadTable             = function(){ console.log("Table loading") }
Racmacs.App.prototype.onSaveMap               = function(){ console.log("Save map") }
Racmacs.App.prototype.onSaveTable             = function(){ console.log("Save table") }
Racmacs.App.prototype.onSaveCoords            = function(){ console.log("Save coords") }
Racmacs.App.prototype.onLoadPointStyles       = function(){ console.log("Loading point styles") }
Racmacs.App.prototype.onRelaxMap              = function(){ console.log("Relax map") }
Racmacs.App.prototype.onRelaxMapOneStep       = function(){ console.log("Relax map one step") }
Racmacs.App.prototype.onRandomizeMap          = function(){ console.log("Randomize map") }
Racmacs.App.prototype.onProjectionChange      = function(projection){}
Racmacs.App.prototype.onCoordsChange          = function(){ console.log("Coords moved") }
Racmacs.App.prototype.onOrientProjections     = function(){ console.log("Orient projections") }
Racmacs.App.prototype.onRemoveOptimizations   = function(){ console.log("Remove optimizations") }
Racmacs.App.prototype.onRunOptimizations      = function(args){ console.log(args) }
Racmacs.App.prototype.onMoveTrappedPoints     = function(){ console.log("Find trapped points") }
Racmacs.App.prototype.onCheckHemisphering     = function(){ console.log("Check hemisphering") }
Racmacs.App.prototype.onAddTriangulationBlobs = function(args){ console.log(args) }
Racmacs.App.prototype.onProcrustes            = function(args){ console.log(args) }
Racmacs.App.prototype.onReflectMap            = function(axis){ console.log(axis) }

// Manipulating the control panel
Racmacs.App.prototype.showControlPanel = function(){
    this.controlpanel.show();
}

Racmacs.App.prototype.hideControlPanel = function(){
    this.controlpanel.show();
}

Racmacs.App.prototype.openControlTab = function(tab){
    this.controlpanel.tabset.showTab(tab);
}

// Coloring points
Racmacs.App.prototype.colorBySequenceAtPosition = function(position){
    this.colorpanel.seqbtn.input.checked = true;
    this.colorpanel.seqbtn.input.onchange();
    this.colorpanel.seqinput.value = position;
    this.colorpanel.seqinput.oninput();
}

// Fetching coordinates
Racmacs.App.prototype.getAntigenCoords = function(){

    var ndims = this.data.dimensions();
    return(this.antigens.map( p => p.getPosition().slice(0, ndims) ));

}

Racmacs.App.prototype.getSeraCoords = function(){

    var ndims = this.data.dimensions();
    return(this.sera.map( p => p.getPosition().slice(0, ndims) ));

}

Racmacs.App.prototype.setCoords = function(data){

    for(var i=0; i<data.antigens.length; i++){
        if(data.antigens[i].length == 2){ data.antigens[i].push(0) }
        this.antigens[i].setPosition([
            data.antigens[i][0], 
            data.antigens[i][1], 
            data.antigens[i][2]
        ]);
    }

    for(var i=0; i<data.sera.length; i++){
        if(data.sera[i].length == 2){ data.sera[i].push(0) }
        this.sera[i].setPosition([
            data.sera[i][0], 
            data.sera[i][1], 
            data.sera[i][2]
        ]);
    }

    if (data.stress !== undefined) {
        this.updateStress(data.stress);
    }

    this.render();

}


Racmacs.App.prototype.getSelectedPointIndices = function(){

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

Racmacs.App.prototype.selectByPointIndices = function(indices){

    for(var i=0; i<indices.antigens.length; i++){

        var index = indices.antigens[i];
        this.antigens[index].select();

    }

    for(var i=0; i<indices.sera.length; i++){

        var index = indices.sera[i];
        this.sera[index].select();

    }

}

Racmacs.App.prototype.selectPointsByIndices = function(indices){

    indices.map( i => this.points[i].select() );

}

Racmacs.App.prototype.selectAntigensByIndices = function(indices){

    indices.map( i => this.antigens[i].select() );

}

Racmacs.App.prototype.selectSeraByIndices = function(indices){

    indices.map( i => this.sera[i].select() );

}

Racmacs.App.prototype.reflect = function(axis){

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

Racmacs.App.prototype.enterGUImode = function(){

    this.controlpanel.showShinyElements();

}

Racmacs.App.prototype.exitGUImode = function(){

    this.controlpanel.hideShinyElements();

}
