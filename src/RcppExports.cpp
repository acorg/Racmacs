// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include "Racmacs_types.h"
#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

// ac_ag_names
std::vector<std::string> ac_ag_names(const AcMap map);
RcppExport SEXP _Racmacs_ac_ag_names(SEXP mapSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const AcMap >::type map(mapSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_ag_names(map));
    return rcpp_result_gen;
END_RCPP
}
// ac_get_ag_coords
arma::mat ac_get_ag_coords(const AcOptimization opt);
RcppExport SEXP _Racmacs_ac_get_ag_coords(SEXP optSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const AcOptimization >::type opt(optSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_get_ag_coords(opt));
    return rcpp_result_gen;
END_RCPP
}
// ac_get_sr_coords
arma::mat ac_get_sr_coords(const AcOptimization opt);
RcppExport SEXP _Racmacs_ac_get_sr_coords(SEXP optSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const AcOptimization >::type opt(optSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_get_sr_coords(opt));
    return rcpp_result_gen;
END_RCPP
}
// ac_set_ag_coords
AcOptimization ac_set_ag_coords(AcOptimization opt, const arma::mat coords);
RcppExport SEXP _Racmacs_ac_set_ag_coords(SEXP optSEXP, SEXP coordsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< AcOptimization >::type opt(optSEXP);
    Rcpp::traits::input_parameter< const arma::mat >::type coords(coordsSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_set_ag_coords(opt, coords));
    return rcpp_result_gen;
END_RCPP
}
// ac_set_sr_coords
AcOptimization ac_set_sr_coords(AcOptimization opt, const arma::mat coords);
RcppExport SEXP _Racmacs_ac_set_sr_coords(SEXP optSEXP, SEXP coordsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< AcOptimization >::type opt(optSEXP);
    Rcpp::traits::input_parameter< const arma::mat >::type coords(coordsSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_set_sr_coords(opt, coords));
    return rcpp_result_gen;
END_RCPP
}
// ac_align_optimization
AcOptimization ac_align_optimization(AcOptimization source_optimization, const AcOptimization target_optimization);
RcppExport SEXP _Racmacs_ac_align_optimization(SEXP source_optimizationSEXP, SEXP target_optimizationSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< AcOptimization >::type source_optimization(source_optimizationSEXP);
    Rcpp::traits::input_parameter< const AcOptimization >::type target_optimization(target_optimizationSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_align_optimization(source_optimization, target_optimization));
    return rcpp_result_gen;
END_RCPP
}
// ac_subset_map
AcMap ac_subset_map(AcMap map, const arma::uvec ags, const arma::uvec sr);
RcppExport SEXP _Racmacs_ac_subset_map(SEXP mapSEXP, SEXP agsSEXP, SEXP srSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< AcMap >::type map(mapSEXP);
    Rcpp::traits::input_parameter< const arma::uvec >::type ags(agsSEXP);
    Rcpp::traits::input_parameter< const arma::uvec >::type sr(srSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_subset_map(map, ags, sr));
    return rcpp_result_gen;
END_RCPP
}
// ac_table_colbases
arma::vec ac_table_colbases(const AcTiterTable titer_table, const std::string min_col_basis);
RcppExport SEXP _Racmacs_ac_table_colbases(SEXP titer_tableSEXP, SEXP min_col_basisSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const AcTiterTable >::type titer_table(titer_tableSEXP);
    Rcpp::traits::input_parameter< const std::string >::type min_col_basis(min_col_basisSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_table_colbases(titer_table, min_col_basis));
    return rcpp_result_gen;
END_RCPP
}
// ac_table_distances
arma::mat ac_table_distances(const AcTiterTable titer_table, const arma::vec colbases);
RcppExport SEXP _Racmacs_ac_table_distances(SEXP titer_tableSEXP, SEXP colbasesSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const AcTiterTable >::type titer_table(titer_tableSEXP);
    Rcpp::traits::input_parameter< const arma::vec >::type colbases(colbasesSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_table_distances(titer_table, colbases));
    return rcpp_result_gen;
END_RCPP
}
// ac_dimension_test_map
DimTestOutput ac_dimension_test_map(AcTiterTable titer_table, arma::uvec dimensions_to_test, double test_proportion, std::string minimum_column_basis, bool column_bases_from_full_table, int num_optimizations, std::string method, int maxit, bool dim_annealing);
RcppExport SEXP _Racmacs_ac_dimension_test_map(SEXP titer_tableSEXP, SEXP dimensions_to_testSEXP, SEXP test_proportionSEXP, SEXP minimum_column_basisSEXP, SEXP column_bases_from_full_tableSEXP, SEXP num_optimizationsSEXP, SEXP methodSEXP, SEXP maxitSEXP, SEXP dim_annealingSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< AcTiterTable >::type titer_table(titer_tableSEXP);
    Rcpp::traits::input_parameter< arma::uvec >::type dimensions_to_test(dimensions_to_testSEXP);
    Rcpp::traits::input_parameter< double >::type test_proportion(test_proportionSEXP);
    Rcpp::traits::input_parameter< std::string >::type minimum_column_basis(minimum_column_basisSEXP);
    Rcpp::traits::input_parameter< bool >::type column_bases_from_full_table(column_bases_from_full_tableSEXP);
    Rcpp::traits::input_parameter< int >::type num_optimizations(num_optimizationsSEXP);
    Rcpp::traits::input_parameter< std::string >::type method(methodSEXP);
    Rcpp::traits::input_parameter< int >::type maxit(maxitSEXP);
    Rcpp::traits::input_parameter< bool >::type dim_annealing(dim_annealingSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_dimension_test_map(titer_table, dimensions_to_test, test_proportion, minimum_column_basis, column_bases_from_full_table, num_optimizations, method, maxit, dim_annealing));
    return rcpp_result_gen;
END_RCPP
}
// ac_merge_titers
AcTiter ac_merge_titers(std::vector<AcTiter> titers, double sd_lim);
RcppExport SEXP _Racmacs_ac_merge_titers(SEXP titersSEXP, SEXP sd_limSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::vector<AcTiter> >::type titers(titersSEXP);
    Rcpp::traits::input_parameter< double >::type sd_lim(sd_limSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_merge_titers(titers, sd_lim));
    return rcpp_result_gen;
END_RCPP
}
// ac_merge_titer_layers
AcTiterTable ac_merge_titer_layers(std::vector<AcTiterTable> titer_layers);
RcppExport SEXP _Racmacs_ac_merge_titer_layers(SEXP titer_layersSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::vector<AcTiterTable> >::type titer_layers(titer_layersSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_merge_titer_layers(titer_layers));
    return rcpp_result_gen;
END_RCPP
}
// ac_relaxOptimization
AcOptimization ac_relaxOptimization(const arma::mat& tabledist_matrix, const arma::umat& titertype_matrix, arma::mat ag_coords, arma::mat sr_coords, const std::string method, const int maxit, bool check_gradient_fn);
RcppExport SEXP _Racmacs_ac_relaxOptimization(SEXP tabledist_matrixSEXP, SEXP titertype_matrixSEXP, SEXP ag_coordsSEXP, SEXP sr_coordsSEXP, SEXP methodSEXP, SEXP maxitSEXP, SEXP check_gradient_fnSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const arma::mat& >::type tabledist_matrix(tabledist_matrixSEXP);
    Rcpp::traits::input_parameter< const arma::umat& >::type titertype_matrix(titertype_matrixSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type ag_coords(ag_coordsSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type sr_coords(sr_coordsSEXP);
    Rcpp::traits::input_parameter< const std::string >::type method(methodSEXP);
    Rcpp::traits::input_parameter< const int >::type maxit(maxitSEXP);
    Rcpp::traits::input_parameter< bool >::type check_gradient_fn(check_gradient_fnSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_relaxOptimization(tabledist_matrix, titertype_matrix, ag_coords, sr_coords, method, maxit, check_gradient_fn));
    return rcpp_result_gen;
END_RCPP
}
// random_coords
arma::mat random_coords(int nrow, int ndim, double min, double max);
RcppExport SEXP _Racmacs_random_coords(SEXP nrowSEXP, SEXP ndimSEXP, SEXP minSEXP, SEXP maxSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< int >::type nrow(nrowSEXP);
    Rcpp::traits::input_parameter< int >::type ndim(ndimSEXP);
    Rcpp::traits::input_parameter< double >::type min(minSEXP);
    Rcpp::traits::input_parameter< double >::type max(maxSEXP);
    rcpp_result_gen = Rcpp::wrap(random_coords(nrow, ndim, min, max));
    return rcpp_result_gen;
END_RCPP
}
// ac_runBoxedOptimization
AcOptimization ac_runBoxedOptimization(const arma::mat& tabledist_matrix, const arma::umat& titertype_matrix, const int& num_dims, const double coord_boxsize, const std::string method, const int maxit, const bool dim_annealing);
RcppExport SEXP _Racmacs_ac_runBoxedOptimization(SEXP tabledist_matrixSEXP, SEXP titertype_matrixSEXP, SEXP num_dimsSEXP, SEXP coord_boxsizeSEXP, SEXP methodSEXP, SEXP maxitSEXP, SEXP dim_annealingSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const arma::mat& >::type tabledist_matrix(tabledist_matrixSEXP);
    Rcpp::traits::input_parameter< const arma::umat& >::type titertype_matrix(titertype_matrixSEXP);
    Rcpp::traits::input_parameter< const int& >::type num_dims(num_dimsSEXP);
    Rcpp::traits::input_parameter< const double >::type coord_boxsize(coord_boxsizeSEXP);
    Rcpp::traits::input_parameter< const std::string >::type method(methodSEXP);
    Rcpp::traits::input_parameter< const int >::type maxit(maxitSEXP);
    Rcpp::traits::input_parameter< const bool >::type dim_annealing(dim_annealingSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_runBoxedOptimization(tabledist_matrix, titertype_matrix, num_dims, coord_boxsize, method, maxit, dim_annealing));
    return rcpp_result_gen;
END_RCPP
}
// ac_runOptimizations
std::vector<AcOptimization> ac_runOptimizations(const AcTiterTable& titertable, arma::vec& colbases, const int& num_dims, const int& num_optimizations, const std::string& method, const int& maxit, const bool& dim_annealing);
RcppExport SEXP _Racmacs_ac_runOptimizations(SEXP titertableSEXP, SEXP colbasesSEXP, SEXP num_dimsSEXP, SEXP num_optimizationsSEXP, SEXP methodSEXP, SEXP maxitSEXP, SEXP dim_annealingSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const AcTiterTable& >::type titertable(titertableSEXP);
    Rcpp::traits::input_parameter< arma::vec& >::type colbases(colbasesSEXP);
    Rcpp::traits::input_parameter< const int& >::type num_dims(num_dimsSEXP);
    Rcpp::traits::input_parameter< const int& >::type num_optimizations(num_optimizationsSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type method(methodSEXP);
    Rcpp::traits::input_parameter< const int& >::type maxit(maxitSEXP);
    Rcpp::traits::input_parameter< const bool& >::type dim_annealing(dim_annealingSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_runOptimizations(titertable, colbases, num_dims, num_optimizations, method, maxit, dim_annealing));
    return rcpp_result_gen;
END_RCPP
}
// reduce_matrix_dimensions
arma::mat reduce_matrix_dimensions(arma::mat m, int dim);
RcppExport SEXP _Racmacs_reduce_matrix_dimensions(SEXP mSEXP, SEXP dimSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< arma::mat >::type m(mSEXP);
    Rcpp::traits::input_parameter< int >::type dim(dimSEXP);
    rcpp_result_gen = Rcpp::wrap(reduce_matrix_dimensions(m, dim));
    return rcpp_result_gen;
END_RCPP
}
// numeric_titers
arma::vec numeric_titers(std::vector<AcTiter> titers);
RcppExport SEXP _Racmacs_numeric_titers(SEXP titersSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::vector<AcTiter> >::type titers(titersSEXP);
    rcpp_result_gen = Rcpp::wrap(numeric_titers(titers));
    return rcpp_result_gen;
END_RCPP
}
// log_titers
arma::vec log_titers(std::vector<AcTiter> titers);
RcppExport SEXP _Racmacs_log_titers(SEXP titersSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::vector<AcTiter> >::type titers(titersSEXP);
    rcpp_result_gen = Rcpp::wrap(log_titers(titers));
    return rcpp_result_gen;
END_RCPP
}
// titer_types_int
arma::uvec titer_types_int(std::vector<AcTiter> titers);
RcppExport SEXP _Racmacs_titer_types_int(SEXP titersSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::vector<AcTiter> >::type titers(titersSEXP);
    rcpp_result_gen = Rcpp::wrap(titer_types_int(titers));
    return rcpp_result_gen;
END_RCPP
}
// ac_procrustes
Procrustes ac_procrustes(arma::mat X, arma::mat Xstar, bool translation, bool dilation);
RcppExport SEXP _Racmacs_ac_procrustes(SEXP XSEXP, SEXP XstarSEXP, SEXP translationSEXP, SEXP dilationSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< arma::mat >::type X(XSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type Xstar(XstarSEXP);
    Rcpp::traits::input_parameter< bool >::type translation(translationSEXP);
    Rcpp::traits::input_parameter< bool >::type dilation(dilationSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_procrustes(X, Xstar, translation, dilation));
    return rcpp_result_gen;
END_RCPP
}
// ac_align_coords
arma::mat ac_align_coords(arma::mat source, arma::mat target, bool translation, bool dilation);
RcppExport SEXP _Racmacs_ac_align_coords(SEXP sourceSEXP, SEXP targetSEXP, SEXP translationSEXP, SEXP dilationSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< arma::mat >::type source(sourceSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type target(targetSEXP);
    Rcpp::traits::input_parameter< bool >::type translation(translationSEXP);
    Rcpp::traits::input_parameter< bool >::type dilation(dilationSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_align_coords(source, target, translation, dilation));
    return rcpp_result_gen;
END_RCPP
}
// euc_dist
double euc_dist(NumericVector& coords1, NumericVector& coords2);
RcppExport SEXP _Racmacs_euc_dist(SEXP coords1SEXP, SEXP coords2SEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericVector& >::type coords1(coords1SEXP);
    Rcpp::traits::input_parameter< NumericVector& >::type coords2(coords2SEXP);
    rcpp_result_gen = Rcpp::wrap(euc_dist(coords1, coords2));
    return rcpp_result_gen;
END_RCPP
}
// ac_mapDists
NumericMatrix ac_mapDists(NumericMatrix ag_coords, NumericMatrix sr_coords);
RcppExport SEXP _Racmacs_ac_mapDists(SEXP ag_coordsSEXP, SEXP sr_coordsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericMatrix >::type ag_coords(ag_coordsSEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type sr_coords(sr_coordsSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_mapDists(ag_coords, sr_coords));
    return rcpp_result_gen;
END_RCPP
}
// ac_pointStress
double ac_pointStress(double map_dist, double table_dist, bool less_than);
RcppExport SEXP _Racmacs_ac_pointStress(SEXP map_distSEXP, SEXP table_distSEXP, SEXP less_thanSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< double >::type map_dist(map_distSEXP);
    Rcpp::traits::input_parameter< double >::type table_dist(table_distSEXP);
    Rcpp::traits::input_parameter< bool >::type less_than(less_thanSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_pointStress(map_dist, table_dist, less_than));
    return rcpp_result_gen;
END_RCPP
}
// ac_coordStress
double ac_coordStress(NumericVector map_dist, NumericVector table_dist, LogicalVector less_than);
RcppExport SEXP _Racmacs_ac_coordStress(SEXP map_distSEXP, SEXP table_distSEXP, SEXP less_thanSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericVector >::type map_dist(map_distSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type table_dist(table_distSEXP);
    Rcpp::traits::input_parameter< LogicalVector >::type less_than(less_thanSEXP);
    rcpp_result_gen = Rcpp::wrap(ac_coordStress(map_dist, table_dist, less_than));
    return rcpp_result_gen;
END_RCPP
}
// grid_search
NumericVector grid_search(NumericMatrix test_coords, NumericMatrix pair_coords, NumericVector table_dist, NumericVector lessthans, NumericVector morethans, NumericVector na_vals);
RcppExport SEXP _Racmacs_grid_search(SEXP test_coordsSEXP, SEXP pair_coordsSEXP, SEXP table_distSEXP, SEXP lessthansSEXP, SEXP morethansSEXP, SEXP na_valsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericMatrix >::type test_coords(test_coordsSEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type pair_coords(pair_coordsSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type table_dist(table_distSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type lessthans(lessthansSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type morethans(morethansSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type na_vals(na_valsSEXP);
    rcpp_result_gen = Rcpp::wrap(grid_search(test_coords, pair_coords, table_dist, lessthans, morethans, na_vals));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_Racmacs_ac_ag_names", (DL_FUNC) &_Racmacs_ac_ag_names, 1},
    {"_Racmacs_ac_get_ag_coords", (DL_FUNC) &_Racmacs_ac_get_ag_coords, 1},
    {"_Racmacs_ac_get_sr_coords", (DL_FUNC) &_Racmacs_ac_get_sr_coords, 1},
    {"_Racmacs_ac_set_ag_coords", (DL_FUNC) &_Racmacs_ac_set_ag_coords, 2},
    {"_Racmacs_ac_set_sr_coords", (DL_FUNC) &_Racmacs_ac_set_sr_coords, 2},
    {"_Racmacs_ac_align_optimization", (DL_FUNC) &_Racmacs_ac_align_optimization, 2},
    {"_Racmacs_ac_subset_map", (DL_FUNC) &_Racmacs_ac_subset_map, 3},
    {"_Racmacs_ac_table_colbases", (DL_FUNC) &_Racmacs_ac_table_colbases, 2},
    {"_Racmacs_ac_table_distances", (DL_FUNC) &_Racmacs_ac_table_distances, 2},
    {"_Racmacs_ac_dimension_test_map", (DL_FUNC) &_Racmacs_ac_dimension_test_map, 9},
    {"_Racmacs_ac_merge_titers", (DL_FUNC) &_Racmacs_ac_merge_titers, 2},
    {"_Racmacs_ac_merge_titer_layers", (DL_FUNC) &_Racmacs_ac_merge_titer_layers, 1},
    {"_Racmacs_ac_relaxOptimization", (DL_FUNC) &_Racmacs_ac_relaxOptimization, 7},
    {"_Racmacs_random_coords", (DL_FUNC) &_Racmacs_random_coords, 4},
    {"_Racmacs_ac_runBoxedOptimization", (DL_FUNC) &_Racmacs_ac_runBoxedOptimization, 7},
    {"_Racmacs_ac_runOptimizations", (DL_FUNC) &_Racmacs_ac_runOptimizations, 7},
    {"_Racmacs_reduce_matrix_dimensions", (DL_FUNC) &_Racmacs_reduce_matrix_dimensions, 2},
    {"_Racmacs_numeric_titers", (DL_FUNC) &_Racmacs_numeric_titers, 1},
    {"_Racmacs_log_titers", (DL_FUNC) &_Racmacs_log_titers, 1},
    {"_Racmacs_titer_types_int", (DL_FUNC) &_Racmacs_titer_types_int, 1},
    {"_Racmacs_ac_procrustes", (DL_FUNC) &_Racmacs_ac_procrustes, 4},
    {"_Racmacs_ac_align_coords", (DL_FUNC) &_Racmacs_ac_align_coords, 4},
    {"_Racmacs_euc_dist", (DL_FUNC) &_Racmacs_euc_dist, 2},
    {"_Racmacs_ac_mapDists", (DL_FUNC) &_Racmacs_ac_mapDists, 2},
    {"_Racmacs_ac_pointStress", (DL_FUNC) &_Racmacs_ac_pointStress, 3},
    {"_Racmacs_ac_coordStress", (DL_FUNC) &_Racmacs_ac_coordStress, 3},
    {"_Racmacs_grid_search", (DL_FUNC) &_Racmacs_grid_search, 6},
    {NULL, NULL, 0}
};

RcppExport void R_init_Racmacs(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
