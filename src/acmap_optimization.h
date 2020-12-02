
#include "procrustes.h"
#include "utils.h"

#ifndef Racmacs__acmap_optimization__h
#define Racmacs__acmap_optimization__h

// Define the optimization class
class AcOptimization {

  private:

    arma::vec column_bases;
    std::string min_column_basis;
    arma::mat ag_base_coords;
    arma::mat sr_base_coords;
    std::string comment;
    arma::mat transformation;
    arma::mat translation;

  public:

    double stress = arma::datum::nan;

    // Getters
    arma::vec get_column_bases() const { return column_bases; }
    std::string get_min_column_basis() const { return min_column_basis; }
    arma::mat get_ag_base_coords() const { return ag_base_coords; }
    arma::mat get_sr_base_coords() const { return sr_base_coords; }
    std::string get_comment() const { return comment; }
    arma::mat get_transformation() const { return transformation; }
    arma::mat get_translation() const { return translation; }
    double get_stress() const { return stress; }

    // Setters
    void set_column_bases( arma::vec column_bases_in ){ column_bases = column_bases_in; }
    void set_min_column_basis( std::string min_column_basis_in ){ min_column_basis = min_column_basis_in; }
    void set_ag_base_coords( arma::mat ag_base_coords_in ){ ag_base_coords = ag_base_coords_in; }
    void set_sr_base_coords( arma::mat sr_base_coords_in ){ sr_base_coords = sr_base_coords_in; }
    void set_comment( std::string comment_in ){ comment = comment_in; }
    void set_transformation( arma::mat transformation_in ){ transformation = transformation_in; }
    void set_translation( arma::mat translation_in ){ translation = translation_in; }
    void set_stress( double stress_in ){ stress = stress_in; }

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
    arma::mat agCoords(){
      return transform_coords(
        ag_base_coords,
        transformation,
        translation
      );
    }

    // Retrieve sera coordinates
    arma::mat srCoords(){
      return transform_coords(
        sr_base_coords,
        transformation,
        translation
      );
    }

    // Retrieve point coordinates (ags then sr)
    arma::mat ptCoords(){
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

};

#endif
