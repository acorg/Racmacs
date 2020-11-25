
#include "procrustes.h"

#ifndef Racmacs__acmap_optimization__h
#define Racmacs__acmap_optimization__h

// Define the optimization class
class AcOptimization {

  public:

    arma::vec colbases;
    arma::mat ag_base_coords;
    arma::mat sr_base_coords;
    std::string comment;
    arma::mat transformation;
    arma::mat translation;
    double stress;

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
