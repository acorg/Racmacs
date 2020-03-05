#include <Rcpp.h>
#include <string>
using namespace Rcpp;

// [[Rcpp::export]]
Rcpp::List convert2logCpp(StringMatrix titers) {

  int nrow = titers.nrow();
  int ncol = titers.ncol();
  int nsize = nrow*ncol;

  CharacterMatrix titer_type(nrow, ncol);
  NumericMatrix   log_titers(nrow, ncol);

  for(int i=0; i<nsize; i++){

    // Get the titer
    std::string titer = as<std::string>(titers[i]);
    double log_titer;

    // Do the conversion
    if(titer == "NA" || titer.substr(0,1) == "*"){

      log_titers[i] = NA_REAL;
      titer_type[i] = NA_STRING;

    } else if(titer.substr(0,1) == "<"){

      titer.erase(0,1);
      log_titer = log2(std::stod(titer)/10)-1;
      log_titers[i] = log_titer;
      titer_type[i] = "lessthan";

    } else if(titer.substr(0,1) == ">"){

      titer.erase(0,1);
      log_titer = log2(std::stod(titer)/10)+1;
      log_titers[i] = log_titer;
      titer_type[i] = "morethan";

    } else {

      log_titer = log2(std::stod(titer)/10);
      log_titers[i] = log_titer;
      titer_type[i] = "disc";

    }

  }

  // Return a list of matrices
  return Rcpp::List::create(
    Rcpp::Named("log_titers") = log_titers,
    Rcpp::Named("titer_type") = titer_type
  );

}



