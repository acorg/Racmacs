
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


// Define a row of ag titers
class AcTiterRow {

  private:
    std::vector <AcTiter> titers;

  public:
    AcTiterRow(
      int num_sr
    ){
      titers = std::vector<AcTiter>(num_sr);
    }

    AcTiter operator[](
      int sr_num
    ){
      return titers[sr_num];
    }

    void remove_serum(
      int sr_num
    ){
      titers.erase(titers.begin()+sr_num);
    }

    void subset_sera(
      arma::uvec sr
    ){
      std::vector<AcTiter> new_titers(sr.size());
      for(int i=0; i<sr.size(); i++){
        new_titers[i] = titers[sr[i]];
      }
      titers.swap(new_titers);
    }

};


// Define the titertable class
class AcTiterTable {

  private:
    int num_ags;
    int num_sr;
    std::vector <AcTiterRow> titer_rows;

  public:

    // Constructor
    AcTiterTable(
      int nags,
      int nsr
    ):
      titer_rows(nsr, nags){

      // Initiate titer table
      num_ags = nags;
      num_sr = nsr;

    };

    // Get dimensions
    int nags() const { return num_ags; }
    int nsr() const { return num_sr; }

    // Get a given titer
    AcTiter get_titer(
        int agnum,
        int srnum
    ) const {

      AcTiterRow titer_row = titer_rows[agnum];
      return titer_row[srnum];

    }

    // Set a given titer
    void set_titer(
        int agnum,
        int srnum,
        AcTiter titer
    ){

      // Error if out of range
      if(agnum >= num_ags || srnum >= num_sr || agnum < 0 || srnum < 0){
        Rcpp::stop("Titer selection out of range");
      }

      // Set the titer
      titer_rows[agnum][srnum] = titer;

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
      titer_rows.erase(
        titer_rows.begin() + agnum
      );
    }

    // Remove a serum
    void remove_serum(
      int srnum
    ){
      for(int i=0; i<num_ags; i++){
        titer_rows[i].remove_serum(srnum);
      }
    }

    // Subsetting
    void subset_antigens(
      arma::uvec ags
    ){

      std::vector<AcTiterRow> new_titer_rows(ags.size(), nsr());
      for(int i=0; i<ags.size(); i++){
        new_titer_rows[i] = titer_rows[ags[i]];
      }
      titer_rows.swap(new_titer_rows);

    }

    void subset_sera(
        arma::uvec sr
    ){

      for(int i=0; i<titer_rows.size(); i++){
        titer_rows[i].subset_sera(sr);
      }

    }

    void subset(
        arma::uvec ags,
        arma::uvec sr
    ){

      subset_antigens(ags);
      subset_sera(sr);

    }

};

#endif


