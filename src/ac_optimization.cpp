
#include <RcppArmadillo.h>
#include "acmap_optimization.h"

// For optimization sorting
bool compare_optimization_stress(
    AcOptimization opt1,
    AcOptimization opt2
){
  if(!std::isfinite(opt1.stress)){
    return false;
  }
  if(!std::isfinite(opt2.stress)){
    return true;
  }
  return (opt1.stress < opt2.stress);
}

void sort_optimizations_by_stress(
    std::vector<AcOptimization> &optimizations
){

  sort(
    optimizations.begin(),
    optimizations.end(),
    compare_optimization_stress
  );

}


// For optimization alignment
void align_optimizations(
    std::vector<AcOptimization> &optimizations
){

  if(optimizations.size() > 1){
    for(arma::uword i=1; i<optimizations.size(); i++){
      optimizations.at(i).alignToOptimization(optimizations.at(0));
    }
  }

}

