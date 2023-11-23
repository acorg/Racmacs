
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
* Add an option to use arrowheads rather than arrows to show outlier points when plotting

# Racmacs 1.1.18
* Add option to edit titers in the titer table view and fix previous error that had been introduced stopping the table view
* Fix the map viewer stress calculations to account for the new "dilution stepsize" setting
* Add option to get and set antigen reactivity in the viewer
* Fix an error that was causing NAs to appear in transformed coordinates in linux builds

# Racmacs 1.1.19
* Add option to `procrustesData()` to included only specific antigens or sera, as can already be done for `procrustesMap()`
* Add methods to calculate point leverage, the effect of removing different strains and sera from the map, `agLeverage()`, `srLeverage()`, `titerLeverage()`
* Change the `view.acmap()` method to allow for an option `num_optimizations` to specify how many optimizations to send to the viewer.
* Add an option for and basic check by default for convergence of solutions when running map optimizations.

# Racmacs 1.1.20
* Slight re-implementation of dimensional annealing to not report progress bar multiple times.
* Added ability to include and exclude antigens and sera when optimizing in the javascript viewer by alt clicking the name in the browser or the titer in the interactive titer table.
* Added ability in the javascript viewer to change the antigen reactivity adjustment by selecting the antigen and editing the value as it appears in the `diagnostics` tab.
* Use quicker algorithm for calculating 2d density blobs
* Dimension testing now calculates proportion of titers to exclude as test set as proportion of measured titers, not proportion of detectable titers.
* Fixes an error when only one blob would be displayed in the viewer in cases where more than one blob was associated with a point
* Speed improvements to the calculation of contour blobs from point densities in 2-dimensions
* Added the option to set a description field for the map with the `mapDescription()` function

# Racmacs 1.1.21
* Full precision used in rapidjson when parsing doubles to load and save maps
* Added `numSeraGroups()` function
* Added "extra" field for antigens and sera, and corresponding `agExtra()` and `srExtra()` functions
* Antigen and serum groups will now be maintained and merged when running `mergeMaps()`
* Where maps have shared `dilutionStepsize()` settings, this will be applied to the merged map. Alternatively a warning will be issued and a default setting of 1 applied where they have different `dilutionStepsize()` settings.
* Add attribute getter `numLayers()` for returning the number of titer table layers in a map.
* `titerTable()<-` will now throw an error if the titer table applied does not have the same dimensions as the map in terms of number of antigens and sera
* When maps are merged the `mapName` will be used to name the titer table layers, layer names can also be get and set directly using the new `layerNames()` function

# Racmacs 1.1.22
* `agReactivityAdjustments` now becomes a property of the base acmap object rather than individual optimization runs

# Racmacs 1.1.23
* Fix `subsetMap()` to also subset ag reactivity adjustments!

# Racmacs 1.1.24
* Regions outside of plot border will now be masked when running `plot()` on a map

# Racmacs 1.1.25
* Throw an error instead of crashing when trying to do procrustes on maps with duplicate antigen/sera names/ids
* Add option to extend density blobs for e.g. bootstrapBlobs to extend beyond the range of the actual coordinates.

# Racmacs 1.1.26
* Add option to select the algorithm MASS::kde2d or ks::kde for calculating 2D density blobs.
* Add functions to help plot and inspect bootstrap blobs, `agBootstrapBlob()`, `srBootstrapBlob()`, `agBootstrapCoords()`, `srBootstrapCoords()`, `blob()`

# Racmacs 1.1.27
* `logtiterTable()` nows returns a table with named columns and rows
* Fix issue showing individual bootstrap points in 3D
* Add option `show_group_legend` to `view()` to show interactive legend based on `agGroups()` and `srGroups()` point groupings
* Add ability in viewer to filter and color antigens and sera by group

# Racmacs 1.1.28
* `agStress()` and `srStress()` fixed to work with NA coordinates
* Correct error when calculating `agStressPerTiter()` and `srStressPerTiter()` with missing titers.
* Antigen/Sera sequence and date information now write to json fields in line with acmacs-web.
* Add attribute getters and setters `agAnnotations()`, `srAnnotations()`, `agLabIDs()`

# Racmacs 1.1.29
* `mergeMaps()` now accepts maps as either separate arguments `mergeMaps(map1, map2)` or as a list `mergeMaps(list(map1, map2))`
* Additional checks for antigen and serum attribute inputs
* Error corrected where merging maps with multiple titer layers caused session to crash

# Racmacs 1.1.30
* Added support for setting indices of homologous antigens for sera with `srHomologousAgs()`

# Racmacs 1.1.31
* Added checks for disconnected groups of points and functions `mapCohesion()`, `agCohesion()`, `srCohesion()` to diagnose poorly connected groups of points
* Add support for point transparency set either through `agOpacity()` and `srOpacity()` or appropriate hex code to the point fill or outline attribute e.g. `"#FF000099"`.

# Racmacs 1.1.32
* Disconnected maps now return an error rather than a warning
* `agStressPerTiter()` and `srStressPerTiter()` now return a matrix with columns corresponding to stress per titer when nd values are excluded and when they are included
* Corrected error when coloring maps by stress or showing error lines with disconnected points
* If a titer table has column or row names but not sera or antigen names provided, names will be taken from the row and column names when creating a map.
* Add support for reading maps with brotli compression
* `agSequences()` and `srSequences()` now works when the stored sequences have different lengths or are missing for some points
* Correct error where maps with duplicate antigen or serum names would not optimize

# Racmacs 1.1.33
* Add some basic support for viewing 1D maps
* Fix an issue viewing sequence data where sequence data is not present for all antigens / sera
* Fix an error reoptimize merging maps with no optimizations
* Add verbosity argument to `mergeMaps()`
* Verbosity argument also suppresses optimization progress messages
* Issue a warning if duplicate antigen or serum names are found when creating a map

# Racmacs 1.1.34
* Add support for getting and setting serum species with `srSpecies()`.
* Redundant attributes `agNamesAbbreviated`, `agNamesFull`, `srNamesAbbreviated`, `srNamesFull` removed

# Racmacs 1.1.35
* Add antigen and sera attributes: `agLineage()`, `srLineage()`, `agReassortant()`, `srReassortant()`, `agStrings()`, `srStrings()`, `agContinent()`, `agNucleotideSequences()`, `srNucleotideSequences()` 

# Racmacs 1.1.36
* Fix error in reoptimized-merge
* `logtiterTableLayers()` function exported
* Fix error when blobs are smaller than grid-spacing used to calculate them
* Add the `blobsize()` function for calculating the area/volume of uncertainty blobs
* Removed function `triangulationBlobSize()` - now use e.g. `sapply(agTriangulationBlobs(map), blobsize)`
* 3D blob meshes are now separated into a list of contiguous meshes so that number of blobs can be retrieved from the length, i.e. `sapply(agTriangulationBlobs(map), length)`

# Racmacs 1.1.37
* Fix error where serum column base label would remain after turning titer labels off
* Set default margins of 0.5 inches when plotting a map
* Add support for insertions in amino acids sequences

# Racmacs 1.1.38
* Add option to specify a subset of antigens and sera for which to calculate blobs in the `bootstrapBlobs()` function
* Add method for plotting a map using ggplot i.e. `ggplot(map)`.
* When coloring by sequence a more distinct color palette is used

# Racmacs 1.1.39
* Correct error when plotting cases where blobs were calculated for only 1 antigen / serum
* Only show plot outlier arrowheads if point is marked as shown
* Numeric table distances account for dilution stepsize setting of map

# Racmacs 1.1.40
* Add some options to view.acmap to set the starting viewer translation, rotation and zoom
* Add `grid.lwd` option to control grid linewidth in `ggplot(map)`
* Add antigen and sera names to vector when retrieving antigen and sera attributes like `agFill()`

# Racmacs 1.2.0
* Add new options and default methods to use when merging titers as described for `RacMerge.options()`
* Return a more useful error if `bootstrapBlobs()` is run on a map where `bootstrapMap()` has not yet been performed.
* Add `grid.margin.lwd` option to control grid margin linewidth in `ggplot(map)`
* Improve user interruption of map optimization runs

# Racmacs 1.2.1
* Titer merge method changed so that sd limit is implemented before any merging to < values
* Expose further optimization options as user controllable options
* Add the option to set lighting using the r3js::light3js() function
* Add the option to set the viewer background color

# Racmacs 1.2.2
* Add argument in view.acmap to control set viewer background color

# Racmacs 1.2.3
* Fix error where light was not being added to the viewer properly

# Racmacs 1.2.4
* Add arguments to control procrustes arrow appearance in `plot.acmap()`

# Racmacs 1.2.5
* Allow for shorthand description of shapes e.g. "C" for "CIRCLE" in map .ace files.

# Racmacs 1.2.6
* Set the default number of cores to use as 2 unless otherwise specified in either RacOptimizer.options, or by setting the global option 'RacOptimizer.num_cores' with e.g. `options(RacOptimizer.num_cores = parallel::detectCores())`.

# Racmacs 1.2.7
* `on.exit()` calls added to code in `R/map_plot.R` and `inst/shinyapps/RacmacsGUI/app.R` where changes to graphical parameters and user options are made.
* `snapshotMap()` function removed.

# Racmacs 1.2.8
* Function `splitTiterLayers()` now exported.
* Use `readxl::read_excel()` for reading excel files instead of `gdata::read.xls()`
