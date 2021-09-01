
// Here we can include functions to run on different loading states,
// currently unused
$(window).on("load", function(){});
$(document).on('shiny:sessioninitialized', function(event) {});


// Functions to run when the app session disconnects, leaving just the viewer
$(document).on('shiny:disconnected', function(event) {

  // Hide the shiny elements
  racmacsviewer.exitGUImode();

});


// Add event listener for the viewer being loaded
window.addEventListener("racViewerLoaded", function(e){

  // Get viewer reference
  var viewer = e.detail;
  racmacsviewer = viewer;

  // Show the shiny-app-specific button elements in the viewer
  viewer.enterGUImode();

  // Loaders and savers, these functions run a click event on the underlying
  // but hidden load and save file buttons provided by the shiny load file
  // functions, this allows us to have our own load file buttons nested in the
  // custom GUI but to use the functionality of the shiny built in load file
  // buttons

  // Get references to the hidden shiny file loaders and savers
  var mapfileloader        = document.getElementById("mapDataLoaded");
  var procrustesfileloader = document.getElementById("procrustesDataLoaded");
  var tablefileloader      = document.getElementById("tableDataLoaded");
  var pointstylefileloader = document.getElementById("pointStyleDataLoaded");

  var mapfilesaver = document.getElementById("mapDataSaved");
  var tablefilesaver = document.getElementById("tableDataSaved");
  var coordsfilesaver = document.getElementById("coordsDataSaved");

  // Link click events from the GUI load buttons
  viewer.onLoadMap = function(){
    mapfileloader.click()
  };
  viewer.onLoadTable = function(){
    tablefileloader.click();
    this.controlpanel.tabset.showTab("hitable");
  };
  viewer.onLoadPointStyles = function(){
    pointstylefileloader.click()
  };

  // Link click events from the GUI save buttons
  viewer.onSaveMap = function(){
    Shiny.setInputValue("selectedPoints", viewer.getSelectedPointIndices(), { priority : "event" });
    mapfilesaver.click()
  };
  viewer.onSaveTable = function(){
    Shiny.setInputValue("selectedPoints", viewer.getSelectedPointIndices(), { priority : "event" });
    tablefilesaver.click()
  };
  viewer.onSaveCoords = function(){
    Shiny.setInputValue("selectedPoints", viewer.getSelectedPointIndices(), { priority : "event" });
    coordsfilesaver.click()
  };


  // Set methods to receive data from session, passing the data onto the
  // javascript viewer to be updated and displayed appropriately
  Shiny.addCustomMessageHandler("loadMapData", function(data){
    viewer.load(JSON.parse(data));
  });

  Shiny.addCustomMessageHandler("reloadMapData", function(data){
    viewer.load(JSON.parse(data), { maintain_viewpoint:true });
  });

  Shiny.addCustomMessageHandler("updateMapData", function(data){
    var selected_opt = viewer.data.projection();
    viewer.data.load(JSON.parse(data));
    viewer.data.setProjection(selected_opt);
  });

  Shiny.addCustomMessageHandler("animateCoords", function(data){
    viewer.animateToCoords(data);
    viewer.clearDiagnostics();
  });

  Shiny.addCustomMessageHandler("setCoords", function(data){
    viewer.setCoords(data);
    viewer.clearDiagnostics();
  });

  Shiny.addCustomMessageHandler("addBlobData", function(data){
    viewer.addTriangulationBlobs(data);
  });

  Shiny.addCustomMessageHandler("addHemispheringData", function(data){
    viewer.showHemisphering(data);
  });

  Shiny.addCustomMessageHandler("addProcrustesData", function(data){
    viewer.addProcrustesToBaseCoords(data);
  });


  // Set methods to send data to the app session in the background, reporting
  // that the user has done something like click a button

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

  // Relaxing the map
  viewer.onRelaxMap = function(){
    Shiny.setInputValue("selectedPoints", viewer.getSelectedPointIndices(), { priority : "event" });
    Shiny.setInputValue("relaxMap", true, { priority : "event" });
  };

  // Overwrite javascript relax map method
  viewer.relaxMap = function(){};
  viewer.toggleRelaxMap = function(){};

  // Relaxing the map one step
  viewer.onRelaxMapOneStep = function(){
    Shiny.setInputValue("relaxMapOneStep", true, { priority : "event" });
  };

  // Randomizing points
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
  viewer.onAddTriangulationBlobs = function(args){
    args.selected_points = viewer.getSelectedPointIndices();
    Shiny.setInputValue("triangulationBlobs", args, { priority : "event" });
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







