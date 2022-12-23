
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
#include "acmap_optimization.h"

// Constructors
AcOptimization::AcOptimization(
  const int &dimensions,
  const int &num_antigens,
  const int &num_sera
) {

  ag_base_coords = arma::mat(num_antigens, dimensions, arma::fill::zeros);
  sr_base_coords = arma::mat(num_sera, dimensions, arma::fill::zeros);
  transformation = arma::mat(dimensions, dimensions, arma::fill::eye);
  translation    = arma::mat(dimensions, 1, arma::fill::zeros);
  ag_diagnostics.resize(num_antigens);
  sr_diagnostics.resize(num_sera);

  min_column_basis = "none";
  fixed_column_bases = arma::vec(num_sera);
  fixed_column_bases.fill(arma::datum::nan);
  ag_reactivity_adjustments = arma::vec(num_antigens, arma::fill::zeros);

}

AcOptimization::AcOptimization(
  const int &dimensions,
  const int &num_antigens,
  const int &num_sera,
  const std::string &min_column_basis,
  const arma::vec &fixed_column_bases,
  const arma::vec &ag_reactivity_adjustments
)
  :min_column_basis(min_column_basis),
   fixed_column_bases(fixed_column_bases),
   ag_reactivity_adjustments(ag_reactivity_adjustments)
{

  ag_base_coords = arma::mat(num_antigens, dimensions, arma::fill::zeros);
  sr_base_coords = arma::mat(num_sera, dimensions, arma::fill::zeros);
  transformation = arma::mat(dimensions, dimensions, arma::fill::eye);
  translation    = arma::mat(dimensions, 1, arma::fill::zeros);
  ag_diagnostics.resize(num_antigens);
  sr_diagnostics.resize(num_sera);

}

// Getters
std::string AcOptimization::get_min_column_basis() const { return min_column_basis; }
arma::vec AcOptimization::get_fixed_column_bases() const { return fixed_column_bases; }
double AcOptimization::get_fixed_column_bases(arma::uword i) const { return fixed_column_bases(i); }
arma::vec AcOptimization::get_ag_reactivity_adjustments() const { return ag_reactivity_adjustments; }
double AcOptimization::get_ag_reactivity_adjustments(arma::uword i) const { return ag_reactivity_adjustments(i); }
std::string AcOptimization::get_comment() const { return comment; }
arma::mat AcOptimization::get_transformation() const { return transformation; }
arma::mat AcOptimization::get_translation() const { return translation; }
double AcOptimization::get_stress() const { return stress; }
int AcOptimization::get_dimensions() const { return ag_base_coords.n_cols; }

// Setters
void AcOptimization::set_comment( std::string comment_in ) { comment = comment_in; }
void AcOptimization::set_transformation( arma::mat transformation_in ) { transformation = transformation_in; }
void AcOptimization::set_translation( arma::mat translation_in ) { translation = translation_in; }
void AcOptimization::set_stress( double stress_in ) { stress = stress_in; }
void AcOptimization::set_ag_reactivity_adjustments( arma::vec ag_reactivity_adjustments_in ) {
  ag_reactivity_adjustments = ag_reactivity_adjustments_in;
}

void AcOptimization::set_fixed_column_bases(
    arma::vec fixed_column_bases_in,
    bool reset_stress
) {

  // Check fixed col bases validity
  if (fixed_column_bases_in.n_elem != sr_base_coords.n_rows) {
    Rf_error("Fixed column base length does not match the number of sera");
  }
  fixed_column_bases = fixed_column_bases_in;

  // Invalidate stress
  if (reset_stress) invalidate_stress();

}

void AcOptimization::set_min_column_basis(
    const std::string min_column_basis_in,
    bool reset_stress
) {

  // Check min col basis validity
  if (min_column_basis_in != "none") {
    check_valid_titer(min_column_basis_in);
  }

  // Set min col basis
  min_column_basis = min_column_basis_in;

  // Invalidate stress
  if (reset_stress) invalidate_stress();

}

// Update the currently calculated stress
void AcOptimization::update_stress(
    AcTiterTable titertable,
    double dilution_stepsize
) {

  stress = ac_coords_stress(
    titertable,
    min_column_basis,
    fixed_column_bases,
    ag_reactivity_adjustments,
    ag_base_coords,
    sr_base_coords,
    dilution_stepsize
  );

}

// Invalidate the currently calculated stress, for example when points are moved
void AcOptimization::invalidate_stress() { stress = arma::datum::nan; }

// Getting antigen base coords
arma::mat AcOptimization::get_ag_base_coords() const { return ag_base_coords; }
arma::vec AcOptimization::get_ag_base_coords( arma::uword& ag ) const {
  return arma::vectorise(
    ag_base_coords.row(ag)
  );
}

// Getting sera base coords
arma::mat AcOptimization::get_sr_base_coords() const { return sr_base_coords; }
arma::vec AcOptimization::get_sr_base_coords( arma::uword& sr ) const {
  return arma::vectorise(
    sr_base_coords.row(sr)
  );
}


// Setting antigen base coords
void AcOptimization::set_ag_base_coords( arma::mat ag_base_coords_in ) {
  // Check input
  if (ag_base_coords_in.n_rows != ag_base_coords.n_rows) {
    ac_error(
      "ag_base_coords rows (" + std::to_string(ag_base_coords.n_rows) + ")" +
      "does not match input rows (" + std::to_string(ag_base_coords_in.n_rows) + ")"
    );
  }
  // Update coords
  ag_base_coords = ag_base_coords_in;
  invalidate_stress();
}


// Setting sera base coords
void AcOptimization::set_sr_base_coords( arma::mat sr_base_coords_in ) {
  // Check input
  if (sr_base_coords_in.n_rows != sr_base_coords.n_rows) {
    ac_error(
      "sr_base_coords rows (" + std::to_string(sr_base_coords.n_rows) + ")" +
      "does not match input rows (" + std::to_string(sr_base_coords_in.n_rows) + ")"
    );
  }
  // Update coords
  sr_base_coords = sr_base_coords_in;
  invalidate_stress();
}


// Setting coords of a specific ag
void AcOptimization::set_ag_base_coords(
    arma::uword ag_index,
    arma::vec ag_base_coords_in
) {
  // Check input
  if (ag_base_coords_in.n_elem != ag_base_coords.n_cols) {
    ac_error(
      "antigen coords length (" + std::to_string(ag_base_coords_in.n_elem) + ")" +
      "exceeds antigen coords dimensions (" + std::to_string(ag_base_coords.n_cols) + ")"
    );
  }
  // Update coords
  for(arma::uword i=0; i<ag_base_coords.n_cols; i++) {
    ag_base_coords( ag_index, i ) = ag_base_coords_in(i);
  }
  invalidate_stress();
}


// Setting coords of a specific sr
void AcOptimization::set_sr_base_coords(
    arma::uword sr_index,
    arma::vec sr_base_coords_in
) {
  // Check input
  if (sr_base_coords_in.n_elem != sr_base_coords.n_cols) {
    ac_error(
      "sera coords length (" + std::to_string(sr_base_coords_in.n_elem) + ")" +
      "exceeds sera coords dimensions (" + std::to_string(sr_base_coords.n_cols) + ")"
    );
  }
  // Update coords
  for(arma::uword i=0; i<sr_base_coords.n_cols; i++) {
    ag_base_coords( sr_index, i ) = sr_base_coords_in(i);
  }
  invalidate_stress();
}


// Setting coords of a subset of ags
void AcOptimization::set_ag_base_coords(
    arma::uvec ag_indices,
    arma::mat ag_base_coords_in
) {
  // Check input
  if (ag_base_coords_in.n_rows != ag_indices.n_elem) {
    ac_error(
      "ag_indices length (" + std::to_string(ag_indices.n_elem) + ")" +
      "does not match input rows (" + std::to_string(ag_base_coords_in.n_rows) + ")"
    );
  }
  if (ag_indices.max() > ag_base_coords.n_rows - 1) {
    ac_error(
      "ag_indices max (" + std::to_string(ag_indices.max()) + ")" +
      "exceeds max antigen index (" + std::to_string(ag_base_coords.n_rows - 1) + ")"
    );
  }
  // Update coords
  ag_base_coords.rows( ag_indices ) = ag_base_coords_in;
  invalidate_stress();
}


// Setting coords of a subset of sr
void AcOptimization::set_sr_base_coords(
    arma::uvec sr_indices,
    arma::mat sr_base_coords_in
) {
  // Check input
  if (sr_base_coords_in.n_rows != sr_indices.n_elem) {
    ac_error(
      "sr_indices length (" + std::to_string(sr_indices.n_elem) + ")" +
      "does not match input rows (" + std::to_string(sr_base_coords_in.n_rows) + ")"
    );
  }
  if (sr_indices.max() > sr_base_coords.n_rows - 1) {
    ac_error(
      "sr_indices max (" + std::to_string(sr_indices.max()) + ")" +
      "exceeds max serum index (" + std::to_string(sr_base_coords.n_rows - 1) + ")"
    );
  }
  // Update coords
  sr_base_coords.rows( sr_indices ) = sr_base_coords_in;
  invalidate_stress();
}


// Get dimensions
int AcOptimization::dim() const {
  return ag_base_coords.n_cols;
}

int AcOptimization::num_ags() const {
  return ag_base_coords.n_rows;
}

int AcOptimization::num_sr() const {
  return sr_base_coords.n_rows;
}

// Retrieve point base coordinates (ag then sera)
arma::mat AcOptimization::ptBaseCoords() const {
  return arma::join_cols(
    ag_base_coords,
    sr_base_coords
  );
}

// Retrieve antigen coordinates
arma::mat AcOptimization::agCoords() const {
  return transform_coords(
    ag_base_coords,
    transformation,
    translation
  );
}

// Retrieve sera coordinates
arma::mat AcOptimization::srCoords() const {
  return transform_coords(
    sr_base_coords,
    transformation,
    translation
  );
}

// Retrieve point coordinates (ags then sr)
arma::mat AcOptimization::ptCoords() const {
  return arma::join_cols(
    agCoords(),
    srCoords()
  );
}

// Apply the optimization transform to an arbitrary set of coordinates
arma::mat AcOptimization::applyTransformation(
    arma::mat coords
) const {
  return transform_coords(
    coords,
    transformation,
    translation
  );
}

// Bake in the current transformation into the base coordinates
void AcOptimization::bake_transformation() {

  // Set the base coordinates
  ag_base_coords = agCoords();
  sr_base_coords = srCoords();

  // Reset transformation and translation
  set_transformation(
    arma::mat(dim(), dim(), arma::fill::eye)
  );
  set_translation(
    arma::mat(dim(), 1, arma::fill::zeros)
  );

}

// Set ag coordinates
void AcOptimization::set_ag_coords(
    arma::mat coords
) {
  bake_transformation();
  set_ag_base_coords(coords);
}

// Set sr coordinates
void AcOptimization::set_sr_coords(
    arma::mat coords
) {
  bake_transformation();
  set_sr_base_coords(coords);
}

// Align to another optimization
void AcOptimization::alignToOptimization(
    AcOptimization target
) {

  // Get coordinates
  arma::mat source_coords = ptBaseCoords();
  arma::mat target_coords = target.ptBaseCoords();

  // Perform procrustes
  Procrustes pc = ac_procrustes(
    source_coords,
    target_coords
  );

  // Set transformation
  transformation = pc.R;
  translation = pc.tt;

}

// Calculate the distance matrix
arma::mat AcOptimization::distance_matrix(
) const {

  int nags = num_ags();
  int nsr = num_sr();

  arma::mat distmat( nags, nsr );
  for(int ag=0; ag<nags; ag++) {
    for(int sr=0; sr<nsr; sr++) {
      distmat(ag, sr) = ptDist(ag, sr);
    }
  }

  return distmat;

}

// Calculate point distance
double AcOptimization::ptDist(
    int ag,
    int sr
) const {

  return euc_dist(
    arma::vectorise(ag_base_coords.row(ag)),
    arma::vectorise(sr_base_coords.row(sr))
  );

}

// Calculate the column bases
arma::vec AcOptimization::calc_colbases(
    AcTiterTable titers
) const {
  return titers.calc_colbases(
    min_column_basis,
    fixed_column_bases,
    ag_reactivity_adjustments
  );
}

// Reduce dimensions of optimization through principle component analysis
void AcOptimization::reduceDimensions(
    arma::uword dims
) {

  // Reduce coordinate dimensions
  arma::mat coords = arma::join_cols(
    ag_base_coords,
    sr_base_coords
  );
  arma::mat coeff = arma::princomp(coords);
  ag_base_coords = ag_base_coords * coeff.cols(0, dims - 1);
  sr_base_coords = sr_base_coords * coeff.cols(0, dims - 1);

  transformation.resize(dims, dims);
  translation.resize(dims, 1);

  invalidate_stress();

}

// Randomise coordinates
void AcOptimization::randomizeCoords(
    double boxsize
) {

  double min = -boxsize/2.0;
  double max = boxsize/2.0;
  ag_base_coords.randu();
  sr_base_coords.randu();
  ag_base_coords = ag_base_coords*(max-min) + min;
  sr_base_coords = sr_base_coords*(max-min) + min;
  invalidate_stress();

}

// Get table distances
arma::mat AcOptimization::numeric_table_distances(
    const AcTiterTable &titers
) const {

  return(
    titers.numeric_table_distances(
      min_column_basis,
      fixed_column_bases,
      ag_reactivity_adjustments
    )
  );

}

// Relax the optimization
void AcOptimization::relax_from_raw_matrices(
    const arma::mat &tabledist_matrix,
    const arma::imat &titertype_matrix,
    const AcOptimizerOptions options,
    const arma::uvec &fixed_antigens,
    const arma::uvec &fixed_sera,
    const arma::mat &titer_weights,
    const double &dilution_stepsize
) {

  stress = ac_relax_coords(
    tabledist_matrix,
    titertype_matrix,
    ag_base_coords,
    sr_base_coords,
    options,
    fixed_antigens,
    fixed_sera,
    titer_weights,
    dilution_stepsize
  );

}

void AcOptimization::relax_from_titer_table(
    AcTiterTable titers,
    const AcOptimizerOptions options,
    const arma::uvec &fixed_antigens,
    const arma::uvec &fixed_sera,
    const arma::mat &titer_weights,
    const double &dilution_stepsize
) {

  relax_from_raw_matrices(
    titers.numeric_table_distances(
      min_column_basis,
      fixed_column_bases,
      ag_reactivity_adjustments
    ),
    titers.get_titer_types(),
    options,
    fixed_antigens,
    fixed_sera,
    titer_weights,
    dilution_stepsize
  );

}

// Removing antigens and sera
void AcOptimization::remove_antigen(
    arma::uword ag
) {
  ag_base_coords.shed_row(ag);
  ag_diagnostics.erase(ag_diagnostics.begin() + ag);
  ag_reactivity_adjustments.shed_row(ag);
}

void AcOptimization::remove_serum(
    arma::uword sr
) {
  sr_base_coords.shed_row(sr);
  sr_diagnostics.erase(sr_diagnostics.begin() + sr);
  fixed_column_bases.shed_row(sr);
}

// Subsetting
void AcOptimization::subset(
    arma::uvec ags,
    arma::uvec sr
) {

  ag_base_coords = ag_base_coords.rows(ags);
  sr_base_coords = sr_base_coords.rows(sr);
  fixed_column_bases = fixed_column_bases.elem(sr);
  ag_reactivity_adjustments = ag_reactivity_adjustments.elem(ags);
  ag_diagnostics = subset_vector(ag_diagnostics, ags);
  sr_diagnostics = subset_vector(sr_diagnostics, sr);
  invalidate_stress();

}

// Transformation
void AcOptimization::transform(
    arma::mat transform_matrix
) {

  ac_transform_translation(
    translation,
    transform_matrix
  );

  ac_transform_transformation(
    transformation,
    transform_matrix
  );

}

// Translation
void AcOptimization::translate(
    arma::mat translation_matrix
) {

  ac_translate_translation(
    translation,
    translation_matrix
  );

}

// Rotation
void AcOptimization::rotate(
    double degrees,
    arma::uword axis_num
) {

  transform(
    ac_rotation_matrix(
      degrees,
      dim(),
      axis_num
    )
  );

}

// Reflection
void AcOptimization::reflect(
    arma::uword axis_num
) {

  transform(
    ac_reflection_matrix(
      dim(),
      axis_num
    )
  );

}

// Scale
void AcOptimization::scale(
    double scaling
) {

  transform(
    ac_scaling_matrix(
      dim(),
      scaling
    )
  );

}

// Set scaling
void AcOptimization::set_scaling(
    double scaling
) {

  double current_scaling = fabs(arma::det(transformation));
  double scaling_diff = scaling / current_scaling;
  scale(scaling_diff);

}

// Check if values are still the default (used when outputting to json)
bool AcOptimization::isdefault(
    std::string attribute
) {

  if (attribute == "fixed_column_bases") {

    return(
      arma::accu(arma::find_finite(fixed_column_bases)) == 0
    );

  } else if (attribute == "minimum_column_basis") {

    return(
      min_column_basis == "none"
    );

  } else if (attribute == "comment") {

    return(
      comment == ""
    );

  } else if (attribute == "transformation") {

    return(
      arma::approx_equal(
        transformation,
        arma::mat(ag_base_coords.n_cols, ag_base_coords.n_cols, arma::fill::eye),
        "absdiff", 0.0001
      )
    );

  } else if (attribute == "translation") {

    return(
      arma::approx_equal(
        translation,
        arma::mat(ag_base_coords.n_cols, 1, arma::fill::zeros),
        "absdiff", 0.0001
      )
    );

  } else if (attribute == "ag_reactivity") {

    return(
      arma::approx_equal(
        ag_reactivity_adjustments,
        arma::vec(ag_base_coords.n_rows, arma::fill::zeros),
        "absdiff", 0.0001
      )
    );

  } else if (attribute == "bootstrap") {

    return(
      bootstrap.size() == 0
    );

  } else {

    return(false);

  }

}


