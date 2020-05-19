

// Initiate dynamic objects
R3JS.Scene.prototype.makeDynamic = function(){

    if(!this.dynamic){

        // Mark scene as dynamic
        this.dynamic = true;
        var plotdims = this.plotdims;

        // Set holders for dynamic plot components
        this.dynamic_objects = [];
        this.dynamicDeco = {
            faces : Array(6),
            edges : Array(12)
        }

        for(var i=0; i<6; i++){
            this.dynamicDeco.faces[i] = [];
        }

        for(var i=0; i<12; i++){
            this.dynamicDeco.edges[i] = Array(6);
            for(var j=0; j<6; j++){
                this.dynamicDeco.edges[i][j] = [];
            }
        }

        // Set variables
        var aspect = this.plotdims.aspect;

        // Set box vertices
        var vertices = [];
        for(var i=0; i<2; i++){
            for(var j=0; j<2; j++){
                for(var k=0; k<2; k++){
                    vertices.push([
                        (i-0.5)*aspect[0],
                        (j-0.5)*aspect[1],
                        (k-0.5)*aspect[2]
                    ]);
                }
            }
        }

        // Store variables for bounding box
        this.boundingBox = {
            edge_vertices : [
                [0,4], // y-z-  x 0
                [1,5], // z+y-  x 1
                [3,7], // y+z+  x 2
                [2,6], // y+z-  x 3
                [0,2], // x-z-  y 4
                [1,3], // z+x-  y 5
                [5,7], // x+z+  y 6
                [4,6], // x+z-  y 7
                [0,1], // x-y-  z 8
                [4,5], // x+y-  z 11
                [6,7], // x+y+  z 10
                [2,3], // y+x-  z 9
            ],
            edge_faces : [
                [4,5], // y-z-  x
                [2,4], // z+y-  x
                [1,2], // y+z+  x
                [1,5], // y+z-  x
                [3,5], // x-z-  y
                [2,3], // z+x-  y
                [0,2], // x+z+  y
                [0,5], // x+z-  y
                [3,4], // x-y-  z
                [1,3], // y+x-  z
                [0,1], // x+y+  z
                [0,4]  // x+y-  z
            ],
            face_normals : [
                [1,0,0],  // x+ 0
                [0,1,0],  // y+ 1
                [0,0,1],  // z+ 2
                [-1,0,0], // x- 3
                [0,-1,0], // y- 4
                [0,0,-1]  // z- 5
            ],
            face_vertices : [
                [5,6,4,7], //0
                [2,7,3,6], //1
                [1,7,3,5], //2
                [0,3,2,1], //3
                [0,5,4,1], //4
                [0,6,4,2]  //5
            ],
            vertices : vertices
        }

        // Work out edge midpoints
        var edge_midpoints = [];
        for(var i=0; i<12; i++){
            edge_midpoints.push( new THREE.Vector3( 
                (vertices[this.boundingBox.edge_vertices[i][0]][0] + vertices[this.boundingBox.edge_vertices[i][1]][0])/2,
                (vertices[this.boundingBox.edge_vertices[i][0]][1] + vertices[this.boundingBox.edge_vertices[i][1]][1])/2,
                (vertices[this.boundingBox.edge_vertices[i][0]][2] + vertices[this.boundingBox.edge_vertices[i][1]][2])/2
            ));
        }
        this.boundingBox.edge_midpoints = edge_midpoints;

    }

}


// Function to hide and show any dynamic objects
R3JS.Scene.prototype.showhideDynamics = function(camera){

    if(this.dynamic){
        
        var aspect = this.plotdims.aspect;

        // Set variables
        var face_normals   = this.boundingBox.face_normals;
        var edge_vertices  = this.boundingBox.edge_vertices;
        var face_vertices  = this.boundingBox.face_vertices;
        var edge_faces     = this.boundingBox.edge_faces;
        var edge_midpoints = this.boundingBox.edge_midpoints;

        // Work out which faces are visible
        var face_visibility = [0,0,0,0,0,0];
        for(var face=0; face<3; face++){
            var face_norm = new THREE.Vector3().fromArray(face_normals[face]);
            face_norm.applyQuaternion(this.plotHolder.quaternion);
            
            // Get plotpoint position
            var origin = new THREE.Vector3().fromArray(this.getTranslation());

            origin.applyQuaternion(this.plotHolder.quaternion);
            camera_to_origin = origin.clone().sub( camera.position );
            var face_angle   = camera_to_origin.angleTo(face_norm);
            var face_visible = face_angle < Math.PI/2;

            if(face_visible){
                face_visibility[face] = 1;
            } else {
                face_visibility[face+3] = 1;
            }
        }

        // Hide all objects associated with dynamic faces
        var dynamic_objects = this.dynamic_objects;
        for(var i=0; i<dynamic_objects.length; i++){
            dynamic_objects[i].hide();
        }

        // Show objects associated with shown box faces
        var boxfaces = this.dynamicDeco.faces;
        for(var i=0; i<6; i++){
            if(face_visibility[i] == 1){
                for(var j=0; j<boxfaces[i].length; j++){
                    boxfaces[i][j].show();
                }
            }
        }

        // Apply plot rotation to edge midpoints
        var rotated_midpoints = [];
        for(var i=0; i<12; i++){
            rotated_midpoints.push( edge_midpoints[i].clone().applyQuaternion(this.plotHolder.quaternion) );
        }

        // Cycle through edges
        var visible_edges = [];
        for(var i=0; i<12; i++){
            visible_edges.push([0,0,0,0]);
        }
        for(var i=0; i<12; i=i+4){
            
            if(face_visibility[edge_faces[i][0]] + 
               face_visibility[edge_faces[i][1]] == 1){
                var a = i;
                var b = i+2;
            } else {
                var a = i+1;
                var b = i+3;
            }

            visible_edges[a][0] = 1;
            visible_edges[b][0] = 1;

            if(rotated_midpoints[a].x >= rotated_midpoints[b].x) { visible_edges[a][1] = 1 }
            else                                                 { visible_edges[b][1] = 1 }
            if(rotated_midpoints[a].y >= rotated_midpoints[b].y) { visible_edges[a][2] = 1 }
            else                                                 { visible_edges[b][2] = 1 }
            if(rotated_midpoints[a].z >= rotated_midpoints[b].z) { visible_edges[a][3] = 1 }
            else                                                 { visible_edges[b][3] = 1 }

        }

        // Show objects associated with shown dynamic edges
        var boxedges = this.dynamicDeco.edges;
        for(var i=0; i<12; i++){
            
            if(visible_edges[i][0] == 1){
                for(var j=0; j<3; j++){
                    if(visible_edges[i][j+1] == 1){
                        
                        for(var k=0; k<boxedges[i][j].length; k++){
                            boxedges[i][j][k].show();
                        }

                    } else {

                        for(var k=0; k<boxedges[i][j+3].length; k++){
                            boxedges[i][j+3][k].show();
                        }

                    }
                }
            }

        }

    }

};

