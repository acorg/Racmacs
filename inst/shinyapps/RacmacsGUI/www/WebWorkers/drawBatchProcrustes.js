
importScripts("../libraries/three.min.js");
importScripts("../RacViewer-1.0.0/r3js/functions/plotting.js");
importScripts("../RacViewer-1.0.0/functions/procrustes.js");

onmessage = function(e) {

    var mapData  = e.data.mapData;
    var from_run = e.data.selectedRun;
    var procrustes = {
      vertices : [],
      normals  : []
    };

    for(var i=0; i<mapData.batch_runs.length; i++){

      var pc = procrustes2BatchRunObject(mapData, from_run, i);
      postMessage({
        prop_complete : (i+1)/mapData.batch_runs.length
      });

      procrustes.vertices.push(pc.geometry.getAttribute('position').array)
      procrustes.normals.push(pc.geometry.getAttribute('normal').array);

    }

    postMessage({
      procrustes : procrustes
    });

};


