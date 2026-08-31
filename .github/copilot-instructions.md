# Copilot instructions for gui-v2

Venus OS GUI v2 — Qt6/QML touch UI for Victron Energy GX devices and WebAssembly remote console.

## Code review

When asked to review code, you **must** immediately re-read the **entire** [Code Review](.github/code-review.md) document without skipping any sections, and **then** follow the process step-by-step to perform the review. Do not substitute your own ad-hoc review heuristics or skip sections you judge to be irrelevant — apply every section of the checklist systematically.

## Topic guides

> **Keep documentation current.** When making changes that affect any of the topics below, update the relevant documentation file(s) as part of the same change.

- [Architecture](.github/architecture.md) — backend data layer, singletons, navigation hierarchy, component organization
- [Code Review](.github/code-review.md) — structured correctness, performance, and maintainability checklist for reviews
- [Key Navigation](.github/key-navigation.md) — keyboard/button navigation system (must be supported by all features)
- [Layout Modes](.github/layout-modes.md) — landscape and portrait mode implementation (must be supported by all features)
- [Internationalisation](.github/i18n-l10n.md) — translations, dynamic language changes, POEditor workflow
- [Device Settings](.github/device-settings.md) — settings data binding, access levels, ListSetting component hierarchy
- [Unit Tests](.github/unit-tests.md) — test framework, creating tests, running tests, best practices
- [Visual Regression Tests](.github/visual-regression-tests.md) — image-capture testing, comparison tool, verifying UI changes

## Build & test

```bash
# Configure and build (out-of-source required)
cmake -B build -DCMAKE_BUILD_TYPE=Debug <source-path>
cmake --build build

# Run all unit tests
cd build && ctest -V

# Run a single unit test
cd build && ctest -R tst_units -V

# UI smoke tests (mock mode, in-process)
./bin/venus-gui-v2 --mock --ui-test smoke/mock-maximal
```

Desktop builds automatically enable unit tests. Use `-DRUN_UNIT_TESTS=ON` to run them as a post-build step.

### Running tests on Windows (important for Copilot / headless environments)

Qt routes `qDebug`/test output via `OutputDebugString` when it detects no interactive console on stderr. In headless or redirected environments (e.g. Copilot CLI subprocesses), test output will be silently lost. Set this environment variable before running tests:

```powershell
$env:QT_ASSUME_STDERR_HAS_CONSOLE = "1"
```

This tells Qt to write to stderr even without a detected console, making output capturable via normal redirection.

## Key conventions

- **QML imports**: Every QML file imports `Victron.VenusOS` (provides `Theme`, `Global`, `VenusOS` enums, `CommonWords`).
- **Theme values**: Use `Theme.color_*`, `Theme.geometry_*`, `Theme.font_*` — never hardcode colors or sizes.
- **Pages**: Extend `components/Page.qml`. Navigate with `Global.pageManager.pushPage()`/`popPage()`.
- **List items**: Build settings UIs with types from `components/listitems/core/` (e.g. `ListSwitch`, `ListNavigation`, `ListSpinBox`).
- **Data binding**: Use `VeQuickItem { uid: ... }` to bind to Venus OS data paths. Access aggregated data via `Global.system`, `Global.tanks`, etc.
- **Translations**: Use `qsTrId("id")` with `//% "Source text"` in binding expressions (not imperative code). Reuse strings from `CommonWords.qml`. Dynamic language changes must work — see [i18n/l10n](.github/i18n-l10n.md).
- **C++ style**: C++20, formatted per `victron.astyle` (1TBS, tabs, 120 char lines). Expose types to QML with `QML_ELEMENT`/`QML_SINGLETON`.
- **Enums**: All enums defined in C++ (`src/enums.h`) and accessed in QML as `VenusOS.EnumName_Value`.
- **Key navigation**: All interactive elements must be keyboard-navigable. Set `focusPolicy: Qt.TabFocus` and `KeyNavigationHighlight.active: activeFocus`. See [Key Navigation](.github/key-navigation.md).
- **Portrait + Landscape**: All features must work in both orientations. Use `Theme.screenSize === Theme.Portrait` for layout branching and `Theme.geometry_*` for dimensions. See [Layout Modes](.github/layout-modes.md).
