
#include <math.h>
#include <RcppArmadillo.h>
#include <roptim.h>
// #include <Rcpp/Benchmark/Timer.h>

#include "acmap_optimization.h"

// We use the roptim
using namespace roptim;

// The threshold penalty function
double sigmoid(double &x){

  return(1/(1+exp(-10*x)));

}

// The derivative of the threshold penalty function
double d_sigmoid(double &x){

  return(sigmoid(x)*(1-sigmoid(x)));

}

// This is the point stress function
double ac_ptStress(double &map_dist,
                   double &table_dist,
                   unsigned int &titer_type){

  double x;
  double stress;

  switch(titer_type) {
  case 1:
    // Measurable titer
    stress = pow((table_dist - map_dist), 2);
    break;
  case 2:
    // Less than titer
    x = table_dist - map_dist + 1;
    // x = table_dist - map_dist; // Note that we drop the +1 here since this is now encoded in the distances
    stress = pow(x,2)*sigmoid(x);
    break;
  case 3:
    // More than titer
    stress = 0;
    break;
  default:
    // Missing titer
    stress = 0;
  }

  // Return the stress result
  return stress;

}


// This is the point stress function
double inc_base(
    double &map_dist,
    double &table_dist,
    unsigned int &titer_type
){

  double ibase;
  double x;

  // Deal with 0 map distance
  if(map_dist == 0){
    map_dist = 1e-5;
  }

  switch(titer_type) {
  case 1:
    // Measurable titer
    ibase = (2*(table_dist - map_dist)) / map_dist;
    break;
  case 2:
    // Less than titer
    x = table_dist - map_dist + 1;
    // x = table_dist - map_dist; // Note that we drop the +1 here since this is now encoded in the distances
    ibase = (10*x*x*d_sigmoid(x) + 2*x*sigmoid(x)) / map_dist;
    break;
  case 3:
    // More than titer
    ibase = 0;
    break;
  default:
    // Missing titer
    ibase = 0;
  }

  // Return the stress result
  return ibase;

}

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
      if(titertype_matrix(ag,sr) == 4){
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
      if(titertype_matrix(ag,sr) == 4){
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
      if(titertype_matrix(ag,sr) != 4){

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
AcOptimization ac_relaxOptimization(
    const arma::mat &tabledist_matrix,
    const arma::umat &titertype_matrix,
    arma::mat ag_coords,
    arma::mat sr_coords,
    const std::string method = "L-BFGS-B",
    const int maxit = 10000,
    bool check_gradient_fn = false
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
  AcOptimization acopt;
  acopt.ag_base_coords = map.ag_coords;
  acopt.sr_base_coords = map.sr_coords;
  acopt.stress = stress;
  return acopt;

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
    const int maxit = 100,
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
    AcOptimization optim = ac_relaxOptimization(
      tabledist_matrix,
      titertype_matrix,
      ag_coords_start,
      sr_coords_start,
      method,
      maxit
    );

    // Reduce coordinate dimensions
    arma::mat coords = arma::join_cols(
      optim.ag_base_coords,
      optim.sr_base_coords
    );
    arma::mat coeff = arma::princomp(coords);
    ag_coords = optim.ag_base_coords*coeff.cols(0, num_dims);
    sr_coords = optim.sr_base_coords*coeff.cols(0, num_dims);

  }
  // Without dimensional annealing
  else {

    // Randomize the coordinates
    ag_coords = random_coords(num_ags, num_dims, -coord_boxsize/2, coord_boxsize/2);
    sr_coords = random_coords(num_sr, num_dims, -coord_boxsize/2, coord_boxsize/2);

  }

  // Return the relaxed optimization
  return ac_relaxOptimization(
    tabledist_matrix,
    titertype_matrix,
    ag_coords,
    sr_coords,
    method,
    maxit
  );

};


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
