
Racmacs.utils.sigmoid = function(x) {
    return(1/(1+Math.exp(-10*x)));
}

Racmacs.utils.d_sigmoid = function(x) {
    return(Racmacs.utils.sigmoid(x)*(1-Racmacs.utils.sigmoid(x)));
}

Racmacs.utils.titerType = function(titer) {

    switch(titer.charAt(0)) {
    case "*":
      // Unmeasured
      return(0);
      break;
    case "<":
      // Less than titer
      return(2);
      break;
    case ">":
      // More than titer
      return(3);
      break;
    default:
      // Missing titer
      return(1);
    }

}

Racmacs.utils.inc_base = function(
    map_dist,
    table_dist,
    titer_type
    ) {

    var ibase;
    var x;
  
    // Deal with 0 map distance
    if(map_dist == 0){
      map_dist = 1e-5;
    }
  
    switch(titer_type) {
    case 1:
      // Measurable titer
      ibase = (2*(table_dist - map_dist)) / map_dist;
      break;
    case 2:
      // Less than titer
      x = table_dist - map_dist + 1;
      ibase = (10*x*x*Racmacs.utils.d_sigmoid(x) + 2*x*Racmacs.utils.sigmoid(x)) / map_dist;
      break;
    case 3:
      // More than titer
      ibase = 0;
      break;
    default:
      // Missing titer
      ibase = 0;
    }
  
    // Return the stress result
    return ibase;

}

Racmacs.utils.ptStress = function(
        map_dist,
        table_dist,
        titer_type
    ) {

    var x;
    var stress;
  
    switch(titer_type) {
    case 1:
      // Measurable titer
      stress = Math.pow((table_dist - map_dist), 2);
      break;
    case 2:
      // Less than titer
      x = table_dist - map_dist + 1;
      stress = Math.pow(x,2)*Racmacs.utils.sigmoid(x);
      break;
    case 3:
      // More than titer
      stress = 0;
      break;
    default:
      // Missing titer
      stress = 0;
    }
  
    // Return the stress result
    return(stress);

}

Racmacs.utils.ptResidual = function(
        map_dist,
        table_dist,
        titer_type
    ) {

    var x;
    var residual;
  
    switch(titer_type) {
    case 1:
      // Measurable titer
      residual = table_dist - map_dist;
      break;
    case 2:
      // Less than titer
      x = table_dist - map_dist + 1;
      residual = x*Racmacs.utils.sigmoid(x);
      break;
    case 3:
      // More than titer
      residual = 0;
      break;
    default:
      // Missing titer
      residual = 0;
    }
  
    // Return the residual result
    return(residual);

}

Racmacs.Optimizer = class RacOptimizer {

	constructor(args) {

	   this.ag_coords        = args.ag_coords;
       this.sr_coords        = args.sr_coords;
       this.fixed_ags        = args.fixed_ags;
       this.fixed_sr         = args.fixed_sr;
       this.num_dims         = args.ag_coords[0].length;
       this.num_ags          = args.ag_coords.length;
       this.num_sr           = args.sr_coords.length;
       this.titertype_matrix = args.titertypes;
       this.tabledist_matrix = args.tabledists;
       this.mapdist_matrix = new Array(this.num_ags);
       for (var i=0; i<this.num_ags; i++) {
          this.mapdist_matrix[i] = new Array(this.num_sr);
       }

       // Setup the gradient vectors
       this.ag_gradients = new Array (this.num_ags);
       for (var i=0; i<this.num_ags; i++) {
          this.ag_gradients[i] = new Array(this.num_dims);
       }
       this.sr_gradients = new Array (this.num_sr);
       for (var i=0; i<this.num_sr; i++) {
          this.sr_gradients[i] = new Array(this.num_dims);
       }
       this.ag_gradients.map(x => x.fill(0));
       this.sr_gradients.map(x => x.fill(0));

       // Update the map distance matrix according to coordinates
       this.update_map_dist_matrix();
       this.update_gradients();

	}

    // Update map coords from parameters
    update_map_coords(pars) {

        var n = 0;
        for(var i = 0; i < this.num_ags; i++) {
            for(var j = 0; j < this.num_dims; j++) {
                this.ag_coords[i][j] = pars[n];
                n++;
            }
        }

        for(var i = 0; i < this.num_sr; i++) {
            for(var j = 0; j < this.num_dims; j++) {
                this.sr_coords[i][j] = pars[n];
                n++;
            }
        }

    }

    // Method to update the distance matrix
    update_map_dist_matrix() {

        for (var ag = 0; ag < this.num_ags; ag++) {
            for (var sr = 0; sr < this.num_sr; sr++) {
                var dist = 0;
                for (var i = 0; i < this.num_dims; i++) {
                    dist += Math.pow(
                        this.ag_coords[ag][i] - this.sr_coords[sr][i],
                        2
                    );
                }
                dist = Math.sqrt(dist);
                this.mapdist_matrix[ag][sr] = dist;
            }
        }

    }

    // Calculating gradients for variables
    update_gradients(){

      // Setup to update gradients
      this.ag_gradients.map(x => x.fill(0));
      this.sr_gradients.map(x => x.fill(0));

      // Now we cycle through each antigen and sera and calculate the gradient
      for (var sr = 0; sr < this.num_sr; sr++) {
        for(var ag = 0; ag < this.num_ags; ag++) {

          // Skip unmeasured titers
          if(this.titertype_matrix[ag][sr] == 0){
            continue;
          }

          // Calculate inc_base
          var ibase = Racmacs.utils.inc_base(
            this.mapdist_matrix[ag][sr],
            this.tabledist_matrix[ag][sr],
            this.titertype_matrix[ag][sr]
          );

          // Now calculate the gradient for each coordinate
          for(var i = 0; i < this.num_dims; ++i) {
            var gradient = ibase*(this.ag_coords[ag][i] - this.sr_coords[sr][i]);
            this.ag_gradients[ag][i] -= gradient;
            this.sr_gradients[sr][i] += gradient;
          }

        }
      }

      // Reset gradients for fixed points
      this.fixed_ags.map(ag => this.ag_gradients[ag].fill(0));
      this.fixed_sr.map(sr => this.sr_gradients[sr].fill(0));

    }

    // Calculate map stress
    calculate_stress(){

        // Set the start stress
        var stress = 0;
  
        // Now we cycle through and sum up the stresses
        for(var sr = 0; sr < this.num_sr; sr++) {
            for(var ag = 0; ag < this.num_ags; ag++) {
    
                // Skip unmeasured titers
                if(this.titertype_matrix[ag][sr] == 0){
                    continue;
                }
      
                // Now calculate the stress
                stress += Racmacs.utils.ptStress(
                    this.mapdist_matrix[ag][sr],
                    this.tabledist_matrix[ag][sr],
                    this.titertype_matrix[ag][sr]
                );
    
            }
        }
  
        // Return the map stress
        return stress;

    }

}

Racmacs.Viewer.prototype.relaxMap = function() {

    // Calculate table distances
    var tabledists = this.antigens.map((ag, i) => 
        this.sera.map((sr, j) => this.data.tableDist(i, j))
    );

    // Get titer types
    var titertypes = this.antigens.map((ag, i) => 
        this.sera.map((sr, j) => this.data.titerType(i, j))
    );

    // Get fixed points
    var fixed_ags = [];
    var fixed_sr = [];
    if (this.selected_pts.length > 0) {
        this.antigens.map(ag => { if(!ag.selected) fixed_ags.push(ag.typeIndex); });
        this.sera.map(sr => { if(!sr.selected) fixed_sr.push(sr.typeIndex); });
    }

    // Setup optimizer object
    var map_optimizer = new Racmacs.Optimizer({
        ag_coords : this.data.agBaseCoords(),
        sr_coords : this.data.srBaseCoords(),
        tabledists : tabledists,
        titertypes : titertypes,
        fixed_ags : fixed_ags,
        fixed_sr : fixed_sr
    });

    map_optimizer.update_map_dist_matrix();
    map_optimizer.update_gradients();

    // Setup parameters
    var base_coords = this.data.ptBaseCoords();
    var init_pars = base_coords.reduce(function(a, b) {
        return a.concat(b);
    });

    // Setup objective function
    var objective = function (x) {
        
        map_optimizer.update_map_coords(x);
        map_optimizer.update_map_dist_matrix();
        var stress = map_optimizer.calculate_stress();
        return (stress);

    }

    // Setup gradient function
    var gradient = function (x) {
        
        map_optimizer.update_map_coords(x);
        map_optimizer.update_map_dist_matrix();
        map_optimizer.update_gradients();
        
        var gradients = [];
        gradients = gradients.concat(map_optimizer.ag_gradients);
        gradients = gradients.concat(map_optimizer.sr_gradients);
        gradients = gradients.reduce(function(a, b) {
            return a.concat(b);
        });
        return(gradients);

    }

    // Apply the mimimization
    var solution = optimjs.minimize_L_BFGS(
        objective, 
        gradient, 
        init_pars
    );
    map_optimizer.update_map_coords(solution.argument);
    map_optimizer.update_map_dist_matrix();
    
    // Apply the solution
    var new_coords = [];
    new_coords = new_coords.concat(map_optimizer.ag_coords);
    new_coords = new_coords.concat(map_optimizer.sr_coords);

    // Update the stress and coordinate data
    this.data.updateBaseCoords(new_coords);
    this.onCoordsChange();

    this.antigens.map((ag, i) => ag.animateToCoords(
        this.data.agCoords(i)
    ));

    this.sera.map((sr, i) => sr.animateToCoords(
        this.data.srCoords(i)
    ));

    // Update the stress
    this.updateStress(
        map_optimizer.calculate_stress()
    );

};

