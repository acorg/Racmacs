
#include <RcppArmadillo.h>
#include "acmap_map.h"

template <typename T>
arma::ivec ac_match_points(
  T const& points1,
  T const& points2
){

  arma::ivec matches(points1.size());
  matches.fill(-1);

  for(arma::uword i=0; i<points1.size(); i++){
    for(arma::uword j=0; j<points2.size(); j++){

      std::string id1 = points1[i].get_match_id();
      std::string id2 = points2[j].get_match_id();

      if(id1 == id2){
        // Check we are replacing a -1 value
        if(matches(i) == -1){
          matches(i) = j;
        }
        // Otherwise throw an error
        else {
          Rcpp::stop("Multiple matches found for '"+id2+"'");
        }
      }

    }
  }
  return matches;

}

// [[Rcpp::export]]
arma::ivec ac_match_map_ags(
    AcMap const& map1,
    AcMap const& map2
){
  return ac_match_points( map1.antigens, map2.antigens );
}

// [[Rcpp::export]]
arma::ivec ac_match_map_sr(
    AcMap const& map1,
    AcMap const& map2
){
  return ac_match_points( map1.sera, map2.sera );
}
