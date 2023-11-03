import { _QtLoader } from "./qtloader.js";

let qtLoader = undefined;
function init() {
  var spinner = document.querySelector('#qtspinner');
  var canvas = document.querySelector('#screen');
  var status = document.querySelector('#qtstatus')

  qtLoader = new _QtLoader({
      canvasElements : [canvas],
      showLoader: function(loaderStatus) {
          spinner.style.display = 'block';
          canvas.style.display = 'none';
          status.innerHTML = loaderStatus + "...";
      },
      showError: function(errorText) {
          status.innerHTML = errorText;
          spinner.style.display = 'block';
          canvas.style.display = 'none';
      },
      showExit: function() {
          status.innerHTML = "Application exit";
          if (qtLoader.exitCode !== undefined)
              status.innerHTML += " with code " + qtLoader.exitCode;
          if (qtLoader.exitText !== undefined)
              status.innerHTML += " (" + qtLoader.exitText + ")";
          spinner.style.display = 'block';
          canvas.style.display = 'none';
      },
      showCanvas: function() {
          spinner.style.display = 'none';
          canvas.style.display = 'block';
      },
  });
  qtLoader.loadEmscriptenModule("venus-gui-v2");
}

init()
