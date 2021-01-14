
// GL line constructor
R3JS.element.constructors.line = function(
    plotobj,
    viewer
    ){

    // Take colors from plot object
    plotobj.properties.color.r = plotobj.properties.color.r[0];
    plotobj.properties.color.g = plotobj.properties.color.g[0];
    plotobj.properties.color.b = plotobj.properties.color.b[0];

    // Make the line
    var element = new R3JS.element.Line({
        from:    plotobj.position[0],
        to:      plotobj.position[1],
        lwd:     plotobj.properties.lwd / viewer.scene.plotdims.size[0],
        properties : plotobj.properties,
        dimensions : plotobj.properties.dimensions
    });

    // Scale geometry
    // element.scaleGeo([
    //   viewer.scene.plotdims.size[0] / viewer.scene.plotdims.aspect[0],
    //   viewer.scene.plotdims.size[0] / viewer.scene.plotdims.aspect[1],
    //   viewer.scene.plotdims.size[0] / viewer.scene.plotdims.aspect[2]
    // ]);

    return(element);

}


R3JS.element.Line = class Line extends R3JS.element.base {

  constructor(args){

      super();

      // Make line object
      var mat = R3JS.Material(args.properties);

      if(args.from[0] == args.to[0] && 
         args.from[1] == args.to[1] && 
         args.from[2] == args.to[2]){
        
        var geo = new THREE.BufferGeometry();

      } else {
      
        if(args.dimensions == 2){
          var geo = R3JS.Geometries.line2d({
            from: args.from,
            to: args.to,
            lwd: args.lwd
          });
        } else {
          var geo = R3JS.Geometries.line3d({
            from: args.from,
            to: args.to,
            lwd: args.lwd
          });
        }

      }

      this.object = new THREE.Mesh(geo, mat);
      this.object.element = this;

    }

}


R3JS.Geometries.line2d = function(args){

  	var from      = args.from;
  	var to        = args.to;
    var lwd       = args.lwd;
    var cap       = args.cap;
    var shrinkage = args.shrinkage;
    var offset    = args.offset;
    var arrow     = args.arrow;

    // Get direction and length
    var direction = new THREE.Vector3(to[0]-from[0],
                                      to[1]-from[1],
                                      to[2]-from[2]);
    var length = direction.length();
    if(shrinkage){
        length = length - shrinkage;
    }
    if(arrow){
        length = length - arrow.headlength;
    }

    // Set object geometry
    var geo = new THREE.PlaneGeometry( lwd, length, 1, 1);
    geo.translate( 0, -length/2, 0 );
    if(shrinkage){
        geo.translate( 0, -shrinkage/2, 0 );
    }
    if(offset){
        geo.translate( offset[0], offset[1], offset[2] );
    }
    if(arrow){
        geo.translate( 0, -arrow.headlength, 0 );
        var arrowhead = new THREE.Geometry();
        arrowhead.vertices.push( new THREE.Vector3(arrow.headwidth/2, -arrow.headlength, 0) );
        arrowhead.vertices.push( new THREE.Vector3(-arrow.headwidth/2, -arrow.headlength, 0) );
        arrowhead.vertices.push( new THREE.Vector3(0, 0, 0) );
        arrowhead.faces.push( new THREE.Face3( 0, 2, 1 ) );
        geo.merge(arrowhead);
    }
    
    // Add cap if requested
    if(cap){
        var cap = new THREE.CircleGeometry( lwd/2, 16, 0, Math.PI );
        geo.merge(cap);
        var cap = new THREE.CircleGeometry( lwd/2, 16, Math.PI, Math.PI );
        cap.translate(0,-length,0);
        geo.merge(cap);
    }

    // Make translation matrix
    var transmat = new THREE.Matrix4();
    transmat.makeTranslation(to[0], to[1], to[2]);

    // Make rotation matrix
    var axis = new THREE.Vector3(0, 1, 0);
    var quat = new THREE.Quaternion().setFromUnitVectors(axis, direction.clone().normalize());
    var rotmat = new THREE.Matrix4().makeRotationFromQuaternion(quat);

    // Rotate to match direction and position
    geo.applyMatrix4(rotmat);
    geo.applyMatrix4(transmat);

    return(geo);

}


R3JS.Geometries.line3d = function(args){

  var from      = args.from;
  var to        = args.to;
  var lwd       = args.lwd;
  var cap       = args.cap;
  var shrinkage = args.shrinkage;
  var offset    = args.offset;
  var arrow     = args.arrow;
  var box       = args.box;
  var arrowend  = args.arrowend;

  // Get direction and length
  var direction = new THREE.Vector3(to[0]-from[0],
                                    to[1]-from[1],
                                    to[2]-from[2]);
  var length = direction.length();
  if(arrow){
      length = length - arrow.headlength;
  }
  if(shrinkage){
      length = length - shrinkage;
  }

  // Set object geometry
  if(!box){
      var geo = new THREE.CylinderGeometry( lwd/2, lwd/2, length, 32);
  } else {
      var geo = new THREE.BoxGeometry( lwd, length, lwd );
  }
  geo.translate( 0, (-length/2), 0 );
  if(shrinkage){
      geo.translate( 0, -shrinkage/2, 0 );
  }
  if(offset){
      geo.translate( offset[0], offset[1], offset[2] );
  }
  if(arrow){
      geo.translate( 0, -arrow.headlength, 0 );
      if(arrow.end == "circle"){
          var arrowhead = new THREE.SphereGeometry( arrow.headlength, 32, 32 );
      } else {
          var arrowhead = new THREE.ConeGeometry( arrow.headwidth/2, arrow.headlength, 32 );
          arrowhead.translate(0,-arrow.headlength/2,0);
      }
      geo.merge(arrowhead);
  }
  
  // Add cap if requested
  if(cap){
      var cap = new THREE.SphereGeometry( lwd/2, 16, 16, 0, Math.PI );
      geo.merge(cap);
      var cap = new THREE.SphereGeometry( lwd/2, 16, 16, 0, Math.PI*2, Math.PI, Math.PI );
      cap.translate(0,-length,0);
      geo.merge(cap);
  }

  // Make translation matrix
  var transmat = new THREE.Matrix4();
  transmat.makeTranslation(to[0], to[1], to[2]);

  // Make rotation matrix
  var axis = new THREE.Vector3(0, 1, 0);
  var quat = new THREE.Quaternion().setFromUnitVectors(axis, direction.clone().normalize());
  var rotmat = new THREE.Matrix4().makeRotationFromQuaternion(quat);

  // Rotate to match direction and position
  geo.applyMatrix4(rotmat);
  geo.applyMatrix4(transmat);

  return(geo);

}






