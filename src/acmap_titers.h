
#include <RcppArmadillo.h>

#ifndef Racmacs__acmap_titers__h
#define Racmacs__acmap_titers__h

// For converting from numeric to string titers
class AcTiter {

  public:
    double numeric;
    int type;

    AcTiter(){
      numeric = 0;
      type = 0;
    }

    AcTiter(
      double numeric_titer,
      int titer_type
    ){
      numeric = numeric_titer;
      type = titer_type;
    }

    AcTiter(
      double numeric_titer
    ){
      numeric = numeric_titer;
      type = 1;
    }

    AcTiter(
      std::string titer
    ){

      switch(titer.at(0)){
        case '<':
          // Less than titer
          titer.erase(0,1);
          type = 2;
          numeric = std::stod(titer);
          break;
        case '>':
          // Greater than titer
          titer.erase(0,1);
          type = 3;
          numeric = std::stod(titer);
          break;
        case '*':
          // Non-detectable titer
          type = 0;
          numeric = arma::datum::nan;
          break;
        default:
          // Measurable titer
          type = 1;
          numeric = std::stod(titer);
      }

    }

    // Conversion back to a string
    std::string toString() const {

      // Get the titer as a string
      std::ostringstream ss;
      ss << numeric;
      std::string titer = ss.str();

      // Append lessthan signs etc depending on type
      switch(type) {
        case 1:
          // Measurable titer
          break;
        case 2:
          // Less than titer
          titer = "<"+titer;
          break;
        case 3:
          // More than titer
          titer = ">"+titer;
          break;
        default:
          // Missing titer
          titer = "*";
      }

      // Return the titer
      return titer;

    }

    // Conversion to log titer
    double logTiter(){
      switch(type){
      case 1:
        return std::log2(numeric/10.0);
        break;
      case 2:
        return std::log2(numeric/10.0)-1;
        break;
      case 3:
        return std::log2(numeric/10.0)+1;
        break;
      default:
        return arma::datum::nan;
      }
    }

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
    arma::umat titer_types;

  public:

    // Constructor
    AcTiterTable(
      int nags,
      int nsr
    ):
      numeric_titers(nags, nsr, arma::fill::zeros),
      titer_types(nags, nsr, arma::fill::zeros){};

    // Get dimensions
    arma::uword nags() const { return numeric_titers.n_rows; }
    arma::uword nsr() const { return numeric_titers.n_cols; }
    arma::SizeMat size() const { return arma::size(numeric_titers); }

    // Get and set numeric_titers and titer types
    arma::mat get_numeric_titers() const { return numeric_titers; }
    void set_numeric_titers(arma::mat numeric_titers_in){ numeric_titers = numeric_titers_in; }

    arma::umat get_titer_types() const { return titer_types; }
    void set_titer_types(arma::umat titer_types_in){ titer_types = titer_types_in; }

    // Get a given titer
    AcTiter get_titer(
        int agnum,
        int srnum
    ) const {

      return AcTiter(
        numeric_titers(agnum, srnum),
        titer_types(agnum, srnum)
      );

    }

    // Set a given titer
    void set_titer(
        arma::uword agnum,
        arma::uword srnum,
        AcTiter titer
    ){

      // Error if out of range
      if(agnum >= nags() || srnum >= nsr() || agnum < 0 || srnum < 0){
        Rcpp::stop("Titer selection out of range");
      }

      // Set the titer
      numeric_titers(agnum, srnum) = titer.numeric;
      titer_types(agnum, srnum) = titer.type;

    }

    // Getting and setting by string
    std::string get_titer_string(
      arma::uword agnum,
      arma::uword srnum
    ) const {

      AcTiter titer = get_titer(agnum, srnum);
      return titer.toString();

    }

    void set_titer_string(
      arma::uword agnum,
      arma::uword srnum,
      std::string titerstring
    ){

      AcTiter titer = AcTiter(titerstring);
      set_titer(agnum, srnum, titer);

    }

    void set_titer_double(
        arma::uword agnum,
        arma::uword srnum,
        double titerdouble
    ){

      AcTiter titer = AcTiter(titerdouble);
      set_titer(agnum, srnum, titer);

    }

    // Get vector of titers for a given antigen
    std::vector<AcTiter> agTiters(
      arma::uword agnum
    ){

      const arma::uword num_sr = nsr();
      std::vector<AcTiter> ag_titers(num_sr);
      for(arma::uword srnum=0; srnum<num_sr; srnum++){
        ag_titers[srnum] = get_titer(agnum, srnum);
      }
      return ag_titers;
    }

    // Get vector of titers for a given serum
    std::vector<AcTiter> srTiters(
        arma::uword srnum
    ){

      const arma::uword num_ags = nags();
      std::vector<AcTiter> sr_titers(num_ags);
      for(arma::uword agnum=0; agnum<num_ags; agnum++){
        sr_titers[agnum] = get_titer(agnum, srnum);
      }
      return sr_titers;
    }

    // Remove an antigen
    void remove_antigen(
      arma::uword agnum
    ){
      numeric_titers.shed_row(agnum);
      titer_types.shed_row(agnum);
    }

    // Remove a serum
    void remove_serum(
      arma::uword srnum
    ){
      numeric_titers.shed_col(srnum);
      titer_types.shed_col(srnum);
    }

    // Subsetting
    void subset_antigens(
      arma::uvec ags
    ){

      numeric_titers = numeric_titers.rows(ags);
      titer_types = titer_types.rows(ags);

    }

    void subset_sera(
        arma::uvec sr
    ){

      numeric_titers = numeric_titers.cols(sr);
      titer_types = titer_types.cols(sr);

    }

    void subset(
        arma::uvec ags,
        arma::uvec sr
    ){

      numeric_titers = numeric_titers.submat(ags, sr);
      titer_types = titer_types.submat(ags, sr);

    }

    // Counting titers
    int num_measured(
    ) const {
      return arma::accu(titer_types == 1);
    }

    int num_unmeasured(
    ) const {
      return arma::accu(titer_types == 0);
    }

    // Check if a titer is measured
    bool titer_measured(
      const int& ag,
      const int& sr
    ) const {
      return titer_types(ag, sr) != 0;
    }

    // Setting unmeasured titers
    void set_unmeasured(
        arma::uvec indices
    ){
      titer_types.elem(indices).zeros();
      numeric_titers.elem(indices).zeros();
    }

    // Getting indices of titers
    arma::uvec vec_indices_measured(
    ) const {

      int n_measured = arma::accu(titer_types != 0);
      arma::uvec indices(n_measured);

      int vec_i = 0;
      for(arma::uword i=0; i<titer_types.n_elem; i++){
          if(titer_types(i) != 0){
            indices(vec_i) = i;
            vec_i++;
          }
      }

      return indices;

    }

    // Calculate column bases
    arma::vec calc_colbases(
        const std::string &min_colbasis,
        const arma::vec &fixed_colbases,
        const arma::vec &ag_reactivity_adjustments
    ) const {

      // Check input
      if(fixed_colbases.n_elem != nsr()) Rf_error("fixed_colbases does not match number of sera");
      if(ag_reactivity_adjustments.n_elem != nags()) Rf_error("ag_reactivity_adjustments does not match number of antigens");
      if(arma::accu(titer_types) == 0) return fixed_colbases;

      // Get log titers
      arma::mat num_titers = numeric_titers;
      arma::mat log_titers = arma::log2(num_titers / 10.0);

      // Apply antigen reactivity adjustments
      log_titers.each_col() += ag_reactivity_adjustments;

      // Calculate column bases
      log_titers.replace(arma::datum::nan, log_titers.min());
      arma::vec colbases = arma::max(log_titers.t(), 1);

      // Apply any minimum column bases
      if(min_colbasis != "none"){
        colbases = arma::clamp(
          colbases,
          AcTiter(min_colbasis).logTiter(),
          colbases.max()
        );
      }

      // Apply any fixed column bases
      if(fixed_colbases.size() > 0){
        if(fixed_colbases.size() != colbases.n_elem){
          Rcpp::stop("Length of fixed column bases does not match the length of the column bases");
        }
        arma::uvec nonan = arma::find_finite(fixed_colbases);
        colbases.elem( nonan ) = fixed_colbases.elem( nonan );
      }

      // Return the column bases
      return colbases;

    }

    // Calculate table distances
    arma::mat numeric_table_distances(
      const std::string &minimum_col_basis,
      const arma::vec &fixed_colbases,
      const arma::vec &ag_reactivity_adjustments
    ) const {

      // Calculate column bases
      arma::vec colbases = calc_colbases(
        minimum_col_basis,
        fixed_colbases,
        ag_reactivity_adjustments
      );

      // Set distances as log titers
      arma::mat dists = arma::log2(numeric_titers / 10.0);

      // Apply antigen reactivity adjustments
      dists.each_col() += ag_reactivity_adjustments;

      // Subtract each log titer row from colbases to arrive at distance
      for(arma::uword i=0; i<dists.n_rows; i++){
        dists.row(i) = colbases.as_row() - dists.row(i);
      }

      // Do not allow distances < 0
      // if (std::isfinite(dists.max())) {
      //   dists = arma::clamp(dists, 0, dists.max());
      // }

      // Replace na titers with na dists
      dists.elem( arma::find(titer_types == 0) ).fill( arma::datum::nan );

      // Return distance matrix
      return dists;

    }

    // Add log titers to the titer table
    void add_log_titers(
      arma::mat log_titers_to_add
    ){

      arma::mat logtiters = arma::log2(numeric_titers / 10.0);
      logtiters += log_titers_to_add;
      numeric_titers = arma::exp2(logtiters)*10.0;

    }

};

#endif


