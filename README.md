
<!-- badges: start -->
[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
<!-- badges: end -->

<img src="man/figures/logo.png" align="right" style="width:200px; margin-top:40px">

# Racmacs
The Racmacs package provides a toolkit for making antigenic maps from assay data such as HI assays, as described in [Smith et al. 2004](https://doi.org/10.1126/science.1097211).

For a general introduction to using Racmacs to make an antigenic map from titer data see the article "[Making an antigenic map from titer data](https://acorg.github.io/Racmacs/articles/making-a-map-from-scratch.html)". For documentation of the functions available see the [references](https://acorg.github.io/Racmacs/reference/index.html) section.

## Installation instructions
### Install the devtools package
If not already installed, install the `devtools` package, this provides functions to help with installation.
```R
install.packages("devtools")
```

### Install Racmacs
Now you can install Racmacs directly from the latest development source code. In future pre-built binary versions will 
also be included.

```R
# To build from github source
devtools::install_github("acorg/Racmacs")
```

#### Building Racmacs to run code in parallel
Racmacs uses [OpenMP](https://www.openmp.org) instructions to specify when code, for example map optimization runs, can be run in parallel to increase performance. The resulting speed-up can be significant, but you need to check whether the compiler you use supports OpenMP. The default compiler on mac systems for example in `clang` which does not support OpenMP and will compile Racmacs as a single-threaded program.

Luckily in these cases it is relatively easy to install to install an alternative compiler like `gcc` which does support OpenMP and will compile Racmacs as a multi-threaded program. To do this you need to first install gcc and then tell R that you would like to use the gcc compiler instead.

__Installing gcc__  
The easiest way to install gcc is through [homebrew](https://brew.sh). First download homebrew if you haven't already then simply run:

```
brew install gcc
```

This will then install the `g++` compiler executable

__Changing the default compiler in R__  
To change the default compiler in R, you can specify this in your local `Makevars` file. This exists in the `.R` folder in your home folder, i.e. `~/.R/Makevars`. It is possible you will have to create the `.R` folder and the `Makevars` text file.

Once done, add the following lines to the `Makevars` file:

```
CXX=/usr/local/bin/g++-10
CXX1X=/usr/local/bin/g++-10
CXX11=/usr/local/bin/g++-10
SHLIB_CXXLD=/usr/local/bin/g++-10
FC=/usr/local/bin/gfortran-10
F77=/usr/local/bin/gfortran-10
MAKE=make -j8

SHLIB_OPENMP_CFLAGS=-fopenmp
SHLIB_OPENMP_CXXFLAGS=-fopenmp
SHLIB_OPENMP_FCFLAGS=-fopenmp
SHLIB_OPENMP_FFLAGS=-fopenmp
```

Now when you try and install and build the package from source things should be setup to use g++, with support for OpenMP parallization now included.

