
#include "acmap_optimization.h"
#include "acmap_titers.h"
#include "acmap_point.h"
#include "acmap_map.h"
#include "ac_merge.h"
#include "ac_matching.h"
#include "ac_optim_map_stress.h"
#include "utils.h"

// AcMap
AcMap::AcMap(
  int num_ags,
  int num_sr
):
  titer_table_flat(num_ags, num_sr){

  // Set antigens
  antigens.resize(num_ags);
  for(int i=0; i<num_ags; i++){
    antigens[i].set_name("ANTIGEN "+std::to_string(i));
  }

  // Set sera
  sera.resize(num_sr);
  for(int i=0; i<num_sr; i++){
    sera[i].set_name("SERA "+std::to_string(i));
  }

  // Set point drawing order
  pt_drawing_order = arma::regspace<arma::uvec>(0, num_ags + num_sr - 1);

  // Set dilution stepsize
  dilution_stepsize = 1.0;

  // Set ag and sr group levels
  ag_group_levels.resize(0);
  sr_group_levels.resize(0);

  // Set ag reactivity adjustments
  ag_reactivity_adjustments.zeros(num_ags);

}

// Invalidate all calculated optimization stresses, for example when titers are changed
void AcMap::update_stresses() {
  for(auto &optimization : optimizations){
    optimization.update_stress(
      titer_table_flat,
      dilution_stepsize
    );
  }
};

// Get and set ag and sr group levels
std::vector<std::string> AcMap::get_ag_group_levels() const { return ag_group_levels; }
std::vector<std::string> AcMap::get_sr_group_levels() const { return sr_group_levels; }
void AcMap::set_ag_group_levels( std::vector<std::string> levels ){ ag_group_levels = levels; }
void AcMap::set_sr_group_levels( std::vector<std::string> levels ){ sr_group_levels = levels; }

// Get and set antigen reactivity adjustments
arma::vec AcMap::get_ag_reactivity_adjustments() const { return ag_reactivity_adjustments; }
double AcMap::get_ag_reactivity_adjustments(arma::uword i) const { return ag_reactivity_adjustments(i); }
void AcMap::set_ag_reactivity_adjustments( arma::vec ag_reactivity_adjustments_in ) {
  ag_reactivity_adjustments = ag_reactivity_adjustments_in;
}

// Get and set titers from a single titer table, resetting any layers
AcTiterTable AcMap::get_titer_table() const {
  return titer_table_flat;
}

void AcMap::set_titer_table(
    AcTiterTable titers
){
  titer_table_flat = titers;
  titer_table_layers.clear();
  update_stresses();
}

// Get and set the flat version of the titer table directly
AcTiterTable AcMap::get_titer_table_flat() const {
  return titer_table_flat;
}

void AcMap::set_titer_table_flat(
    AcTiterTable titers
){
  titer_table_flat = titers;
  update_stresses();
}

// Get and set titers from vector of titer layers
std::vector<AcTiterTable> AcMap::get_titer_table_layers() const {
  if(titer_table_layers.size() == 0){
    return std::vector<AcTiterTable>{ titer_table_flat };
  } else {
    return titer_table_layers;
  }
}

void AcMap::set_titer_table_layers(
    const std::vector<AcTiterTable> titers,
    const AcMergeOptions& merge_options
){
  titer_table_flat = ac_merge_titer_layers(titers, merge_options);
  titer_table_layers = titers;
  update_stresses();
}

// Remove antigen(s)
void AcMap::remove_antigen(int agnum){

  // Deal with homologous serum records
  arma::uvec ag_indices = arma::regspace<arma::uvec>(0, antigens.size() - 1);
  ag_indices.shed_row(agnum);
  for (auto &serum : sera) {
    arma::uvec new_indices;
    for (arma::uword i=0; i<serum.homologous_ags.n_elem; i++) {
      for (arma::uword j=0; j<ag_indices.n_elem; j++) {
        if (serum.homologous_ags[i] == ag_indices[j]) {
          uvec_push(new_indices, j);
        }
      }
    }
    serum.homologous_ags = new_indices;
  }

  // Deal with titers
  titer_table_flat.remove_antigen(agnum);
  for(auto &titer_table_layer : titer_table_layers){
    titer_table_layer.remove_antigen(agnum);
  }

  // Deal with optimizations
  for(auto &optimization : optimizations){
    optimization.remove_antigen(agnum);
  }

  // Finally remove the antigen
  antigens.erase(antigens.begin()+agnum);

}

void AcMap::remove_antigens(arma::uvec agnums){

  for(arma::uword i=0; i<agnums.n_elem; i++){
    remove_antigen(agnums[i]);
  }

}

// Remove serum(s)
void AcMap::remove_serum(int srnum){
  sera.erase(sera.begin()+srnum);
  titer_table_flat.remove_serum(srnum);
  for(auto &titer_table_layer : titer_table_layers){
    titer_table_layer.remove_serum(srnum);
  }
  for(auto &optimization : optimizations){
    optimization.remove_serum(srnum);
  }
}

void AcMap::remove_sera(arma::uvec srnums){
  for(arma::uword i=0; i<srnums.n_elem; i++){
    remove_serum(srnums[i]);
  }
}

// Subsetting
void AcMap::subset(
    arma::uvec ags,
    arma::uvec sr
){

  // Check inputs
  if(ags.max() >= antigens.size()){
    Rcpp::stop("Antigen index out of range");
  }
  if(sr.max() >= sera.size()){
    Rcpp::stop("Sera index out of range");
  }

  // Deal with homologous serum records
  arma::uvec ag_indices = arma::regspace<arma::uvec>(0, antigens.size() - 1);
  ag_indices = ag_indices.elem(ags);
  for (auto &serum : sera) {
    arma::uvec new_indices;
    for (arma::uword i=0; i<serum.homologous_ags.n_elem; i++) {
      for (arma::uword j=0; j<ag_indices.n_elem; j++) {
        if (serum.homologous_ags[i] == ag_indices[j]) {
          uvec_push(new_indices, j);
        }
      }
    }
    serum.homologous_ags = new_indices;
  }

  // Define point indices of the subset
  arma::uvec pts = arma::join_cols(ags, sr + antigens.size());

  // Subset antigens
  std::vector<AcAntigen> new_antigens;
  for(arma::uword i=0; i<ags.size(); i++){
    arma::uword agnum = ags[i];
    new_antigens.push_back(antigens[agnum]);
  }
  antigens.swap(new_antigens);

  // Subset sera
  std::vector<AcSerum> new_sera;
  for(arma::uword i=0; i<sr.size(); i++){
    arma::uword srnum = sr[i];
    new_sera.push_back(sera[srnum]);
  }
  sera.swap(new_sera);

  // Subset titers
  titer_table_flat.subset(ags, sr);
  for(auto &titer_table_layer : titer_table_layers){
    titer_table_layer.subset(ags, sr);
  }

  // Subset optimizations
  for(auto &optimization : optimizations){
    optimization.subset(ags, sr);
  }

  // Subset antigen reactivity adjustments
  ag_reactivity_adjustments = ag_reactivity_adjustments.elem(ags);

  // Subset drawing order
  pt_drawing_order = pt_drawing_order.elem(pts); // Subset
  pt_drawing_order = arma::sort_index(pt_drawing_order); // Ordering twice means you retrieve
  pt_drawing_order = arma::sort_index(pt_drawing_order); // 1:nPoints numeric sequence

  // Update stresses
  update_stresses();

}

// Optimizations
int AcMap::num_optimizations(){
  return optimizations.size();
}

arma::mat AcMap::agCoords(
    int opt_num
) const {
  return optimizations.at(opt_num).agCoords();
}

arma::mat AcMap::srCoords(
    int opt_num
) const {
  return optimizations.at(opt_num).srCoords();
}

arma::mat AcMap::ptCoords(
    int opt_num
) const {
  return optimizations.at(opt_num).ptCoords();
}

// Antigen characteristics
std::vector<std::string> AcMap::agNames() const {
  int num_ags = antigens.size();
  std::vector<std::string> names(num_ags);
  for(arma::uword i=0; i<antigens.size(); i++){
    names[i] = antigens[i].get_name();
  }
  return names;
}

// Optimization
void AcMap::optimize(
    int num_dims,
    int num_optimizations,
    std::string min_col_basis,
    arma::vec fixed_col_bases,
    arma::vec ag_reactivity_adjustments,
    const AcOptimizerOptions &options,
    const arma::mat &titer_weights
){

  // Run optimizations
  optimizations = ac_runOptimizations(
    titer_table_flat,
    min_col_basis,
    fixed_col_bases,
    ag_reactivity_adjustments,
    num_dims,
    num_optimizations,
    options,
    titer_weights,
    dilution_stepsize
  );

}

// Shuffling optimizations
void AcMap::keepSingleOptimization(
    int i
){
  AcOptimization opt = optimizations.at(i);
  optimizations.clear();
  optimizations.push_back(opt);
}

// Aligning to other maps
void AcMap::realign_to_map(
    AcMap targetmap,
    int targetmap_optnum,
    bool translation,
    bool scaling,
    bool align_to_base_coords
){

  // Get matching antigens and sera
  arma::ivec matched_ags = ac_match_points( antigens, targetmap.antigens );
  arma::ivec matched_sr  = ac_match_points( sera, targetmap.sera );

  // Get the target map coords
  arma::mat target_ag_coords;
  arma::mat target_sr_coords;
  AcOptimization targetopt = targetmap.optimizations.at(targetmap_optnum);

  if(align_to_base_coords){
    target_ag_coords = subset_rows(targetopt.get_ag_base_coords(), matched_ags);
    target_sr_coords = subset_rows(targetopt.get_sr_base_coords(), matched_sr);
  } else {
    target_ag_coords = subset_rows(targetopt.agCoords(), matched_ags);
    target_sr_coords = subset_rows(targetopt.srCoords(), matched_sr);
  }
  arma::mat target_coords = arma::join_cols(target_ag_coords, target_sr_coords);

  // Realign each optimization
  for (auto &optimization : optimizations) {

    // Get the source map base coords
    arma::mat source_ag_coords = optimization.get_ag_base_coords();
    arma::mat source_sr_coords = optimization.get_sr_base_coords();
    arma::mat source_coords = arma::join_cols( source_ag_coords, source_sr_coords );

    // Calculate the procrustes
    Procrustes pc = ac_procrustes(
      source_coords,
      target_coords,
      translation,
      scaling
    );

    // Apply it to the optimization
    optimization.set_transformation( pc.R );
    optimization.set_translation( pc.tt );
    optimization.set_scaling( pc.s );

  }

}

// Point drawing order
arma::uvec AcMap::get_pt_drawing_order() const {
  return pt_drawing_order;
}

void AcMap::set_pt_drawing_order( const arma::uvec& order ){
  pt_drawing_order = order;
}

// Get and set layer names
std::vector<std::string> AcMap::get_layer_names() const {
  return layer_names;
}

void AcMap::set_layer_names( const std::vector<std::string> layer_names_in ){
  layer_names = layer_names_in;
}

// Determine if setting are defaults, useful when outputting to json
bool AcMap::isdefault(
    std::string attribute
) {

  if (attribute == "ag_group_levels") {
    return(ag_group_levels.size() == 0);
  }
  else if (attribute == "sr_group_levels") {
    return(sr_group_levels.size() == 0);
  }
  else if (attribute == "description") {
    return(description == "");
  }
  else if (attribute == "layer_names") {
    int i = 0;
    for(auto &layer_name : layer_names){
      if (layer_name != "") i++;
    }
    return(i == 0);
  } else if (attribute == "ag_reactivity") {
    return(
      arma::approx_equal(
        ag_reactivity_adjustments,
        arma::vec(antigens.size(), arma::fill::zeros),
        "absdiff", 0.0001
      )
    );
  } else if (attribute == "dilution_stepsize") {
    return(dilution_stepsize == 1);
  } else {
    return(false);
  }

}
