
#include <RcppArmadillo.h>

#ifndef Racmacs__acmap_titers__h
#define Racmacs__acmap_titers__h

// For converting from numeric to string titers
class AcTiter {

  public:
    double numeric;
    int type;

    AcTiter();
    AcTiter(
      double numeric_titer,
      int titer_type
    );

    AcTiter(
      double numeric_titer
    );

    AcTiter(
      std::string titer
    );

    // Conversion back to a string
    std::string toString() const;

    // Conversion to log titer
    double logTiter(
        double dilution_stepsize
    );

    // Round the titer
    void roundTiter();

};


// Define the titertable class
class AcTiterTable {

  private:
    // The titers are stored as a matrix of numeric forms and one of titer types
    // Types:
    // 0 = not measured
    // 1 = measured detectable e.g. "40"
    // 2 = measured lessthan e.g. "<10"
    // 3 = measured morethan e.g. ">1280"
    arma::mat numeric_titers;
    arma::imat titer_types;

  public:

    // Constructor
    AcTiterTable(
      int nags,
      int nsr
    );

    // Get dimensions
    arma::uword nags() const;
    arma::uword nsr() const;
    arma::SizeMat size() const;

    // Get and set numeric_titers and titer types
    arma::mat get_numeric_titers() const;
    void set_numeric_titers(arma::mat numeric_titers_in);

    arma::imat get_titer_types() const;
    void set_titer_types(arma::imat titer_types_in);

    // Get a given titer
    AcTiter get_titer(
        int agnum,
        int srnum
    ) const;

    // Set a given titer
    void set_titer(
        arma::uword agnum,
        arma::uword srnum,
        AcTiter titer
    );

    // Getting and setting by string
    std::string get_titer_string(
      arma::uword agnum,
      arma::uword srnum
    ) const;

    void set_titer_string(
      arma::uword agnum,
      arma::uword srnum,
      std::string titerstring
    );

    void set_titer_double(
        arma::uword agnum,
        arma::uword srnum,
        double titerdouble
    );

    // Get vector of titers for a given antigen
    std::vector<AcTiter> agTiters(
      arma::uword agnum
    );

    // Get vector of titers for a given serum
    std::vector<AcTiter> srTiters(
        arma::uword srnum
    );

    // Remove an antigen
    void remove_antigen(
      arma::uword agnum
    );

    // Remove a serum
    void remove_serum(
      arma::uword srnum
    );

    // Subsetting
    void subset_antigens(
      arma::uvec ags
    );

    void subset_sera(
        arma::uvec sr
    );

    void subset(
        arma::uvec ags,
        arma::uvec sr
    );

    // Counting titers
    int num_measured() const;
    int num_unmeasured() const;

    // Check if a titer is measured
    bool titer_measured(
      const int& ag,
      const int& sr
    ) const;

    // Setting unmeasured titers
    void set_unmeasured(
        arma::uvec indices
    );

    // Getting indices of titers
    arma::uvec vec_indices_measured(
    ) const;

    // Calculate column bases
    arma::vec calc_colbases(
        const std::string &min_colbasis,
        const arma::vec &fixed_colbases,
        const arma::vec &ag_reactivity_adjustments
    ) const;

    // Calculate table distances
    arma::mat numeric_table_distances(
      const std::string &minimum_col_basis,
      const arma::vec &fixed_colbases,
      const arma::vec &ag_reactivity_adjustments
    ) const;

    // Add log titers to the titer table
    void add_log_titers(
      arma::mat log_titers_to_add
    );

    // Round the titers
    void roundTiters();

};

#endif


