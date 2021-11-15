
// == Add relevant event listeners ==
R3JS.Viewer.prototype.eventListeners.push({
    name : "optimizer-ags-fixed",
    fn : function(e){
        let viewer = e.detail.viewer;
        viewer.optimizerFixAntigens();
        if (viewer.optimizing) {
            viewer.endOptimizer();
            viewer.relaxMap();
        }
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "optimizer-ags-unfixed",
    fn : function(e){
        let viewer = e.detail.viewer;
        viewer.optimizerUnfixAntigens();
        if (viewer.optimizing) {
            viewer.endOptimizer();
            viewer.relaxMap();
        }
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "optimizer-srs-fixed",
    fn : function(e){
        let viewer = e.detail.viewer;
        viewer.optimizerFixSera();
        if (viewer.optimizing) {
            viewer.endOptimizer();
            viewer.relaxMap();
        }
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "optimizer-srs-unfixed",
    fn : function(e){
        let viewer = e.detail.viewer;
        viewer.optimizerUnfixSera();
        if (viewer.optimizing) {
            viewer.endOptimizer();
            viewer.relaxMap();
        }
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "point-included",
    fn : function(e){
        let point  = e.detail.point;
        let viewer = point.viewer;
        if (viewer.optimizing) {
            viewer.endOptimizer();
            viewer.relaxMap();
        }
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "point-excluded",
    fn : function(e){
        let point  = e.detail.point;
        let viewer = point.viewer;
        if (viewer.optimizing) {
            viewer.endOptimizer();
            viewer.relaxMap();
        }
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "titer-changed",
    fn : function(e){
        let viewer = e.detail.viewer;
        if (viewer.optimizing) {
            viewer.endOptimizer();
            viewer.relaxMap();
        }
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "points-randomized",
    fn : function(e){
        let viewer = e.detail.viewer;
        if (viewer.optimizing) {
            viewer.endOptimizer(false);
            viewer.relaxMap();
        }
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "ag-reactivity-changed",
    fn : function(e){
        let viewer = e.detail.point.viewer;
        if (viewer.optimizing) {
            viewer.endOptimizer();
            viewer.relaxMap();
        }
    }
});


// == Stress related functions ==
Racmacs.utils.sigmoid = function(x) {
    return(1/(1+Math.exp(-10*x)));
}

Racmacs.utils.d_sigmoid = function(x) {
    return(Racmacs.utils.sigmoid(x)*(1-Racmacs.utils.sigmoid(x)));
}

Racmacs.utils.titerType = function(titer) {

    switch(titer.charAt(0)) {
    case ".":
      // Not there in merge
      return(-1);
      break;
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
    titer_type,
    dilution_stepsize
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
      x = table_dist - map_dist + dilution_stepsize;
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
        titer_type,
        dilution_stepsize
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
      x = table_dist - map_dist + dilution_stepsize;
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
        titer_type,
        dilution_stepsize
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
      x = table_dist - map_dist + dilution_stepsize;
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
    return(-residual);

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
       this.dilutionstepsize = args.dilutionstepsize;
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
            this.titertype_matrix[ag][sr],
            this.dilutionstepsize
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
                    this.titertype_matrix[ag][sr],
                    this.dilutionstepsize
                );
    
            }
        }
  
        // Return the map stress
        return stress;

    }

}

Racmacs.Viewer.prototype.optimizerFixAntigens = function() { this.optimizer_ags_fixed = true; }
Racmacs.Viewer.prototype.optimizerUnfixAntigens = function() { this.optimizer_ags_fixed = false; }
Racmacs.Viewer.prototype.optimizerFixSera = function() { this.optimizer_srs_fixed = true; }
Racmacs.Viewer.prototype.optimizerUnfixSera = function() { this.optimizer_srs_fixed = false; }

Racmacs.Viewer.prototype.toggleRelaxMap = function(onlyselected) {

    if (this.optimizing) this.endOptimizer();
    else                 this.relaxMap(onlyselected);

}

Racmacs.Viewer.prototype.relaxMap = function(onlyselected, maxsteps) {

    this.optimDragOn = () => {

        if(this.raytracer.intersected.length > 0){

            this.navigable = false;
            this.optimdragging = true;
            var intersected_elements = this.raytracer.intersectedElements();
            this.primaryDragPoint = intersected_elements[0].point;
            this.dragfn = e => this.dragPoints(false);
            this.viewport.div.addEventListener("mousemove", this.dragfn);

        }

    }

    this.optimDragOff = () => {

        this.navigable = true;
        this.optimdragging = false;
        this.primaryDragPoint = null;
        this.viewport.div.removeEventListener("mousemove", this.dragfn);
        this.endOptimizer();
        this.data.updateCoords();
        this.relaxMap();
        console.log("end dragging");

    }

    this.viewport.div.addEventListener("mousedown", this.optimDragOn);
    this.viewport.div.addEventListener("mouseup", this.optimDragOff);

    // Record whether this is only a onestep optimization
    this.optimizer_maxsteps = maxsteps;
    this.optimizer_stepnum = 0;

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
    if (this.selected_pts.length > 0 && onlyselected) {
        this.antigens.map(ag => { if(!ag.selected) fixed_ags.push(ag.typeIndex); });
        this.sera.map(sr => { if(!sr.selected) fixed_sr.push(sr.typeIndex); });
    }

    if (this.optimizer_ags_fixed) this.antigens.map(ag => { fixed_ags.push(ag.typeIndex) });
    if (this.optimizer_srs_fixed) this.sera.map(sr => { fixed_sr.push(sr.typeIndex) });

    // Setup optimizer object
    this.optimizer = new Racmacs.Optimizer({
        ag_coords : this.data.agBaseCoords(),
        sr_coords : this.data.srBaseCoords(),
        tabledists : tabledists,
        titertypes : titertypes,
        fixed_ags : fixed_ags,
        fixed_sr : fixed_sr,
        dilutionstepsize : this.data.dilutionstepsize_cache
    });

    this.optimizer.update_map_dist_matrix();
    this.optimizer.update_gradients();
    this.optimizer_solution = this.optimizer.calculate_stress();

    // Setup parameters
    var base_coords = this.data.ptBaseCoords();
    this.optimizer_pars = base_coords.reduce(function(a, b) {
        return a.concat(b);
    });

    // Start the optimization loop
    this.btns["relaxMap"].highlight();
    this.optimizing = true;

    // Setup objective function
    var viewer = this;
    this.optimizer_objective = function (x) {
        
        viewer.optimizer.update_map_coords(x);
        viewer.optimizer.update_map_dist_matrix();
        var stress = viewer.optimizer.calculate_stress();
        return (stress);

    }

    // Setup gradient function
    this.optimizer_gradient = function (x) {
        
        viewer.optimizer.update_map_coords(x);
        viewer.optimizer.update_map_dist_matrix();
        viewer.optimizer.update_gradients();
        
        var gradients = [];
        gradients = gradients.concat(viewer.optimizer.ag_gradients);
        gradients = gradients.concat(viewer.optimizer.sr_gradients);
        gradients = gradients.reduce(function(a, b) {
            return a.concat(b);
        });
        return(gradients);

    }

    // Set transformation and translation
    this.optimizer_transformation = this.data.transformation();
    this.optimizer_translation = this.data.translation();

};


Racmacs.Viewer.prototype.stepOptimizer = function() {

    // Do not run optimizer if dragging
    if (this.optimdragging) return(false);

    // Record stepnum
    this.optimizer_stepnum++;

    // Apply the mimimization
    var solution = optimjs.minimize_GradientDescent(
        this.optimizer_objective, 
        this.optimizer_gradient, 
        this.optimizer_pars,
        1
    );

    // Update optimizer based on values
    this.optimizer_pars = solution.argument;
    this.optimizer.update_map_coords(solution.argument);
    this.optimizer.update_map_dist_matrix();
    
    // Step the coordinates forward to the new positions
    this.antigens.map((ag, i) => ag.setPosition(
        Racmacs.utils.transformTranslateCoords(
            this.optimizer.ag_coords[i],
            this.optimizer_transformation,
            this.optimizer_translation
        )
    ));

    this.sera.map((sr, i) => sr.setPosition(
        Racmacs.utils.transformTranslateCoords(
            this.optimizer.sr_coords[i],
            this.optimizer_transformation,
            this.optimizer_translation
        )
    ));

    // Update the stress
    var new_stress = this.optimizer.calculate_stress();
    this.updateStress(new_stress);

    // Check if optimization should be ended
    if ((this.optimizer_maxsteps !== undefined && this.optimizer_stepnum == this.optimizer_maxsteps) 
        // || this.optimizer_solution - new_stress < 1e-8
        ) {
        this.endOptimizer();
    } else {
        this.optimizer_solution = new_stress;
    }
    

}


Racmacs.Viewer.prototype.endOptimizer = function(update_coords = true) {

    this.viewport.div.removeEventListener("mousedown", this.optimDragOn);
    this.viewport.div.removeEventListener("mouseup", this.optimDragOff);

    // Quit the optimization loop
    this.btns["relaxMap"].dehighlight();
    this.optimizing = false;

    // Update the stress and coordinate data
    var new_coords = [];
    new_coords = new_coords.concat(this.optimizer.ag_coords);
    new_coords = new_coords.concat(this.optimizer.sr_coords);

    // Update the stress
    if (update_coords) this.data.updateBaseCoords(new_coords);
    this.updateStress(
        this.optimizer.calculate_stress()
    );

    // Trigger any on coordinates change events
    this.onCoordsChange();

}


Racmacs.Viewer.prototype.randomizeCoords = function(){

    // this.antigens.map( ag => ag.setPosition() );
    var xcoords = this.data.transformedCoords().map( x => isNaN(x[0]) ? 0 : x[0] );
    var xlim = [Math.min(...xcoords), Math.max(...xcoords)];
    
    var ycoords = this.data.transformedCoords().map( x => isNaN(x[1]) ? 0 : x[1] );
    var ylim = [Math.min(...ycoords), Math.max(...ycoords)];

    var zcoords = this.data.transformedCoords().map( x => isNaN(x[2]) ? 0 : x[2] );
    var zlim = [Math.min(...zcoords), Math.max(...zcoords)];

    this.antigens.map( ag => ag.setPosition([
        xlim[0] + Math.random()*(xlim[1] - xlim[0]),
        ylim[0] + Math.random()*(ylim[1] - ylim[0]),
        zlim[0] + Math.random()*(zlim[1] - zlim[0])
    ], false) );

    this.sera.map( sr => sr.setPosition([
        xlim[0] + Math.random()*(xlim[1] - xlim[0]),
        ylim[0] + Math.random()*(ylim[1] - ylim[0]),
        zlim[0] + Math.random()*(zlim[1] - zlim[0])
    ], false) );

    // Dispatch an event
    this.updateStress();
    this.updateFrustrum();
    this.data.updateCoords();
    this.dispatchEvent("points-randomized", { 
        viewer : this
    });
    this.render();

}


