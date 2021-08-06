
#include "acmap_optimization.h"
#include "acmap_titers.h"
#include "acmap_point.h"
#include "ac_merge.h"
#include "ac_matching.h"
#include "ac_optim_map_stress.h"
#include "utils.h"

#ifndef Racmacs__acmap_map__h
#define Racmacs__acmap_map__h

// Define the acmap class
class AcMap {

  private:
    // EXTRAS
    std::vector<std::string> ag_group_levels;
    std::vector<std::string> sr_group_levels;
    arma::uvec pt_drawing_order;

  public:
    // ATTRIBUTES
    std::string name;
    std::vector<AcOptimization> optimizations;
    std::vector<AcAntigen> antigens;
    std::vector<AcSerum> sera;
    AcTiterTable titer_table_flat;
    std::vector<AcTiterTable> titer_table_layers;

    // Construct a new acmap
    AcMap(
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

      // Set ag and sr group levels
      ag_group_levels.resize(0);
      sr_group_levels.resize(0);

    }

    // Invalidate all calculated optimization stresses, for example when titers are changed
    void update_stresses() {
      for(auto &optimization : optimizations){
        optimization.update_stress(titer_table_flat);
      }
    };

    // Get and set ag and sr group levels
    std::vector<std::string> get_ag_group_levels() const { return ag_group_levels; }
    std::vector<std::string> get_sr_group_levels() const { return sr_group_levels; }
    void set_ag_group_levels( std::vector<std::string> levels ){ ag_group_levels = levels; }
    void set_sr_group_levels( std::vector<std::string> levels ){ sr_group_levels = levels; }

    // Get and set titers from a single titer table, resetting any layers
    AcTiterTable get_titer_table() const {
      return titer_table_flat;
    }

    void set_titer_table(
      AcTiterTable titers
    ){
      titer_table_flat = titers;
      titer_table_layers.clear();
      update_stresses();
    }

    // Get and set the flat version of the titer table directly
    AcTiterTable get_titer_table_flat() const {
      return titer_table_flat;
    }

    void set_titer_table_flat(
      AcTiterTable titers
    ){
      titer_table_flat = titers;
    }

    // Get and set titers from vector of titer layers
    std::vector<AcTiterTable> get_titer_table_layers() const {
      if(titer_table_layers.size() == 0){
        return std::vector<AcTiterTable>{ titer_table_flat };
      } else {
        return titer_table_layers;
      }
    }

    void set_titer_table_layers(
      const std::vector<AcTiterTable> titers
    ){
      titer_table_flat = ac_merge_titer_layers(titers);
      titer_table_layers = titers;
      update_stresses();
    }

    // Remove antigen(s)
    void remove_antigen(int agnum){
      antigens.erase(antigens.begin()+agnum);
      titer_table_flat.remove_antigen(agnum);
      for(auto &titer_table_layer : titer_table_layers){
        titer_table_layer.remove_antigen(agnum);
      }
      for(auto &optimization : optimizations){
        optimization.remove_antigen(agnum);
      }
    }

    void remove_antigens(arma::uvec agnums){
      for(arma::uword i=0; i<agnums.n_elem; i++){
        remove_antigen(agnums[i]);
      }
    }

    // Remove serum(s)
    void remove_serum(int srnum){
      sera.erase(sera.begin()+srnum);
      titer_table_flat.remove_serum(srnum);
      for(auto &titer_table_layer : titer_table_layers){
        titer_table_layer.remove_serum(srnum);
      }
      for(auto &optimization : optimizations){
        optimization.remove_serum(srnum);
      }
    }

    void remove_sera(arma::uvec srnums){
      for(arma::uword i=0; i<srnums.n_elem; i++){
        remove_serum(srnums[i]);
      }
    }

    // Subsetting
    void subset(
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

      // Subset drawing order
      pt_drawing_order = pt_drawing_order.elem(pts); // Subset
      pt_drawing_order = arma::sort_index(pt_drawing_order); // Ordering twice means you retrieve
      pt_drawing_order = arma::sort_index(pt_drawing_order); // 1:nPoints numeric sequence

      // Update stresses
      update_stresses();

    }

    // Optimizations
    int num_optimizations(){
      return optimizations.size();
    }

    arma::mat agCoords(
      int opt_num = 0
    ) const {
      return optimizations[opt_num].agCoords();
    }

    arma::mat srCoords(
        int opt_num = 0
    ) const {
      return optimizations[opt_num].srCoords();
    }

    arma::mat ptCoords(
        int opt_num = 0
    ) const {
      return optimizations[opt_num].ptCoords();
    }

    // Antigen characteristics
    std::vector<std::string> agNames() const {
      int num_ags = antigens.size();
      std::vector<std::string> names(num_ags);
      for(arma::uword i=0; i<antigens.size(); i++){
        names[i] = antigens[i].get_name();
      }
      return names;
    }

    // Optimization
    void optimize(
      int num_dims,
      int num_optimizations,
      std::string min_col_basis,
      arma::vec fixed_col_bases,
      arma::vec ag_reactivity_adjustments,
      const AcOptimizerOptions &options,
      const arma::mat &titer_weights = arma::mat()
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
        titer_weights
      );

    }

    // Shuffling optimizations
    void keepSingleOptimization(
      int i
    ){
      AcOptimization opt = optimizations[i];
      optimizations.clear();
      optimizations.push_back(opt);
    }

    // Aligning to other maps
    void realign_to_map(
      AcMap targetmap,
      int targetmap_optnum = 0,
      bool translation = true,
      bool scaling = false,
      bool align_to_base_coords = false
    ){

      // Get matching antigens and sera
      arma::ivec matched_ags = ac_match_points( antigens, targetmap.antigens );
      arma::ivec matched_sr  = ac_match_points( sera, targetmap.sera );

      // Get the target map coords
      arma::mat target_ag_coords;
      arma::mat target_sr_coords;
      AcOptimization targetopt = targetmap.optimizations[targetmap_optnum];

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

      }

    }

    // Point drawing order
    arma::uvec get_pt_drawing_order() const {
      return pt_drawing_order;
    }

    void set_pt_drawing_order( const arma::uvec& order ){
      pt_drawing_order = order;
    }

};

#endif
