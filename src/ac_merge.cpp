
# include <RcppArmadillo.h>
# include "ac_optim_map_stress.h"
# include "ac_merge.h"
# include "ac_titers.h"
# include "ac_matching.h"
# include "ac_optimization.h"

// For merging character titers
// [[Rcpp::export]]
AcTiter ac_merge_titers(
    const std::vector<AcTiter>& titers,
    const AcMergeOptions& options
){

  // Use the user specified merge function if applicable
  if (options.method == "function") {

    // Convert AcTiter vector to Rcpp Character vector
    Rcpp::CharacterVector character_titers(titers.size());
    for (arma::uword i=0; i<titers.size(); i++) { character_titers[i] = titers[i].toString(); }

    // Pass to the function and recast output as AcTiter
    try {
      return(AcTiter(Rcpp::as<std::string>(options.merge_function(character_titers))));
    } catch(std::exception &ex) {
      std::string exstr = ex.what();
      ac_error("Could not parse results from user-defined titer merge function, error was '" + exstr + "'");
    } catch(...) {
      ac_error("Could not parse results from user-defined titer merge function");
    }

  }

  // Return the titer if size 1
  if (titers.size() == 1) {
    return titers[0];
  }

  // Get vectors of numeric titers and titer types
  arma::vec numtiters = numeric_titers(titers);
  arma::ivec ttypes = titer_types_int(titers);
  arma::uvec nona = arma::find(ttypes > 0);

  // 1. If there are > and < titers, result is "*"
  if (arma::any(ttypes == 2) && arma::any(ttypes == 3)) {

    return AcTiter();

  } else
  // 2a. If there are just ".", result is "."
  if (arma::all(ttypes == -1)) {

    return AcTiter(0, -1);

  } else
  // 2. If there are just "*" or ".", result is "*"
  if (arma::all(ttypes <= 0)) {

    return AcTiter();

  } else
  // 3. If there are just lessthan titers, result is min of them, keeping lessthan
  if (arma::all(ttypes.elem(nona) == 2)) {

    return AcTiter(
      arma::min(numtiters),
      2 // Less than type
    );

  } else
  // 4. If there are just morethan titers, result is max of them, keeping morethan
  if (arma::all(ttypes.elem(nona) == 3)) {

    return AcTiter(
      arma::max(numtiters),
      3 // More than type
    );

  } else {

    // 5. Convert > and < titers to their next values, i.e. <40 to 20, >10240 to 20480, etc. and take the log
    arma::vec logtiters = log_titers(titers, options.dilution_stepsize);

    // 6. Compute SD, if SD > options.sd_limit, result is *, otherwise return the mean
    if (
      options.sd_limit == options.sd_limit && // Check sd_limit not set to NA
      arma::stddev(logtiters.elem(nona), options.method == "lispmds") > options.sd_limit
    ) {

      return AcTiter();

    } else {

      // Special case for conservative / lispmds method
      // If there is a mix of < values and others then return convert to log and return the largest less than
      if (options.method != "likelihood" && arma::any(ttypes == 2)) {

        return AcTiter(
          std::pow(2.0, arma::max(logtiters.elem(nona)) + options.dilution_stepsize)*10,
          2 // Set lessthan type
        );

      }

      return AcTiter(
        std::pow(2.0, arma::mean(logtiters.elem(nona)))*10,
        1 // Set measurable type
      );

    }

  }

}

// For merging titer layers
// [[Rcpp::export]]
AcTiterTable ac_merge_titer_layers(
    const std::vector<AcTiterTable>& titer_layers,
    const AcMergeOptions& options
){

  int num_ags = titer_layers.at(0).nags();
  int num_sr  = titer_layers.at(0).nsr();
  int num_layers = titer_layers.size();

  AcTiterTable merged_table = AcTiterTable(
    num_ags,
    num_sr
  );

  std::vector<AcTiter> titers(num_layers, AcTiter());

  for(int ag=0; ag<num_ags; ag++){
    for(int sr=0; sr<num_sr; sr++){
      for(int i=0; i<num_layers; i++){
        titers[i] = titer_layers.at(i).get_titer(ag,sr);
      }
      merged_table.set_titer(
        ag, sr,
        ac_merge_titers(
          titers,
          options
        )
      );
    }
  }

  return merged_table;

}


// Check if point already in points
template <typename T>
int pt_match(
    const T& pt,
    const std::vector<T>& pts
){

  for (arma::uword i=0; i<pts.size(); i++) {
    if (pts[i].get_match_id() == pt.get_match_id()) {
      return i;
    }
  }
  return -1;

}


// Construct another titer table based on a subset of indices
AcTiterTable subset_titer_table(
  const AcTiterTable& titer_table,
  const arma::ivec& agsubset,
  const arma::ivec& srsubset
){

  AcTiterTable titer_table_subset(
    agsubset.n_elem,
    srsubset.n_elem
  );

  for (arma::uword ag=0; ag<agsubset.n_elem; ag++) {
    for (arma::uword sr=0; sr<srsubset.n_elem; sr++) {
      if (agsubset(ag) != -1 && srsubset(sr) != -1) {
        titer_table_subset.set_titer(
          ag, sr,
          titer_table.get_titer(
            agsubset(ag),
            srsubset(sr)
          )
        );
      } else {
        titer_table_subset.set_titer(
          ag, sr,
          AcTiter(".")
        );
      }
    }
  }

  return titer_table_subset;

}


// Helper function for merging coordinates
template <typename T>
arma::mat merge_matching_pt_coords(
    const std::vector<T>& merged_points,
    const std::vector<T>& points1,
    const std::vector<T>& points2,
    const arma::mat& coords1,
    const arma::mat& coords2
){

  // Check input
  if(coords1.n_cols != coords2.n_cols){
    Rf_error("Dimensions do not match");
  }

  // Create the merged coords
  arma::mat merged_coords( merged_points.size(), coords1.n_cols );

  // Get point matches
  arma::ivec matches1 = ac_match_points(merged_points, points1);
  arma::ivec matches2 = ac_match_points(merged_points, points2);

  // Set coordinates
  for(arma::uword i=0; i<merged_points.size(); i++){
    if(matches1(i) > -1 && matches2(i) > -1){
      // Both match
      merged_coords.row(i) = (coords1.row(matches1(i)) + coords2.row(matches2(i))) / 2;
    } else if(matches1(i) > -1){
      // 1 matches
      merged_coords.row(i) = coords1.row(matches1(i));
    } else if(matches2(i) > -1){
      // 2 matches
      merged_coords.row(i) = coords2.row(matches2(i));
    } else {
      // No matches
      Rf_error("No matches");
    }
  }

  // Return the averaged coordinates
  return merged_coords;

}

// Merging min column basis
std::string merge_min_column_basis(
    const std::vector<AcMap>& maps
){

  std::string min_col_basis = maps[0].optimizations.at(0).get_min_column_basis();
  for(arma::uword i=1; i<maps.size(); i++){
    if(min_col_basis != maps[i].optimizations.at(0).get_min_column_basis()){
      Rcpp::Rcerr << "\nMinimum column basis of merged maps do not match, they will be taken from the first map";
    }
  }
  return min_col_basis;

}


// Merging fixed column bases
arma::vec merge_fixed_column_bases(
    const std::vector<AcMap>& maps,
    const std::vector<AcSerum>& merged_sera
){

  // Create the merged column bases
  arma::vec merged_fixed_colbases( merged_sera.size() );
  merged_fixed_colbases.fill( arma::datum::nan );

  // Fetch column bases from maps
  for(arma::uword i=0; i<maps.size(); i++){

    arma::ivec matches = ac_match_points( maps[i].sera, merged_sera );
    for(arma::uword j=0; j<matches.n_elem; j++){

      double merged_colbase = merged_fixed_colbases( matches(j) );
      double map_colbase = maps[i].optimizations.at(0).get_fixed_column_bases(j);

      if(std::isfinite(merged_colbase) && merged_colbase != map_colbase){
        // Warn if different fixed column bases used
        Rcpp::Rcerr << "\nFixed column basis of merged maps do not match, they will be taken from the first map";
      } else {
        // Otherwise apply the fixed column base to the merge
        merged_fixed_colbases( matches(j) ) = map_colbase;
      }

    }

  }

  // Return the fixed column basis
  return merged_fixed_colbases;

}


// Merging antigen reacitivity adjustments
arma::vec merge_ag_reactivity_adjustments(
    const std::vector<AcMap>& maps,
    const std::vector<AcAntigen>& merged_antigens
){

  // Create the merged column bases
  arma::vec merged_ag_reactivity_adjustments( merged_antigens.size() );
  merged_ag_reactivity_adjustments.fill( arma::datum::nan );

  // Fetch ag reactivity adjustments from maps
  for(arma::uword i=0; i<maps.size(); i++){

    arma::ivec matches = ac_match_points( maps[i].antigens, merged_antigens );
    for(arma::uword j=0; j<matches.n_elem; j++){

      double merged_ag_reactivity_adjustment = merged_ag_reactivity_adjustments( matches(j) );
      double map_ag_reactivity_adjustment = maps[i].get_ag_reactivity_adjustments(j);

      if(std::isfinite(merged_ag_reactivity_adjustment) && merged_ag_reactivity_adjustment != map_ag_reactivity_adjustment) {
        // Warn if different ag reactivity adjustments used
        Rcpp::Rcerr << "\nAntigen reactivity adjustments of merged maps do not match, they will be taken from the first map";
      } else {
        // Otherwise apply the fixed column base to the merge
        merged_ag_reactivity_adjustments( matches(j) ) = map_ag_reactivity_adjustment;
      }

    }

  }

  // Return the fixed column basis
  return merged_ag_reactivity_adjustments;

}



// == TABLE MERGE ======
// Just merge the map tables, any optimizations are lost. This function forms the basis
// for all of the other merging functions
// [[Rcpp::export]]
AcMap ac_merge_tables(
  std::vector<AcMap> maps,
  const AcMergeOptions& merge_options
){

  // Setup for output
  std::vector<AcAntigen> merged_antigens;
  std::vector<AcSerum> merged_sera;
  std::vector<AcTiterTable> merged_layers;

  // Record how each antigen and sera maps its index to the merged map
  std::vector<arma::uvec> mapped_ag_indices(maps.size());
  std::vector<arma::uvec> mapped_sr_indices(maps.size());

  // Add antigens and sera
  for(arma::uword i=0; i<maps.size(); i++){

    mapped_ag_indices[i].set_size(maps[i].antigens.size());
    mapped_sr_indices[i].set_size(maps[i].sera.size());

    for(arma::uword ag=0; ag<maps[i].antigens.size(); ag++){
      int match = pt_match(maps[i].antigens[ag], merged_antigens);
      if (match == -1){
        merged_antigens.push_back(maps[i].antigens[ag]);
        mapped_ag_indices[i][ag] = merged_antigens.size() - 1;
      } else {
        mapped_ag_indices[i][ag] = match;
      }
    }

    for(arma::uword sr=0; sr<maps[i].sera.size(); sr++){
      int match = pt_match(maps[i].sera[sr], merged_sera);
      if(match == -1){
        merged_sera.push_back(maps[i].sera[sr]);
        mapped_sr_indices[i][sr] = merged_sera.size() - 1;
      } else{
        mapped_sr_indices[i][sr] = match;
      }
    }

  }

  // Remap sera homologous antigens
  for (auto &serum : merged_sera) {
    serum.homologous_ags.clear();
  }

  for (arma::uword i=0; i<maps.size(); i++) {
    for (arma::uword sr=0; sr<maps[i].sera.size(); sr++) {
      for (arma::uword j=0; j<maps[i].sera[sr].homologous_ags.n_elem; j++) {
        uvec_push(
          merged_sera[mapped_sr_indices[i][sr]].homologous_ags,
          mapped_ag_indices[i][maps[i].sera[sr].homologous_ags[j]]
        );
      }
    }
  }

  for (auto &serum : merged_sera) {
    serum.homologous_ags = arma::unique(serum.homologous_ags);
  }

  // Add titer table layers
  std::vector<std::string> layer_map_names;
  for(arma::uword i=0; i<maps.size(); i++){

    arma::ivec merged_map_ag_matches = ac_match_points(merged_antigens, maps[i].antigens);
    arma::ivec merged_map_sr_matches = ac_match_points(merged_sera, maps[i].sera);

    std::vector<AcTiterTable> titer_table_layers = maps[i].get_titer_table_layers();

    for(arma::uword layer=0; layer<titer_table_layers.size(); layer++){
      layer_map_names.push_back(maps[i].name);
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

  // Set the titer table layers
  merged_map.titer_table_layers = merged_layers;

  // Set the flat titer table
  merged_map.titer_table_flat = ac_merge_titer_layers(
    merged_layers,
    merge_options
  );

  // Set titer table names
  merged_map.layer_names.resize( merged_map.titer_table_layers.size() );
  for (arma::uword i = 0; i < merged_map.titer_table_layers.size(); i++) {
    merged_map.layer_names[i] = layer_map_names[i];
  }

  // Return the merged map
  return merged_map;

}


// == REOPTIMIZED MERGE ======
// Merge the tables then run some fresh optimizations
// [[Rcpp::export]]
AcMap ac_merge_reoptimized(
  std::vector<AcMap> maps,
  int num_dims,
  int num_optimizations,
  std::string min_col_basis,
  AcOptimizerOptions optimizer_options,
  AcMergeOptions merge_options
){

  // Merge the map tables
  AcMap merged_map = ac_merge_tables(maps, merge_options);

  // Merge antigen reactivity adjustments
  arma::vec ag_reactivity_adjustments = merge_ag_reactivity_adjustments( maps, merged_map.antigens );

  // Run the optimizations
  merged_map.optimize(
    num_dims,
    num_optimizations,
    min_col_basis,
    arma::vec(merged_map.sera.size(), arma::fill::value(arma::datum::nan)),
    ag_reactivity_adjustments,
    optimizer_options
  );

  // Return the map
  return merged_map;

}


// == FROZEN OVERLAY MERGE ======
// This fixes the positions of points in each map and tries to best match them simply through re-orientation.
// Once the best re-orientation is found, points that are in common between the maps are moved to the average
// position.
// [[Rcpp::export]]
AcMap ac_merge_frozen_overlay(
  std::vector<AcMap> maps,
  const AcMergeOptions& merge_options
){

  // Check input
  if(maps.size() > 2){
    Rf_error("This type of merge only works with 2 maps");
  }
  if(maps[0].num_optimizations() == 0 || maps[1].num_optimizations() == 0){
    Rf_error("Map does not have any optimizations to merge");
  }

  // Merge the map tables
  AcMap merged_map = ac_merge_tables(maps, merge_options);

  // Orient map 2 to map 1
  maps[1].realign_to_map( maps[0] );

  // Create a fresh optimization
  AcOptimization opt(
    maps[0].optimizations.at(0).dim(),
    merged_map.antigens.size(),
    merged_map.sera.size()
  );

  // Merge coordinates
  opt.set_ag_base_coords(
    merge_matching_pt_coords(
      merged_map.antigens,
      maps[0].antigens,
      maps[1].antigens,
      maps[0].optimizations.at(0).agCoords(),
      maps[1].optimizations.at(0).agCoords()
    )
  );

  opt.set_sr_base_coords(
    merge_matching_pt_coords(
      merged_map.sera,
      maps[0].sera,
      maps[1].sera,
      maps[0].optimizations.at(0).srCoords(),
      maps[1].optimizations.at(0).srCoords()
    )
  );

  // Merge column bases
  opt.set_min_column_basis( merge_min_column_basis(maps) );
  opt.set_fixed_column_bases( merge_fixed_column_bases(maps, merged_map.sera) );

  // Merge antigen reactivity adjustments
  opt.set_ag_reactivity_adjustments( merge_ag_reactivity_adjustments( maps, merged_map.antigens ) );

  // Calculate stress
  opt.update_stress(
    merged_map.titer_table_flat,
    maps[0].dilution_stepsize
  );

  // Add optimization
  merged_map.optimizations.push_back( opt );

  // Return the map
  return merged_map;

}


// == RELAXED OVERLAY MERGE ======
// This is the same as the frozen-overlay but points in the resulting map are
// then allowed to relax.
// [[Rcpp::export]]
AcMap ac_merge_relaxed_overlay(
    std::vector<AcMap> maps,
    AcOptimizerOptions optimizer_options,
    AcMergeOptions merge_options
){

  // Do the frozen overlay
  AcMap merged_map = ac_merge_frozen_overlay(
    maps,
    merge_options
  );

  // Relax the optimization
  merged_map.optimizations.at(0).relax_from_titer_table(
    merged_map.titer_table_flat,
    optimizer_options
  );

  // Return the result
  return merged_map;

}


// == FROZEN MERGE ======
// In this version, positions of all points in the first map are fixed and
// remain fixed, so the original map does not change. The second map is then
// realigned to the first as closely as possible and then all the new points
// appearing in the second map are allowed to relax into their new positions.
// [[Rcpp::export]]
AcMap ac_merge_frozen_merge(
    std::vector<AcMap> maps,
    const AcOptimizerOptions& optimizer_options,
    const AcMergeOptions& merge_options
){

  // Start with a frozen merge
  AcMap merged_map = ac_merge_frozen_overlay(maps, merge_options);

  // Find matching points from map 1
  arma::uvec map1_ag_matches = arma::conv_to< arma::uvec >::from( ac_match_points(maps[0].antigens, merged_map.antigens) );
  arma::uvec map1_sr_matches = arma::conv_to< arma::uvec >::from( ac_match_points(maps[0].sera, merged_map.sera) );

  // Move the matching points back to their position in map 1, undoing any averaging
  // done by ac_merge_frozen_overlay
  merged_map.optimizations.at(0).set_ag_base_coords( map1_ag_matches, maps[0].optimizations.at(0).get_ag_base_coords() );
  merged_map.optimizations.at(0).set_sr_base_coords( map1_sr_matches, maps[0].optimizations.at(0).get_sr_base_coords() );

  // Now relax the map while fixing points in map 1
  merged_map.optimizations.at(0).relax_from_titer_table(
      merged_map.titer_table_flat,
      optimizer_options,
      map1_ag_matches, // Fixed antigens
      map1_sr_matches  // Fixed sera
  );

  // Return the map
  return merged_map;

}


// == INCREMENTAL MERGE ======
AcMap ac_merge_incremental_single(
    const std::vector<AcMap>& maps,
    int num_dims,
    int num_optimizations,
    std::string min_colbasis,
    const AcOptimizerOptions& optimizer_options,
    const AcMergeOptions& merge_options
){

  // Check input
  if(maps.size() != 2) Rf_error("Expecting 2 maps");

  // Merge the maps
  AcMap merged_map = ac_merge_tables(maps, merge_options);

  // Setup default fixed column bases
  arma::vec fixed_colbases = arma::vec( merged_map.sera.size() );
  fixed_colbases.fill( arma::datum::nan );

  // Setup default ag reactivity adjustments
  arma::vec ag_reactivity_adjustments = arma::vec(
    merged_map.antigens.size(),
    arma::fill::zeros
  );

  // Get table distance matrix and titer type matrix
  arma::mat tabledist_matrix = merged_map.titer_table_flat.numeric_table_distances(
    min_colbasis,
    fixed_colbases,
    ag_reactivity_adjustments
  );
  arma::imat titertype_matrix = merged_map.titer_table_flat.get_titer_types();

  // Generate optimizations with random starting coords
  std::vector<AcOptimization> optimizations = ac_generateOptimizations(
    tabledist_matrix,
    titertype_matrix,
    min_colbasis,
    fixed_colbases,
    ag_reactivity_adjustments,
    num_dims,
    num_optimizations,
    optimizer_options
  );

  // Set coordinates of points found in map 1 back to their positions in map1
  arma::uvec map1_ag_matches = arma::conv_to<arma::uvec>::from( ac_match_points(maps[0].antigens, merged_map.antigens) );
  arma::uvec map1_sr_matches = arma::conv_to<arma::uvec>::from( ac_match_points(maps[0].sera, merged_map.sera) );

  for(auto &optimization : optimizations){
    arma::mat ag_base_coords = optimization.get_ag_base_coords();
    arma::mat sr_base_coords = optimization.get_sr_base_coords();
    ag_base_coords.rows( map1_ag_matches ) = maps[0].optimizations.at(0).get_ag_base_coords();
    sr_base_coords.rows( map1_sr_matches ) = maps[0].optimizations.at(0).get_sr_base_coords();
    optimization.set_ag_base_coords( ag_base_coords );
    optimization.set_sr_base_coords( sr_base_coords );
  }

  // Relax the optimizations
  ac_relaxOptimizations(
    optimizations,
    optimizations.at(0).dim(),
    tabledist_matrix,
    titertype_matrix,
    optimizer_options
  );

  // Sort the optimizations by stress
  sort_optimizations_by_stress(optimizations);

  // Realign optimizations to the first one
  align_optimizations(optimizations);

  // Set column bases
  for(auto &optimization : optimizations){
    optimization.set_min_column_basis(min_colbasis);
    optimization.set_fixed_column_bases(fixed_colbases);
  }

  // Add optimizations to merged map and return it
  merged_map.optimizations = optimizations;
  return merged_map;

}

// [[Rcpp::export]]
AcMap ac_merge_incremental(
    const std::vector<AcMap>& maps,
    int num_dims,
    int num_optimizations,
    std::string min_colbasis,
    const AcOptimizerOptions& optimizer_options,
    const AcMergeOptions& merge_options
){

  // Check input
  if(maps.size() < 2) Rf_error("Expected at least 2 maps");

  // Set the merged map
  AcMap merged_map = maps[0];

  // Set fixed column bases to all ignored, setting fixed colbases isn't
  // included in inc merge yet.
  arma::vec fixed_colbases = arma::vec( merged_map.sera.size() );
  fixed_colbases.fill( arma::datum::nan );

  // Set ag reactivity adjustments to all ignored, setting ag reactivity adjustments
  // isn't included in inc merge yet.
  arma::vec ag_reactivity_adjustments = arma::vec(
    merged_map.sera.size(),
    arma::fill::zeros
  );

  // Perform an optimization on the first map, if not done already
  if(merged_map.num_optimizations() == 0){
    merged_map.optimize(
      num_dims,
      num_optimizations,
      min_colbasis,
      fixed_colbases,
      ag_reactivity_adjustments,
      optimizer_options
    );
  }

  // Do an incremental merge for each map in turn
  for(arma::uword i=1; i < maps.size(); i++){
    merged_map = ac_merge_incremental_single(
      std::vector<AcMap> { merged_map, maps[i] },
      num_dims,
      num_optimizations,
      min_colbasis,
      optimizer_options,
      merge_options
    );
  }

  // Return the merged map
  return merged_map;

}


// [[Rcpp::export]]
int ac_titer_merge_type(
    const std::vector<AcTiter>& titers
) {

  // Determine titer types
  arma::ivec ttypes = titer_types_int(titers);

  // Case -1: All .
  if (arma::all(ttypes == -1)) {
    return(-1);
  } else
  // Case 0: Nothing measured
  if (arma::all(ttypes <= 0)) {
    return(0);
  } else
  // Case 1: Only detectable
  if (arma::all(ttypes == 1)) {
    return(1);
  } else
  // Case 2: Only <
  if (arma::all(ttypes == 2)) {
    return(2);
  } else
  // Case 3: Only >
  if (arma::all(ttypes == 3)) {
    return(3);
  } else
  // Case 4: Contains some mixture of <, > and detectable values
  {
    return(4);
  }

}


// Determing the type of titer merge happening in tables
// [[Rcpp::export]]
arma::imat ac_titer_layer_merge_types(
    const std::vector<AcTiterTable>& titer_layers
){

  int num_ags = titer_layers.at(0).nags();
  int num_sr  = titer_layers.at(0).nsr();
  int num_layers = titer_layers.size();

  arma::imat merge_types(num_ags, num_sr);
  std::vector<AcTiter> titers(num_layers, AcTiter());

  for (int ag=0; ag<num_ags; ag++) {
    for (int sr=0; sr<num_sr; sr++) {
      for (int i=0; i<num_layers; i++) {
        titers[i] = titer_layers.at(i).get_titer(ag,sr);
      }
      merge_types(ag, sr) = ac_titer_merge_type(titers);
    }
  }

  return merge_types;

}


// Determing the type of titer merge happening in tables
// [[Rcpp::export]]
arma::mat ac_titer_layer_sd(
    const std::vector<AcTiterTable>& titer_layers,
    const double dilution_stepsize
){

  int num_ags = titer_layers.at(0).nags();
  int num_sr  = titer_layers.at(0).nsr();
  int num_layers = titer_layers.size();

  arma::mat merge_sd(num_ags, num_sr);
  std::vector<AcTiter> titers(num_layers, AcTiter());

  for (int ag=0; ag<num_ags; ag++) {
    for (int sr=0; sr<num_sr; sr++) {
      for (int i=0; i<num_layers; i++) {
        titers[i] = titer_layers.at(i).get_titer(ag,sr);
      }
      merge_sd(ag, sr) = arma::stddev(log_titers(titers, dilution_stepsize));
    }
  }

  return merge_sd;

}
