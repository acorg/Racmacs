
#include <RcppArmadillo.h>
#include "acmap_titers.h"
#include "ac_stress.h"
#include "ac_stress_blobs.h"

// For calculating the point stress at each grid point
double point_stress(
    arma::vec &mapdists,
    arma::vec &tabledists,
    arma::uvec &titertypes
) {

  double stress = 0;

  for(arma::uword i=0; i<mapdists.n_elem; i++){

    // Skip unmeasured titers
    if(titertypes(i) == 0){
      continue;
    }

    // Now calculate the stress
    stress += ac_ptStress(
      mapdists(i),
      tabledists(i),
      titertypes(i)
    );

  }

  return stress;

}

// For updating the map distances
void update_map_dists(
    arma::vec &mapdists,
    arma::vec &testcoords,
    arma::mat &coords
){

  for(arma::uword n=0; n<mapdists.n_elem; n++){
    double dist = 0;
    for(arma::uword i = 0; i < coords.n_cols; ++i) {
      dist += pow(testcoords(i) - coords(n, i), 2);
    }
    mapdists(n) = sqrt(dist);
  }

}

// [[Rcpp::export]]
StressBlobGrid2d ac_stress_blob_grid_2d(
  arma::vec testcoords,
  arma::mat coords,
  arma::vec tabledists,
  arma::uvec titertypes,
  double stress_lim,
  double grid_spacing
){

  // Setup for grid
  double xmin = arma::min(coords.col(0) - tabledists - stress_lim);
  double xmax = arma::max(coords.col(0) + tabledists + stress_lim);
  double ymin = arma::min(coords.col(1) - tabledists - stress_lim);
  double ymax = arma::max(coords.col(1) + tabledists + stress_lim);

  // Set grid coordinates
  arma::vec xcoords = arma::regspace<arma::vec>( xmin, grid_spacing, xmax );
  arma::vec ycoords = arma::regspace<arma::vec>( ymin, grid_spacing, ymax );

  // Calculate the initial point stress
  arma::vec mapdists(coords.n_rows);
  update_map_dists(mapdists, testcoords, coords);
  double base_stress = point_stress(
    mapdists,
    tabledists,
    titertypes
  );

  // Setup results grid
  arma::mat zmat(xcoords.n_elem, ycoords.n_elem);
  for(arma::uword i=0; i<xcoords.n_elem; i++){
    for(arma::uword j=0; j<ycoords.n_elem; j++){

      // Update map distances
      testcoords(0) = xcoords(i);
      testcoords(1) = ycoords(j);
      update_map_dists(mapdists, testcoords, coords);

      // Calculate point stress
      zmat(i,j) = point_stress(
        mapdists,
        tabledists,
        titertypes
      );

    }
  }

  // Setup for output
  struct StressBlobGrid2d results{
    zmat - base_stress,
    xcoords,
    ycoords,
    stress_lim
  };

  // Return the matrix result
  return results;

}

