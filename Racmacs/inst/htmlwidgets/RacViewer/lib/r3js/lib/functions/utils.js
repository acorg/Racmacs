
R3JS.utils = {};

R3JS.utils.normalise_coords = function(
    coords,
    plotdims
    ){

    norm_coords = [];
    for(var i=0; i<coords.length; i++){
        R3JS.utils.normalise_coord(
            coords[i],
            plotdims
        );
    }

}

R3JS.utils.normalise_coord = function(
    coord, 
    plotdims
    ){

    var lims   = plotdims.lims;
    var aspect = plotdims.aspect;
    var size   = plotdims.size;

    // Normalised coordinates
    for(var i=0; i<lims.length; i++){
        coord[i] = ((coord[i] - lims[i][0]) / size[i]) * aspect[i] ;
    }

}

R3JS.utils.generatePlane = function(planeData){

    var plane = new THREE.Plane();
    if(planeData.coplanarPoints){
        plane.setFromCoplanarPoints(
            new THREE.Vector3().fromArray(planeData.coplanarPoints[0]),
            new THREE.Vector3().fromArray(planeData.coplanarPoints[1]),
            new THREE.Vector3().fromArray(planeData.coplanarPoints[2])
        );
    }
    if(planeData.normal && planeData.coplanarPoint){
        plane.setFromNormalAndCoplanarPoint(
            new THREE.Vector3().fromArray(planeData.normal),
            new THREE.Vector3().fromArray(planeData.coplanarPoint)
        );
    }
    return(plane);

}





