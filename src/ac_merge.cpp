
# include <RcppArmadillo.h>
# include "acmap_titers.h"
# include "ac_titers.h"

// For merging character titers
//' @export
// [[Rcpp::export]]
AcTiter ac_merge_titers(
    std::vector<AcTiter> titers,
    double sd_lim = 1.0
){

  // Return the titer if size 1
  if(titers.size() == 1){
    return titers[0];
  }

  // Get vectors of numeric titers and titer types
  arma::vec numtiters = numeric_titers(titers);
  arma::uvec ttypes = titer_types_int(titers);
  arma::uvec nona = arma::find(ttypes != 0);

  // 1. If there are > and < titers, result is *
  if(arma::any(ttypes == 2) && arma::any(ttypes == 3)){
    return AcTiter();
  } else
    // 2. If there are just *, result is *
    if(arma::all(ttypes == 0)){
      return AcTiter();
    } else
      // 3. If there are just lessthan titers, result is min of them, keeping lessthan
      if(arma::all(ttypes.elem(nona) == 2)){
        return AcTiter(
          arma::min(numtiters),
          2
        );
      } else
        // 4. If there are just morethan titers, result is max of them, keeping morethan
        if(arma::all(ttypes.elem(nona) == 3)){
          return AcTiter(
            arma::max(numtiters),
            3
          );
        } else {

          // 5. Convert > and < titers to their next values, i.e. <40 to 20, >10240 to 20480, etc. and take the log
          arma::vec logtiters = log_titers(titers);

          // 6. Compute SD, if SD > 1, result is *
          if(sd_lim == sd_lim && arma::stddev(logtiters.elem(nona)) > sd_lim){
            return AcTiter();
          }
          // 7. Otherwise return the mean (ignoring nas)
          else{
            return AcTiter(
              std::pow(2.0, arma::mean(logtiters.elem(nona)))*10,
              1
            );
          }
        }

}

// For merging titer layers
//' @export
// [[Rcpp::export]]
AcTiterTable ac_merge_titer_layers(
    std::vector<AcTiterTable> titer_layers
){

  int num_ags = titer_layers[0].nags();
  int num_sr  = titer_layers[0].nsr();
  int num_layers = titer_layers.size();

  AcTiterTable merged_table = AcTiterTable(
    num_ags,
    num_sr
  );

  std::vector<AcTiter> titers(num_layers, AcTiter());

  for(int ag=0; ag<num_ags; ag++){
    for(int sr=0; sr<num_sr; sr++){
      for(int i=0; i<num_layers; i++){
        titers[i] = titer_layers[i].get_titer(ag,sr);
      }
      merged_table.set_titer(
        ag, sr,
        ac_merge_titers(
          titers
        )
      );
    }
  }

  return merged_table;

}
