
HTMLWidgets.widget({

  name: 'RacViewer',

  type: 'output',

  factory: function(el, width, height) {

    // Create an empty viewer object
    var viewer = new Racmacs.Viewer(el);

    return {

      renderValue: function(x) {

        // TODO: code to render the widget, e.g.
        viewer.load(x.mapData, x.settings);

      },

      // A method to expose our chart to the outside
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
