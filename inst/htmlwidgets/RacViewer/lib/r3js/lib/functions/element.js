
R3JS.element = {};
R3JS.element.constructors = {};

R3JS.element.base = class Element {

    constructor(){
        this.layers = new THREE.Layers();
    }
	show(){ this.object.visible = true  }
    hide(){ this.object.visible = false }
    showMat(){ 
        if(this.object.material){
            this.object.material.visible = true
        }
    }
    
    hideMat(){ 
        if(this.object.material){
            this.object.material.visible = false 
        }
    }

    showHighlight(){
    	if(this.highlight){
    		this.hideMat();
    		this.highlight.show();
    	}
    }

	hideHighlight(){
    	if(this.highlight){
    		this.showMat();
    		this.highlight.hide();
    	}
    }

    highlightGroup(){
    	if(this.group){
    		for(var i=0; i<this.group.length; i++){
    			this.group[i].showHighlight();
    		}
    	}
    }

    dehighlightGroup(){
    	if(this.group){
    		for(var i=0; i<this.group.length; i++){
    			this.group[i].hideHighlight();
    		}
    	}
    }

    // Setting coordinates
    setCoords(x,y,z){
        this.object.position.set(x, y, z);
    }

    // Geometry rotation
    rotateGeoX(rotation){ this.object.geometry.rotateX(rotation) }
    rotateGeoY(rotation){ this.object.geometry.rotateY(rotation) }
    rotateGeoZ(rotation){ this.object.geometry.rotateZ(rotation) }

    // Geometry scaling
    scaleGeo(scale){
    	this.object.geometry.scale(
    		scale[0],
    		scale[1],
    		scale[2]
    	);
    }

    setRenderOrder(order){
    	this.object.renderOrder = order;
    }

    elements(){
        return([this]);
    }

    setColor(color){
        this.object.material.color.set(color);
    }

    raycast(a,b){
        this.object.raycast(a,b);
    }

    hover(){
        this.highlightGroup();
    }

    dehover(){
    	this.dehighlightGroup();
    }

    click(event){
    }

    // Check whether point falls within a selection rectangle
    withinRectangle(
        corner1, 
        corner2, 
        camera
    ){

        var projectedPosition = this.object.position.clone()
                                                    .applyMatrix4(this.object.parent.matrixWorld)
                                                    .project(camera.camera);

        var aspect = camera.aspect;
        
        var size       = this.size;
        var ptRadius   = 0;

        // var ptRadius = (this.pointobj.material.uniforms.scale.value*0.0032*this.size)/
        //                (3*this.pointobj.material.uniforms.viewportPixelRatio.value);

        return(projectedPosition.x + ptRadius/aspect > Math.min(corner1.x, corner2.x) &&
               projectedPosition.x - ptRadius/aspect < Math.max(corner1.x, corner2.x) &&
               projectedPosition.y + ptRadius > Math.min(corner1.y, corner2.y) &&
               projectedPosition.y - ptRadius < Math.max(corner1.y, corner2.y));
 
    }

    // Event for selection within a rectangle
    rectangleSelect(){
    }

    breakupMesh(){
        this.object = R3JS.utils.breakupMesh(this.object);
    }

}



