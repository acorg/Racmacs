
#include <RcppArmadillo.h>
#include "procrustes.h"
#include "utils.h"
#include "ac_titers.h"
#include "acmap_titers.h"
#include "ac_optimizer_options.h"
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
      min_column_basis = "none";
      fixed_column_bases = arma::vec(num_sera);
      fixed_column_bases.fill(arma::datum::nan);

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
    int get_dimensions() const { return ag_base_coords.n_cols; }

    // Setters
    void set_ag_base_coords( arma::mat ag_base_coords_in ){ ag_base_coords = ag_base_coords_in; }
    void set_sr_base_coords( arma::mat sr_base_coords_in ){ sr_base_coords = sr_base_coords_in; }
    void set_comment( std::string comment_in ){ comment = comment_in; }
    void set_transformation( arma::mat transformation_in ){ transformation = transformation_in; }
    void set_translation( arma::mat translation_in ){ translation = translation_in; }
    void set_stress( double stress_in ){ stress = stress_in; }

    void set_fixed_column_bases( arma::vec fixed_column_bases_in ){
      if(fixed_column_bases_in.n_elem != sr_base_coords.n_rows){
        Rf_error("Fixed column base length does not match the number of sera");
      }
      fixed_column_bases = fixed_column_bases_in;
    }

    void set_min_column_basis(
      const std::string min_column_basis_in
    ){

      // Check min col basis validity
      if(min_column_basis_in != "none"){
        check_valid_titer(min_column_basis_in);
      }

      // Set min col basis
      min_column_basis = min_column_basis_in;

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
      return titers.colbases(
        min_column_basis,
        fixed_column_bases
      );
    }

    // Reduce dimensions of optimization through principle component analysis
    void reduceDimensions(
      int dims
    ){

      // Reduce coordinate dimensions
      arma::mat coords = arma::join_cols(
        ag_base_coords,
        sr_base_coords
      );
      arma::mat coeff = arma::princomp(coords);
      ag_base_coords = ag_base_coords*coeff.cols(0, dims);
      sr_base_coords = sr_base_coords*coeff.cols(0, dims);

    }

    // Randomise coordinates
    void randomizeCoords(
      double boxsize
    ){

      double min = -boxsize/2.0;
      double max = boxsize/2.0;
      ag_base_coords.randu();
      sr_base_coords.randu();
      ag_base_coords = ag_base_coords*(max-min) + min;
      sr_base_coords = sr_base_coords*(max-min) + min;

    }

    // Relax the optimization
    void relax_from_raw_matrices(
      const arma::mat &tabledist_matrix,
      const arma::umat &titertype_matrix,
      const AcOptimizerOptions options
    ){

      stress = ac_relax_coords(
        tabledist_matrix,
        titertype_matrix,
        ag_base_coords,
        sr_base_coords,
        options
      );

    }

    void relax_from_titer_table(
      AcTiterTable titers,
      const AcOptimizerOptions options
    ){

      relax_from_raw_matrices(
        titers.table_distances(
          calc_colbases(titers)
        ),
        titers.get_titer_types(),
        options
      );

    }

};

#endif
