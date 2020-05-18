HTMLWidgets.widget({

  name: 'RacTable',

  type: 'output',

  factory: function(el, width, height) {

    // Create an empty table object
    var table = new Racmacs.Table(el);

    return {

      renderValue: function(x) {

        // Code to render the widget
        var mapdata = JSON.parse(x.mapData);
        table.load(
          mapdata,
          x
        );
        table.resize(width, height);

      },

      // A resize function
      resize: function(width, height) {
        table.resize(width, height);
      },

      // A method to expose our viewer to the outside
      getTable: function(){
          return table;
      },

      rac: el

    };
  }
});
