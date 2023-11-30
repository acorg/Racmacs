## R CMD check results

0 errors | 0 warnings | 1 note

Resubmission to fix failing CRAN checks:

- One test is skipped if pandoc is not available on the system
- Some changes made to try and address the warning "format string is not a 
string literal (potentially insecure) [-Wformat-security]", although note 
that Rcpp also throws this warning on r-devel-linux-x86_64-fedora-clang and 
r-devel-linux-x86_64-debian-clang
