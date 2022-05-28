
#include <RcppArmadillo.h>
#include "procrustes.h"
#include "utils.h"
#include "utils_error.h"
#include "utils_transformation.h"
#include "ac_titers.h"
#include "acmap_titers.h"
#include "acmap_diagnostics.h"
#include "ac_optimizer_options.h"
#include "ac_relax_coords.h"
#include "ac_coords_stress.h"
#include "ac_bootstrap_output.h"

#ifndef Racmacs__acmap_optimization__h
#define Racmacs__acmap_optimization__h

// Define the optimization class
class AcOptimization {

  private:

    std::string min_column_basis;
    arma::vec fixed_column_bases;
    arma::vec ag_reactivity_adjustments;
    arma::mat ag_base_coords;
    arma::mat sr_base_coords;
    std::string comment;
    arma::mat transformation;
    arma::mat translation;

  public:

    std::vector<AcDiagnostics> ag_diagnostics;
    std::vector<AcDiagnostics> sr_diagnostics;
    std::vector<BootstrapOutput> bootstrap;
    double stress = arma::datum::nan;

    // Constructors
    AcOptimization(
      const int &dimensions,
      const int &num_antigens,
      const int &num_sera
    );

    AcOptimization(
      const int &dimensions,
      const int &num_antigens,
      const int &num_sera,
      const std::string &min_column_basis,
      const arma::vec &fixed_column_bases,
      const arma::vec &ag_reactivity_adjustments
    );

    // Getters
    std::string get_min_column_basis() const;
    arma::vec get_fixed_column_bases() const;
    double get_fixed_column_bases(arma::uword i) const;
    arma::vec get_ag_reactivity_adjustments() const;
    double get_ag_reactivity_adjustments(arma::uword i) const;
    std::string get_comment() const;
    arma::mat get_transformation() const;
    arma::mat get_translation() const;
    double get_stress() const;
    int get_dimensions() const;

    // Setters
    void set_comment( std::string comment_in );
    void set_transformation( arma::mat transformation_in );
    void set_translation( arma::mat translation_in );
    void set_stress( double stress_in );
    void set_ag_reactivity_adjustments( arma::vec ag_reactivity_adjustments_in );

    void set_fixed_column_bases(
      arma::vec fixed_column_bases_in,
      bool reset_stress = true
    );

    void set_min_column_basis(
      const std::string min_column_basis_in,
      bool reset_stress = true
    );

    // Update the currently calculated stress
    void update_stress(
      AcTiterTable titertable,
      double dilution_stepsize
    );

    // Invalidate the currently calculated stress, for example when points are moved
    void invalidate_stress();

    // Getting antigen base coords
    arma::mat get_ag_base_coords() const;
    arma::vec get_ag_base_coords( arma::uword& ag ) const;

    // Getting sera base coords
    arma::mat get_sr_base_coords() const;
    arma::vec get_sr_base_coords( arma::uword& sr ) const;

    // Setting antigen base coords
    void set_ag_base_coords( arma::mat ag_base_coords_in );

    // Setting sera base coords
    void set_sr_base_coords( arma::mat sr_base_coords_in );

    // Setting coords of a specific ag
    void set_ag_base_coords(
        arma::uword ag_index,
        arma::vec ag_base_coords_in
    );

    // Setting coords of a specific sr
    void set_sr_base_coords(
        arma::uword sr_index,
        arma::vec sr_base_coords_in
    );

    // Setting coords of a subset of ags
    void set_ag_base_coords(
        arma::uvec ag_indices,
        arma::mat ag_base_coords_in
    );

    // Setting coords of a subset of sr
    void set_sr_base_coords(
        arma::uvec sr_indices,
        arma::mat sr_base_coords_in
    );

    // Get dimensions
    int dim() const;
    int num_ags() const;
    int num_sr() const;

    // Retrieve point base coordinates (ag then sera)
    arma::mat ptBaseCoords() const;

    // Retrieve antigen coordinates
    arma::mat agCoords() const;

    // Retrieve sera coordinates
    arma::mat srCoords() const;

    // Retrieve point coordinates (ags then sr)
    arma::mat ptCoords() const;

    // Apply the optimization transform to an arbitrary set of coordinates
    arma::mat applyTransformation(
      arma::mat coords
    ) const;

    // Bake in the current transformation into the base coordinates
    void bake_transformation();

    // Set ag coordinates
    void set_ag_coords(
      arma::mat coords
    );

    // Set sr coordinates
    void set_sr_coords(
        arma::mat coords
    );

    // Align to another optimization
    void alignToOptimization(
      AcOptimization target
    );

    // Calculate the distance matrix
    arma::mat distance_matrix() const;

    // Calculate point distance
    double ptDist(
      int ag,
      int sr
    ) const;

    // Calculate the column bases
    arma::vec calc_colbases(
       AcTiterTable titers
    ) const;

    // Reduce dimensions of optimization through principle component analysis
    void reduceDimensions(
      arma::uword dims
    );

    // Randomise coordinates
    void randomizeCoords(
      double boxsize
    );

    // Get table distances
    arma::mat numeric_table_distances(
      const AcTiterTable &titers
    ) const;

    // Relax the optimization
    void relax_from_raw_matrices(
      const arma::mat &tabledist_matrix,
      const arma::imat &titertype_matrix,
      const AcOptimizerOptions options,
      const arma::uvec &fixed_antigens = arma::uvec(),
      const arma::uvec &fixed_sera = arma::uvec(),
      const arma::mat &titer_weights = arma::mat(),
      const double &dilution_stepsize = 1.0
    );

    void relax_from_titer_table(
      AcTiterTable titers,
      const AcOptimizerOptions options,
      const arma::uvec &fixed_antigens = arma::uvec(),
      const arma::uvec &fixed_sera = arma::uvec(),
      const arma::mat &titer_weights = arma::mat(),
      const double &dilution_stepsize = 1.0
    );

    // Removing antigens and sera
    void remove_antigen(
        arma::uword ag
    );

    void remove_serum(
        arma::uword sr
    );

    // Subsetting
    void subset(
        arma::uvec ags,
        arma::uvec sr
    );

    // Transformation
    void transform(
      arma::mat transform_matrix
    );

    // Translation
    void translate(
      arma::mat translation_matrix
    );

    // Rotation
    void rotate(
      double degrees,
      arma::uword axis_num = 2
    );

    // Reflection
    void reflect(
      arma::uword axis_num = 0
    );

    // Scale
    void scale(
        double scaling
    );

    // Set scaling
    void set_scaling(
        double scaling
    );

    // Check if values are still the default (used when outputting to json)
    bool isdefault(
        std::string attribute
    );

};

#endif
