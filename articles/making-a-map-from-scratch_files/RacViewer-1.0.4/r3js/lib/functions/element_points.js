
// GL line constructor
R3JS.element.constructors.point = function(
    plotobj,
    viewer
    ){

    // Generate the point object
    if(plotobj.shape[0].substring(plotobj.shape[0].length - 4) == "open") {
      plotobj.properties.outlinecolor = plotobj.properties.color;
      delete plotobj.properties.color;
    } else if(plotobj.shape[0].substring(plotobj.shape[0].length - 6) == "filled") {
      plotobj.properties.outlinecolor = plotobj.properties.color;
      plotobj.properties.fillcolor = plotobj.fill;
      delete plotobj.properties.color;
    }

    // Decide on the shape
    var shape = plotobj.shape[0];
    switch(shape) {
      case "circle open": shape = "circle"; break;
      case "circle filled": shape = "circle"; break;
      case "square open": shape = "square"; break;
      case "square filled": shape = "square"; break;
      case "triangle open": shape = "triangle"; break;
      case "triangle filled": shape = "triangle"; break;
      case "sphere open": shape = "sphere"; break;
      case "sphere filled": shape = "sphere"; break;
      case "cube open": shape = "cube"; break;
      case "cube filled": shape = "cube"; break;
      default: "circle"
    }

    var element = new R3JS.element.Point({
        coords : plotobj.position,
        size : plotobj.size[0]*0.1,
        shape : shape,
        properties : plotobj.properties,
        dimensions : plotobj.properties.dimensions
    });    

    // Apply rotation to geometry
    if (plotobj.properties.rotation !== undefined) {
        if (plotobj.properties.rotation[0] !== 0) element.rotateGeoX(plotobj.properties.rotation[0]);
        if (plotobj.properties.rotation[1] !== 0) element.rotateGeoY(plotobj.properties.rotation[1]);
        if (plotobj.properties.rotation[2] !== 0) element.rotateGeoZ(plotobj.properties.rotation[2]);
    }

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
      if(args.properties.color){
        var mat = R3JS.Material(args.properties);
        var geo = R3JS.Geometries[args.shape].fill(this.lwd);
        this.fill = new THREE.Mesh(geo, mat);
        this.fill.element = this;
        this.object.add(this.fill);
      }
      if(args.properties.fillcolor){
        args.properties.color = args.properties.fillcolor;
        var mat = R3JS.Material(args.properties);
        var geo = R3JS.Geometries[args.shape].inner(this.lwd);
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
      this.object.scale.set(
        args.size, 
        args.size, 
        args.size
      );

      // Position object
      this.object.position.set(
        args.coords[0],
        args.coords[1],
        args.coords[2]
      );

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
      if (this.fill) {
        this.fill.material.color.set(color);
      }
    }

    setFillOpacity(opacity){
      if (opacity === 0) this.fill.visible = false;
      else               this.fill.visible = true;
      if (this.fill) {
        this.fill.material.opacity = opacity;
      }
    }

    setOutlineOpacity(opacity){
      this.outline.material.opacity = opacity; 
    }

    // Geometry rotation
    rotateGeoX(rotation) { 
      if (this.fill.geometry) this.fill.geometry.rotateX(rotation);
      if (this.outline && this.outline.geometry) this.outline.geometry.rotateX(rotation);
    }
    rotateGeoY(rotation) { 
      if (this.fill.geometry) this.fill.geometry.rotateY(rotation);
      if (this.outline && this.outline.geometry) this.outline.geometry.rotateY(rotation);
    }
    rotateGeoZ(rotation) { 
      if (this.fill.geometry) this.fill.geometry.rotateZ(rotation);
      if (this.outline && this.outline.geometry) this.outline.geometry.rotateZ(rotation);
    }

    raycast(ray, intersected){
      if (this.shown && this.dynamic_shown) {
        if(this.fill){
          this.fill.raycast(ray,intersected);
        }
      }
    }

}

// Point geometries
R3JS.Geometries = {};

R3JS.Geometries.sphere = {
  fill : function(lwd){
    return( new THREE.SphereBufferGeometry(0.1, 25, 25) );
  },
  outline : function(lwd){
    return( new THREE.BufferGeometry() );
  },
  inner : function(lwd){
    return( new THREE.SphereBufferGeometry(0.1, 25, 25) );
  }
}

R3JS.Geometries.cube = {
  fill : function(lwd){
    return(new THREE.BoxBufferGeometry( 0.2, 0.2, 0.2 ));
  },
  outline : function(lwd){
    var size = 0.2;
    lwd  = lwd/12;
    var lims = [-size/2+lwd/4, size/2-lwd/4];
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

  },
  inner : function(lwd){
    lwd  = lwd/12;
    return(new THREE.BoxBufferGeometry( 0.2-lwd, 0.2-lwd, 0.2-lwd ));
  }
}

R3JS.Geometries.tetrahedron = {
  fill : function(lwd){
    var geo = new THREE.TetrahedronGeometry(0.16);
    geo.rotateZ( Math.PI/4 );
    geo.rotateX( -Math.PI/5 );
    geo.translate(0, -0.05, -0.05);
    return(geo);
  },
  outline : function(lwd){
    return( new THREE.BufferGeometry() );
  }
}


// 2D point geometries
R3JS.Geometries.circle = {
  fill : function(lwd){
    return(new THREE.CircleBufferGeometry(0.1, 32));
  },
  outline : function(lwd){
    return(new THREE.RingGeometry( 0.1-lwd/25, 0.1, 32 ));
  },
  inner : function(lwd){
    return(new THREE.CircleBufferGeometry(0.1-lwd/25, 32));
  }
}

R3JS.Geometries.square = {
  fill : function(lwd){
    return(new THREE.PlaneBufferGeometry(0.2, 0.2));
  },
  outline : function(lwd){
    lwd  = lwd/12;
    var size = 0.2;
    var inner = Math.sqrt((Math.pow(size-lwd,2))/2);
    var outer = Math.sqrt((Math.pow(size,2))/2);
    var geo = new THREE.RingBufferGeometry(inner, outer, 4, 1);
    geo.rotateZ( Math.PI/4 );
    return(geo);
  },
  inner : function(lwd){
    return(new THREE.PlaneBufferGeometry(0.2 - lwd/12, 0.2 - lwd/12));
  }
}

R3JS.Geometries.triangle = {
  fill : function(lwd){
    const geo = new THREE.CircleBufferGeometry(0.13, 0);
    geo.rotateZ( Math.PI/2 );
    geo.translate(0, -0.03, 0);
    return(geo);
  },
  outline : function(lwd){
    lwd  = lwd/12;
    const geo = new THREE.RingBufferGeometry(0.13 - lwd, 0.13, 1, 1);
    geo.rotateZ( Math.PI/2 );
    geo.translate(0, -0.03, 0);
    return(geo);
  },
  inner : function(lwd){
    lwd  = lwd/12;
    const geo = new THREE.CircleBufferGeometry(0.13 - lwd, 0);
    geo.rotateZ( Math.PI/2 );
    geo.translate(0, -0.03, 0);
    return(geo);
  }
}







