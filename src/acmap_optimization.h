
#ifndef Racmacs__acmap_optimization__h
#define Racmacs__acmap_optimization__h

// Define the optimization class
class Optimization {

  public:
    arma::mat ag_coords;
    arma::mat sr_coords;
    double stress;

    Optimization(
      arma::mat ag_coords_input,
      arma::mat sr_coords_input,
      double stress_input
    ){
      ag_coords = ag_coords_input;
      sr_coords = sr_coords_input;
      stress = stress_input;
    }

};

#endif
