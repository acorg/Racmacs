
#include <RcppArmadillo.h>
#include "acmap_titers.h"
#include "ac_stress.h"
#include "ac_stress_blobs.h"

// For calculating the point stress at each grid point
double point_stress(
    arma::vec &mapdists,
    arma::vec &tabledists,
    arma::ivec &titertypes,
    double &dilution_stepsize
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
      titertypes(i),
      dilution_stepsize
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
StressBlobGrid ac_stress_blob_grid(
    arma::vec testcoords,
    arma::mat coords,
    arma::vec tabledists,
    arma::ivec titertypes,
    double stress_lim,
    double grid_spacing,
    double dilution_stepsize
){

  // Get the map dimensions
  arma::uword mapdims = coords.n_cols;

  // Set grid coordinates
  double xmin = arma::min(coords.col(0) - tabledists - stress_lim);
  double xmax = arma::max(coords.col(0) + tabledists + stress_lim);
  arma::vec xcoords = arma::regspace<arma::vec>( xmin, grid_spacing, xmax );

  double ymin = arma::min(coords.col(1) - tabledists - stress_lim);
  double ymax = arma::max(coords.col(1) + tabledists + stress_lim);
  arma::vec ycoords = arma::regspace<arma::vec>( ymin, grid_spacing, ymax );

  arma::vec zcoords;
  if(mapdims == 3){
    double zmin = arma::min(coords.col(2) - tabledists - stress_lim);
    double zmax = arma::max(coords.col(2) + tabledists + stress_lim);
    zcoords = arma::regspace<arma::vec>( zmin, grid_spacing, zmax );
  } else {
    zcoords = arma::vec{0};
  }

  // Calculate the initial point stress
  arma::vec mapdists(coords.n_rows);
  update_map_dists(mapdists, testcoords, coords);
  double base_stress = point_stress(
    mapdists,
    tabledists,
    titertypes,
    dilution_stepsize
  );

  // Setup results grid
  arma::cube stressmat(xcoords.n_elem, ycoords.n_elem, zcoords.n_elem);
  for(arma::uword i=0; i<xcoords.n_elem; i++){
    for(arma::uword j=0; j<ycoords.n_elem; j++){
      for(arma::uword k=0; k<zcoords.n_elem; k++){

        // Update map distances
        testcoords(0) = xcoords(i);
        testcoords(1) = ycoords(j);
        if(mapdims == 3){
          testcoords(2) = zcoords(k);
        }
        update_map_dists(mapdists, testcoords, coords);

        // Calculate point stress
        stressmat(i,j,k) = point_stress(
          mapdists,
          tabledists,
          titertypes,
          dilution_stepsize
        );

      }
    }
  }

  // Setup for output
  struct StressBlobGrid results{
    stressmat - base_stress,
    xcoords,
    ycoords,
    zcoords,
    stress_lim
  };

  // Return the matrix result
  return results;

}



