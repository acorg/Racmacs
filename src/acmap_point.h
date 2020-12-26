
#include "acmap_optimization.h"
#include "acmap_titers.h"

#ifndef Racmacs__acmap_point__h
#define Racmacs__acmap_point__h

// Define the generic point class
class AcPoint {

  protected:

    // Regular details
    std::string type;
    std::string name;
    int group_values;
    std::string date;
    bool reference;
    std::string name_full;
    std::string name_abbreviated;
    std::string id = "";
    int group;
    std::string sequence;

    // Plotspec details
    bool shown = true;
    double size = 5.0;
    std::string shape = "CIRCLE";
    std::string fill = "green";
    std::string outline = "black";
    double outline_width = 1.0;
    double rotation = 0.0;
    double aspect = 1.0;
    int drawing_order = 1;

  public:

    // Regular details
    std::string get_type() const { return type; }
    std::string get_name() const { return name; }
    int get_group_values() const { return group_values; }
    std::string get_date() const { return date; }
    bool get_reference() const { return reference; }
    std::string get_name_full() const { return name_full; }
    std::string get_name_abbreviated() const { return name_abbreviated; }
    std::string get_id() const { return id; }
    int get_group() const { return group; }
    std::string get_sequence() const { return sequence; }

    void set_type( std::string value ){ type = value; }
    void set_name( std::string value ){ name = value; }
    void set_group_values( int value ){ group_values = value; }
    void set_date( std::string value ){ date = value; }
    void set_reference( bool value ){ reference = value; }
    void set_name_full( std::string value ){ name_full = value;}
    void set_name_abbreviated( std::string value ){ name_abbreviated = value; }
    void set_id( std::string value ){ id = value; }
    void set_group( int value ){ group = value; }
    void set_sequence( std::string value ){ sequence = value; }

    // Plotspec details
    bool get_shown() const { return shown; };
    double get_size() const { return size; };
    std::string get_fill() const { return fill; };
    std::string get_outline() const { return outline; };
    double get_outline_width() const { return outline_width; };
    double get_rotation() const { return rotation; };
    double get_aspect() const { return aspect; };
    std::string get_shape() const { return shape; };
    int get_drawing_order() const { return drawing_order; };

    void set_shown(bool shown_in){ shown = shown_in; };
    void set_size(double size_in){ size = size_in; };
    void set_fill(std::string fill_in){ fill = fill_in; };
    void set_outline(std::string outline_in){ outline = outline_in; }
    void set_outline_width(double outline_width_in){ outline_width = outline_width_in; };
    void set_rotation(double rotation_in){ rotation = rotation_in; };
    void set_aspect(double aspect_in){ aspect = aspect_in; };
    void set_shape(std::string shape_in){ shape = shape_in; };
    void set_drawing_order(int drawing_order_in){ drawing_order = drawing_order_in; }

    // Get IDs for matching
    std::string get_match_id() const {
      if(id == ""){
        return name;
      } else {
        return id;
      }
    }

};

// Define the antigen class
class AcAntigen: public AcPoint {

  public:
    AcAntigen(){
      set_type("ag");
    }

};

// Define the sera class
class AcSerum: public AcPoint {

  public:
    AcSerum(){
      set_type("sr");
      set_shape("BOX");
      set_fill("transparent");
    }

};

#endif
