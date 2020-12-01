
# include <RcppArmadillo.h>

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
    int nags() const { return numeric_titers.n_rows; }
    int nsr() const { return numeric_titers.n_cols; }

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
        int agnum,
        int srnum,
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
      int agnum,
      int srnum
    ) const {

      AcTiter titer = get_titer(agnum, srnum);
      return titer.toString();

    }

    void set_titer_string(
      int agnum,
      int srnum,
      std::string titerstring
    ){

      AcTiter titer = AcTiter(titerstring);
      set_titer(agnum, srnum, titer);

    }

    void set_titer_double(
        int agnum,
        int srnum,
        double titerdouble
    ){

      AcTiter titer = AcTiter(titerdouble);
      set_titer(agnum, srnum, titer);

    }

    // Get vector of titers for a given antigen
    std::vector<AcTiter> agTiters(
        int agnum
    ){

      const int num_sr = nsr();
      std::vector<AcTiter> ag_titers(num_sr);
      for(int srnum=0; srnum<num_sr; srnum++){
        ag_titers[srnum] = get_titer(agnum, srnum);
      }
      return ag_titers;
    }

    // Get vector of titers for a given serum
    std::vector<AcTiter> srTiters(
      int srnum
    ){

      const int num_ags = nags();
      std::vector<AcTiter> sr_titers(num_ags);
      for(int agnum=0; agnum<num_ags; agnum++){
        sr_titers[agnum] = get_titer(agnum, srnum);
      }
      return sr_titers;
    }

    // Remove an antigen
    void remove_antigen(
      int agnum
    ){
      numeric_titers.shed_row(agnum);
      titer_types.shed_row(agnum);
    }

    // Remove a serum
    void remove_serum(
      int srnum
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

};

#endif


