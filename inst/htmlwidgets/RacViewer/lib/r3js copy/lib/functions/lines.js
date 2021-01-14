





// function make_line(object){

//     var linewidth = object.properties.lwd*0.001;

//     // Set default dimensionality
//     if(!object.properties.dimensions){
//         object.properties.dimensions = 3;
//     }

//     // Get coordinates
//     var coords = object.position;

//     // Normalise coords
//     if(object.normalise){
//         for(var i=0; i<coords.length; i++){
//             coords[i] = normalise_coords(coords[i],
//                                          object.lims,
//                                          object.aspect);
//         }
//     }
    
//     // Make overall geometry
//     var geometries = [];
//     var geo;

//     // Add in line geometries
//     for(var n=1; n<coords.length; n++){

//         // Set from and to
//         var from = coords[n-1];
//         var to   = coords[n];

//         // Get line vector
//         var vector = new THREE.Vector3(to[0]-from[0],
//                                        to[1]-from[1],
//                                        to[2]-from[2]);
//         var length = vector.length();

//         // Get line geometry
//         geo = unitLineGeo(linewidth);

//         // Add vertex colors and set length
//         var position = geo.attributes.position;
//         var color    = new Float32Array( position.count * 4 );

//         for(var i=0; i<position.count; i++){
//             if(position.array[i*3+1] == 0){
//                 // Bottom point
//                 color[i*4]   = object.properties.color[0][n];
//                 color[i*4+1] = object.properties.color[1][n];
//                 color[i*4+2] = object.properties.color[2][n];
//                 color[i*4+3] = 1;
//             } else {
//                 // Top point
//                 color[i*4]   = object.properties.color[0][n-1];
//                 color[i*4+1] = object.properties.color[1][n-1];
//                 color[i*4+2] = object.properties.color[2][n-1];
//                 color[i*4+3] = 1;
                
//                 // Make correct length
//                 position.array[i*3+1] = length;
//             }
//         }
//         geo.setAttribute( 'color', new THREE.BufferAttribute( color, 4 ) );

//         // Make translation matrix
//         var transmat = new THREE.Matrix4();
//         transmat.makeTranslation(to[0], to[1], to[2]);

//         // Make rotation matrix
//         var axis = new THREE.Vector3(0, -1, 0);
//         var quat = new THREE.Quaternion().setFromUnitVectors(axis, vector.clone().normalize());

//         var rotmat = new THREE.Matrix4();
//         rotmat.makeRotationFromQuaternion(quat);
        
//         // Rotate to match vector and position
//         geo.applyMatrix4(rotmat);
//         geo.applyMatrix4(transmat);

//         // Add to overall geometry
//         geometries.push(geo);

//     }

//     // Add in spheres for corner pieces
//     if(object.properties.ljoin == 0){
//         for(var n=0; n<coords.length; n++){

//             if((n == 0 || n == coords.length - 1) && object.properties.lend != 0){
//                 continue;
//             }
            
//             geo = new THREE.SphereBufferGeometry(linewidth/2, 12, 12);
//             var position = geo.attributes.position;
//             var color    = new Float32Array( position.count * 4 );
//             for(var i=0; i<position.count; i++){
                
//                 color[i*4]   = object.properties.color[0][n];
//                 color[i*4+1] = object.properties.color[1][n];
//                 color[i*4+2] = object.properties.color[2][n];
//                 color[i*4+3] = 1;
                
//             }
//             geo.setAttribute( 'color', new THREE.BufferAttribute( color, 4 ) );
//             geo.translate(coords[n][0], coords[n][1], coords[n][2]);

//             // Add to overall geometry
//             geometries.push(geo);

//         }
//     }
    
//     // Merge geometries
//     var geometry = THREE.BufferGeometryUtils.mergeBufferGeometries(geometries);

//     // Get material
//     var material = get_object_material(object);
//     material.color = new THREE.Color();
//     material.vertexColors = THREE.VertexColors;

//     // Return line
//     var line = new THREE.Mesh(geometry, material);
//     return(line);
    
// }

// function unitLineGeo(linewidth){

//     var geo = new THREE.CylinderBufferGeometry( linewidth/2, linewidth/2, 1, 8, 1);
//     geo.translate(0,0.5,0);
//     return(geo);

// }





















// function make_lineMesh(from, to, material, linewidth, dimensions){

//     // Get geo
//     var geometry = make_lineMeshGeo(from, 
//                                     to, 
//                                     linewidth, 
//                                     dimensions);

//     // Make line object
//     geometry = new THREE.BufferGeometry().fromGeometry( geometry );
//     var line = new THREE.Mesh(geometry, material);

//     // Return line
//     return(line);

// }

// function make_lineShader(object){

//     var from = normalise_coords(object.position.from, 
//                                 object.lims, 
//                                 object.aspect);
//     var to   = normalise_coords(object.position.to, 
//                                 object.lims, 
//                                 object.aspect);
    
//     object.properties.mat = "linemesh";
//     var material = get_object_material(object);

//     var geometry = new THREE.Geometry();
//     geometry.vertices.push( new THREE.Vector3().fromArray(from) );
//     geometry.vertices.push( new THREE.Vector3().fromArray(to)   );

//     var line = new MeshLine();
//     line.setGeometry( geometry );

//     var mesh = new THREE.Mesh( line.geometry, material );
//     return(mesh);

// }




// function get_lineGeos(dimensions, lwd){

//     if(dimensions == 2){

//         var line = function(length, width){
//             var geo = new THREE.PlaneGeometry( width*0.05, length );
//             geo.translate( 0, -length/2, 0 );
//             return(geo);
//         };
//         var arrow = function(length, width){
//             var geo = new THREE.Geometry();
//             geo.vertices.push(
//                 new THREE.Vector3( 0, 0, 0 ),
//                 new THREE.Vector3( width/2, length, 0 ),
//                 new THREE.Vector3( -width/2, length, 0 )
//             );
//             geo.faces.push( new THREE.Face3( 0, 1, 2 ) );
//             return(geo);
//         };

//     }

//     if(dimensions == 3){

//         var line = function(length, width){
//             var geo = new THREE.CylinderGeometry( width*0.025, width*0.025, length, 16 );
//             geo.translate( 0, -length/2, 0 );
//             return(geo);
//         };
//         var arrow = function(length, width){
//             var geo = new THREE.ConeGeometry( width/2, length, 16 );
//             geo.translate( 0, -length/2, 0 );
//             return(geo);
//         };

//     }
    
//     return({
//         line:    line,
//         arrow:   arrow
//     })
// }


// function make_lineMeshGeo(from, to, linewidth, dimensions, vertex_cols){

//     // Return an empty geometry if the line start and ends in the same place
//     if(from[0] == to[0] &&
//        from[1] == to[1] &&
//        from[2] == to[2]){
//         return new THREE.Geometry();
//     }

//     // Get direction and length
//     var direction = new THREE.Vector3(to[0]-from[0],
//                                       to[1]-from[1],
//                                       to[2]-from[2]);
//     var line_length = direction.length();

//     // Set object geometry
//     var geometries = get_lineGeos(dimensions);
//     var geo = geometries.line(line_length, linewidth/20);

//     // Make translation matrix
//     var transmat = new THREE.Matrix4();
//     transmat.makeTranslation(to[0], to[1], to[2]);

//     // Make rotation matrix
//     var axis = new THREE.Vector3(0, 1, 0);
//     var quat = new THREE.Quaternion().setFromUnitVectors(axis, direction.clone().normalize());

//     var rotmat = new THREE.Matrix4();
//     rotmat.makeRotationFromQuaternion(quat);
    
//     // Rotate to match direction and position
//     geo.applyMatrix4(rotmat);
//     geo.applyMatrix4(transmat);

//     return(geo);

// }



// function make_meshline(object){
    
//     // Get coordinates
//     var coords = object.position;

//     // Normalise coords
//     if(object.normalise){
//         for(var i=0; i<coords.length; i++){
//             coords[i] = normalise_coords(coords[i],
//                                          object.lims,
//                                          object.aspect);
//         }
//     }
    
//     // Create the line geometry
//     var geometry = new THREE.Geometry();
//     geometry.vertexAlpha = [];
//     for(var i=0; i<coords.length; i++){
//         geometry.vertices.push(new THREE.Vector3().fromArray(coords[i]));
//         geometry.colors.push(new THREE.Color( 
//             object.properties.color[0][i],
//             object.properties.color[1][i],
//             object.properties.color[2][i]
//         ));
//         geometry.vertexAlpha.push(1);
//     }
    
//     // Create the meshline
//     var line = new MeshLine();
//     line.setGeometry( geometry );

//     // Create the material
//     var material = new MeshLineMaterial({
//         resolution : new THREE.Vector2(1000, 600),
//         lineWidth: 0.01
//     });

//     var mesh = new THREE.Mesh( line.geometry, material );
//     return(mesh);

// }

