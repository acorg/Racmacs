
Racmacs.Point.prototype.animateToCoords = function(coords){
    
    var viewer = this.viewer;
    if(coords.length == 2){ coords.push(0) }
    if(viewer.animated_points.indexOf(this) === -1){
        viewer.animated_points.push(this);
    }
    this.targetCoords = new THREE.Vector3().fromArray(coords);
    this.startCoords  = this.coordsVector.clone();
    this.targetSteps  = 20;

}

Racmacs.Point.prototype.stepToCoords = function(stepsize = 0.1){
    
    if(this.targetSteps == 0){

        // Remove from animated points
        var viewer = this.viewer;
        var index = viewer.animated_points.indexOf(this);
        if(index !== -1){
            viewer.animated_points.splice(index, 1);
        }

        // Remove target coords
        this.targetCoords = null;
        this.startCoords  = null;
        this.targetSteps  = null;

    } else {
        
        // Set the movement vector
        var movementVector = this.targetCoords.clone().sub(this.startCoords);
        movementVector.multiplyScalar(1 - (this.targetSteps / 20));
        
        // Set the coordinates to step to
        var stepCoords = this.startCoords.clone().add(movementVector);

        // Step to the coordinates
        this.setPosition(
            stepCoords.x,
            stepCoords.y,
            stepCoords.z
        );

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

}


