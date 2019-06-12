

$(window).on("load", function(){
  console.log("loaded");
});

$(document).on('shiny:sessioninitialized', function(event) {

});

$(document).on('shiny:disconnected', function(event) {

  // Hide the shiny elements
  racmacsviewer.controlpanel.hideShinyElements();

});


// Add event listener for the viewer being loaded
window.addEventListener("racViewerLoaded", function(e){

  // Get viewer reference
  var viewer = e.detail;
  racmacsviewer = viewer;

  // Show the shiny elements
  viewer.controlpanel.showShinyElements();

  // Get the file loaders
  var mapfileloader        = document.getElementById("mapDataLoaded");
  var procrustesfileloader = document.getElementById("procrustesDataLoaded");
  var tablefileloader      = document.getElementById("tableDataLoaded");
  var pointstylefileloader = document.getElementById("pointStyleDataLoaded");

  var mapfilesaver = document.getElementById("mapDataSaved");
  var tablefilesaver = document.getElementById("tableDataSaved");
  var coordsfilesaver = document.getElementById("coordsDataSaved");


  // Set methods to receive data from session
  Shiny.addCustomMessageHandler("loadMapData",         function(data){ viewer.load(data)                              });
  Shiny.addCustomMessageHandler("reloadMapData",       function(data){ viewer.load(data, { maintain_viewpoint:true }) });
  Shiny.addCustomMessageHandler("animateCoords",       function(data){ 
    viewer.animateToCoords(data);
    viewer.clearDiagnostics();
  });
  Shiny.addCustomMessageHandler("setCoords",           function(data){ 
    viewer.setCoords(data);
    viewer.clearDiagnostics();
  });
  Shiny.addCustomMessageHandler("addHemispheringData", function(data){ 
    viewer.addHemispheringData(data);
  });

  // Loaders
  viewer.onLoadMap           = function(){ mapfileloader.click()        };
  viewer.onLoadTable         = function(){ 
    tablefileloader.click();
    this.controlpanel.tabset.showTab("hitable");
  };
  viewer.onLoadPointStyles   = function(){ pointstylefileloader.click() };

  // Savers
  viewer.onSaveMap           = function(){
    Shiny.setInputValue("selectedPoints", viewer.getSelectedPointIndices(), { priority : "event" });
    mapfilesaver.click()
  };
  viewer.onSaveTable         = function(){
    Shiny.setInputValue("selectedPoints", viewer.getSelectedPointIndices(), { priority : "event" });
    tablefilesaver.click()
  };
  viewer.onSaveCoords        = function(){
    Shiny.setInputValue("selectedPoints", viewer.getSelectedPointIndices(), { priority : "event" });
    coordsfilesaver.click()
  };

  // Flip map
  viewer.onReflectMap = function(axis){
    Shiny.setInputValue("reflectMap", axis, { priority : "event" });
  }

  // Add procrustes
  viewer.onProcrustes = function(args){
    args.selected_points = viewer.getSelectedPointIndices();
    Shiny.setInputValue("procrustes", args, { priority : "event" });
    procrustesfileloader.click();
  };

  // Signals
  viewer.onRelaxMap          = function(){
    Shiny.setInputValue("relaxMap", true, { priority : "event" });
  };

  viewer.onRelaxMapOneStep = function(){
    Shiny.setInputValue("relaxMapOneStep", true, { priority : "event" });
  };

  viewer.onRandomizeMap = function(){
    Shiny.setInputValue("randomizeMap", true, { priority : "event" });
  };

  // Orient optimizations
  viewer.onOrientProjections = function(){
    Shiny.setInputValue("alignOptimizations", true, { priority : "event" });
  };

  // Remove optimizations
  viewer.onRemoveOptimizations = function(){
    Shiny.setInputValue("removeOptimizations", true, { priority : "event" });
  };

  // Move trapped points
  viewer.onMoveTrappedPoints = function(){
    Shiny.setInputValue("moveTrappedPoints", true, { priority : "event" });
  };

  // Check for hemisphering
  viewer.onCheckHemisphering = function(){
    Shiny.setInputValue("checkHemisphering", true, { priority : "event" });
  };

  // Run optimizations
  viewer.onRunOptimizations  = function(args){
    Shiny.setInputValue("runOptimizations", args, { priority : "event" });
  };

  // Add stress blobs
  viewer.onAddStressBlobs = function(args){
    args.selected_points = viewer.getSelectedPointIndices();
    Shiny.setInputValue("stressBlobs", args, { priority : "event" });
  };

  // Change in optimization
  viewer.onProjectionChange  = function(optimization){
    Shiny.setInputValue("optimizationChanged", optimization, { priority : "event" })
  };

  // Callback when coordinates are changed in the viewer (by dragging them)
  viewer.onCoordsChange = function(){
    this.clearDiagnostics();
    Shiny.setInputValue("coordsChanged", {
      antigens : this.getAntigenCoords(),
      sera     : this.getSeraCoords()
    }, { priority : "event" })
  };

  //// Change notification behaviour
  //viewport.notifications.error   = function(x){ Shiny.setInputValue("notification", x, { priority : "event" }) };
  //viewport.notifications.warning = function(x){ Shiny.setInputValue("notification", x, { priority : "event" }) };
  //viewport.notifications.info    = function(x){ Shiny.setInputValue("notification", x, { priority : "event" }) };

});







