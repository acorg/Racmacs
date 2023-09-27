
#include "acmap_optimization.h"
#include "acmap_titers.h"
#include "acmap_plotspec.h"
#include "acmap_sequences.h"

#ifndef Racmacs__acmap_point__h
#define Racmacs__acmap_point__h

// Define the generic point class
class AcPoint {

  protected:

    // Regular details
    std::string type;
    std::string name;
    std::string extra;
    std::string date;
    bool reference = false;
    std::string id = "";
    int group = 0;
    std::string sequence;
    std::vector<SeqInsertion> sequence_insertions;
    std::string passage;
    std::string species;
    std::vector<std::string> clade;
    std::vector<std::string> annotations;
    std::vector<std::string> labids;
    std::string lineage;
    std::string reassortant;
    std::string strings;
    std::string continent;
    std::string nucleotidesequence;

  public:

    // Plotspec details
    AcPlotspec plotspec;

    // Public attributes
    arma::uvec homologous_ags;

    // Regular details
    std::string get_type() const;
    std::string get_name() const;
    std::string get_extra() const;
    std::string get_date() const;
    bool get_reference() const;
    std::string get_passage() const;
    std::string get_id() const;
    std::string get_species() const;
    int get_group() const;
    std::string get_sequence() const;
    std::vector<SeqInsertion> get_sequence_insertions() const;
    std::vector<std::string> get_clade() const;
    std::vector<std::string> get_annotations() const;
    std::vector<std::string> get_labids() const;
    std::string get_lineage() const;
    std::string get_reassortant() const;
    std::string get_strings() const;
    std::string get_continent() const;
    std::string get_nucleotidesequence() const;

    void set_type( std::string value );
    void set_name( std::string value );
    void set_extra( std::string value );
    void set_date( std::string value );
    void set_reference( bool value );
    void set_passage( std::string value );
    void set_id( std::string value );
    void set_species( std::string value );
    void set_group( int value );
    void set_sequence( std::string value );
    void set_sequence_insertions( std::vector<SeqInsertion> );
    void set_clade( std::vector<std::string> value );
    void set_annotations( std::vector<std::string> value );
    void set_labids( std::vector<std::string> value );
    void set_lineage( std::string value );
    void set_reassortant( std::string value );
    void set_strings( std::string value );
    void set_continent( std::string value );
    void set_nucleotidesequence( std::string value );

    // Get IDs for matching
    std::string get_match_id() const;

    // Check if values are defaults
    bool isdefault(std::string attribute);

};

// Define the antigen class
class AcAntigen: public AcPoint {

  public:
    AcAntigen();

};

// Define the sera class
class AcSerum: public AcPoint {

  public:
    AcSerum();

    arma::uvec get_homologous_ags() const;
    void set_homologous_ags( arma::uvec value );

};

#endif
