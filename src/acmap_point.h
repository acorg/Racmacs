
#include "acmap_optimization.h"
#include "acmap_titers.h"
#include "acmap_plotspec.h"

#ifndef Racmacs__acmap_point__h
#define Racmacs__acmap_point__h

// Define the generic point class
class AcPoint {

  protected:

    // Regular details
    std::string type;
    std::string name;
    std::string date;
    bool reference = false;
    std::string name_full;
    std::string name_abbreviated;
    std::string id = "";
    int group = 0;
    std::string sequence;
    std::string passage;
    std::vector<std::string> clade;

  public:

    // Plotspec details
    AcPlotspec plotspec;

    // Regular details
    std::string get_type() const { return type; }
    std::string get_name() const { return name; }
    std::string get_date() const { return date; }
    bool get_reference() const { return reference; }
    std::string get_passage() const { return passage; }
    std::string get_name_full() const { return name_full; }
    std::string get_name_abbreviated() const { return name_abbreviated; }
    std::string get_id() const { return id; }
    int get_group() const { return group; }
    std::string get_sequence() const { return sequence; }
    std::vector<std::string> get_clade() const { return clade; }

    void set_type( std::string value ){ type = value; }
    void set_name( std::string value ){ name = value; }
    void set_date( std::string value ){ date = value; }
    void set_reference( bool value ){ reference = value; }
    void set_passage( std::string value ){ passage = value; }
    void set_name_full( std::string value ){ name_full = value; }
    void set_name_abbreviated( std::string value ){ name_abbreviated = value; }
    void set_id( std::string value ){ id = value; }
    void set_group( int value ){ group = value; }
    void set_sequence( std::string value ){ sequence = value; }
    void set_clade( std::vector<std::string> value ){ clade = value; }

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
      plotspec.set_shape("BOX");
      plotspec.set_fill("transparent");
    }

};

#endif
