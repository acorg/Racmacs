
Racmacs.Point.prototype.animateToCoords = function(coords, target_steps = 20){
    
    var viewer = this.viewer;
    if(coords.length == 2){ coords.push(0) }
    if(viewer.animated_points.indexOf(this) === -1){
        viewer.animated_points.push(this);
    }
    
    var targetCoords = new THREE.Vector3().fromArray(coords);
    var startCoords  = this.coordsVector.clone();

    // Set the movement vector
    this.movementVector = targetCoords.sub(startCoords);
    this.movementVector.multiplyScalar(1 / target_steps);
    this.targetSteps  = target_steps;

}

Racmacs.Point.prototype.animateThroughCoords = function(coords_array, target_steps = 20, step = 0){
    
    this.targetCoordsArray = coords_array;
    this.animateToCoords(this.targetCoordsArray.shift());

}

Racmacs.Point.prototype.stepToCoords = function(){
    
    if(this.targetSteps == 0){

        // Step to next coordinate set
        if (this.targetCoordsArray && this.targetCoordsArray.length > 0) {

            this.animateToCoords(this.targetCoordsArray.shift());

        } else {

            // Remove from animated points
            var viewer = this.viewer;
            var index = viewer.animated_points.indexOf(this);
            if(index !== -1){
                viewer.animated_points.splice(index, 1);
            }

            // Remove target coords
            this.targetCoords = null;
            this.movementVector = null;

        }

    } else {
        
        // Set the coordinates to step to
        var stepCoords = this.coordsVector.clone().add(this.movementVector);

        // Step to the coordinates
        this.setPosition([
            stepCoords.x,
            stepCoords.y,
            stepCoords.z
        ]);

        // Decrease the number of steps remaining
        this.targetSteps--;

    }

}

Racmacs.Viewer.prototype.animateToCoords = function(data){

    for(var i=0; i<data.antigens.length; i++){
        this.antigens[i].animateToCoords(data.antigens[i]);
    }

    for(var i=0; i<data.sera.length; i++){
        this.sera[i].animateToCoords(data.sera[i]);
    }

    if (data.stress !== undefined) {
        this.updateStress(data.stress);
    }

}

Racmacs.Viewer.prototype.animateThroughCoords = function(data){

    for(var i=0; i<data.antigens[0].length; i++){
        this.antigens[i].animateThroughCoords(
            data.antigens.map(step => step[i])
        );
    }

    for(var i=0; i<data.sera[0].length; i++){
        this.sera[i].animateThroughCoords(
            data.sera.map(step => step[i])
        );
    }

}


