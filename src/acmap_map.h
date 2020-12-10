
#include "acmap_optimization.h"
#include "acmap_titers.h"
#include "acmap_point.h"
#include "ac_merge.h"
#include "ac_matching.h"

#ifndef Racmacs__acmap_map__h
#define Racmacs__acmap_map__h

// Define the acmap class
class AcMap {

  public:
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

    }

    // Get and set titers from a single titer table, resetting any layers
    AcTiterTable get_titer_table(){
      return titer_table_flat;
    }

    void set_titer_table(
      AcTiterTable titers
    ){
      titer_table_flat = titers;
      titer_table_layers.clear();
    }

    // Get and set the flat version of the titer table directly
    AcTiterTable get_titer_table_flat(){
      return titer_table_flat;
    }

    void set_titer_table_flat(
      AcTiterTable titers
    ){
      titer_table_flat = titers;
    }

    // Get and set titers from vector of titer layers
    std::vector<AcTiterTable> get_titer_table_layers(){
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
    }

    // Remove antigen(s)
    void remove_antigen(int agnum){
      antigens.erase(antigens.begin()+agnum);
      titer_table_flat.remove_antigen(agnum);
      for(int i=0; i<titer_table_layers.size(); i++){
        titer_table_layers[i].remove_antigen(agnum);
      }
    }

    void remove_antigens(arma::uvec agnums){
      for(int i=0; i<agnums.size(); i++){
        remove_antigen(agnums[i]);
      }
    }

    // Remove serum(s)
    void remove_serum(int srnum){
      sera.erase(sera.begin()+srnum);
      titer_table_flat.remove_serum(srnum);
      for(int i=0; i<titer_table_layers.size(); i++){
        titer_table_layers[i].remove_serum(srnum);
      }
    }

    void remove_sera(arma::uvec srnums){
      for(int i=0; i<srnums.size(); i++){
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

      // Subset antigens
      std::vector<AcAntigen> new_antigens;
      for(int i=0; i<ags.size(); i++){
        arma::uword agnum = ags[i];
        new_antigens.push_back(antigens[agnum]);
      }
      antigens.swap(new_antigens);

      // Subset sera
      std::vector<AcSerum> new_sera;
      for(int i=0; i<sr.size(); i++){
        arma::uword srnum = sr[i];
        new_sera.push_back(sera[srnum]);
      }
      sera.swap(new_sera);

      // Subset titers
      titer_table_flat.subset(ags, sr);
      for(int i=0; i<titer_table_layers.size(); i++){
        titer_table_layers[i].subset(ags, sr);
      }

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
      for(int i=0; i<antigens.size(); i++){
        names[i] = antigens[i].get_name();
      }
      return names;
    }

    // Matching to other maps
    arma::ivec match_map_antigens(
      AcMap targetmap
    ){

      return ac_match_points(
        antigens,
        targetmap.antigens
      );

    }

    arma::ivec match_map_sera(
        AcMap targetmap
    ){

      return ac_match_points(
        sera,
        targetmap.sera
      );

    }

};

#endif
