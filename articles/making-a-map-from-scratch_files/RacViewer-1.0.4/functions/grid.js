
Racmacs.Viewer.prototype.setGrid = function(
    options = {}
    ){

	// Clear any previous grids
	if(this.gridelement){
		this.gridholder.remove(this.gridelement.object);
	}

	// Work out grid vertices
	var gridcoords = Racmacs.Grid.generate({
		radius     : this.mapdims.sphere.radius,
		dimensions : this.mapdims.dimensions
	});

    // Set grid options
    var grid_color = new THREE.Color(options["grid.col"]);

	// Create the grid element
    var element = new R3JS.element.gllines_fat({
        coords : gridcoords,
        segments : true,
        properties : {
            color : {
                r : Array(gridcoords.length).fill(grid_color.r),
                g : Array(gridcoords.length).fill(grid_color.g),
                b : Array(gridcoords.length).fill(grid_color.b)
            },
            mat : "line",
            lwd : 1
        },
        viewer : this
    });

    // Rotate and fade if in 3D
    if(this.mapdims.dimensions == 3){

    	// Estimate a standard camera position
    	var camera_pos = new THREE.Vector3(0,0,3);

    	// Rotate
    	element.rotateGeoY( -Math.PI / 4 );
    	element.rotateGeoX( Math.PI / 16 );
    	camera_pos.applyAxisAngle(new THREE.Vector3(1,0,0), -Math.PI / 16);
    	camera_pos.applyAxisAngle(new THREE.Vector3(0,1,0), Math.PI / 4);

    	// Fade
    	var coord_dists = gridcoords.map(function(coord){
    		return(
    			camera_pos.distanceTo(
    				new THREE.Vector3().fromArray(coord)
    			)
    		);
    	});
    	var max_dist  = Math.max(...coord_dists);
    	var min_dist  = Math.min(...coord_dists);
    	var dist_diff = max_dist - min_dist;

    	var coord_colors = coord_dists.map( 
    		x => 0.5 * Math.sqrt( ((x-min_dist)/dist_diff) )+0.3
    	);

        // Set colors
        var background_color = new THREE.Color("#ffffff");

        var coord_colors_r = coord_colors.map( x => x*background_color.r + (1 - x)*grid_color.r );
        var coord_colors_g = coord_colors.map( x => x*background_color.g + (1 - x)*grid_color.g );
        var coord_colors_b = coord_colors.map( x => x*background_color.b + (1 - x)*grid_color.b );

    	element.setColor({
    		r : coord_colors_r,
    		g : coord_colors_g,
    		b : coord_colors_b
    	});

    }

    if(this.svg){
        element = new R3JS.element.base();
        element.object = new THREE.Object3D();
    }

    this.gridholder.add(element.object);
    this.gridelement = element;

}

Racmacs.Viewer.prototype.getGridLineWidth = function(){

    if(this.gridelement){
        return(this.gridelement.getLineWidth());
    } else {
        return(null);
    }

}

Racmacs.Viewer.prototype.setGridLineWidth = function(linewidth){

    if(this.gridelement){
        this.gridelement.setLineWidth(linewidth);
        this.render();
    }

}


Racmacs.Grid = {};
Racmacs.Grid.generate = function(args){

	var radius     = args.radius;
	var dimensions = args.dimensions;

	var bbox      = {
		min : [], 
		max : []
	};

    // Get maximum distance from origin
    var min_val  = Math.floor(-radius);
    var max_val  = Math.ceil(radius);

    bbox.min[0] = min_val;
    bbox.min[1] = min_val;
    bbox.min[2] = min_val;
    bbox.max[0] = max_val;
    bbox.max[1] = max_val;
    bbox.max[2] = max_val;

    // Set variables based on number of dimensions
	if(dimensions <= 2){
		
		var num_grids = 1;

		// Extend range of grid if 2D
		bbox.min[2] = -20;
		bbox.max[2] = -20;
		var range_x = bbox.max[0] - bbox.min[0];
		var range_y = bbox.max[1] - bbox.min[1];
		bbox.min[0] = bbox.min[0] - range_x;
		bbox.max[0] = bbox.max[0] + range_x;
		bbox.min[1] = bbox.min[1] - range_y;
		bbox.max[1] = bbox.max[1] + range_y;

	} else {

		var num_grids = 3;

	}

    // Generate the geometry
    var vertices = [];
	for(var j=0; j<num_grids; j++){

		if(j==2){ var k = 0;   }
		else    { var k = j+1; }
		if(k==2){ var l = 0;   }
		else    { var l = k+1; }

		var min0 = bbox.min[j];
		var max0 = bbox.max[j];
		var min1 = bbox.min[k];
		var max1 = bbox.max[k];
		var min2 = bbox.min[l];
		var max2 = bbox.max[l];

		for(var i=min0; i<=max0; i++){
		  var vector1 = [min2,min2,min2];
		  var vector2 = [min2,min2,min2];
		  vector1[j] = i;
		  vector1[k] = min1;
		  vector2[j] = i;
		  vector2[k] = max1;
		  vertices.push(vector1, 
		                vector2);
		}
		for(var i=min1; i<=max1; i++){
		  var vector1 = [min2,min2,min2];
		  var vector2 = [min2,min2,min2];
		  vector1[k] = i;
		  vector1[j] = min0;
		  vector2[k] = i;
		  vector2[j] = max0;
		  vertices.push(vector1, 
		                vector2);
		}

	}

	return(vertices);

};

function bind_gridFunctions(viewport){

    viewport.setGrid = function(){
        
        // Remove a grid if already present
        if(this.grid){
        	this.scene.remove(this.grid);
        }

        // Generate a new grid
        this.grid = generateGrid(
            this.scene.sphere.radius, 
            this.dimensions
        );

        // Add the new grid to the scene
        this.scene.add(this.grid);

    }

}



function median(values) {

    values.sort( function(a,b) {return a - b;} );

    var half = Math.floor(values.length/2);

    if(values.length % 2)
        return values[half];
    else
        return (values[half-1] + values[half]) / 2.0;
}



// function generateGrid(radius, dimensions){

// 	var bbox    = new THREE.Box3();

// 	// Get maximum distance from origin
// 	var min_val  = Math.floor(-radius);
// 	var max_val  = Math.ceil(radius);
// 	bbox.min.x = min_val;
// 	bbox.min.y = min_val;
// 	bbox.min.z = min_val;
// 	bbox.max.x = max_val;
// 	bbox.max.y = max_val;
// 	bbox.max.z = max_val;

//     // Set variables based on number of dimensions
// 	if(dimensions == 2){
// 		var num_grids = 1;
// 		bbox.min.z = -20;
// 		bbox.max.z = -20;
// 		var range_x = bbox.max.x - bbox.min.x;
// 		var range_y = bbox.max.y - bbox.min.y;
// 		bbox.min.x = bbox.min.x - range_x;
// 		bbox.max.x = bbox.max.x + range_x;
// 		bbox.min.y = bbox.min.y - range_y;
// 		bbox.max.y = bbox.max.y + range_y;
// 		var grid_col = new THREE.Color( "#eeeeee" );
// 	} else {
// 		var num_grids = 3;
// 		var grid_col = new THREE.Color( "#cccccc" );
// 	}

//     // Generate the geometry
//     var grid_geo   = new THREE.Geometry();
// 	for(var j=0; j<num_grids; j++){

// 		if(j==2){ var k = 0;   }
// 		else    { var k = j+1; }
// 		if(k==2){ var l = 0;   }
// 		else    { var l = k+1; }

// 		var min0 = bbox.min.getComponent(j);
// 		var max0 = bbox.max.getComponent(j);
// 		var min1 = bbox.min.getComponent(k);
// 		var max1 = bbox.max.getComponent(k);
// 		var min2 = bbox.min.getComponent(l);
// 		var max2 = bbox.max.getComponent(l);

// 		for(var i=min0; i<=max0; i++){
// 		  var vector1 = new THREE.Vector3(min2,min2,min2);
// 		  var vector2 = new THREE.Vector3(min2,min2,min2);
// 		  vector1.setComponent ( j, i );
// 		  vector1.setComponent ( k, min1 );
// 		  vector2.setComponent ( j, i );
// 		  vector2.setComponent ( k, max1 );
// 		  grid_geo.vertices.push(vector1, 
// 		                         vector2);
// 		  grid_geo.colors.push(grid_col,
// 		  	                   grid_col);
// 		}
// 		for(var i=min1; i<=max1; i++){
// 		  var vector1 = new THREE.Vector3(min2,min2,min2);
// 		  var vector2 = new THREE.Vector3(min2,min2,min2);
// 		  vector1.setComponent ( k, i );
// 		  vector1.setComponent ( j, min0 );
// 		  vector2.setComponent ( k, i );
// 		  vector2.setComponent ( j, max0 );
// 		  grid_geo.vertices.push(vector1, 
// 		                         vector2);
// 		  grid_geo.colors.push(grid_col,
// 		  	                   grid_col);
// 		}

// 	}

//     // Set the grid material
// 	var grid_mat = new THREE.LineBasicMaterial( {
// 		//color: new THREE.Color("#cccccc"),
// 		vertexColors: THREE.VertexColors,
// 		linewidth: 1
// 	} );
// 	var grid = new THREE.LineSegments(grid_geo, grid_mat);

// 	// Add to a grid holder
// 	var grid_holder = new THREE.Object3D();
// 	grid_holder.add(grid);


// 	// Rotate grid and fade grid lines
// 	if(dimensions == 3){
		
// 		grid_holder.rotateX(Math.PI/16);
// 		grid_holder.rotateY(-Math.PI/4);
// 		grid_holder.updateMatrixWorld();

// 	    // Fade grid lines
// 	    var max_vertex_z = 0;
// 	    var min_vertex_z = 0;
// 	    var vertices_z   = [];
// 	    for(var i=0; i < grid.geometry.colors.length; i++){
// 	    	var vertex_pos = grid.geometry.vertices[i].clone();
// 	    	vertex_pos.applyMatrix4(grid.matrixWorld);
// 	    	vertices_z.push(vertex_pos.z);
// 	    	if(vertex_pos.z > max_vertex_z){ max_vertex_z = vertex_pos.z }
// 	    	if(vertex_pos.z < min_vertex_z){ min_vertex_z = vertex_pos.z }
// 	    }
// 	    var z_range = max_vertex_z - min_vertex_z;
// 	    var max_col_val = 0.95;
// 	    var min_col_val = 0.5;
// 	    for(var i=0; i < vertices_z.length; i++){
// 	    	var col_val = 1 - (vertices_z[i]-min_vertex_z)/z_range;
// 	    	col_val = Math.pow(col_val, 0.4);
// 	    	col_val = col_val*(max_col_val - min_col_val) + min_col_val;
// 	    	var vertex_col = new THREE.Color(col_val, col_val, col_val);
// 	    	grid.geometry.colors[i] = vertex_col;
// 	    }

// 	    // Add thicker grid lines for edges
// 	    var grid_outline_geo = new THREE.Geometry();
// 	    var grid_outline_col1 = new THREE.Color( "#eeeeee" );
// 	    var grid_outline_col2 = new THREE.Color( "#aaaaaa" );

// 	    grid_outline_geo.vertices.push(new THREE.Vector3(min_val, min_val, min_val), 
// 			                           new THREE.Vector3(max_val, min_val, min_val));
// 	    grid_outline_geo.colors.push(grid_outline_col1, 
// 			                         grid_outline_col2);
// 	    grid_outline_geo.vertices.push(new THREE.Vector3(min_val, min_val, min_val), 
// 			                           new THREE.Vector3(min_val, max_val, min_val));
// 	    grid_outline_geo.colors.push(grid_outline_col1, 
// 			                         grid_outline_col1);
// 	    grid_outline_geo.vertices.push(new THREE.Vector3(min_val, min_val, min_val), 
// 			                           new THREE.Vector3(min_val, min_val, max_val));
// 	    grid_outline_geo.colors.push(grid_outline_col1, 
// 			                         grid_outline_col2);

// 	    var grid_outline = new THREE.LineSegments(grid_outline_geo, grid_mat);
// 	    grid_holder.add(grid_outline);

// 	}

// 	// Return the grid object
// 	return(grid_holder);

// }




