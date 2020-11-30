
#include "acmap_optimization.h"
#include "acmap_titers.h"
#include "acmap_point.h"
#include "ac_merge.h"

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
      std::vector<AcTiterTable> titers
    ){
      titer_table_flat = ac_merge_titer_layers(titers);
      titer_table_layers.swap(titers);
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

      // Subset antigens
      std::vector<AcAntigen> new_antigens(ags.size());
      for(int i=0; i<ags.size(); i++){
        new_antigens[i] = antigens[ags[i]];
      }
      antigens.swap(new_antigens);

      // Subset sera
      std::vector<AcSerum> new_sera(sr.size());
      for(int i=0; i<sr.size(); i++){
        new_sera[i] = sera[sr[i]];
      }
      sera.swap(new_sera);

      // Subset titers
      titer_table_flat.subset(ags, sr);
      for(int i=0; i<titer_table_layers.size(); i++){
        titer_table_layers[i].subset(ags, sr);
      }

    }

};

#endif
