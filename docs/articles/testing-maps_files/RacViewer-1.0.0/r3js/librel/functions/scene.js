
R3JS.Scene = class Scene {

    constructor(){

        // Set defaults
        this.sceneChange = false;
        this.defaults = {
            translation : [0,0,0],
            rotation    : [0,0,0]
        };
        this.plotdims = {};
        this.clippingPlanes = [];
        this.selectable_elements = [];
        this.toggles = {
            names : [],
            objects : []
        }
        this.elements    = [];
        this.onrotate    = [];
        this.ontranslate = [];
        this.lights      = [];

        // Create scene
        this.scene = new THREE.Scene();

        // Create plotHolder for rotation
        this.plotHolder = new THREE.Object3D();
        this.scene.add(this.plotHolder);

        // Create plotPoints for panning
        this.plotPoints = new THREE.Object3D();
        this.plotPoints.clippingPlanes = [];
        this.plotHolder.add(this.plotPoints);

        // Add clipping planes for the outer edges of plot
        // this.setOuterClippingPlanes();

    }

    // Setting lims and aspect
    setPlotDims(plotdims){

        // Update properties
        this.plotdims.dimensions = plotdims.dimensions;
        this.plotdims.lims       = plotdims.lims;
        this.plotdims.aspect     = plotdims.aspect;
        this.plotdims.size       = [];
        for(var i=0; i<plotdims.lims.length; i++){
            this.plotdims.size.push(
                plotdims.lims[i][1] - plotdims.lims[i][0]
            );
        }
        this.plotdims.midpoints = [];
        for(var i=0; i<plotdims.lims.length; i++){
            this.plotdims.midpoints.push(
                (plotdims.lims[i][0] + plotdims.lims[i][1])/2
            );
        }

        // Rescale plotPoints
        this.plotPoints.scale.set(
            this.plotdims.aspect[0] / this.plotdims.size[0],
            this.plotdims.aspect[1] / this.plotdims.size[0],
            this.plotdims.aspect[2] / this.plotdims.size[0]
        );

        // Reposition plotPoints
        this.plotdims.baseposition = [
            -this.plotdims.midpoints[0]*this.plotdims.aspect[0] / this.plotdims.size[0],
            -this.plotdims.midpoints[1]*this.plotdims.aspect[1] / this.plotdims.size[0],
            -this.plotdims.midpoints[2]*this.plotdims.aspect[2] / this.plotdims.size[0]
        ]
        this.plotPoints.position.fromArray(
            this.plotdims.baseposition  
        );

        // Redefine outer clipping planes
        this.setOuterClippingPlanes();

    }

    // Add an object to the scene
    add(object){

        this.plotPoints.add(object);
        this.sceneChange = true;

    }

    // Remove an object from the scene
    remove(object){

        this.plotPoints.remove(object);
        this.sceneChange = true;

    }

    // Add elements to the scene
    addElement(element){
        element.id = this.elements.length;
        this.elements.push(element);
    }
    addElements(elements){

        for(var i=0; i<elements.length; i++){
            this.addElement(elements[i]);
        }

    }

    // Add selectable elements
    addSelectableElement(element){
        if(this.selectable_elements.indexOf(element) === -1){
            this.selectable_elements.push(element);
        }
    }
    addSelectableElements(elements){
        for(var i=0; i<elements.length; i++){
            this.addSelectableElement(elements[i]);
        }
    }

    // Remove a selectable element
    removeSelectableElement(element){
        var index = this.selectable_elements.indexOf(element);
        if(index !== -1){
            this.selectable_elements.splice(index, 1);
        }
    }

    // Get and set rotation
    // Rotate the scene on an axis
    rotateOnAxis(axis, rotation){

        // Rotate the plot holder
        var q = new THREE.Quaternion().setFromAxisAngle( axis, rotation );
        this.plotHolder.applyQuaternion( q );

        // Rotate the clipping planes
        var world_axis = axis.clone().applyQuaternion(q);

        for(var i=0; i<this.plotPoints.clippingPlanes.length; i++){
            var norm = this.plotPoints.clippingPlanes[i].normal;
            norm.applyAxisAngle(world_axis, rotation);
            this.plotPoints.clippingPlanes[i].set(norm, this.plotPoints.clippingPlanes[i].constant);
        }

        for(var i=0; i<this.clippingPlanes.length; i++){
           var norm = this.clippingPlanes[i].normal;
           norm.applyAxisAngle(world_axis, rotation);
           this.clippingPlanes[i].set(norm, this.clippingPlanes[i].constant);
        }

        // Run any rotation events
        for(var i=0; i<this.onrotate.length; i++){
            this.onrotate[i]();
        }

        // Do any dynamic showing and hiding
        if(this.dynamic) this.showhideDynamics(this.viewer.camera.camera);

    }

    // Rotate by euclidean coordinates
    rotateEuclidean(rotation){
        
        this.rotateOnAxis(new THREE.Vector3(0,0,1), rotation[2]);
        this.rotateOnAxis(new THREE.Vector3(0,1,0), rotation[1]);
        this.rotateOnAxis(new THREE.Vector3(1,0,0), rotation[0]);

    }

    setRotation(rotation){
        
        // Get the rotation
        var rot = this.plotHolder.rotation.toVector3();
            
        // Rotate back to origin
        this.rotateOnAxis(new THREE.Vector3(1,0,0), -rot.x);
        this.rotateOnAxis(new THREE.Vector3(0,1,0), -rot.y);
        this.rotateOnAxis(new THREE.Vector3(0,0,1), -rot.z);

        // Perform the rotation
        this.rotateEuclidean(rotation);

    }

    getRotation(){
        var rot = this.plotHolder.rotation.toArray();
        return([
            rot[0],
            rot[1],
            rot[2]
        ]);
    }

    setRotationDegrees(rotation){
        this.setRotation([
            (rotation[0]/180)*Math.PI,
            (rotation[1]/180)*Math.PI,
            (rotation[2]/180)*Math.PI
        ])
    }

    getRotationDegrees(){
        var rot = this.plotHolder.rotation.toArray();
        return([
            (rot[0]/Math.PI)*180,
            (rot[1]/Math.PI)*180,
            (rot[2]/Math.PI)*180
        ]);
    }

    // Reflect the scene
    reflect(axis){
    }

    // Get and set translation
    panScene(translation){

        translation = new THREE.Vector3().fromArray(translation);
        this.plotPoints.position.add(translation);

        // Pan outer plot clipping planes
        var globalpos = translation.applyMatrix4(this.plotHolder.matrixWorld);
        for(var i=0; i<this.plotPoints.clippingPlanes.length; i++){
            var pos = globalpos.clone();
            var norm = this.plotPoints.clippingPlanes[i].normal.clone();
            var orignorm = norm.clone().applyMatrix4(this.plotHolder.matrixWorld);
            pos.projectOnVector(norm);
            var offset = pos.length()*pos.clone().normalize().dot(norm);
            this.plotPoints.clippingPlanes[i].constant -= offset;
        }

        // Pan additional clipping planes
        for(var i=0; i<this.clippingPlanes.length; i++){
            var pos = globalpos.clone();
            var norm = this.clippingPlanes[i].normal.clone();
            var orignorm = norm.clone().applyMatrix4(this.plotHolder.matrixWorld);
            pos.projectOnVector(norm);
            var offset = pos.length()*pos.clone().normalize().dot(norm);
            this.clippingPlanes[i].constant -= offset;
        }

        // Run any translation events
        for(var i=0; i<this.ontranslate.length; i++){
            this.ontranslate[i]();
        }

     }

    setTranslation(translation){

        // Get current translation
        var currenttranslation = this.getTranslation();
        var newtranslation = [0,0,0];

        // Get difference between current position and center position
        if(translation[0] !== null){ 
            newtranslation[0] = translation[0] - currenttranslation[0];
        }
        if(translation[1] !== null){ 
            newtranslation[1] = translation[1] - currenttranslation[1];
        }
        if(translation[2] !== null){ 
            newtranslation[2] = translation[2] - currenttranslation[2];
        }

        // Pan the scene by the difference
        this.panScene(newtranslation);
        this.showhideDynamics(this.viewer.camera.camera);

    }

    getTranslation(){
        
        // Get the position
        var translation = this.plotPoints.position.clone();

        // Correct for scene center
        translation.sub(
            new THREE.Vector3().fromArray(this.plotdims.baseposition)
        );

        // Return the translation
        return(translation.toArray());

    }



    // Function to set the default transformation specified by the plotting data
    resetTransformation(){
        this.setTranslation(this.defaults.translation);
        this.setRotation(this.defaults.rotation);
    }


    // Set background color
    setBackgroundColor(color){
        this.scene.background = new THREE.Color(color.r,
                                                color.g,
                                                color.b);
    }



    // Clipping planes
    setOuterClippingPlanes(){
        var lower_lims = this.plotCoordToScene([
            this.plotdims.lims[0][0],
            this.plotdims.lims[1][0],
            this.plotdims.lims[2][0]
        ]);
        var upper_lims = this.plotCoordToScene([
            this.plotdims.lims[0][1],
            this.plotdims.lims[1][1],
            this.plotdims.lims[2][1]
        ]);
        this.plotPoints.clippingPlanes = [
            new THREE.Plane( new THREE.Vector3( 1, 0, 0 ).applyQuaternion(this.plotHolder.quaternion),  -(this.plotdims.lims[0][0] * this.plotPoints.scale.x + this.plotPoints.position.x) ),
            new THREE.Plane( new THREE.Vector3( -1, 0, 0 ).applyQuaternion(this.plotHolder.quaternion), this.plotdims.lims[0][1] * this.plotPoints.scale.x + this.plotPoints.position.x ),
            new THREE.Plane( new THREE.Vector3( 0, 1, 0 ).applyQuaternion(this.plotHolder.quaternion),  -(this.plotdims.lims[1][0] * this.plotPoints.scale.y + this.plotPoints.position.y) ),
            new THREE.Plane( new THREE.Vector3( 0, -1, 0 ).applyQuaternion(this.plotHolder.quaternion), this.plotdims.lims[1][1] * this.plotPoints.scale.y + this.plotPoints.position.y ),
            new THREE.Plane( new THREE.Vector3( 0, 0, 1 ).applyQuaternion(this.plotHolder.quaternion),  -(this.plotdims.lims[2][0] * this.plotPoints.scale.z + this.plotPoints.position.z) ),
            new THREE.Plane( new THREE.Vector3( 0, 0, -1 ).applyQuaternion(this.plotHolder.quaternion), this.plotdims.lims[2][1] * this.plotPoints.scale.z + this.plotPoints.position.z ),
        ];
        // for(var i=0; i<this.plotPoints.clippingPlanes.length; i++){
        //     var helper = new THREE.PlaneHelper( this.plotPoints.clippingPlanes[i], 1, 0xffff00 );
        //     this.scene.add( helper );
        // }
    }

    // Add a new clipping plane
    addClippingPlane(plane){

        // See if plane is already referenced
        for(var i=0; i<this.clippingPlanes.length; i++){
            
            var scene_plane = this.clippingPlanes[i];
            if(scene_plane.constant == plane.constant &&
                scene_plane.normal.x == plane.normal.x && 
                scene_plane.normal.y == plane.normal.y && 
                scene_plane.normal.z == plane.normal.z){
                return(scene_plane);
            }

        }

        // If not then add a reference
        this.clippingPlanes.push(plane);
        // var helper = new THREE.PlaneHelper( plane, 1, 0xffff00 );
        // this.scene.add( helper );
        return(plane);


    }        

    
    // Add a clipping plane reference to the scene, if a reference does not 
    // already exist
    fetchClippingPlaneReference(clippingPlaneData){

        // Variable for returning clipping plane refs
        var clippingPlanes = [];
        
        // Work through clipping plane data
        for(var i=0; i<clippingPlaneData.length; i++){
            
            var planeData = clippingPlaneData[i];
            
            // Normalise and coordinates provided
            planeData.coplanarPoints = this.plotCoordsToScene(planeData.coplanarPoints);

            // Make the plane
            var plane = R3JS.utils.generatePlane(planeData);
            clippingPlanes.push(
                this.addClippingPlane(plane)
            );

        }
        return(clippingPlanes);

    }

    // Convert coordinates in the plotpoint system to the scene
    plotCoordToScene(coord){
        var converted_coord = new THREE.Vector3().fromArray(coord);
        converted_coord.multiply(this.plotPoints.scale);
        converted_coord.add(this.plotPoints.position);
        converted_coord.applyQuaternion(this.plotHolder.quaternion);
        return(converted_coord.toArray());
    }

    plotCoordsToScene(coords){
        var converted_coords = [];
        for(var i=0; i<coords.length; i++){
            converted_coords.push(
                this.plotCoordToScene(coords[i])
            );
        }
        return(converted_coords);
    }

    // Empty
    empty(){

        // Remove clipping planes
        this.clippingPlanes = [];

        // Remove selectable elements
        this.selectable_elements = [];

        // Remove elements
        for(var i=0; i<this.elements.length; i++){
            this.remove(this.elements[i].object);
        }
        this.elements = [];

        // Remove additional objects
        while(this.plotPoints.children.length > 0){
            this.plotPoints.remove(this.plotPoints.children[0]);
        }

    }

    // Clear all lights
    clearLights(){

        for(var i=0; i<this.lights.length; i++){
            this.scene.remove(this.lights[i]);
        }
        this.lights = [];

    }

    addLight(args){

        var light = new R3JS.element.Light(args);

        this.scene.add( light.object );
        this.lights.push( light.object );

        // var helper = new THREE.DirectionalLightHelper( light.object, 0.2, 0xFF0000 );
        // this.scene.add( helper );

    }

    // sceneCoordToPlot(coord){
    //     var converted_coord = new THREE.Vector3().fromArray(coord);
    //     converted_coord.multiply(this.plotPoints.scale);
    //     converted_coord.add(this.plotPoints.position);
    //     converted_coord.applyQuaternion(this.plotHolder.quaternion);
    //     return(converted_coord.toArray());
    // }

    // sceneCoordsToPlot(coords){
    //     var converted_coords = [];
    //     for(var i=0; i<coords.length; i++){
    //         converted_coords.push(
    //             this.sceneCoordToPlot(coords[i])
    //         );
    //     }
    //     return(converted_coords);
    // }


}









// function addScene(viewport, plotData){

//     viewport.scene = generate_scene(plotData);

// }


// function generate_scene(plotData){

// 	// Create scene
//     var scene = new THREE.Scene();

//     // Add ambient light
//     var ambient_light = new THREE.AmbientLight( 0x404040 );
//     scene.add( ambient_light );

//     // Add positional light
//     var light       = new THREE.DirectionalLight(0xe0e0e0);
//     light.position.set(-1,1,1).normalize();
//     light.intensity = 1.0;
//     // scene.light  = light;
//     scene.add( light );

//     // Create plotHolder for rotation
//     var plotHolder = new THREE.Object3D();
//     scene.plotHolder = plotHolder;

//     // Create plotPoints for panning
//     var plotPoints = new THREE.Object3D();
//     plotHolder.add(plotPoints);
//     scene.add(plotHolder);
//     scene.plotPoints = plotPoints;

//     // Set scene background color
//     var bg_col = new THREE.Color(plotData.scene.background[0],
//                                  plotData.scene.background[1],
//                                  plotData.scene.background[2]);
//     scene.background = bg_col;

//     // Set scene variables
//     scene.primary_objects       = [];
//     scene.selectable_objects    = [];
//     scene.dynamic_objects       = [];
//     scene.dynamic_cornerObjects = [];
//     scene.labels                = [];
//     scene.toggles = {
//     	names   : [],
//     	objects : []
//     };

//     // Define the clipping planes
//     plotPoints.clippingPlanes = [
//         new THREE.Plane( new THREE.Vector3( 1, 0, 0 ),  0 ),
//         new THREE.Plane( new THREE.Vector3( -1, 0, 0 ), plotData.aspect[0] ),
//         new THREE.Plane( new THREE.Vector3( 0, 1, 0 ),  0 ),
//         new THREE.Plane( new THREE.Vector3( 0, -1, 0 ), plotData.aspect[1] ),
//         new THREE.Plane( new THREE.Vector3( 0, 0, 1 ),  0 ),
//         new THREE.Plane( new THREE.Vector3( 0, 0, -1 ), plotData.aspect[2] )
//     ];

//     scene.clippingPlanes = {};
//     scene.clippingPlanes.planes = [];
//     scene.clippingPlanes.includeAndReferencePlane     = function(plane){
        
//         // See if plane is already referenced
//         for(var i=0; i<scene.clippingPlanes.planes.length; i++){
            
//             var scene_plane = scene.clippingPlanes.planes[i];
//             if(scene_plane.constant == plane.constant &&
//                 scene_plane.normal.x == plane.normal.x && 
//                 scene_plane.normal.y == plane.normal.y && 
//                 scene_plane.normal.z == plane.normal.z){
//                 return(scene_plane);
//             }

//         }

//         // If not then add a reference
//         scene.clippingPlanes.planes.push(plane);
//         return(plane);

//     }
//     scene.clippingPlanes.includeAndReferencePlaneData = function(properties){
        


//     };


    
//     // // Setup helper objects
//     // scene.helperObjects = [];
//     // scene.showHelpers = function(){
//     // 	var helper_objects = [];
//     //     for(var i=0; i<this.plotPoints.clippingPlanes.length; i++){
//     // 	    var helper = new THREE.PlaneHelper( this.plotPoints.clippingPlanes[i], 1, 0xffff00 );
//     // 	    helper_objects.push(helper);
//     //         scene.add( helper );
//     //     }
//     //     scene.helperObjects = helper_objects;
//     // }

//     // scene.hideHelpers = function(){
//     //     for(var i=0; i<scene.helperObjects.length; i++){
//     // 	    scene.helperObjects[i].parent.remove(scene.helperObjects[i]);
//     //     }
//     // }









// 	// Center and rotate the scene
//     scene.resetTransformation();

//     // Return the populated scene
//     return(scene);

// }


// function scene_to_triangles(scene, camera){
    
//     scene.updateMatrixWorld();
//     scene.showhideDynamics( camera );
//     var scene_data = [];

//     scene.traverseVisible(function(object){

//     	if(object.isMesh){
            
// 			var geo = object.geometry.clone();
// 			var mat = object.material;


// 			if(geo.isBufferGeometry){
// 			    geo = new THREE.Geometry().fromBufferGeometry(geo);
// 			}
			
// 			geo.applyMatrix(object.matrixWorld);

// 			var objdata = {
// 				vertices : [],
// 				faces    : [],
// 				colors   : [],
// 				mat      : []
// 			}
            
// 			for(var i=0; i<geo.vertices.length; i++){
// 				objdata.vertices.push(geo.vertices[i].toArray());
// 			}

// 			for(var i=0; i<geo.faces.length; i++){
// 				objdata.faces.push([
// 					geo.faces[i].a,
// 					geo.faces[i].b,
// 					geo.faces[i].c
// 				]);
// 			}
            
// 			objdata.colors.push("#"+mat.color.getHexString());
// 			objdata.mat.push(mat.mat);
// 			if(objdata.faces.length > 0){
// 			    scene_data.push(objdata);
// 			}

//     	}

//     });

//     return(scene_data);

// }


// function generatePlane(planeData){

//     var plane = new THREE.Plane();
//     if(planeData.coplanarPoints){
//         plane.setFromCoplanarPoints(
//             new THREE.Vector3().fromArray(planeData.coplanarPoints[0]),
//             new THREE.Vector3().fromArray(planeData.coplanarPoints[1]),
//             new THREE.Vector3().fromArray(planeData.coplanarPoints[2])
//         );
//     }
//     if(planeData.normal && planeData.coplanarPoint){
//         plane.setFromNormalAndCoplanarPoint(
//             new THREE.Vector3().fromArray(planeData.normal),
//             new THREE.Vector3().fromArray(planeData.coplanarPoint)
//         );
//     }
//     return(plane);

// }
