

R3JS.Viewer.prototype.clickBackground = function(elements){
  
}

R3JS.Viewer.prototype.clickElements = function(elements, event){

  for(var i=0; i<elements.length; i++){
    elements[i].click(event);
  }
  this.sceneChange = true;

}

R3JS.Viewer.prototype.hoverElements = function(elements){

	for(var i=0; i<elements.length; i++){
    elements[i].hover();
	}
	this.sceneChange = true;

}

R3JS.Viewer.prototype.dehoverElements = function(elements){

	for(var i=0; i<elements.length; i++){
    elements[i].dehover();
  }
  this.sceneChange = true;

}



