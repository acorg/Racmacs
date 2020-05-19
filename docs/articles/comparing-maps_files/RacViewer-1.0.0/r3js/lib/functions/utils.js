
R3JS.utils = {};

// Function for getting mouse position
R3JS.utils.getMousePos = function(event, container){
    var offsets = container.getBoundingClientRect();
    var top     = offsets.top;
    var left    = offsets.left;
    var mouseX  = ( (event.clientX-left) / container.offsetWidth ) * 2 - 1;
    var mouseY  = -( (event.clientY-top) / container.offsetHeight ) * 2 + 1;
    return({
        x:mouseX,
        y:mouseY
    });
}

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

R3JS.utils.breakupMesh = function(full_mesh){

    // Make a group for the new broken mesh
    var broken_mesh = new THREE.Group();

    // Get the geometry
    var geo = full_mesh.geometry;
    if(!geo.isBufferGeometry){
        geo = new THREE.BufferGeometry().fromGeometry(geo);
    }

    // Get the material
    var mat = R3JS.utils.cloneMaterial(full_mesh.material);

    // Break apart the geometry
    for(var i=0; i<(geo.attributes.position.count/3); i++){
    
        var x_mean = (geo.attributes.position.array[i*9] + geo.attributes.position.array[i*9+3] + geo.attributes.position.array[i*9+6])/3
        var y_mean = (geo.attributes.position.array[i*9+1] + geo.attributes.position.array[i*9+4] + geo.attributes.position.array[i*9+7])/3
        var z_mean = (geo.attributes.position.array[i*9+2] + geo.attributes.position.array[i*9+5] + geo.attributes.position.array[i*9+8])/3
        var g = new THREE.BufferGeometry();
        var v = new Float32Array( [
            geo.attributes.position.array[i*9] - x_mean,
            geo.attributes.position.array[i*9+1] - y_mean,
            geo.attributes.position.array[i*9+2] - z_mean,
            geo.attributes.position.array[i*9+3] - x_mean,
            geo.attributes.position.array[i*9+4] - y_mean,
            geo.attributes.position.array[i*9+5] - z_mean,
            geo.attributes.position.array[i*9+6] - x_mean,
            geo.attributes.position.array[i*9+7] - y_mean,
            geo.attributes.position.array[i*9+8] - z_mean
        ] );
        g.setAttribute( 'position', new THREE.BufferAttribute( v, 3 ) );
        var c = new Float32Array( [
            geo.attributes.color.array[i*9],
            geo.attributes.color.array[i*9+1],
            geo.attributes.color.array[i*9+2],
            geo.attributes.color.array[i*9+3],
            geo.attributes.color.array[i*9+4],
            geo.attributes.color.array[i*9+5],
            geo.attributes.color.array[i*9+6],
            geo.attributes.color.array[i*9+7],
            geo.attributes.color.array[i*9+8]
        ] );
        g.setAttribute( 'color', new THREE.BufferAttribute( c, 3 ) );
        var n = new Float32Array( [
            geo.attributes.normal.array[i*9],
            geo.attributes.normal.array[i*9+1],
            geo.attributes.normal.array[i*9+2],
            geo.attributes.normal.array[i*9+3],
            geo.attributes.normal.array[i*9+4],
            geo.attributes.normal.array[i*9+5],
            geo.attributes.normal.array[i*9+6],
            geo.attributes.normal.array[i*9+7],
            geo.attributes.normal.array[i*9+8]
        ] );
        g.setAttribute( 'normal', new THREE.BufferAttribute( n, 3 ) );
        
        // Set clipping
        var mesh = new THREE.Mesh( g, mat );
        mesh.position.set(x_mean, y_mean, z_mean);
        broken_mesh.add(mesh);

    }
    
    // Return the mesh as a new group
    return(broken_mesh);

}


R3JS.utils.separateSides = function(full_mesh){
    
    var mat = full_mesh.material;
    var geo = full_mesh.geometry;

    // mat.colorWrite = false;
    mat.side = THREE.BackSide;
    var mat_cw = R3JS.utils.cloneMaterial(mat);
    // mat_cw.colorWrite = true;
    mat_cw.side = THREE.FrontSide;

    var mesh  = THREE.SceneUtils.createMultiMaterialObject( 
        geo,[mat,mat_cw]
    );

    return(mesh);

}


R3JS.utils.removeSelfTransparency = function(full_mesh){
    
    var mat = full_mesh.material;
    var geo = full_mesh.geometry;

    mat.colorWrite = false;
    // mat.side = THREE.FrontSide;
    var mat_cw = R3JS.utils.cloneMaterial(mat);
    mat_cw.colorWrite = true;
    // mat_cw.side = THREE.BackSide;

    var mesh  = THREE.SceneUtils.createMultiMaterialObject( 
        geo,[mat,mat_cw]
    );

    return(mesh);

}


R3JS.utils.cloneMaterial = function(material){
    
    var mat = material.clone();
    if(material.clippingPlanes){
        mat.clippingPlanes = material.clippingPlanes;
    }

    return(mat);

}

