
library(testthat)
context("Procrustes utils")
set.seed(100)

test_that("R and C++ give same procrustes result", {

  matrix1 <- matrix(rnorm(8), 4, 2)
  matrix2 <- matrix(rnorm(8), 4, 2)

  for(translation in c(TRUE, FALSE)){
    for(dilation in c(TRUE, FALSE)){

      mcmc_proc <- MCMCpack::procrustes(
        matrix1,
        matrix2,
        translation = translation,
        dilation = dilation
      )

      ac_proc <- Racmacs:::ac_procrustes(
        matrix1,
        matrix2,
        translation = translation,
        dilation = dilation
      )

      matrix12 <- Racmacs:::ac_align_coords(
        matrix1,
        matrix2,
        translation = translation,
        dilation = dilation
      )

      expect_equal(mcmc_proc$X.new, matrix12)
      expect_equal(mcmc_proc$R, ac_proc$R)
      expect_equal(mcmc_proc$tt, ac_proc$tt)
      expect_equal(mcmc_proc$s, ac_proc$s)

    }
  }

})

