
R3JS.Viewer.prototype.rotateSceneEuclidean = function(rotation){
	
    this.scene.rotateEuclidean(rotation);
    // this.scene.showhideDynamics( viewport.camera );
    this.render();
}

