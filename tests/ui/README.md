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


## Do not hide the window while a test run is in progress

A minimised (or otherwise unmapped) window receives no frame callbacks, and Qt waits
for a frame callback before rendering the next frame. Every QML animation therefore stops. For a
test run this means the page transition in progress never finishes: `StackView.busy` stays true,
`Global.mainView.animating` stays true, and the next `WaitUntil` on it times out. The run then
fails at whatever page it happened to be on when the window was hidden, with no QML error and
nothing wrong with the code under test.

So: leave the window alone while a run is in progress. Minimising it part-way through is enough
to fail the run.

For unattended runs, where nobody can promise not to touch the window, use the offscreen
platform. There is no window at all, so there is nothing to hide, and it still renders real
screenshots via software rasterisation, so CaptureAndCompare works normally:

```
QT_QPA_PLATFORM=offscreen ./bin/venus-gui-v2 --mock --ui-test smoke/mock-maximal
```

Offscreen is a safe default: running `smoke/mock-maximal` offscreen and on a real X server gives
the same 6198 steps, the same 0 failures, the same 1662 missing values and the same 1271 captures.

The captured *images* are not interchangeable between the two, though. Every one of those 1271
captures differs, on about 13% of its pixels - the content and layout are identical, and only the
rasterisation of glyphs and edges changes. So a baseline captured offscreen will not compare clean
against a run on a real display, and vice versa. Pick one platform for a given set of baselines
and stay on it.

Offscreen is also the more reproducible of the two: two offscreen runs of the same build produced
byte-identical files for 1269 of the 1271 captures.

Two things follow when reading a failed run:

* If a run ends after far fewer steps than usual, suspect this before suspecting the change under
  test. Offscreen, a healthy run of `smoke/generic-capture` on the `maximal` mock configuration
  completes 4148 steps with 0 failures, and `smoke/mock-maximal` 6198. Repeated runs of an
  unchanged configuration have scored anywhere between 7 and a full sweep purely from this. Re-run
  before concluding anything, and re-run each arm at least twice when bisecting - this noise is
  easily mistaken for a real result, and has already produced one confident but wrong bisect.
* A single `Step timed out!` is normally followed by a cascade of `Callable returned false!` and
  `mouseClick(): invalid item!` failures. That is one stall poisoning the rest of the test case,
  not several distinct problems. Note also that `cleanup()` runs between test functions but not
  between test *files*, so a stall in one test file can fail the file that follows it; check a
  test on its own before blaming it.


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
* MockConfiguration - the mock configuration that the test requires, e.g.
  ":/data/mock/conf/maximal.json". Set this only if the test is designed for one particular
  configuration; if it is not set, the caller chooses the configuration with --mock-conf. It is an
  error to pass --mock-conf for a test that names its own configuration.
  Note that the mock timers are always turned off for a UI test, so that the mock data randomizers
  cannot change values between runs and break the image comparisons.
* Steps - contains configurations for UI test steps
  * For example, for the "CaptureAndCompare" step, if you set "ComparisonThreshold" to 0.1, then it will compare captured images with an error threshold of 0.1%.

Image captures are stored in the directory specified by the test JSON configuration; for the `mock-maximal` test, this is `<working-directory>/image-captures`. You may set `VENUS_GUI_TEST_CAPTURE_DIR` to override the configured image capture directory:

```
VENUS_GUI_TEST_CAPTURE_DIR=~/tests/ui/image-captures ./bin/venus-gui-v2 --mock --ui-test smoke/mock-maximal
```

## UI test case API

QML test files must extend the `UiTestCase` type from the `Victron.UiTest` module.

The API follows QML TestCase conventions in that:

* Test functions are specified with a `test_` prefix
* Data functions can be specified with a `_data` suffix
* If `initTestCase()` and `cleanupTestCase()` are specified, they are run before and after all test functions
* If `init()` and `cleanup()` are specified, they are run before and after each test function (and if data functions are specified, `init()` and `cleanup()` are run before each data-associated function invocation)

**Give a test case a `cleanup()` that pops the page stack.** A test function does not always get to
finish tidily: when a step fails, `UiTestStepGroup` does not run the `runSteps()` callback, so the
rest of that function's steps - including anything that would have popped its pages - never run.
`cleanup()` still runs, because it is a test function in its own right, so it is the place to
guarantee that the next test function starts from a known state:

```qml
function cleanup() {
    Global.pageManager.popAllPages(PageStack.Immediate)

    // No steps have been added, so call goToNextTestFunction() instead of runSteps().
    goToNextTestFunction()
}
```

Pop with `PageStack.Immediate`: the default is animated, and a click is ignored while the page stack
animates, so the next test function's first navigation would be swallowed. Without a `cleanup()`,
one failed capture cost two failures instead of one - the next test function, which did not even use
`RecursivePageCapture`, could not click the status bar because the abandoned pages were covering it.

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


## Checking which pages a test run reached

Each `RecursivePageCapture` capture step logs the url of the page it captured, e.g.

```
[2: CaptureAndCompare: tst_all-Settings_Devices_1: Devices [url: /pages/settings/devicelist/DeviceListPage.qml]]
```

Comparing those urls against the pages that the UI can push shows which parts of the UI the backend
data does not reach. For a mock backend, that is a list of gaps in the mock configurations:

```
# All pages that can be pushed by url
grep -rhoE '"/pages/[A-Za-z0-9_/-]+\.qml"' --include=*.qml . | tr -d '"' | sort -u > all-pages.txt

# All pages reached by the test runs
grep -ho "url: [^]]*" *.log | sed 's/url: //' | sort -u > visited-pages.txt

comm -23 all-pages.txt visited-pages.txt
```

**This is a starting point, not a coverage report.** It only sees pages that are pushed by url. A
page is just as often pushed as a `Component`, and `PageStack.pushPage()` records an empty url for
anything that is not a string, so such a page appears in neither list: it is not matched by the
grep for `"/pages/....qml"`, and its capture step logs no `[url: ...]` at all. For example:

```qml
onClicked: Global.pageManager.pushPage(canBusComponent, { title: text, canbusProfile: canbusProfile })

Component {
    id: canBusComponent

    PageSettingsCanbus { }
}
```

Those pages *are* captured by the sweep - only the url bookkeeping cannot see them. In a
`smoke/generic-capture` run against `maximal`, 345 of the 848 capture steps logged no url, 337 of
them nested pages pushed this way (the rest are the main view's own screens, which are not on the
page stack at all). So an empty `comm` output means "every page that is pushed by url was reached",
which is a much weaker statement than "every page in the UI was reached". Read the missing entries
it does report, but do not treat the empty case as proof of full coverage.

See also the `--mock-coverage` option, described in `data/mock/conf/README.md`, which reports the
individual values that the UI asked for but that the mock configuration does not provide.


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
* `RecursivePageCapture` clicks the first clickable child of a list item, so it cannot navigate list items whose first clickable child does something else. For example, the `ListDevicePriority` items on the Opportunity Loads page have re-ordering buttons before the navigation area, so the pages they navigate to (`PageControllableLoadsBattery.qml`, `PageControllableLoadsEVCS.qml`, `PageControllableLoadsS2Rm.qml`) are not captured.
* `UiTestCase` should provide `keyPress` function for testing key navigation.
* Other?

