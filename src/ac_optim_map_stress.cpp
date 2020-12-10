
#include <math.h>
#include <RcppArmadillo.h>
#include <roptim.h>
// #include <Rcpp/Benchmark/Timer.h>

#include "ac_stress.h"
#include "acmap_titers.h"
#include "acmap_optimization.h"

// We use the roptim package
using namespace roptim;

// Setup the map optimiser class
class MapOptimiser : public Functor {

  public:
    double operator()(const arma::vec &pars) override;
    void Gradient(const arma::vec &pars, arma::vec &grad) override;

    void update_map_coords(const arma::vec &pars);
    void update_map_dist_matrix();

    arma::mat tabledist_matrix;
    arma::umat titertype_matrix;
    int num_dims;

    arma::mat mapdist_matrix;
    arma::mat ag_coords;
    arma::mat sr_coords;
    int num_ags;
    int num_sr;

    // // For benchmarking
    // Rcpp::Timer timer;

    MapOptimiser(
      arma::mat ag_start_coords,
      arma::mat sr_start_coords,
      arma::mat tabledist,
      arma::umat titertype,
      int dims) {

      tabledist_matrix = tabledist;
      titertype_matrix = titertype;
      num_dims = dims;

      num_ags = tabledist_matrix.n_rows;
      num_sr = tabledist_matrix.n_cols;

      mapdist_matrix = arma::mat(num_ags, num_sr);
      ag_coords = ag_start_coords;
      sr_coords = sr_start_coords;

    }

    // Checking your gradient approximation
    void check_gradient_fn(const arma::vec &pars){

      update_map_coords(pars);
      update_map_dist_matrix();

      arma::vec grad1, grad2;
      Gradient(pars, grad1);
      ApproximateGradient(pars, grad2);

      Rcpp::Rcout << "Gradient checking" << std::endl;
      arma::mat gradc = arma::join_rows(grad1, grad2);
      gradc.print();

    }

    // // Benchmarking
    // Rcpp::NumericVector benchmark(const arma::vec &pars){
    //
    //   // start the timer
    //   timer.step("start");
    //
    //   // Record stress calculation
    //   operator()(pars);
    //
    //   // Record gradient calculation
    //   arma::vec grad;
    //   Gradient(pars, grad);
    //
    //   // Return the result
    //   Rcpp::NumericVector res(timer);
    //   return res;
    //
    // }

};


// code for evaluating objective function
double MapOptimiser::operator()(const arma::vec &pars) {

  // Set variables
  double stress;

  // Update coords from parameters and the distance matrix
  update_map_coords(pars);
  // timer.step("update_coords");
  update_map_dist_matrix();
  // timer.step("update_dist");

  // Set the start stress
  stress = 0;

  // Now we cycle through and sum up the stresses
  for(int ag = 0; ag < num_ags; ++ag) {
    for(int sr = 0; sr < num_sr; ++sr) {

      // Skip unmeasured titers
      if(titertype_matrix(ag,sr) == 0){
        continue;
      }

      // Now calculate the stress
      stress += ac_ptStress(
        mapdist_matrix(ag,sr),
        tabledist_matrix(ag,sr),
        titertype_matrix(ag,sr)
      );

    }
  }

  // timer.step("update_stress");

  // Return the map stress
  return stress;

}


// code for evaluating gradient
void MapOptimiser::Gradient(const arma::vec &pars, arma::vec &grad){

  // Set variables
  double gradient = 0;

  // Set the vector for gradients
  grad = arma::zeros<arma::vec>( pars.size() );

  // Now we cycle through each antigen and sera and calculate the gradient
  for(int ag = 0; ag < num_ags; ++ag) {
    for(int sr = 0; sr < num_sr; ++sr) {

      // Skip unmeasured titers
      if(titertype_matrix(ag,sr) == 0){
        continue;
      }

      // Calculate inc_base
      double ibase = inc_base(
        mapdist_matrix(ag,sr),
        tabledist_matrix(ag,sr),
        titertype_matrix(ag,sr)
      );

      // Now calculate the gradient for each coordinate
      for(int i = 0; i < num_dims; ++i) {
        gradient = ibase*(ag_coords(ag,i) - sr_coords(sr,i));
        grad(ag*num_dims+i) -= gradient;
        grad(sr*num_dims+i + num_ags*num_dims) += gradient;
      }

    }
  }

}

// Method to update the coordinates record from pars
void MapOptimiser::update_map_coords(const arma::vec &pars){

  int parnum = 0;
  for(int ag = 0; ag < num_ags; ++ag) {
    for(int i = 0; i < num_dims; ++i) {

      // Update the coordinates
      ag_coords(ag,i) = pars(parnum);
      parnum++;

    }
  }

  for(int sr = 0; sr < num_sr; ++sr) {
    for(int i = 0; i < num_dims; ++i) {

      // Update the coordinates
      sr_coords(sr,i) = pars(parnum);
      parnum++;

    }
  }

}


// Method to update the distance matrix from the coords
void MapOptimiser::update_map_dist_matrix(){

  for (int ag = 0; ag < num_ags; ag++) {
    for (int sr = 0; sr < num_sr; sr++) {

      // Only calculate distances where ag and sr were titrated
      if(titertype_matrix(ag,sr) != 0){

        // Calculate the euclidean distance
        double map_dist = 0;
        for(int i = 0; i < num_dims; ++i) {
          map_dist += pow(ag_coords(ag, i) - sr_coords(sr, i), 2);
        }
        mapdist_matrix(ag,sr) = sqrt(map_dist);

      }

    }
  }

}


//' @export
// [[Rcpp::export]]
double ac_relax_coords(
    const arma::mat &tabledist_matrix,
    const arma::umat &titertype_matrix,
    arma::mat &ag_coords,
    arma::mat &sr_coords,
    const std::string method,
    const int maxit,
    bool check_gradient_fn
){

  // Set variables
  int num_dims = ag_coords.n_cols;
  int num_ags  = ag_coords.n_rows;
  int num_sr   = sr_coords.n_rows;
  int parnum;

  // Create the map object for the map optimiser
  MapOptimiser map(
    ag_coords,
    sr_coords,
    tabledist_matrix,
    titertype_matrix,
    num_dims
  );

  // Create the vector of parameters
  arma::vec pars = arma::vec(num_ags*num_dims + num_sr*num_dims);
  parnum = 0;

  for(int ag = 0; ag < num_ags; ag++){
    for(int i = 0; i < num_dims; i++){
      pars(parnum) = ag_coords(ag, i);
      parnum++;
    }
  }

  for(int sr = 0; sr < num_sr; sr++){
    for(int i = 0; i < num_dims; i++){
      pars(parnum) = sr_coords(sr, i);
      parnum++;
    }
  }

  // Test the gradient function if requested
  if(check_gradient_fn){
    map.check_gradient_fn(pars);
  }

  // Perform the optimization
  Roptim<MapOptimiser> opt(method);
  opt.control.maxit = maxit;
  opt.minimize(map, pars);
  double stress = opt.value();

  // Update the coordinates to match the optimized coordinates
  map.update_map_coords(opt.par());

  // Return the result
  ag_coords = map.ag_coords;
  sr_coords = map.sr_coords;
  return stress;

};

// Generate a matrix of random coordinates
// [[Rcpp::export]]
arma::mat random_coords(
  int nrow,
  int ndim,
  double min,
  double max
){

  arma::mat random_coords(nrow, ndim, arma::fill::randu);
  return random_coords*(max-min) + min;

}

//' @export
// [[Rcpp::export]]
AcOptimization ac_runBoxedOptimization(
    const arma::mat &tabledist_matrix,
    const arma::umat &titertype_matrix,
    const int &num_dims,
    const double coord_boxsize,
    const std::string method = "L-BFGS-B",
    const int maxit = 1000,
    const bool dim_annealing = false
){

  // Infer variables
  int num_ags = tabledist_matrix.n_rows;
  int num_sr  = tabledist_matrix.n_cols;

  arma::mat ag_coords;
  arma::mat sr_coords;

  // With dimensional annealing
  if(dim_annealing && num_dims < 5){

    // Randomize the coordinates
    arma::mat ag_coords_start = random_coords(num_ags, 5, -coord_boxsize/2, coord_boxsize/2);
    arma::mat sr_coords_start = random_coords(num_sr, 5, -coord_boxsize/2, coord_boxsize/2);

    // Do a first optimization in higher dimensions
    ac_relax_coords(
      tabledist_matrix,
      titertype_matrix,
      ag_coords_start,
      sr_coords_start,
      method,
      maxit
    );

    // Reduce coordinate dimensions
    arma::mat coords = arma::join_cols(
      ag_coords_start,
      sr_coords_start
    );
    arma::mat coeff = arma::princomp(coords);
    ag_coords = ag_coords_start*coeff.cols(0, num_dims);
    sr_coords = sr_coords_start*coeff.cols(0, num_dims);

  }
  // Without dimensional annealing
  else {

    // Randomize the coordinates
    ag_coords = random_coords(num_ags, num_dims, -coord_boxsize/2, coord_boxsize/2);
    sr_coords = random_coords(num_sr, num_dims, -coord_boxsize/2, coord_boxsize/2);

  }

  // Return the relaxed optimization
  double stress = ac_relax_coords(
    tabledist_matrix,
    titertype_matrix,
    ag_coords,
    sr_coords,
    method,
    maxit
  );

  AcOptimization acopt(
    num_dims,
    ag_coords.n_rows,
    sr_coords.n_rows
  );
  acopt.set_ag_base_coords( ag_coords );
  acopt.set_sr_base_coords( sr_coords );
  acopt.set_stress( stress );
  return acopt;

};


// [[Rcpp::export]]
std::vector<AcOptimization> ac_runOptimizations(
    const AcTiterTable &titertable,
    arma::vec &colbases,
    const int &num_dims,
    const int &num_optimizations,
    const std::string &method,
    const int &maxit,
    const bool &dim_annealing
){

  // Get table distance matrix and titer type matrix
  arma::mat tabledist_matrix = titertable.table_distances(colbases);
  arma::umat titertype_matrix = titertable.get_titer_types();

  // First run a rough optimization using max table dist as the box size
  AcOptimization initial_optim = ac_runBoxedOptimization(
    tabledist_matrix,
    titertype_matrix,
    num_dims,
    tabledist_matrix.max(),
    method,
    100,
    dim_annealing
  );

  // Set boxsize based on initial optimization result
  arma::mat distmat = initial_optim.distance_matrix();
  double coord_maxdist = distmat.max();
  double coord_boxsize = coord_maxdist*2;

  // Run and return optimization results
  std::vector<AcOptimization> optimizations(num_optimizations);

  for(int i=0; i<num_optimizations; i++){

    // check for interrupt every 10 iterations
    if(i % 10 == 0){
      Rcpp::checkUserInterrupt();
    }

    optimizations[i] = ac_runBoxedOptimization(
      tabledist_matrix,
      titertype_matrix,
      num_dims,
      coord_boxsize,
      method,
      maxit,
      dim_annealing
    );

  }
  return optimizations;

}


bool compare_optimization_stress(
    AcOptimization opt1,
    AcOptimization opt2
  ){
  return (opt1.stress < opt2.stress);
}

void sort_optimizations_by_stress(
  std::vector<AcOptimization> &optimizations
){
  sort(
    optimizations.begin(),
    optimizations.end(),
    compare_optimization_stress
  );
}

// Use principle component analysis to reduce coordinates to lower dimensions
//' @export
// [[Rcpp::export]]
arma::mat reduce_matrix_dimensions(
    arma::mat m,
    int dim
){

  arma::mat coeff = arma::princomp(m);
  return m*coeff.cols(0, dim);

}


// //' @export
// // [[Rcpp::export]]
// Rcpp::NumericVector benchmark_relaxation(
//     const arma::mat &tabledist_matrix,
//     const arma::umat &titertype_matrix,
//     arma::mat ag_coords,
//     arma::mat sr_coords,
//     const std::string method = "L-BFGS-B",
//     const int maxit = 10000
// ){
//
//   // Set variables
//   int num_dims = ag_coords.n_cols;
//   int num_ags  = ag_coords.n_rows;
//   int num_sr   = sr_coords.n_rows;
//   int parnum;
//
//   // Create the map object for the map optimiser
//   MapOptimiser map(
//       ag_coords,
//       sr_coords,
//       tabledist_matrix,
//       titertype_matrix,
//       num_dims
//   );
//
//   // Create the vector of parameters
//   arma::vec pars = arma::vec(num_ags*num_dims + num_sr*num_dims);
//   parnum = 0;
//
//   for(int ag = 0; ag < num_ags; ag++){
//     for(int i = 0; i < num_dims; i++){
//       pars(parnum) = ag_coords(ag, i);
//       parnum++;
//     }
//   }
//
//   for(int sr = 0; sr < num_sr; sr++){
//     for(int i = 0; i < num_dims; i++){
//       pars(parnum) = sr_coords(sr, i);
//       parnum++;
//     }
//   }
//
//   // Perform benchmarking
//   return map.benchmark(pars);
//
// }
