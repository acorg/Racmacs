
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





