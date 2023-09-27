
HTMLWidgets.widget({

  name: 'RacViewer',

  type: 'output',

  factory: function(el, width, height) {

    // Create an empty viewer object
    var viewer = new Racmacs.Viewer(el);

    return {

      renderValue: function(x) {

        // Code to render the widget
        var mapdata = JSON.parse(x.mapData);
        viewer.load(
          mapdata,
          x.options,
          x.plotdata,
          x.light
        );

      },

      // A resize function
      resize: function(width, height) {
        viewer.viewport.onwindowresize();
      },

      // A method to expose our viewer to the outside
      getViewer: function(){
          return viewer;
      },

      rac: el

    };
  }
});


function getRacViewer(id){

  // Get the HTMLWidgets object
  var htmlWidgetsObj = HTMLWidgets.find("#" + id);

  // Get the underlying viewer
  var racViewer = htmlWidgetsObj.getViewer();

  return(racViewer);

}
