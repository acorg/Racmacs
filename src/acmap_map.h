
#include "acmap_optimization.h"
#include "acmap_titers.h"
#include "acmap_point.h"
#include "ac_merge.h"
#include "ac_matching.h"
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
    std::string description;
    double dilution_stepsize;
    std::vector<AcOptimization> optimizations;
    std::vector<AcAntigen> antigens;
    std::vector<AcSerum> sera;
    AcTiterTable titer_table_flat;
    std::vector<AcTiterTable> titer_table_layers;
    std::vector<std::string> layer_names;
    arma::vec ag_reactivity_adjustments;

    // Getters
    arma::vec get_ag_reactivity_adjustments() const;
    double get_ag_reactivity_adjustments(arma::uword i) const;

    // Setters
    void set_ag_reactivity_adjustments( arma::vec ag_reactivity_adjustments_in );

    // Construct a new acmap
    AcMap(
      int num_ags,
      int num_sr
    );

    // Invalidate all calculated optimization stresses, for example when titers are changed
    void update_stresses();

    // Get and set ag and sr group levels
    std::vector<std::string> get_ag_group_levels() const;
    std::vector<std::string> get_sr_group_levels() const;
    void set_ag_group_levels( std::vector<std::string> levels );
    void set_sr_group_levels( std::vector<std::string> levels );

    // Get and set titers from a single titer table, resetting any layers
    AcTiterTable get_titer_table() const;

    void set_titer_table(
      AcTiterTable titers
    );

    // Get and set the flat version of the titer table directly
    AcTiterTable get_titer_table_flat() const;

    void set_titer_table_flat(
      AcTiterTable titers
    );

    // Get and set titers from vector of titer layers
    std::vector<AcTiterTable> get_titer_table_layers() const;

    void set_titer_table_layers(
      const std::vector<AcTiterTable> titers,
      const AcMergeOptions& merge_options
    );

    // Get and set layer names
    std::vector<std::string> get_layer_names() const;
    void set_layer_names(
      const std::vector<std::string> layer_names_in
    );

    // Remove antigen(s)
    void remove_antigen(int agnum);
    void remove_antigens(arma::uvec agnums);

    // Remove serum(s)
    void remove_serum(int srnum);
    void remove_sera(arma::uvec srnums);

    // Subsetting
    void subset(
      arma::uvec ags,
      arma::uvec sr
    );

    // Optimizations
    int num_optimizations();
    arma::mat agCoords(
      int opt_num = 0
    ) const;

    arma::mat srCoords(
        int opt_num = 0
    ) const;

    arma::mat ptCoords(
        int opt_num = 0
    ) const;

    // Antigen characteristics
    std::vector<std::string> agNames() const;

    // Optimization
    void optimize(
      int num_dims,
      int num_optimizations,
      std::string min_col_basis,
      arma::vec fixed_col_bases,
      arma::vec ag_reactivity_adjustments,
      const AcOptimizerOptions &options,
      const arma::mat &titer_weights = arma::mat()
    );

    // Shuffling optimizations
    void keepSingleOptimization(
      int i
    );

    // Aligning to other maps
    void realign_to_map(
      AcMap targetmap,
      int targetmap_optnum = 0,
      bool translation = true,
      bool scaling = false,
      bool align_to_base_coords = false
    );

    // Point drawing order
    arma::uvec get_pt_drawing_order() const;
    void set_pt_drawing_order( const arma::uvec& order );

    // Determine if setting are defaults, useful when outputting to json
    bool isdefault(
        std::string attribute
    );

};

#endif
