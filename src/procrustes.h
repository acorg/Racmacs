
#ifndef Racmacs__procrustes__h
#define Racmacs__procrustes__h

struct Procrustes
{
  arma::mat R;
  arma::mat tt;
  double s;
};

Procrustes ac_procrustes(
    arma::mat X,
    arma::mat Xstar,
    bool translation = true,
    bool dilation = false
);

arma::mat transform_coords(
    arma::mat coords,
    arma::mat rotation,
    arma::mat translation,
    double scaling = 1
);

#endif

