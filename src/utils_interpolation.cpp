/*
 The interp2d function here is derived from the grid.interp.2d function in the "ks"
 package (https://cran.r-project.org/package=ks), with modifications from S.H.Wilks to
 make it compatible with the armadillo C++ library, and as such is release under the
 GPL-2 | GPL-3 licence as included with the original code version.
*/
//________________________________________________

#include <RcppArmadillo.h>

// [[Rcpp::export]]
arma::vec interp2d(
    arma::mat x,
    arma::vec gpoints1,
    arma::vec gpoints2,
    arma::mat f
  ) {

  // Set variables
  arma::uword n = x.n_rows;
  arma::vec x1 = x.col(0);
  arma::vec x2 = x.col(1);
  int M1 = gpoints1.n_elem;
  int M2 = gpoints2.n_elem;
  double a1 = gpoints1(0);
  double a2 = gpoints2(0);
  double b1 = gpoints1(M1 - 1);
  double b2 = gpoints2(M2 - 1);
  arma::vec fun = arma::vectorise(f);
  arma::vec est(n, arma::fill::zeros);

  double fx1, fx2, xdelta1, xdelta2, xpos1, xpos2;
  arma::uword i, ix1, ix2, ixmax1, ixmin1, ixmax2, ixmin2, MM1, MM2;

  MM1 = M1;
  MM2 = M2;
  ixmin1 = 0;
  ixmax1 = MM1 - 2;
  ixmin2 = 0;
  ixmax2 = MM2 - 2;
  xdelta1 = (b1 - a1) / (MM1 - 1);
  xdelta2 = (b2 - a2) / (MM2 - 1);

  // assign linear binning weights
  for (i=0; i < n; i++) {
    if(R_FINITE(x1[i]) && R_FINITE(x2[i])) {
      xpos1 = (x1[i] - a1) / xdelta1;
      xpos2 = (x2[i] - a2) / xdelta2;
      ix1 = floor(xpos1);
      ix2 = floor(xpos2);
      fx1 = xpos1 - ix1;
      fx2 = xpos2 - ix2;

      if(ixmin1 <= ix1 && ix1 <= ixmax1 && ixmin2 <= ix2 && ix2 <= ixmax2) {
	est[i] = fun[ix2*MM1 + ix1]*(1-fx1)*(1-fx2) \
               + fun[ix2*MM1 + ix1 + 1]*fx1*(1-fx2) \
               + fun[(ix2+1)*MM1 + ix1]*(1-fx1)*fx2 \
               + fun[(ix2+1)*MM1 + ix1 + 1]*fx1*fx2;
      }
      else if(ix1 == ixmax1 + 1 && ixmin2 <= ix2 && ix2 <= ixmax2) {
        est[i] = fun[ix2*MM1 + ix1]*(1-fx1)*(1-fx2) \
               + fun[(ix2+1)*MM1 + ix1]*(1-fx1)*fx2;
      }
      else if (ixmin1 <= ix1 && ix1 <= ixmax1 && ix2 == ixmax2 + 1) {
	est[i] = fun[ix2*MM1 + ix1]*(1-fx1)*(1-fx2) \
               + fun[ix2*MM1 + ix1 + 1]*fx1*(1-fx2);
      }
      else if (ix1 == ixmax1 + 1 && ix2 == ixmax2 + 1) {
        est[i] = fun[ix2*MM1 + ix1]*(1-fx1)*(1-fx2);
      }
    }
  }

  // Return the estimate
  return est;

}

