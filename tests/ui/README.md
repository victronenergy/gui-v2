# Automated UI testing

The `gui-v2/tests/ui` directory contains automated UI unit tests. These are run in-process, if the `--ui-test` command-line option has been specified on startup.

For example, this runs the `smoke/mock-maximal` test when gui-v2 is loaded:

```
./bin/venus-gui-v2 --mock --ui-test smoke/mock-maximal
```

The `smoke/mock-maximal` test configuration specifies that the UI should also load the "maximal" mock configuration, so it is not necessary to set `--mock-conf maximal`.

In comparison, the `smoke/generic-capture` test does not specify a mock configuration, because the test simply captures all available screens regardless of the backend:

```
# Run `smoke/generic-capture` test on the default D-Bus backend
venus-gui-v2 --ui-test smoke/generic-capture

# Or run it on a mock backend against the `barebones` mock configuration
venus-gui-v2 --mock --mock-conf barebones --ui-test smoke/generic-capture
```


## Tests directory structure

UI tests are stored under `gui-v2/tests/ui`:

* `gui-v2/tests/ui/smoke` - "smoke tests", i.e. those run as a quick sanity check on the UI
* `gui-v2/tests/ui/<feature>` - feature test that verifies some feature in more detail

Each test is specified by a JSON configuration file, and one or more QML test files. The JSON file must have the same name as the test directory.

For example, the `gui-v2/tests/ui/smoke/mock-maximal` is a smoke test for the "maximal" mock configuration. That is, it captures all UI screens that are shown when gui-v2 is run in mock mode with the "maximal" configuration. The test contains these files:

* `mock-maximal.json` - configuration for the `mock-maximal` test
* `tst_cards.qml` - test for control cards and switch pane
* `tst_overview.qml` - test for Overview page and its drilldowns
* `tst_settings.qml` - test for Settings page and all of its child pages
* etc.


## Test configuration

Tests are configured with a JSON file; see `smoke/mock-maximal` for an example. The main configuration settings are:

* Tests - a list of QML test files
* Logging - enable a venus.gui.test logging type - e.g. "debug", "info". The default level is "info".
* Mock - when running in mock mode, sets the mock mode parameters
* Steps - contains configurations for UI test steps
  * For example, for the "CaptureAndCompare" step, if you set "ComparisonThreshold" to 0.1, then it will compare captured images with an error threshold of 0.1%.

Image captures are stored in the directory specified by the test JSON configuration; for the `mock-maximal` test, this is `<working-directory>/image-captures`. You may set `VENUS_GUI_TEST_CAPTURE_DIR` to override the configured image capture directory:

```
VENUS_GUI_TEST_CAPTURE_DIR=~/tests/ui/image-captures ./bin/venus-gui-v2 --mock --ui-test smoke/mock-maximal
```


## Headless mode

Add `--ui-test-headless` to run a test without saving or comparing any images:

```
./bin/venus-gui-v2 --ui-test smoke/mock-maximal --ui-test-headless
```

Each screen is still navigated to and rendered, but the capture is discarded instead of being
written to the image capture directory, so no image capture directory is needed. When the test
finishes, the result is printed to stdout (or stderr, if any step failed) regardless of the
configured logging level:

```
UI test 'smoke/mock-maximal' PASSED: All tests finished: 1170 steps passed, 0 steps failed, in 5m 12s
```

This makes the UI test usable as a quick smoke test of the UI, for example from a CI job.

Note that this is unrelated to the QPA platform: use `QT_QPA_PLATFORM=offscreen` to run gui-v2 on a
machine without a display, with or without `--ui-test-headless`.


## Exit code

If the test configuration sets `ExitWhenFinished`, gui-v2 exits when the tests are finished, with a
non-zero exit code if any test step failed. This applies whether or not `--ui-test-headless` is set.


## Continuous integration

The `.github/workflows/run-ui-tests.yml` workflow runs these tests on every pull request:

* the `UI smoke test` job runs `smoke/mock-maximal` with `--ui-test-headless`, and fails if any
  test step failed.
* the `UI image comparison` job captures the images of the pull request and of the commit it is
  based on, and compares the two image sets with `tools/uicompare` in headless mode. Differences do
  not fail the job - a pull request may change the UI on purpose - but they are reported in the job
  summary, and the images that differ are uploaded as a workflow artifact for review.

  Two image artifacts are produced: `ui-image-differences-above-noise` holds only the screens that
  differ by more than the noise floor (usually a handful), and `ui-image-differences` holds every
  differing screen. Each screen appears as a `<screen>-compare.png` showing baseline, candidate and
  the highlighted difference side by side, plus the two originals. GitHub strips images embedded in
  a job summary, so they cannot be shown inline in the summary itself.

  The job also sweeps the baseline build a second time and compares the two baseline sweeps with
  each other. Image captures are not perfectly reproducible, so that same-build comparison is the
  measurement error of the real one; the job summary reports it as a noise floor, and marks any
  screen whose difference is no larger than it. A difference count on its own cannot be told apart
  from noise, so do not read one without the noise floor beside it.

To do the same comparison locally, use `tools/ui_capture_and_compare.py`, which builds two
revisions and shows the differences in the UI Compare tool.


## UI test case API

QML test files must extend the `UiTestCase` type from the `Victron.UiTest` module.

The API follows QML TestCase conventions in that:

* Test functions are specified with a `test_` prefix
* Data functions can be specified with a `_data` suffix
* If `initTestCase()` and `cleanupTestCase()` are specified, they are run before and after all test functions
* If `init()` and `cleanup()` are specified, they are run before and after each test function (and if data functions are specified, `init()` and `cleanup()` are run before each data-associated function invocation)

Typically to run a test, you add a series of steps, then call `runSteps()` to asynchronously execute the steps. For example:

```
import Victron.UiTest

UiTestCase {
    window: Global.main

    function test_overview() {
        addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView, { text: "Overview" }))) } })
        addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
        addStep(UiTestStep.CaptureAndCompare, { imageName: "overview" })
        runSteps()
    }
}
```

Here, `test_overview` clicks the "Overview" button in the bottom navigation bar, waits until the stack view has animated the Overview page into view, then captures the overview page as an image named "overview". The `CaptureAndCompare` step compares the captured image against the "overview" image for the test, if one has been saved from a previous run.

NOTE: `runSteps()` is an asynchronous call. If you have any code after that call, that code will be executed before the steps have even started! If you need to run some code after the steps have completed, pass a callback to `runSteps()` instead.


### Recursive page captures

The `RecursivePageCapture` type provides a convenient way to recursively click through all list items on a page and capture their screens.

For example, this captures and compares all settings pages:

```
import Victron.UiTest

UiTestCase {
    id: root

    window: Global.main

    function test_settings() {
        addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView, { text: "Settings" }))) } })
        addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
        runSteps(recursivePageCapture.start)
    }

    RecursivePageCapture {
        id: recursivePageCapture
        testCase: root
    }
}
```

## Test infrastructure API

The `gui-v2/src` directory contains the C++ API:

* `uitest.h`: the entry point for running test cases inside gui-v2
* `uitestcase.h`: the UiTestCase definition for writing test cases
* `uiteststep.h`: defines the test steps that can be executed in a test case


## Other

UI test logging is configured via the "venus.gui.test" logging category.

This can be configured in the test configuration with the "Logging" key: for example, set this to "debug" to see debug-level logging. This is useful, for example, when a `findItem()' or `findObject()` call fails; there is additional debug-level logging that shows the failed object search path.


## TODO

Mock-maximal test still needs to test:
* Notifications page - clicking on a notification? Or maybe leave this to a notifications-specific test.
* Status bar buttons outside of control cards and switch pane
* Solar history chart - not captured by RecursivePageCapture because it is accessed by clicking a ComboBox rather than a list item
* Toast notifications
* Other?

Open questions:
* What are appropriate defaults for the `CaptureAndCompare` step? E.g. the capture interval, maximum capture attempts. 
  * The capture interval is needed because any page with a Repeater+Column will load those contents asynchronously. This may take a while (particularly when those contents are loaded based on some VeQuickItem value) so it may take up to several hundred ms on device to load the page as per the final expected content, and if you capture it too early, you will not get the desired image.
* Which features should be tested?
* Where will test images be stored?
* What is missing from the API? E.g. some different test step types?

Missing features:
* `RecursivePageCapture` does not click list buttons or radio buttons. This is for the best at the moment, as some buttons have write effects that change the UI and then might result in capture failures, but it also means we can't easily test features where buttons are clicked to open dialogs.
* `UiTestCase` should provide `keyPress` function for testing key navigation.
* Other?

