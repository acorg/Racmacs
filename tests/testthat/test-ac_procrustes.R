
library(testthat)
context("Procrustes utils")
set.seed(100)

R_procrustes <- MCMCpack::procrustes

test_that("R and C++ give same procrustes result", {

  matrix1 <- matrix(rnorm(8), 4, 2)
  matrix2 <- matrix(rnorm(8), 4, 2)

  for (translation in c(TRUE, FALSE)) {
    for (dilation in c(TRUE, FALSE)) {

      mcmc_proc <- MCMCpack::procrustes(
        matrix1,
        matrix2,
        translation = translation,
        dilation = dilation
      )

      ac_proc <- ac_procrustes(
        matrix1,
        matrix2,
        translation = translation,
        dilation = dilation
      )

      matrix12 <- ac_align_coords(
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


test_that("R and C++ give same procrustes result in 3d", {

  matrix1 <- rbind(
    c(2.0000,   3.0000,        0),
    c(3.0000,   2.0000,        0),
    c(1.0000,   9.0000,        0),
    c(8.0000,   1.0000,        0),
    c(3.0000,        0,        0)
  )

  matrix2 <- rbind(
    c(0.7247,   3.0000,   1.8641),
    c(1.0871,   2.0000,   2.7961),
    c(0.3624,   9.0000,   0.9320),
    c(2.8989,   1.0000,   7.4563),
    c(1.0871,        0,   2.7961)
  )

  for (translation in c(TRUE, FALSE)) {
    for (dilation in c(TRUE, FALSE)) {

      mcmc_proc <- R_procrustes(
        matrix1,
        matrix2,
        translation = translation,
        dilation = dilation
      )

      ac_proc <- ac_procrustes(
        matrix1,
        matrix2,
        translation = translation,
        dilation = dilation
      )

      matrix12 <- ac_align_coords(
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
