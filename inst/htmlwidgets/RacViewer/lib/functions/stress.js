
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


Racmacs.Viewer.prototype.updateStress = function(stress){

  // Recalculate stress if not supplied in the function
  if(stress === undefined) {
    var stress = 0;
    for(var i=0; i<this.sera.length; i++){
      stress += this.sera[i].stress();
    }
  }

  // Update the stress
  this.stress.value = stress;
  this.stress.update(stress);

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
  if(titer == "*" || titer.charAt(0) == ">"){
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

