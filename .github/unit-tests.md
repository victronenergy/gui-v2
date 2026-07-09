# Unit tests

This document covers the C++/QML unit test framework. It does **not** cover visual regression tests (the `--ui-test` system) — those are documented separately.

## Test structure

Unit tests live in `tests/`, with one subdirectory per test:

```
tests/
├── CMakeLists.txt              — enables testing and includes UnitTests.cmake macro
├── units/
│   ├── CMakeLists.txt          — add_single_file_unit_test(units)
│   ├── tst_units.cpp           — C++ test runner
│   └── tst_units.qml           — QML test cases
├── device/
│   ├── CMakeLists.txt          — add_single_file_unit_test(device)
│   ├── tst_device.cpp          — C++ test runner (initializes mock backend)
│   └── tst_device.qml          — QML test cases
├── backendconnection/
│   ├── CMakeLists.txt
│   ├── tst_backendconnection.cpp
│   └── tst_backendconnection.qml
├── solarinputmodel/
├── filtereddevicemodel/
├── (many more...)
└── ui/                         — visual regression tests (separate system, not covered here)
```

## Creating a new unit test

### 1. Create the test directory

```
tests/myfeature/
├── CMakeLists.txt
├── tst_myfeature.cpp
└── tst_myfeature.qml
```

### 2. CMakeLists.txt

```cmake
add_single_file_unit_test(myfeature)
```

This macro (defined in `cmake/UnitTests.cmake`) creates an executable `tst_myfeature` that:
- Compiles `tst_myfeature.cpp`
- Copies `tst_myfeature.qml` to the build directory
- Links against all VenusOS QML modules and Qt test libraries
- Registers the test with CTest

### 3. C++ test runner (tst_myfeature.cpp)

The minimal runner just invokes the QML test framework:

```cpp
#include <QtQuickTest/quicktest.h>

int main(int argc, char **argv)
{
    QTEST_SET_MAIN_SOURCE_PATH
    return quick_test_main(argc, argv, "tst_myfeature", "../tests/myfeature/");
}
```

If your test needs the mock backend (to test data-driven components):

```cpp
#include <QtQuickTest/quicktest.h>
#include "backendconnection.h"

int main(int argc, char **argv)
{
    QTEST_SET_MAIN_SOURCE_PATH
    Victron::VenusOS::BackendConnection::create()->setType(
        Victron::VenusOS::BackendConnection::MockSource);
    return quick_test_main(argc, argv, "tst_myfeature", "../tests/myfeature/");
}
```

If your test needs custom C++ setup (e.g. exposing test helpers to QML), use `quick_test_main_with_setup()` and provide a setup object (see `tests/backendconnection/` for an example).

### 4. QML test file (tst_myfeature.qml)

Tests use Qt's `TestCase` type from `QtTest`:

```qml
import QtQuick
import Victron.VenusOS
import QtTest

TestCase {
    name: "MyFeatureTest"

    // Test functions must be prefixed with test_
    function test_basicBehavior() {
        compare(1 + 1, 2)
    }

    // Data-driven tests: define a _data function returning an array of objects
    function test_values_data() {
        return [
            { tag: "zero", input: 0, expected: "0W" },
            { tag: "kilo", input: 12345, expected: "12.35kW" },
        ]
    }

    function test_values(data) {
        const result = Units.getDisplayText(VenusOS.Units_Watt, data.input)
        compare(result.number + result.unit, data.expected)
    }

    // Optional: runs before/after all tests
    function initTestCase() { }
    function cleanupTestCase() { }

    // Optional: runs before/after each test function
    function init() { }
    function cleanup() { }
}
```

### 5. Register in parent CMakeLists.txt

Add the subdirectory to `tests/CMakeLists.txt`:

```cmake
add_subdirectory(myfeature)
```

## Running tests

### Running all tests

```bash
cd build
ctest -V
```

### Running a specific test

```bash
cd build
ctest -R tst_myfeature -V
```

The `-V` flag shows verbose output (individual test function results). Use `-VV` for even more detail.

### Running tests automatically on build

```bash
cmake -B build -DRUN_UNIT_TESTS=ON <source-path>
cmake --build build
# Tests run as a post-build step via ctest
```

### Running a single test function

To run a specific test function, run the test executable directly from the **build directory**. The function selector format is `TestCaseName::test_functionName`:

```bash
cd build
./bin/tst_myfeature -o results.txt MyFeatureTest::test_basicBehavior
```

To run all functions but only from a specific test file:

```bash
cd build
./bin/tst_myfeature -input tst_myfeature.qml -o results.txt
```

> **Note (Windows):** The test executables are built as GUI applications, so console output is not visible when running directly from a terminal. Use `-o results.txt` to write results to a file. Running all tests via `ctest` (as above) handles output capture automatically and is the preferred approach for full test runs. You may omit this argument on other platforms.

## Using the mock backend in tests

When tests need to read/write VeQuickItem data, initialize the mock backend in the C++ runner (as shown above). Then use `MockManager` in QML to set up test data:

```qml
TestCase {
    name: "MyModelTest"

    function init() {
        // Set up mock data before each test
        MockManager.setValue("mock/com.victronenergy.solarcharger.test/DeviceInstance", 1)
        MockManager.setValue("mock/com.victronenergy.solarcharger.test/ProductName", "Test Charger")
        MockManager.setValue("mock/com.victronenergy.solarcharger.test/Dc/0/Voltage", 28.5)
    }

    function cleanup() {
        // Clean up mock data after each test
        MockManager.removeServices("solarcharger")
    }

    function test_deviceProperties() {
        const device = deviceComponent.createObject(root)
        device.serviceUid = "mock/com.victronenergy.solarcharger.test"
        compare(device.productName, "Test Charger")
        device.destroy()
    }

    Component {
        id: deviceComponent
        Device { }
    }
}
```

## Best practices

### Test organization

- **One test per feature/model** — each test directory should focus on a single class or feature
- **Use data-driven tests** — prefer `test_foo_data()` + `test_foo(data)` over many separate `test_foo_case1()`, `test_foo_case2()` functions
- **Use descriptive tags** — each data row should have a `tag` property that identifies the test case in output
- **Test boundary conditions** — include NaN, zero, negative, maximum values, and empty/invalid states

### Test isolation

- Use `init()` / `cleanup()` to set up and tear down state for each test function
- Always clean up mock data after tests (`MockManager.removeServices()` or `MockManager.removeValue()`)
- Create QML objects with `Component.createObject()` and destroy them with `.destroy()` in cleanup
- Do not rely on test execution order — each `test_*` function should be independent

### What to test

- **C++ model logic** — filtering, sorting, aggregation, value computation
- **Unit conversion and formatting** — number display, unit scaling, precision
- **Backend connection logic** — UID construction, service type resolution
- **Data model state transitions** — device discovery, service add/remove, validity changes
- **Business logic** — access levels, validation functions, state machines

### What NOT to test here

- Visual layout and appearance → use the visual regression test system instead
- Complex multi-page navigation flows → use UI smoke tests instead
- Third-party library behavior → trust Qt's own test suite

### Naming conventions

- Directory: feature name in lowercase (e.g. `filtereddevicemodel`, `solarinputmodel`)
- Files: `tst_<name>.cpp` and `tst_<name>.qml`
- TestCase name: descriptive PascalCase (e.g. `"FilteredDeviceModelTest"`)
- Test functions: `test_<descriptiveName>` (e.g. `test_filterByServiceType`)
- Data functions: `test_<descriptiveName>_data`
