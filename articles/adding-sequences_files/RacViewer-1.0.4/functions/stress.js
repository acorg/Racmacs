
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

    this.div.innerHTML = value.total.toFixed(2) + 
    "|" + 
    value.pertiter.toFixed(2) + 
    "<span style='font-size:80%; margin-left:2px;'>[" + value.perdetectable.toFixed(2) + "]</span>";

  }

}


Racmacs.Viewer.prototype.updateStress = function(stress){

  // Recalculate stress if not supplied in the function
  if(stress === undefined) {
    var stress = 0;
    for(var i=0; i<this.sera.length; i++){
      stress += this.sera[i].stress();
    }
  }

  var stress_detectable = 0;
  for(var i=0; i<this.sera.length; i++){
    stress_detectable += this.sera[i].stress_detectable();
  }

  // Update the stress
  this.stress.value = stress;
  this.stress.update({
    total: stress,
    pertiter: stress / this.data.numTiters(),
    perdetectable: stress_detectable / this.data.numDetectableTiters()
  });

  // Update any batch run viewers bound
  if(this.projectionList){
      this.projectionList.updateStress(
          this.data.projection(), 
          stress.toFixed(2)
      );
  }

  // Update data stress
  this.data.updateStress(stress);

}


Racmacs.utils.calcColBases = function(args){

  var logtiters   = Racmacs.utils.logTiters(args.titers);

  // Apply antigen reactivity adjustments
  for (var ag = 0; ag < logtiters.length; ag++) {
    for (var sr = 0; sr < logtiters[0].length; sr++) {
      logtiters[ag][sr] += args.ag_reactivity_adjustment[ag];
    }
  }

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


// Key functions for calculating stress
Racmacs.utils.logTiter = function(titer){
  
  // Deal with > titers
  if(titer == "*" || titer == "." || titer.charAt(0) == ">"){
    return(NaN);
  } else {
    var hi = Number(titer.replace(/^(\<|\>)/, ""));
    return(Math.log(hi/10)/Math.LN2);
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

