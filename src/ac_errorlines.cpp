
# include <RcppArmadillo.h>
# include "ac_errorlines.h"
# include "acmap_map.h"
# include "ac_optim_map_stress.h"

// For merging character titers
// [[Rcpp::export]]
ErrorLineData ac_errorline_data(const AcMap& map){

  // Work out number of lines
  int nlines = map.titer_table_flat.num_measured() * 2;

  // Setup output
  struct ErrorLineData errorlines{
    arma::vec(nlines),
    arma::vec(nlines),
    arma::vec(nlines),
    arma::vec(nlines),
    arma::uvec(nlines)
  };

  // Fetch relevant parameters
  arma::mat residual_table = ac_point_residuals(map, 0);
  arma::mat ag_coords = map.optimizations.at(0).agCoords();
  arma::mat sr_coords = map.optimizations.at(0).srCoords();
  
  // Calculate error lines
  arma::uword n = 0;
  arma::uword num_antigens = map.antigens.size();
  arma::uword num_sera = map.sera.size();

  for (arma::uword ag = 0; ag < num_antigens; ag++) {
    for (arma::uword sr = 0; sr < num_sera; sr++) {

      // Fetch variables
      arma::rowvec from = ag_coords.row(ag);
      arma::rowvec to = sr_coords.row(sr);
      double residual = residual_table(ag, sr);

      if (map.titer_table_flat.get_titer(ag, sr).type > 0) {

        // Calculate the unit vector
        arma::rowvec vec = to - from;
        vec = vec / std::sqrt(arma::accu(arma::square(vec)));

        // Get color
        arma::uword linecol;
        if (residual > 0) linecol = 0;
        else              linecol = 1;

        arma::rowvec from_end = from + vec * (residual / 2);
        arma::rowvec to_end   = to - vec * (residual / 2);

        // Store result
        errorlines.x(n) = from(0);
        errorlines.y(n) = from(1);
        errorlines.xend(n) = from_end(0);
        errorlines.yend(n) = from_end(1);
        errorlines.color(n) = linecol;

        errorlines.x(n+1) = to(0);
        errorlines.y(n+1) = to(1);
        errorlines.xend(n+1) = to_end(0);
        errorlines.yend(n+1) = to_end(1);
        errorlines.color(n+1) = linecol;
        
        n++;
        n++;

      }

    }
  }

  // Return the error line data
  return(errorlines);

}
