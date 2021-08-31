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

