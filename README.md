
# Racmacs package

## Installation instructions
### Install the devtools package
```R
install.packages("devtools")
```

### Install acmacs.r
Depending upon you operating system run one of the commands below

```R
# Mac
remotes::install_url("https://github.com/acorg/acmacs.r/releases/download/v4.0/acmacs.r_4.0_R_macOS-10.14.tgz", build = FALSE)

# Linux
remotes::install_url("https://github.com/acorg/acmacs.r/releases/download/v4.0/acmacs.r_4.0_R_x86_64-pc-linux-gnu.tar.gz", build = FALSE)
```

### Install Racmacs
Run one of the following

```R
# Install compiled binary package
remotes::install_url("https://github.com/acorg/Racmacs/releases/download/v1.0.5/Racmacs_1.0.5.tgz", build = FALSE)

# Building from github source
devtools::install_github("acorg/Racmacs")
```






