
#include <RcppArmadillo.h>

double volume_of_tetrahedron(
    const arma::rowvec &p1,
    const arma::rowvec &p2,
    const arma::rowvec &p3
  ) {

  double v321 = p3[0]*p2[1]*p1[2];
  double v231 = p2[0]*p3[1]*p1[2];
  double v312 = p3[0]*p1[1]*p2[2];
  double v132 = p1[0]*p3[1]*p2[2];
  double v213 = p2[0]*p1[1]*p3[2];
  double v123 = p1[0]*p2[1]*p3[2];
  return (-v321 + v231 + v312 - v132 - v213 + v123) / 6;

}


// [[Rcpp::export]]
double mesh_volume(
    const arma::umat &faces,
    const arma::mat &vertices
  ) {

  double volume = 0;
  arma::rowvec v1;
  arma::rowvec v2;
  arma::rowvec v3;

  for (arma::uword n = 0; n < faces.n_rows; n++) {

    v1 = vertices.row(faces(n, 0));
    v2 = vertices.row(faces(n, 1));
    v3 = vertices.row(faces(n, 2));
    volume += volume_of_tetrahedron(v1, v2, v3);

  }

  return volume;

}


// [[Rcpp::export]]
double polygon_area(
    const arma::vec &x,
    const arma::vec &y
) {

  double area = 0;
  arma::uword i0;
  for (arma::uword i = 0; i < x.n_elem; i++) {

    // Get previous vertex
    i == 0 ? i0 = x.n_elem - 1 : i0 = i - 1;
    area += (-x[i0]*y[i] + x[i]*y[i0]) / 2;

  }

  return area;

}

