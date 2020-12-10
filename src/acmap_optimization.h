
#include <RcppArmadillo.h>
#include "procrustes.h"
#include "utils.h"
#include "acmap_titers.h"
#include "ac_relax_coords.h"

#ifndef Racmacs__acmap_optimization__h
#define Racmacs__acmap_optimization__h

// Define the optimization class
class AcOptimization {

  private:

    arma::vec fixed_column_bases;
    std::string min_column_basis;
    arma::mat ag_base_coords;
    arma::mat sr_base_coords;
    std::string comment;
    arma::mat transformation;
    arma::mat translation;

  public:

    double stress = arma::datum::nan;

    // Constructors
    AcOptimization(){};
    AcOptimization(
      const int &dimensions,
      const int &num_antigens,
      const int &num_sera
    ){

      ag_base_coords = arma::mat(num_antigens, dimensions, arma::fill::zeros);
      sr_base_coords = arma::mat(num_sera, dimensions, arma::fill::zeros);
      transformation = arma::mat(dimensions, dimensions, arma::fill::eye);
      translation    = arma::mat(dimensions, 1, arma::fill::zeros);

    }

    // Getters
    std::string get_min_column_basis() const { return min_column_basis; }
    arma::vec get_fixed_column_bases() const { return fixed_column_bases; }
    arma::mat get_ag_base_coords() const { return ag_base_coords; }
    arma::mat get_sr_base_coords() const { return sr_base_coords; }
    std::string get_comment() const { return comment; }
    arma::mat get_transformation() const { return transformation; }
    arma::mat get_translation() const { return translation; }
    double get_stress() const { return stress; }

    // Setters
    void set_ag_base_coords( arma::mat ag_base_coords_in ){ ag_base_coords = ag_base_coords_in; }
    void set_sr_base_coords( arma::mat sr_base_coords_in ){ sr_base_coords = sr_base_coords_in; }
    void set_comment( std::string comment_in ){ comment = comment_in; }
    void set_transformation( arma::mat transformation_in ){ transformation = transformation_in; }
    void set_translation( arma::mat translation_in ){ translation = translation_in; }
    void set_stress( double stress_in ){ stress = stress_in; }

    void set_fixed_column_bases( arma::vec fixed_column_bases_in ){
      min_column_basis = "fixed";
      if(fixed_column_bases_in.n_elem != sr_base_coords.n_rows){
        Rcpp::stop("Fixed column base length does not match the number of sera");
      }
      fixed_column_bases = fixed_column_bases_in;
    }

    void set_min_column_basis(
      const std::string min_column_basis_in
    ){

      // Input checking
      if(min_column_basis_in == "fixed"){
        Rcpp::stop("A 'fixed' minimum column basis can only be set by specifying a set of fixed column bases");
      }
      // else if (min_column_basis_in != "none"){
      //   // check_titer_validity(min_column_basis_in);
      // }

      min_column_basis = min_column_basis_in;
      fixed_column_bases.reset();

    }

    // Get dimensions
    int dim() const {
      return ag_base_coords.n_cols;
    }

    int num_ags() const {
      return ag_base_coords.n_rows;
    }

    int num_sr() const {
      return sr_base_coords.n_rows;
    }

    // Retrieve point base coordinates (ag then sera)
    arma::mat ptBaseCoords(){
      return arma::join_cols(
        ag_base_coords,
        sr_base_coords
      );
    }

    // Retrieve antigen coordinates
    arma::mat agCoords() const{
      return transform_coords(
        ag_base_coords,
        transformation,
        translation
      );
    }

    // Retrieve sera coordinates
    arma::mat srCoords() const{
      return transform_coords(
        sr_base_coords,
        transformation,
        translation
      );
    }

    // Retrieve point coordinates (ags then sr)
    arma::mat ptCoords() const{
      return arma::join_cols(
        agCoords(),
        srCoords()
      );
    }

    // Bake in the current transformation into the base coordinates
    void bake_transformation(){

      // Set the base coordinates
      set_ag_base_coords(agCoords());
      set_sr_base_coords(srCoords());

      // Reset transformation and translation
      set_transformation(
        arma::mat(dim(), dim(), arma::fill::eye)
      );
      set_translation(
        arma::mat(dim(), 1, arma::fill::zeros)
      );

    }

    // Set ag coordinates
    void set_ag_coords(
      arma::mat coords
    ){
      bake_transformation();
      set_ag_base_coords(coords);
    }

    // Set sr coordinates
    void set_sr_coords(
        arma::mat coords
    ){
      bake_transformation();
      set_sr_base_coords(coords);
    }

    // Align to another optimization
    void alignToOptimization(
      AcOptimization target
    ){

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
    arma::mat distance_matrix(
    ) const {

      int nags = num_ags();
      int nsr = num_sr();

      arma::mat distmat( nags, nsr );
      for(int ag=0; ag<nags; ag++){
        for(int sr=0; sr<nsr; sr++){
          distmat(ag, sr) = ptDist(ag, sr);
        }
      }

      return distmat;

    }

    // Calculate point distance
    double ptDist(
      int ag,
      int sr
    ) const {

      return euc_dist(
        arma::vectorise(ag_base_coords.row(ag)),
        arma::vectorise(sr_base_coords.row(sr))
      );

    }

    // Calculate the column bases
    arma::vec calc_colbases(
       AcTiterTable titers
    ){
      if(min_column_basis == "fixed"){
        return fixed_column_bases;
      } else {
        return titers.colbases(min_column_basis);
      }
    }

    // Relax the optimization
    void relax(
      AcTiterTable titers,
      std::string method = "L-BFGS-B",
      int maxit = 10000
    ){

      stress = ac_relax_coords(
        titers.table_distances(
          calc_colbases(titers)
        ),
        titers.get_titer_types(),
        ag_base_coords,
        sr_base_coords,
        method,
        maxit
      );

    }

};

#endif
