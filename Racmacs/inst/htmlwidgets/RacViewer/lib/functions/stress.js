
Racmacs.StressElement = class StressElement {

  constructor(){

    this.value = 0;
    this.div = document.createElement("div");
    this.div.id = "stress-div";

  }

  bindToViewport(viewport){

    viewport.canvas.appendChild(this.div);

  }

  update(value){

    this.div.innerHTML = value.toFixed(2);

  }

}


Racmacs.Viewer.prototype.updateStress = function(){

  // Create function to update the map stress
  var stress = 0;
  for(var i=0; i<this.sera.length; i++){
    stress += this.sera[i].stress;
  }
  this.stress.value = stress;
  this.stress.update(stress);

  // Update any batch run viewers bound
  if(this.browsers && this.browsers.batch_runs){
    this.browsers.batch_runs.updateRun(stress);
  }

}

Racmacs.utils.logTiters = function(titerset){

  var logtiters = titerset.map(function(titers){
    return(titers.map(function(titer){
      return(Racmacs.utils.logTiter(titer));
    }));
  });
  return(logtiters);

}

Racmacs.utils.calcColBases = function(args){

  var logtiters   = Racmacs.utils.logTiters(args.titers);
  var colbases = Array(logtiters[0].length);
  for(var i=0; i<colbases.length; i++){
    
    colbases[i] = null;
    for(var j=0; j<logtiters.length; j++){
      var logtiter = logtiters[j][i];
      if(!isNaN(logtiter) 
        && (colbases[i] === null || logtiter > colbases[i])){
        colbases[i] = logtiter;
      }
    }

  }
  
  if(args.mincolbasis != "none"){

    var logmincolbasis = Racmacs.utils.logTiter(args.mincolbasis);
    for(var i=0; i<colbases.length; i++){
      if(logmincolbasis > colbases[i]){
        colbases[i] = logmincolbasis;
      }
    }

  }
  
  return(colbases);

}


Racmacs.utils.getLogTiters = function(titers){

  var log_titers = new Array(titers.length);
  for(var i=0; i<titers.length; i++){
    log_titers[i] = Racmacs.utils.logTiter(titers[i]);
  }
  return(log_titers);
  
}


// Key functions for calculating stress
Racmacs.utils.logTiter = function(titer){
  
  // Deal with > titers
  if(titer == "*" || titer.charAt(0) == ">"){
    return(NaN);
  } else {
    var hi = Number(titer.replace(/^(\<|\>)/, ""));
    return(Math.log(hi/10)/Math.LN2);
  }

}


Racmacs.utils.calc_table_dist = function(logTiter, colbase){
  return(colbase - logTiter);
}

Racmacs.utils.calc_stress = function(
  tableDist,
  mapDist,
  titer
  ){
  
  var con_stress;
  if(titer == "*"){
    return(0);
  } else if(titer.charAt(0) == ">"){
    return(0);
  } else {
    if(titer.charAt(0) == "<"){
      var x = tableDist+1-mapDist;
      return(
        Math.pow(x,2)*(1/(1+Math.exp(-10*x)))
      );
    } else {
      return(
        Math.pow(tableDist-mapDist,2)
      );
    }
  }

}




// // Function to relax the map
// function bind_relaxation(viewport){

//   // Create function to update the map stress
//   viewport.updateStress = function(){
//       var stress = 0;
//       for(var i=0; i<this.sera.length; i++){
//           stress += this.sera[i].stress;
//       }
//       this.stress.value = stress;
//       this.stress.div.update(stress);

//       // Update any batch run viewers bound
//       if(this.browsers && this.browsers.batch_runs){
//         this.browsers.batch_runs.updateRun(stress);
//       }
//   }

//   viewport.toggle_relaxMap = function(){

//     viewport = this;
//     var ag_objects = viewport.antigens;
//     var sr_objects = viewport.sera;
//     var selected_objects = [];
//     for(var i=0; i<viewport.selected_pts.length; i++){
//       selected_objects.push(viewport.points[viewport.selected_pts[i]]);
//     }

//     if(viewport.relax_on){ // Toggle off
//       viewport.relax_on = false;
//       if(viewport.onRelaxOff){ viewport.onRelaxOff() }

//       // Restart everything
//       viewport.updateStress();
//       viewport.animate();
//     } else { // Toggle on
//       viewport.relax_on = true;
//       if(viewport.onRelaxOn){ viewport.onRelaxOn() }

//       // Pause animation and disable buttons
//       cancelAnimationFrame( viewport.animationFrame );

//       // Decide which points to relax
//       var relax_objects = [];
//       if(selected_objects.length == 0){
//         for(var i=0; i<ag_objects.length; i++){
//           relax_objects.push(ag_objects[i]);
//         }
//         for(var i=0; i<sr_objects.length; i++){
//           relax_objects.push(sr_objects[i]);
//         }
//       } else {
//         for(var i=0; i<selected_objects.length; i++){
//           relax_objects.push(selected_objects[i]);
//         }
//       }
//       viewport.relax_objects = relax_objects;

//       // Start relaxation
//       viewport.relax_steps = 0;
//       viewport.best_stress = viewport.mapData.stress;
//       relax_map_step(viewport);
//     }
//   };

//   relax_map_step = function(viewport){

//     // Set the best stress to the current stress
//     var orig_stress = viewport.best_stress;
//     var mapData     = viewport.mapData;
//     var num_steps_unsuccessful = 0;
//     var relax_objects = viewport.relax_objects;
//     var ag_objects = viewport.antigens;
//     var sr_objects = viewport.sera;

//     // Stop if max steps reached
//     if(viewport.relax_steps > viewport.relax_steps_max){
//       toggle_relaxMap(viewport);
//     }

//     if(viewport.relax_on){

//       // Increase number of steps
//       viewport.relax_steps++;

//       // Cycle through points to relax
//       for(var i=0; i<relax_objects.length; i++){

//         var pt = relax_objects[i];
//         var orig_x = pt.coords[0];
//         var orig_y = pt.coords[1];
//         var orig_z = pt.coords[2];
//         var deltaX = (Math.random()-0.5)*0.1;
//         var deltaY = (Math.random()-0.5)*0.1;
//         if(viewport.dimensions == 3){
//           var deltaZ = (Math.random()-0.5)*0.1;
//         } else {
//           var deltaZ = 0;
//         }
        
//         var prev_stress = pt.stress;
//         pt.translate(
//           deltaX,
//           deltaY,
//           deltaZ
//         );
//         var new_stress  = pt.stress;

        
//         if(new_stress < prev_stress){
//           viewport.best_stress += (new_stress - prev_stress);
//         } else{
//           pt.setPosition(
//             orig_x,
//             orig_y,
//             orig_z
//           );
//         }

//       }

//       // Stop if improvement was too small
//       if(!orig_stress - viewport.best_stress < viewport.relax_min_reduction){
//         num_steps_unsuccessful++;
//       }
//       if(num_steps_unsuccessful > 5){
//         toggle_relaxMap(viewport);
//       }

//       // Update map stress
//       viewport.updateStress();

//       // Update connection lines
//       if(viewport.connectionLines){
//         for(var i=0; i<relax_objects.length; i++){
//               relax_objects[i].updateConnections();
//           }
//       }
//       if(viewport.errorLines){
//           for(var i=0; i<relax_objects.length; i++){
//               relax_objects[i].updateErrors();
//           }
//       }

//       // Render scene
//       viewport.render();
//       requestAnimationFrame(function(){ relax_map_step(viewport); });

//     }
//   };

// }




