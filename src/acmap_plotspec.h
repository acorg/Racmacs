
#ifndef Racmacs__acmap_plotspec__h
#define Racmacs__acmap_plotspec__h

class AcPlotspec {

  protected:

    bool shown = true;
    double size = 5.0;
    std::string shape = "CIRCLE";
    std::string fill = "green";
    std::string outline = "black";
    double outline_width = 1.0;
    double rotation = 0.0;
    double aspect = 1.0;

  public:

    // Plotspec details
    bool get_shown() const { return shown; };
    double get_size() const { return size; };
    std::string get_fill() const { return fill; };
    std::string get_outline() const { return outline; };
    double get_outline_width() const { return outline_width; };
    double get_rotation() const { return rotation; };
    double get_aspect() const { return aspect; };
    std::string get_shape() const { return shape; };

    void set_shown(bool shown_in){ shown = shown_in; };
    void set_size(double size_in){ size = size_in; };
    void set_fill(std::string fill_in){ fill = fill_in; };
    void set_outline(std::string outline_in){ outline = outline_in; }
    void set_outline_width(double outline_width_in){ outline_width = outline_width_in; };
    void set_rotation(double rotation_in){ rotation = rotation_in; };
    void set_aspect(double aspect_in){ aspect = aspect_in; };
    void set_shape(std::string shape_in){ shape = shape_in; };

};

#endif
