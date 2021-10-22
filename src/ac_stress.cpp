
#include <RcppArmadillo.h>

// The threshold penalty function
double sigmoid(double &x){

  return(1/(1+exp(-10*x)));

}

// The derivative of the threshold penalty function
double d_sigmoid(double &x){

  return(sigmoid(x)*(1-sigmoid(x)));

}

// This is the point stress function
double ac_ptStress(
    double &map_dist,
    double &table_dist,
    arma::sword &titer_type,
    double &dilution_stepsize
  ){

  double x;
  double stress;

  switch(titer_type) {
  case 1:
    // Measurable titer
    stress = pow((table_dist - map_dist), 2);
    break;
  case 2:
    // Less than titer
    x = table_dist - map_dist + dilution_stepsize;
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

// This is the point residual function
double ac_ptResidual(
    double &map_dist,
    double &table_dist,
    arma::sword &titer_type,
    double &dilution_stepsize
){

  double x;
  double residual;

  switch(titer_type) {
  case 1:
    // Measurable titer
    residual = table_dist - map_dist;
    break;
  case 2:
    // Less than titer
    x = table_dist - map_dist + dilution_stepsize;
    residual = x*sigmoid(x);
    break;
  case 3:
    // More than titer
    residual = 0;
    break;
  default:
    // Missing titer
    residual = 0;
  }

  // Return the residual result
  return -residual;

}


// This is for calculating the inc_base part of the stress gradient function
double inc_base(
    double &map_dist,
    double &table_dist,
    arma::sword &titer_type,
    double &dilution_stepsize
  ){

  double ibase;
  double x;

  // Deal with 0 map distance
  if (map_dist == 0) {
    map_dist = 1e-5;
  }

  switch(titer_type) {
  case 1:
    // Measurable titer
    ibase = (2*(table_dist - map_dist)) / map_dist;
    break;
  case 2:
    // Less than titer
    x = table_dist - map_dist + dilution_stepsize;
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


