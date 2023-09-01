## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Alterations upon resubmission

Redundant "R" removed from title.

Full name provided in the Author and Maintainer field.

Package description expanded and reference added describing the methods implemented.

Size of package tarball reduced.

Return value information added to all .Rd files where value information was 
found to be missing.

Looked for but could not find examples of cases where the user's home filespace 
or package directory are written to. Any further pointers on where potential 
violations of this policy were found would be greatly appreciated. Many thanks!

`on.exit()` calls added to code in `R/map_plot.R` and 
`inst/shinyapps/RacmacsGUI/app.R` where changes to graphical parameters and 
user options are made.
