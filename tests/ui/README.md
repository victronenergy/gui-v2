# Automated UI testing

The `gui-v2/tests/ui` directory contains automated UI unit tests. These are run in-process, if the `--ui-test` command-line option has been specified on startup.

For example, this runs the `mock-maximal` test when gui-v2 is loaded:

```
./bin/venus-gui-v2 --mock --ui-test smoke/mock-maximal
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

See `smoke/mock-maximal` for an example. The main configuration settings are:

* Tests - a list of QML test files
* Logging - enable a venus.gui.test logging type - e.g. "debug", "info". The default level is "info".
* Mock - when running in mock mode, sets the mock mode parameters
* Steps - contains configurations for UI test steps

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
        runSteps(recursivePageCapture.start, ["settings"])
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

