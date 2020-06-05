
#include <Rcpp.h>
#include <math.h>
using namespace Rcpp;

// Define external function prototypes
extern NumericMatrix ac_mapDists(NumericMatrix ag_coords,
                                 NumericMatrix sr_coords);

//' @export
// [[Rcpp::export]]
double ac_pointLogLik(
    double map_dist,
    double colbase,
    double max_logtiter,
    double min_logtiter,
    double error_sd,
    double ag_reactivity = 0
  ){

  double loglik;
  if (R_IsNA(max_logtiter)){
    loglik = R::pnorm5(min_logtiter, colbase - map_dist + ag_reactivity, error_sd,0,1);
  } else if(R_IsNA(min_logtiter)){
    loglik = R::pnorm5(max_logtiter, colbase - map_dist + ag_reactivity, error_sd,1,1);
  } else {
    loglik = R::logspace_sub(
      R::pnorm5(max_logtiter, colbase - map_dist + ag_reactivity, error_sd,1,1),
      R::pnorm5(min_logtiter, colbase - map_dist + ag_reactivity, error_sd,1,1)
    );
  }
  return(loglik);

}

//' @export
// [[Rcpp::export]]
double ac_srNegLogLik(
    double colbase,
    NumericVector map_dists,
    NumericVector max_logtiters,
    NumericVector min_logtiters,
    double error_sd
  ){

  double total_negll = 0;
  for(int i = 0; i < map_dists.length(); ++i){
    total_negll -= ac_pointLogLik(
      map_dists[i],
      colbase,
      max_logtiters[i],
      min_logtiters[i],
      error_sd
    );
  }
  return(total_negll);

}


//' @export
// [[Rcpp::export]]
double ac_optimizationNegLogLik(
    NumericMatrix ag_coords,
    NumericMatrix sr_coords,
    NumericMatrix max_logtiter_matrix,
    NumericMatrix min_logtiter_matrix,
    NumericMatrix na_val_matrix,
    NumericVector colbases,
    NumericVector ag_reactivitys,
    double error_sd,
    double colbase_mean = NA_REAL,
    double colbase_sd = NA_REAL,
    double ag_reactivity_sd = NA_REAL
  ){

  // Calculate map distances
  NumericMatrix map_dist_matrix = ac_mapDists(ag_coords, sr_coords);

  // Calculate negative log likelihood
  double total_negll = 0;
  int num_ags = ag_coords.nrow();
  int num_sr  = sr_coords.nrow();

  for(int ag = 0; ag < num_ags; ++ag) {
    for(int sr = 0; sr < num_sr; ++sr) {
      if(!na_val_matrix(ag,sr)){
        total_negll -= ac_pointLogLik(
          map_dist_matrix(ag,sr),
          colbases[sr],
          max_logtiter_matrix(ag,sr),
          min_logtiter_matrix(ag,sr),
          error_sd,
          ag_reactivitys[ag]
        );
      }
    }
  }

  // Add likelihood of colbases
  if (!R_IsNA(colbase_sd)){
    for(int sr = 0; sr < num_sr; ++sr) {
      total_negll -= R::dnorm4(colbases[sr], colbase_mean, colbase_sd, 1);
    }
  }

  // Add likelihood of ag reactivity
  if (!R_IsNA(ag_reactivity_sd)){
    for(int ag = 0; ag < num_ags; ++ag) {
      total_negll -= R::dnorm4(ag_reactivitys[ag], 0.0, ag_reactivity_sd, 1);
    }
  }

  // Return total stress
  return(total_negll);

}


void populate_matrix_pars(
  NumericMatrix *matrix,
  NumericVector *pars,
  int *start_par
){

  int stop_par = *start_par + (*matrix).nrow()*(*matrix).ncol();
  int n = 0;
  for (int i = *start_par; i < stop_par; i++) {
    (*matrix)[n] = (*pars)[i];
    n++;
  }
  *start_par = stop_par;

}


void populate_vector_pars(
  NumericVector *vector,
  NumericVector *pars,
  int *start_par
){

  int stop_par = *start_par + (*vector).length();
  int n = 0;
  for (int i = *start_par; i < stop_par; i++) {
    (*vector)[n] = (*pars)[i];
    n++;
  }
  *start_par = stop_par;

}


//' @export
// [[Rcpp::export]]
double ac_optimizationNegLogLikWrapper(
    NumericVector pars,
    NumericMatrix ag_coords,
    NumericMatrix sr_coords,
    NumericMatrix max_logtiter_matrix,
    NumericMatrix min_logtiter_matrix,
    NumericMatrix na_val_matrix,
    NumericVector colbases,
    NumericVector ag_reactivitys,
    double error_sd,
    double colbase_mean = NA_REAL,
    double colbase_sd = NA_REAL,
    double ag_reactivity_sd = NA_REAL,
    bool optim_ag_coords = true,
    bool optim_sr_coords = true,
    bool optim_colbases = false,
    bool optim_ag_reactivitys = false
){

  int start_par = 0;
  if(optim_ag_coords)            populate_matrix_pars(&ag_coords, &pars, &start_par);
  if(optim_sr_coords)            populate_matrix_pars(&sr_coords, &pars, &start_par);
  if(optim_colbases)             populate_vector_pars(&colbases, &pars, &start_par);
  if(optim_ag_reactivitys)       populate_vector_pars(&ag_reactivitys, &pars, &start_par);

  return(
    ac_optimizationNegLogLik(
      ag_coords,
      sr_coords,
      max_logtiter_matrix,
      min_logtiter_matrix,
      na_val_matrix,
      colbases,
      ag_reactivitys,
      error_sd,
      colbase_mean,
      colbase_sd,
      ag_reactivity_sd
    )
  );

}





