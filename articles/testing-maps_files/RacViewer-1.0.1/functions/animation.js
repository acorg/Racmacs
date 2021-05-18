
Racmacs.Point.prototype.animateToCoords = function(coords){
    
    var viewer = this.viewer;
    if(coords.length == 2){ coords.push(0) }
    if(viewer.animated_points.indexOf(this) === -1){
        viewer.animated_points.push(this);
    }
    
    var targetCoords = new THREE.Vector3().fromArray(coords);
    var startCoords  = this.coordsVector.clone();

    // Set the movement vector
    this.movementVector = targetCoords.sub(startCoords);
    this.movementVector.multiplyScalar(1 / 20);
    this.targetSteps  = 20;

}

Racmacs.Point.prototype.stepToCoords = function(){
    
    if(this.targetSteps == 0){

        // Remove from animated points
        var viewer = this.viewer;
        var index = viewer.animated_points.indexOf(this);
        if(index !== -1){
            viewer.animated_points.splice(index, 1);
        }

        // Remove target coords
        this.targetCoords = null;
        this.movementVector = null;

    } else {
        
        // Set the coordinates to step to
        var stepCoords = this.coordsVector.clone().add(this.movementVector);

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

    if (data.stress !== undefined) {
        this.updateStress(data.stress);
    }

}


