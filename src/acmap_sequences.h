
#include "acmap_optimization.h"
#include "acmap_titers.h"
#include "acmap_plotspec.h"

#ifndef Racmacs__acmap_sequences__h
#define Racmacs__acmap_sequences__h

// Define the generic point class
class SeqInsertion {

  public:
    arma::uword position;
    std::string insertion;

};

#endif
