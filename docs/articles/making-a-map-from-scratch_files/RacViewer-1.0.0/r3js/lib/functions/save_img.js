
R3JS.Viewer.prototype.getImgData = function(){

  if(!this.save_renderer){
    this.save_renderer = new THREE.WebGLRenderer({
      preserveDrawingBuffer: true,
      physicallyCorrectLights: true,
      antialias: true,
      alpha: true
    });
  }

  this.save_renderer.setSize(this.viewport.getWidth(),
                             this.viewport.getHeight());

  this.save_renderer.setPixelRatio( window.devicePixelRatio );
  this.save_renderer.render( 
    this.scene.scene, 
    this.camera.camera
  );

  var img_data = this.save_renderer.domElement.toDataURL();
  return(img_data);

}

R3JS.Viewer.prototype.downloadImage = function(filename){

  var img_data = this.getImgData(viewport);
  R3JS.utils.downloadURI(img_data, filename);

}


R3JS.utils.downloadURI = function(uri, name) {
  var link = document.createElement("a");
  link.download = name;
  link.href = uri;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  delete link;
}



