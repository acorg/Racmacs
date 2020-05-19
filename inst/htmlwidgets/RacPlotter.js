HTMLWidgets.widget({

  name: 'RacPlotter',

  type: 'output',

  factory: function(el, width, height) {

    // Create an empty plotter object
    var plotter = new Racmacs.Plotter(el);

    return {

      renderValue: function(x) {

        // Code to render the widget
        var mapdata = JSON.parse(x.mapData);
        mapdata.procrustes = x.procrustes;
        plotter.load(
          mapdata,
          x
        );
        plotter.resize(width, height);

      },

      // A resize function
      resize: function(width, height) {
        plotter.resize(width, height);
      },

      // A method to expose our viewer to the outside
      getPlotter: function(){
          return plotter;
      },

      rac: el

    };
  }
});
