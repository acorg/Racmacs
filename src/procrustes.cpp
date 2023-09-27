
#include <RcppArmadillo.h>
#include "acmap_map.h"
#include "procrustes.h"
#include "utils.h"
using namespace Rcpp;

// Define a procrustes transformation
// [[Rcpp::export]]
Procrustes ac_procrustes(
  arma::mat X,
  arma::mat Xstar,
  bool translation,
  bool dilation
){

  // Check input
  if(X.n_rows != Xstar.n_rows){ Rf_error("X and Xstar do not have same number of rows."); }

  // Exclude NaN coords
  arma::uvec na_rows = arma::join_cols( na_row_indices(X), na_row_indices(Xstar) );
  na_rows = arma::unique(na_rows);

  X.shed_rows(na_rows);
  Xstar.shed_rows(na_rows);

  // Expand coords to match maximum dimensions
  int dims = arma::max( arma::uvec{ X.n_cols, Xstar.n_cols } );
  X.resize(X.n_rows, dims);
  Xstar.resize(X.n_rows, dims);

  // Perform the calculation
  int n = X.n_rows;
  int m = X.n_cols;

  arma::mat J = arma::mat(n,n,arma::fill::eye);
  if(translation){
    J -= (1.0/n);
  }

  arma::mat tX = arma::trans(X);
  arma::mat tXstar = arma::trans(Xstar);

  arma::mat C = tXstar * J * X;


  arma::vec svd_d;
  arma::mat svd_u;
  arma::mat svd_v;
  arma::svd(
    svd_u,
    svd_d,
    svd_v,
    C
  );

  arma::mat R = svd_v * svd_u.t();
  double s = 1.0;

  if(dilation){

    arma::mat mat1 = tXstar * J * X * R;
    arma::mat mat2 = tX * J * X;

    double s_numer = 0.0;
    double s_denom = 0.0;

    for(int i=0; i<m; i++){
      s_numer += mat1(i,i);
      s_denom += mat2(i,i);
    }

    s = s_numer / s_denom;

  }

  arma::mat tt = arma::mat(m, 1, arma::fill::zeros);
  if(translation){

    arma::mat mat1 = arma::mat(n, 1, arma::fill::ones);
    arma::mat tmatmid = arma::trans(Xstar - s * X * R);
    tt = ((1.0/n) * tmatmid)*mat1;

  }

  Procrustes out;
  out.R = R;
  out.tt = tt;
  out.s = s;
  return out;

}


// Apply a procrustes transformation
arma::mat ac_apply_procrustes(
    arma::mat coords,
    Procrustes p
){

  return transform_coords(
    coords,
    p.R,
    p.tt,
    p.s
  );

}

// Align coordinates via procrustes
// [[Rcpp::export]]
arma::mat ac_align_coords(
    arma::mat source,
    arma::mat target,
    bool translation = true,
    bool dilation = false
){

  Procrustes p = ac_procrustes(
    source,
    target,
    translation,
    dilation
  );

  return ac_apply_procrustes(source, p);

}

// Apply a coordinate transformation
arma::mat transform_coords(
  const arma::mat &coords,
  const arma::mat &rotation,
  const arma::mat &translation,
  const double &scaling
) {

  // Work out maximum dims
  int dims = arma::max(
    arma::uvec{
      coords.n_cols,
      rotation.n_cols,
      translation.n_rows
    }
  );

  // Expand matrices to match maximum dimensions
  arma::mat tcoords(coords.n_rows, dims, arma::fill::zeros);
  tcoords.cols(0, coords.n_cols - 1) = coords;

  arma::mat trotation(dims, dims, arma::fill::eye);
  if(rotation.n_rows > 0){
    trotation.submat(
      0, 0,
      rotation.n_rows - 1, rotation.n_cols - 1
    ) = rotation;
  }

  arma::mat ttranslation(coords.n_rows, dims, arma::fill::zeros);
  for(arma::uword i=0; i<ttranslation.n_rows; i++){
    for(arma::uword j=0; j<translation.n_rows; j++){
      ttranslation(i,j) = translation(j,0);
    }
  }

  // Perform the transformation
  arma::mat out = (scaling*tcoords)*trotation + ttranslation;
  return out;

}

// Get procrustes result from one map to another
// [[Rcpp::export]]
AcCoords ac_procrustes_map_coords(
  const AcMap &base_map,
  AcMap procrustes_map,
  int base_map_optimization_number,
  int procrustes_map_optimization_number,
  bool translation = true,
  bool scaling = false
){

  // First realign the map to the base map
  procrustes_map.keepSingleOptimization( procrustes_map_optimization_number );
  procrustes_map.realign_to_map(
    base_map,
    base_map_optimization_number,
    translation,
    scaling,
    true // align_to_base_coords
  );

  // Return the coordinates of the realigned map
  AcCoords result;
  result.ag_coords = subset_rows( procrustes_map.optimizations.at(0).agCoords(), ac_match_points( base_map.antigens, procrustes_map.antigens ) );
  result.sr_coords = subset_rows( procrustes_map.optimizations.at(0).srCoords(), ac_match_points( base_map.sera, procrustes_map.sera ) );

  // Set coords that were na in the main map to na in the procrustes coords
  arma::uvec na_ags = arma::find_nonfinite(base_map.optimizations.at(base_map_optimization_number).get_ag_base_coords());
  arma::uvec na_srs = arma::find_nonfinite(base_map.optimizations.at(base_map_optimization_number).get_sr_base_coords());
  result.ag_coords.elem(na_ags).fill(arma::datum::nan);
  result.sr_coords.elem(na_srs).fill(arma::datum::nan);

  // Return the coordinates
  return result;

}

// Get a summary of procrustes data
// [[Rcpp::export]]
ProcrustesData ac_procrustes_map_data(
    const AcOptimization &optimization,
    AcCoords pc_coords
){

  // Calculate data
  arma::vec ag_dists = ac_coord_dists( optimization.get_ag_base_coords(), pc_coords.ag_coords );
  arma::vec sr_dists = ac_coord_dists( optimization.get_sr_base_coords(), pc_coords.sr_coords );
  double ag_rmsd = rmsd(ag_dists);
  double sr_rmsd = rmsd(sr_dists);
  double total_rmsd = rmsd( arma::join_cols(ag_dists, sr_dists) );

  // Return the summary of data
  return ProcrustesData{
    ag_dists,
    sr_dists,
    ag_rmsd,
    sr_rmsd,
    total_rmsd
  };

}

