# Racmacs 1.1.11

* Added a `NEWS.md` file to track changes to the package.
* Added test and correction for error where coordinates of under-constrained points were set to NaN for the first optimization run only, not all.
* Added integrated support for setting antigen reactivity adjustments
* Fixed error displaying bootstrap and triangulation blobs for maps that had been rotated
* Bootstrap blobs will now show when doing a standard map plot
* Added ability to control grid size when calculating bootstrap blobs, controlling how finely they are calculated
* Added function `optimizeAgReactivityAdjustments()`
* Updated threejs library
* Fixed bug where points were displayed in incorrect positions in the viewer when the webgl maximum point size had been reached
* Added button to toggle point labels on and off
