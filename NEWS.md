# Racmacs 1.1.11
* Added a `NEWS.md` file to track changes to the package.
* Added test and correction for error where coordinates of under-constrained points were set to NaN for the first optimization run only, not all.
* Added integrated support for setting antigen reactivity adjustments
* Fixed error displaying bootstrap and triangulation blobs for maps that had been rotated
* Bootstrap blobs will now show when doing a standard map plot
* Added ability to control grid size when calculating bootstrap blobs, controlling how finely they are calculated
* Added function `optimizeAgReactivityAdjustments()` for optimizing antigen reactivity adjustments
* Added function `agReactivityAdjustments()` for getting and setting reactivity adjustments
* Updated threejs library
* Fixed bug where points were displayed in incorrect positions in the viewer when the webgl maximum point size had been reached
* Added button to toggle point labels on and off
* Fixed error where ace files with no plotspec field would not read in
* Allow logical specification of antigens and sera for functions like `removeAntigens()`
* Check you do not try and remove all antigens or sera
* Added option to show map stress in plot
* Added ability to relax map points directly from the javascript viewer
* Added the function `mapGadget()` for opening up a map object in the GUI
* Fix error causing 3d arrows to not display
* Update the way point stress and residual is calculated for the stress and residual error table
* Added option to plot.acmap to indicate points outside of plot limits with an arrow
* Fixed error when performing dimensional annealing

# Racmacs 1.1.12
* Fix error in Racmacs when calculating antigen and sera mean stress per titer
* Fix error in viewer code when accounting for antigen reactivity adjustments in stress calculations

# Racmacs 1.1.13
* Add option in `plot.acmap()` to draw stress lines
* Add xlim and ylim options to `view.acmap()` to control how maps are displayed
* Add check to procrustes that there are sufficient matching points

# Racmacs 1.1.14
* Add option to save map in uncompressed format
* Add option to output json in pretty format
* Set default grid margin color to slightly darker than the grid color
* Correct error showing column bases in the viewer

# Racmacs 1.1.15
* Add option to set `dilutionStepsize()` for cases where dilution series did not follow 2-fold dilution steps

# Racmacs 1.1.16
* Fix error when minimum column basis is set to higher than any measurable titer
* Points not included in a procrustes will now be faded out when plotted with `plot()`, similar to the behaviour 
  already implemented in the `view()` function.
* Added the ability to set merge options when merging maps, controlling for example how much standard deviation 
  there has to be between merged titers before the merged titer gets excluded as unreliable.
* Added `mergeReport()` and `htmlMergeReport()` to output formatted tables showing how different titers have 
  been merged in a merged map.
* Functions like `logtiterTable()` and `mergeMaps()` now take account of the dilutionStepsize map setting
* Implement a new titer type '.', like '*' but to represent titers that are missing as a result
  of antigen sera combinations not being present in merged tables
* Fix error calculating bootstrap blobs and showing from a bootstrapped map where "resample" method 
  was used

# Racmacs 1.1.17
* Added `htmlMergeReport()` showing how titers were merged as a formatted html table.
* Added `htmlTiterTable()` for visualizing an html formatted titer table
* Added functions for getting titers after applying antigen reactivity adjustments set with `agReactivityAdjustments()<-`, namely `adjustedTiterTable()`, `adjustedLogTiterTable()`, `htmlAdjustedTiterTable()`
* Details are no longer saved in map json if they are map defaults
* Added an option to round titers to the nearest unit when outputting (for e.g. listmds compatibility)
* Adds the ability to apply and set scaling on an optimization
* Add option to optimize from scratch when performing optimizeAgReactivity
* Fix an error when performing procrustes with some coordinates set to NA
* Fix an error where transforming na coordinates in the viewer would give a numeric value
