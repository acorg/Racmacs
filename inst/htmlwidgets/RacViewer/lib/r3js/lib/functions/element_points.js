
// GL line constructor
R3JS.element.constructors.point = function(
    plotobj,
    viewer
    ){

    // Generate the point object
    if(plotobj.shape[0].substring(0,1) == "o"){
      plotobj.properties.outlinecolor = plotobj.properties.color;
    } else {
      plotobj.properties.fillcolor = plotobj.properties.color;
    }

    // Decide on the shape
    var shape;
    if(plotobj.properties.dimensions == 2){
      if(plotobj.shape[0] == "circle" || plotobj.shape[0] == "ocircle"){
        shape = "circle2d";
      }
      if(plotobj.shape[0] == "square" || plotobj.shape[0] == "osquare"){
        shape = "square2d";
      }
    } else {
      if(plotobj.shape[0] == "circle" || plotobj.shape[0] == "ocircle"){
        shape = "circle3d";
      }
      if(plotobj.shape[0] == "square" || plotobj.shape[0] == "osquare"){
        shape = "square3d";
      }
    }

    var element = new R3JS.element.Point({
        coords : plotobj.position,
        size : plotobj.size[0]*0.1,
        shape : shape,
        properties : plotobj.properties,
        dimensions : plotobj.properties.dimensions
    });

    // Scale geometry
    element.scaleGeo([
      viewer.scene.plotdims.size[0] / viewer.scene.plotdims.aspect[0],
      viewer.scene.plotdims.size[0] / viewer.scene.plotdims.aspect[1],
      viewer.scene.plotdims.size[0] / viewer.scene.plotdims.aspect[2]
    ]);

    return(element);

}


// Make a thin line object
R3JS.element.Point = class Point extends R3JS.element.base {

    constructor(args){

      super();

      // Make holder object
      this.object = new THREE.Object3D();
      this.object.element = this;

      // Set line width property
      this.lwd = args.properties.lwd;

      // Make fill object
      if(args.properties.fillcolor){
        args.properties.color = args.properties.fillcolor;
        var mat = R3JS.Material(args.properties);
        var geo = R3JS.Geometries[args.shape].fill(this.lwd);
        this.fill = new THREE.Mesh(geo, mat);
        this.fill.element = this;
        this.object.add(this.fill);
      }

      // Make outline object
      if(args.properties.outlinecolor){
        args.properties.color = args.properties.outlinecolor;
        var mat = R3JS.Material(args.properties);
        var geo = R3JS.Geometries[args.shape].outline(this.lwd);
        this.outline = new THREE.Mesh(geo, mat);
        this.outline.element = this;
        this.object.add(this.outline);
      }

      // Scale the object
      this.object.scale.set(args.size, 
                            args.size, 
                            args.size);

      // Position object
      this.object.position.set(args.coords[0],
                               args.coords[1],
                               args.coords[2]);

    }

    scale(val){
      this.object.scale.multiplyScalar(val);
    }

    scaleGeo(val){
      if(this.fill){
        this.fill.geometry.scale(
          val[0],
          val[1],
          val[2]
        );
      }
      if(this.outline){
        this.outline.geometry.scale(
          val[0],
          val[1],
          val[2]
        );
      }
    }

    setOutlineColor(color){
      this.outline.material.color.set(color);
    }

    setFillColor(color){
      this.fill.material.color.set(color);
    }

    setFillOpacity(opacity){
      this.fill.material.opacity = opacity;
    }

    setOutlineOpacity(opacity){
      this.outline.material.opacity = opacity; 
    }

    raycast(ray, intersected){
      if(this.fill){
        this.fill.raycast(ray,intersected);
      }
    }

}

// Point geometries
R3JS.Geometries = {};

R3JS.Geometries.circle3d = {
  fill : function(lwd){
    return( new THREE.SphereBufferGeometry(0.1, 25, 25) );
  },
  outline : function(lwd){
    return( new THREE.BufferGeometry() );
  }
}

R3JS.Geometries.square3d = {
  fill : function(lwd){
    return(new THREE.BoxBufferGeometry( 0.12, 0.12, 0.12 ));
  },
  outline : function(lwd){
    var size = 0.12;
    lwd  = lwd/60;
    var lims = [-size/2-lwd/4, size/2+lwd/4];
    var components = [];

    // Draw lines
    for(var i=0; i<2; i++){
      for(var j=0; j<2; j++){
        var line = R3JS.Geometries.line3d({
          from      : [lims[i], lims[j], lims[0]],
          to        : [lims[i], lims[j], lims[1]], 
          lwd       : lwd/2,
          cap       : false, 
          shrinkage : lwd/4, 
          offset    : 0, 
          box       : true
        });
        components.push(line);
      }
    }
    for(var i=0; i<2; i++){
      for(var j=0; j<2; j++){
        var line = R3JS.Geometries.line3d({
          from      : [lims[0], lims[i], lims[j]],
          to        : [lims[1], lims[i], lims[j]], 
          lwd       : lwd/2,
          cap       : false, 
          shrinkage : lwd/4, 
          offset    : 0, 
          box       : true
        });
        components.push(line);
      }
    }
    for(var i=0; i<2; i++){
      for(var j=0; j<2; j++){
        var line = R3JS.Geometries.line3d({
          from      : [lims[i], lims[0], lims[j]],
          to        : [lims[i], lims[1], lims[j]], 
          lwd       : lwd/2,
          cap       : false, 
          shrinkage : lwd/4, 
          offset    : 0, 
          box       : true
        });
        components.push(line);
      }
    }

    // Add corner pieces
    for(var i=0; i<2; i++){
      for(var j=0; j<2; j++){
        for(var k=0; k<2; k++){
          var corner = new THREE.BoxGeometry( lwd/2, lwd/2, lwd/2 );
          corner.translate(lims[i], lims[j], lims[k]);
          components.push(corner);
        }
      }
    }

    var geo = THREE.BufferGeometryUtils.mergeBufferGeometries(components);
    return(geo);

  }
}


// 2D point geometries
R3JS.Geometries.circle2d = {
  fill : function(lwd){
    return(new THREE.CircleBufferGeometry(0.2, 32));
  },
  outline : function(lwd){
    return(new THREE.RingGeometry( 0.2-lwd/25, 0.2, 32 ));
  }
}

R3JS.Geometries.square2d = {
  fill : function(lwd){
    return(new THREE.PlaneBufferGeometry(0.3, 0.3));
  },
  outline : function(lwd){
    lwd  = lwd/12;
    var size = 0.3;
    var inner = Math.sqrt((Math.pow(size,2))/2);
    var outer = Math.sqrt((Math.pow(size+lwd,2))/2);
    var geo = new THREE.RingBufferGeometry(inner, outer, 4, 1);
    geo.rotateZ( Math.PI/4 );
    return(geo);
  }
}







