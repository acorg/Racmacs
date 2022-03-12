
#include "acmap_optimization.h"
#include "acmap_titers.h"
#include "acmap_plotspec.h"
#include "acmap_point.h"

// Regular details
std::string AcPoint::get_type() const { return type; }
std::string AcPoint::get_name() const { return name; }
std::string AcPoint::get_extra() const { return extra; }
std::string AcPoint::get_date() const { return date; }
bool AcPoint::get_reference() const { return reference; }
std::string AcPoint::get_passage() const { return passage; }
std::string AcPoint::get_id() const { return id; }
std::string AcPoint::get_species() const { return species; }
int AcPoint::get_group() const { return group; }
std::string AcPoint::get_sequence() const { return sequence; }
std::vector<std::string> AcPoint::get_clade() const { return clade; }
std::vector<std::string> AcPoint::get_annotations() const { return annotations; }
std::vector<std::string> AcPoint::get_labids() const { return labids; }

void AcPoint::set_type( std::string value ){ type = value; }
void AcPoint::set_name( std::string value ){ name = value; }
void AcPoint::set_extra( std::string value ){ extra = value; }
void AcPoint::set_date( std::string value ){ date = value; }
void AcPoint::set_reference( bool value ){ reference = value; }
void AcPoint::set_passage( std::string value ){ passage = value; }
void AcPoint::set_id( std::string value ){ id = value; }
void AcPoint::set_species( std::string value ){ species = value; }
void AcPoint::set_group( int value ){ group = value; }
void AcPoint::set_sequence( std::string value ){ sequence = value; }
void AcPoint::set_clade( std::vector<std::string> value ){ clade = value; }
void AcPoint::set_annotations( std::vector<std::string> value ){ annotations = value; }
void AcPoint::set_labids( std::vector<std::string> value ){ labids = value; }

// Get IDs for matching
std::string AcPoint::get_match_id() const {
  if(id == ""){
    return name;
  } else {
    return id;
  }
}

// Check if values are defaults
bool AcPoint::isdefault(std::string attribute) {

  if (attribute == "passage") {
    return(passage == "");
  } else if (attribute == "clade") {
    return(clade.size() == 0);
  } else if (attribute == "annotations") {
    return(annotations.size() == 0);
  } else if (attribute == "labids") {
    return(labids.size() == 0);
  } else if (attribute == "group") {
    return(group == 0);
  } else if (attribute == "sequence") {
    return(sequence == "");
  } else if (attribute == "id") {
    return(id == "");
  } else if (attribute == "extra") {
    return(extra == "");
  } else if (attribute == "species") {
    return(species == "");
  } else if (attribute == "date") {
    return(date == "");
  } else {
    return(false);
  }

}

// Define the antigen class
AcAntigen::AcAntigen(){
  set_type("ag");
}

// Define the sera class
AcSerum::AcSerum(){
  set_type("sr");
  plotspec.set_shape("BOX");
  plotspec.set_fill("transparent");
}

arma::uvec AcSerum::get_homologous_ags() const { return homologous_ags; }
void AcSerum::set_homologous_ags( arma::uvec value ){ homologous_ags = value; }

