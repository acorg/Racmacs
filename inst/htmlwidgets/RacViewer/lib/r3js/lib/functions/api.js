
R3JS.Viewer.prototype.rotateSceneEuclidean = function(rotation){
	
    this.scene.rotateEuclidean(rotation);
    // this.scene.showhideDynamics( viewport.camera );
    this.render();
}

R3JS.Viewer.prototype.setBackground = function(color){

    this.scene.scene.background = new THREE.Color(color);

}
