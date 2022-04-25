
#include "acmap_optimization.h"
#include "acmap_titers.h"
#include "acmap_plotspec.h"
#include "acmap_point.h"
#include "acmap_sequences.h"

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
std::vector<SeqInsertion> AcPoint::get_sequence_insertions() const { return sequence_insertions; }
std::vector<std::string> AcPoint::get_clade() const { return clade; }
std::vector<std::string> AcPoint::get_annotations() const { return annotations; }
std::vector<std::string> AcPoint::get_labids() const { return labids; }
std::string AcPoint::get_lineage() const { return lineage; }
std::string AcPoint::get_reassortant() const { return reassortant; }
std::string AcPoint::get_strings() const { return strings; }
std::string AcPoint::get_continent() const { return continent; }
std::string AcPoint::get_nucleotidesequence() const { return nucleotidesequence; }

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
void AcPoint::set_sequence_insertions( std::vector<SeqInsertion> value ){ sequence_insertions = value; }
void AcPoint::set_clade( std::vector<std::string> value ){ clade = value; }
void AcPoint::set_annotations( std::vector<std::string> value ){ annotations = value; }
void AcPoint::set_labids( std::vector<std::string> value ){ labids = value; }
void AcPoint::set_lineage( std::string value ){ lineage = value; }
void AcPoint::set_reassortant( std::string value ){ reassortant = value; }
void AcPoint::set_strings( std::string value ){ strings = value; }
void AcPoint::set_continent( std::string value ){ continent = value; }
void AcPoint::set_nucleotidesequence( std::string value ){ nucleotidesequence = value; }

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
  } else if (attribute == "sequence_insertions") {
    return(sequence_insertions.size() == 0);
  } else if (attribute == "id") {
    return(id == "");
  } else if (attribute == "extra") {
    return(extra == "");
  } else if (attribute == "species") {
    return(species == "");
  } else if (attribute == "date") {
    return(date == "");
  } else if (attribute == "lineage") {
    return(lineage == "");
  } else if (attribute == "reassortant") {
    return(reassortant == "");
  } else if (attribute == "strings") {
    return(strings == "");
  } else if (attribute == "continent") {
    return(continent == "");
  } else if (attribute == "nucleotidesequence") {
    return(nucleotidesequence == "");
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

