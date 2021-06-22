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
* Add option to show map stress in plot
* Add ability to relax map points directly from the javascript viewer
