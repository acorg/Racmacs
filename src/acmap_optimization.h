
#include "procrustes.h"

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
    double stress = arma::datum::nan;

  public:

    // Getters
    arma::vec get_column_bases(){ return column_bases; }
    std::string get_min_column_basis(){ return min_column_basis; }
    arma::mat get_ag_base_coords(){ return ag_base_coords; }
    arma::mat get_sr_base_coords(){ return sr_base_coords; }
    std::string get_comment(){ return comment; }
    arma::mat get_transformation(){ return transformation; }
    arma::mat get_translation(){ return translation; }

    // Setters
    void set_column_bases( arma::vec column_bases_in ){ column_bases = column_bases_in; }
    void set_min_column_basis( std::string min_column_basis_in ){ min_column_basis = min_column_basis_in; }
    void set_ag_base_coords( arma::mat ag_base_coords_in ){ ag_base_coords = ag_base_coords_in; }
    void set_sr_base_coords( arma::mat sr_base_coords_in ){ sr_base_coords = sr_base_coords_in; }
    void set_comment( std::string comment_in ){ comment = comment_in; }
    void set_transformation( arma::mat transformation_in ){ transformation = transformation_in; }
    void set_translation( arma::mat translation_in ){ translation = translation_in; }

    // Retrieve antigen base coordinates
    arma::mat agBaseCoords(){
      return ag_base_coords;
    }

    // Retrieve sera base coordinates
    arma::mat srBaseCoords(){
      return sr_base_coords;
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

};

#endif
