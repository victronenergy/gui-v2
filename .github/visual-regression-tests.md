# Visual regression tests

This document covers the image-capture-based visual regression testing system. It does **not** cover unit tests (see [Unit Tests](.github/unit-tests.md) for those).

**Future changes must not cause visual regressions.** Use the visual test system to verify that UI modifications produce the expected output.

## Overview

The visual regression test system works by:
1. Running gui-v2 in automated test mode with mock data
2. Navigating through the UI programmatically (clicking buttons, opening pages)
3. Capturing screenshots at each step
4. Comparing captured images against a known-good baseline using a separate comparison tool

## Running visual tests

### Capturing images

```bash
# Run the full smoke test suite (captures all pages)
./bin/venus-gui-v2 --mock --ui-test smoke/mock-maximal

# Override the capture output directory
VENUS_GUI_TEST_CAPTURE_DIR=~/my-captures ./bin/venus-gui-v2 --mock --ui-test smoke/mock-maximal
```

The `--mock` flag starts the application with the mock backend (no real hardware needed). The `--ui-test <path>` flag specifies the test configuration to run, relative to `tests/ui/`.

By default, captured images are stored in `<working-directory>/image-captures/` (configurable in the test JSON).

### Comparing images

The comparison tool lives in `tools/uicompare/`. It expects:
- `tools/uicompare/image-captures-baseline/` — known-good reference images
- `tools/uicompare/image-captures/` — newly captured candidate images

```bash
# Build and run the comparison tool
cd tools/uicompare
cmake -B build && cmake --build build
./build/bin/uicompare
```

The tool provides a side-by-side visual interface showing differences, with pass/fail status for each image based on a similarity threshold.

## Workflow for verifying changes

1. **Before your change**: run the visual tests to capture a baseline set of images
2. **Make your change**
3. **After your change**: run the visual tests again to capture candidate images
4. **Compare**: use the `uicompare` tool to review differences between baseline and candidate
5. **Review**: confirm that only expected differences appear (e.g. your intentional UI change) and no unintended regressions

For changes that intentionally modify the UI appearance, update the baseline images after confirming the new captures are correct.

## Test configuration

Each test is defined by a JSON file (e.g. `tests/ui/smoke/mock-maximal/mock-maximal.json`):

```json
{
    "ExitWhenFinished": true,
    "Logging": "info",
    "Tests": [
        "tst_brief.qml",
        "tst_overview.qml",
        "tst_settings.qml"
    ],
    "Mock": {
        "Configuration": ":/data/mock/conf/maximal.json",
        "TimersActive": false,
        "UIAnimations": 0
    },
    "Steps": {
        "CaptureAndCompare": {
            "ImageDir": "image-captures",
            "StabilizationInterval": 16,
            "MaximumStabilizationCaptures": 20,
            "FailIfComparisonFails": false
        },
        "WaitUntil": {
            "DefaultTimeout": 5000
        }
    }
}
```

Key configuration fields:

| Field | Purpose |
|-------|---------|
| `ExitWhenFinished` | Exit the application when all tests complete |
| `Tests` | List of QML test case files to execute in order |
| `Mock.Configuration` | JSON file defining mock device/service data |
| `Mock.TimersActive` | Whether mock timers animate values (false for stable captures) |
| `Mock.UIAnimations` | UI animation duration override (0 disables animations for deterministic captures) |
| `Steps.CaptureAndCompare.ImageDir` | Output directory for captured images |
| `Steps.CaptureAndCompare.StabilizationInterval` | Milliseconds between capture attempts while waiting for page stabilization |
| `Steps.CaptureAndCompare.MaximumStabilizationCaptures` | Max retries waiting for a stable frame |
| `Steps.WaitUntil.DefaultTimeout` | Max milliseconds to wait for a condition |

## Writing visual test cases

### Test file structure

Test files use the `UiTestCase` type from `Victron.UiTest`:

```qml
import QtQuick
import Victron.VenusOS
import Victron.UiTest

UiTestCase {
    id: root

    window: Global.main

    function test_myPage() {
        // Navigate to the page
        addStep(UiTestStep.Invoke, { callable: ()=> {
            return mouseClick(findClickableChild(findItem(Global.mainView, { text: "Overview" })))
        } })
        // Wait for animation to complete
        addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
        // Capture and compare
        addStep(UiTestStep.CaptureAndCompare, { imageName: "my_page_overview" })
        runSteps()
    }
}
```

### Step types

| Step Type | Purpose | Parameters |
|-----------|---------|------------|
| `UiTestStep.Invoke` | Execute a function (e.g. click a button) | `{ callable: () => { ... } }` |
| `UiTestStep.WaitUntil` | Wait for a condition to become true | `{ callable: () => bool }` |
| `UiTestStep.Wait` | Wait a fixed duration | `{ duration: milliseconds }` |
| `UiTestStep.CaptureAndCompare` | Capture a screenshot and compare to baseline | `{ imageName: "name" }` |
| `UiTestStep.Abort` | Abort the current test | — |

### Key API methods

Provided by `UiTestCase`:

| Method | Purpose |
|--------|---------|
| `addStep(type, params)` | Queue a test step |
| `runSteps(callback?)` | Execute all queued steps asynchronously |
| `goToNextTestFunction()` | Proceed to next test function (use when no steps are queued) |
| `findItem(root, properties, typeName?)` | Find a visual item by property values |
| `findObject(root, properties, typeName?)` | Find any QObject by property values |
| `findClickableChild(item)` | Find the clickable area within an item |
| `mouseClick(item)` | Simulate a mouse click |

### Recursive page capture

`RecursivePageCapture` automatically navigates through all list items on a page, clicking each `ListNavigation` item, capturing the resulting page, and recursing into sub-pages:

```qml
UiTestCase {
    id: root
    window: Global.main

    function test_allSettings() {
        // Navigate to Settings
        addStep(UiTestStep.Invoke, { callable: ()=> {
            return mouseClick(findClickableChild(findItem(Global.mainView, { text: "Settings" })))
        } })
        addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
        // Recursively capture all sub-pages
        runSteps(recursivePageCapture.start)
    }

    RecursivePageCapture {
        id: recursivePageCapture
        testCase: root
        // Exclude pages that would make the test too slow or produce unstable output
        excludedPageUrls: ["/pages/settings/debug/PageDebugVeQItems.qml"]
    }
}
```

This is the most efficient way to get full test coverage of settings pages and drill-down hierarchies.

### Test lifecycle

```
initTestCase()          — runs once before all tests
    init()              — runs before each test_* function
        test_foo()      — test function (adds steps, calls runSteps())
    cleanup()           — runs after each test_* function
    init()
        test_bar()
    cleanup()
cleanupTestCase()       — runs once after all tests
```

**Important**: `runSteps()` is asynchronous. Code after `runSteps()` executes immediately, before any steps run. Use callbacks if you need to execute code after steps complete.

## Test directory structure

```
tests/ui/
├── README.md                       — detailed API documentation
├── RecursivePageCapture.qml        — reusable recursive navigation component
└── smoke/
    └── mock-maximal/               — smoke test using "maximal" mock config
        ├── mock-maximal.json       — test configuration
        ├── tst_brief.qml           — Brief page tests
        ├── tst_overview.qml        — Overview page and drilldowns
        ├── tst_settings.qml        — All settings pages (recursive)
        ├── tst_cards.qml           — Control cards and switch pane
        ├── tst_levels.qml          — Levels/tanks page
        ├── tst_notifications.qml   — Notifications page
        └── tst_boat.qml            — Boat page
```

## Important notes

- **Animations must be disabled** (`UIAnimations: 0`) for deterministic captures
- **Mock timers must be off** (`TimersActive: false`) to prevent animated data values from changing between captures
- **Stabilization**: pages with asynchronous content (Repeaters, Loaders) may take multiple frames to stabilize. The system retries captures until the image is stable (consecutive captures are identical)
- **RecursivePageCapture limitations**: it does not click buttons or radio buttons (only `ListNavigation` items), because buttons may have write side-effects that alter the UI state
- **Debug logging**: set `"Logging": "debug"` in the test JSON to see detailed output when `findItem()` calls fail

## C++ infrastructure

The test system is implemented in `src/`:

| File | Purpose |
|------|---------|
| `uitest.h` | `UiTest` singleton — loads config, manages test execution lifecycle |
| `uitestcase.h` | `UiTestCase` — the QML type for writing test cases |
| `uiteststep.h` | `UiTestStep` — defines step types and their execution |

The test system is integrated into the normal application binary — no separate test executable is needed. When `--ui-test` is specified, the application loads normally, waits for `Global.allPagesLoaded`, then begins executing test cases sequentially.
