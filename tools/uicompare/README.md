# Image Comparison Tool

A testing tool for comparing sets of images. This tool compares a baseline set of images against a current set and provides a visual interface to review differences.


## Setup baseline and current directory images

The tool expects two directories in the `tools/uicompare` directory:

- **`image-captures-baseline/`** - Contains the baseline (reference) images
- **`image-captures/`** - Contains the current (test) images to compare against the baseline

The tool will automatically discover all images in both directories and compare images with matching filenames. Supported image formats include PNG, JPG, and other formats supported by Qt's image loading.


## UI interface

The comparison tool provides a split-pane interface with the following features:

### Toolbar (top)
- **Statistics display**: Shows counts for total images, passed, failed, missing baseline, and missing current images
- **Filter buttons**: Filter the image list by status:
  - All images
  - Passed (images that match within tolerance)
  - Failed (images with differences)
  - Missing baseline (images only in current directory)
  - Missing current (images only in baseline directory)

### Image List (left pane)
- Displays all discovered images with their comparison status
- Color-coded indicators:
  - Green: Images match (pass)
  - Red: Images differ (fail)
  - Orange: Missing baseline or current image
- Shows similarity percentage and mean error values
- Click an item to view its comparison in the right pane

### Comparison View (right pane)
- Side-by-side view of baseline (left) and current (right) images
- Visual difference highlighting
- Image metadata display (dimensions, similarity metrics)
- Zoom and pan controls for detailed inspection

### Status Bar (bottom)
- Displays the currently selected image filename


## TODO

- Add keyboard shortcuts
- Image acceptance workflow, overwrite baseline with current
- Add configurable threshold slider
- Add mouse scroll zoom
- Add theming 
