
# include <RcppArmadillo.h>
# include "acmap_map.h"
# include "acmap_titers.h"
# include "ac_titers.h"
# include "ac_matching.h"

// For merging character titers
// [[Rcpp::export]]
AcTiter ac_merge_titers(
    std::vector<AcTiter> titers,
    double sd_lim
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


// Check if point already in points
template <typename T>
bool pt_in_points(
    T const& pt,
    std::vector<T> const& pts
){

  for(auto &ptspt : pts){
    if(ptspt.get_id() == pt.get_id()){
      return true;
    }
  }
  return false;

}


// Construct another titer table based on a subset of indices
AcTiterTable subset_titer_table(
  AcTiterTable titer_table,
  arma::ivec agsubset,
  arma::ivec srsubset
){

  AcTiterTable titer_table_subset(
    agsubset.n_elem,
    srsubset.n_elem
  );

  for(arma::uword ag=0; ag<agsubset.n_elem; ag++){
    for(arma::uword sr=0; sr<srsubset.n_elem; sr++){
      if(agsubset(ag) != -1 && srsubset(sr) != -1){
        titer_table_subset.set_titer(
          ag, sr,
          titer_table.get_titer(
            agsubset(ag),
            srsubset(sr)
          )
        );
      }
    }
  }

  return titer_table_subset;

}

// [[Rcpp::export]]
AcMap ac_merge_map_tables(
  std::vector<AcMap> maps
){

  // Setup for output
  std::vector<AcAntigen> merged_antigens;
  std::vector<AcSerum> merged_sera;
  std::vector<AcTiterTable> merged_layers;

  // Add antigens and sera
  for(arma::uword i=0; i<maps.size(); i++){

    for(arma::uword ag=0; ag<maps[i].antigens.size(); ag++){
      if(!pt_in_points(maps[i].antigens[ag], merged_antigens)){
        merged_antigens.push_back(maps[i].antigens[ag]);
      }
    }

    for(arma::uword sr=0; sr<maps[i].sera.size(); sr++){
      if(!pt_in_points(maps[i].sera[sr], merged_sera)){
        merged_sera.push_back(maps[i].sera[sr]);
      }
    }

  }

  // Add titer table layers
  for(arma::uword i=0; i<maps.size(); i++){

    arma::ivec merged_map_ag_matches = ac_match_points(merged_antigens, maps[i].antigens);
    arma::ivec merged_map_sr_matches = ac_match_points(merged_sera, maps[i].sera);

    std::vector<AcTiterTable> titer_table_layers = maps[i].get_titer_table_layers();

    for(arma::uword layer=0; layer<titer_table_layers.size(); layer++){
      merged_layers.push_back(
        subset_titer_table(
          titer_table_layers[layer],
          merged_map_ag_matches,
          merged_map_sr_matches
        )
      );
    }

  }

  // Create the map
  AcMap merged_map = AcMap(
    merged_antigens.size(),
    merged_sera.size()
  );

  merged_map.antigens = merged_antigens;
  merged_map.sera = merged_sera;
  merged_map.set_titer_table_layers(
    merged_layers
  );

  return merged_map;

}

