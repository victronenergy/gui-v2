# Architecture

## Table of contents

- [Overview](#overview)
- [Backend data layer](#backend-data-layer)
- [Singleton architecture](#singleton-architecture)
- [Data manager](#data-manager)
- [Application and UI structure](#application-and-ui-structure)
- [UI component organization](#ui-component-organization)
- [Theme system](#theme-system)
- [Build variants](#build-variants)
- [Mock system](#mock-system)
- [GUI plugins](#gui-plugins)
- [Translations](#translations)
- [Unit tests](#unit-tests)
- [Visual regression tests](#visual-regression-tests)
- [Key patterns](#key-patterns)

## Overview

gui-v2 is a Qt6/QML application that serves as the UI for Victron Energy Venus OS devices. It runs natively on GX hardware (ARM), as a WebAssembly build in browsers, and as a desktop application for development. The application displays real-time energy system data (solar, battery, AC inputs, tanks, etc.) and provides device configuration.

## Backend data layer

### VeQItem tree

The `src/veutil/` git submodule provides the core data abstraction. All Venus OS data is organized as a hierarchical tree of `VeQItem` objects (defined in `veutil/inc/veutil/qt/ve_qitem.hpp`). Each `VeQItem` has a UID path, a value, min/max bounds, and change notifications.

The tree is populated by a **producer** — one of three backends selected at startup:

| Backend | Producer Class | UID Prefix | When Used |
|---------|---------------|------------|-----------|
| D-Bus | `VeQItemDbusProducer` | `dbus/` | Running on GX hardware |
| MQTT | `VeQItemMqttProducer` | `mqtt/` | WASM/browser via WebSocket |
| Mock | `VeQItemMockProducer` | `mock/` | Desktop development/testing |

### VeQuickItem (QML binding)

`VeQuickItem` (`veutil/inc/veutil/qt/ve_quick_item.hpp`) is the QML element that binds to a single VeQItem by UID path. It exposes `value`, `valid`, `min`, `max`, `uid` properties with change signals. This is the primary way QML code reads and writes Venus OS data:

```qml
VeQuickItem {
    uid: BackendConnection.serviceUidForType("system") + "/Dc/Battery/Voltage"
    // value, valid, min, max are all reactive properties
}
```

### Service UID format

Service UIDs differ by backend:
- **D-Bus**: `dbus/com.victronenergy.<serviceType>[.suffix]/<path>` (e.g. `dbus/com.victronenergy.solarcharger.ttyO1/Dc/0/Voltage`)
- **MQTT**: `mqtt/<serviceType>/<deviceInstance>/<path>` (e.g. `mqtt/solarcharger/255/Dc/0/Voltage`)
- **Mock**: `mock/com.victronenergy.<serviceType>[.suffix]/<path>`

`BackendConnection.uidPrefix()` returns the appropriate prefix for the current backend.

### BackendConnection singleton

`BackendConnection` (C++, `QML_SINGLETON`, not part of veutil) manages the lifecycle of the active producer. It provides:
- Connection state machine (`Idle → Connecting → Connected → Initializing → Ready`)
- `serviceUidForType(type)` / `serviceUidFromName(name, instance)` — UID construction helpers
- VRM portal authentication (MQTT over WebSocket to VRM cloud)
- Heartbeat monitoring for WASM connections

## Singleton architecture

The application uses several C++ singletons exposed to QML via `QML_SINGLETON`:

| Singleton | File | Purpose |
|-----------|------|---------|
| `BackendConnection` | `src/backendconnection.h` | Backend connectivity and UID resolution |
| `AllServicesModel` | `src/allservicesmodel.h` | Model of all discovered services |
| `AllDevicesModel` | `src/alldevicesmodel.h` | Model of all valid device-type services |
| `VenusOS` (Enums) | `src/enums.h` | All application enums (tank types, unit types, states, etc.) |
| `Theme` | `src/theme.h` | Generated theme values (colors, geometry, fonts, animations) |
| `UiConfig` | `src/uiconfig.h` | UI configuration (splash screen, animation, visibility) |
| `ScreenBlanker` | `src/screenblanker.h` | Display timeout/blanking |
| `MockManager` | `src/mockmanager.h` | Mock data manipulation (development only) |
| `GuiPluginLoader` | `src/guiplugins.h` | Third-party plugin integration |
| `Units` | `src/units.h` | Unit conversion and formatting |

Additionally, the QML-side `Global` singleton (`Global.qml`, pragma Singleton) holds references to all major UI and data components.

### Global singleton (QML)

`Global.qml` is the central registry for shared application state. Key properties:

```
Global.main              → Main.qml (the Window)
Global.pageManager       → PageManager navigation controller
Global.mainView          → MainView.qml (root visual container)
Global.dialogLayer       → DialogLayer for modal dialogs
Global.notificationLayer → NotificationLayer for toast/alarm UI

// Data sources (set by DataManager children)
Global.acInputs          → AcInputs.qml
Global.dcInputs          → DcInputs.qml
Global.solarInputs       → SolarInputs.qml
Global.tanks             → Tanks.qml
Global.system            → System.qml
Global.systemSettings    → SystemSettings.qml
Global.inverterChargers  → InverterChargers.qml
Global.generators        → Generators.qml
Global.evChargers        → EvChargers.qml
Global.notifications     → Notifications.qml
Global.switches          → Switches.qml
Global.environmentInputs → EnvironmentInputs.qml
Global.venusPlatform     → VenusPlatform.qml

// State
Global.backendReady      → true when BackendConnection is Ready
Global.dataManagerLoaded  → true when all data sources initialized
Global.allPagesLoaded     → true when swipe view pages are loaded
Global.pagePreloadComplete → true when splash PagePreloader has finished (fail-open splash gate, not compile-success)
Global.startupPhase       → informative, derived VenusOS.Startup_Phase (LoadingBackend/LoadingData/LoadingUi/Splash/Running); describes the boot, does not drive it
```

## Data manager

`data/DataManager.qml` instantiates all data source objects. Each data source (e.g. `AcInputs`, `Tanks`, `System`) is a QtObject that:
1. Creates `VeQuickItem` bindings to read Venus OS paths
2. Creates `FilteredDeviceModel` or `FilteredServiceModel` instances to track devices
3. Registers itself on the `Global` singleton (e.g. `Component.onCompleted: Global.tanks = root`)

The DataManager waits until all data objects are created AND `BackendConnection` reaches `Ready` state before setting `Global.dataManagerLoaded = true`.

### Device discovery

1. `AllServicesModel` listens to the backend producer for new service items
2. `AllDevicesModel` wraps each service as a `Device` object (with `serviceUid`, `deviceInstance`, `productName`, etc.)
3. `FilteredDeviceModel` provides sorted/filtered views over `AllDevicesModel` based on `serviceTypes` and optional child value filters
4. `FilteredServiceModel` provides similar filtering directly over `AllServicesModel` (service UIDs only, no device objects)

## Application and UI structure

### Application startup sequence

```
Main.qml (Window)
  ├─ Splash screen is shown
  ├─ BackendConnection initializes producer
  ├─ DataManager loads (creates all data source objects)
  ├─ Global.dataManagerLoaded = true
  ├─ ApplicationContent.qml loads
  │   └─ MainView.qml loads SwipeView pages
  ├─ Global.allPagesLoaded = true
  ├─ PagePreloader compiles overview drill-down and overlay page types
  └─ SplashSequence reaches Hidden → splash screen hidden
```

`Global.startupPhase` is an informative, read-only `VenusOS.Startup_Phase` derived from the flags above (`LoadingBackend` → `LoadingData` → `LoadingUi` → `Splash` → `Running`). It is a single property to answer "what is the application doing right now"; it describes the boot but does not drive it (the loaders in `Main.qml` remain the authority). `SplashSequence`'s `Splash_Phase` is the sub-state machine while `startupPhase` is `Startup_Phase_Splash`.

`SplashSequence` is the splash phase machine (`VenusOS.Splash_Phase`): Waiting, HidingProgress, FadingLogo, PlayingGauge, WaitingForPreload, FadingOut, Hidden. `SplashView` only starts the animation for the current phase and reports when that step finishes. Wasm skips the animation by default: once pages are loaded and the animation is off, the phase goes straight to Hidden. Welcome onboarding is the exception: `SplashView` forces the animation on when the welcome view loads, and `welcomeActive` holds the sequence in Waiting (including rolling back a later phase) until onboarding finishes. `--skip-splash` hides the splash immediately and does not run the sequence. A UI rebuild that clears `allPagesLoaded` or `dataManagerLoaded` returns an in-progress sequence to Waiting.

`PagePreloader` compiles (does not instantiate) the Overview widget drill-down pages, the Brief side panel / Control / Switch overlay pages, and the first-level Settings pages while the splash GIF is playing. First open of those pages then skips QML compilation. It runs only while the splash animation is visible. UI tests skip it by default (`skipCompile` when `UiTest` is configured) so that `benchmark/pages` still measures cold compile. Isolated unit tests inject a short URL list and override `skipCompile`, `timeoutMs`, and `compileOnActive` to cover compile, bad URLs, and timeout without enabling preload for other UI tests. Splash fade-out waits until the gauge intro has paused and `Global.pagePreloadComplete` is true. That flag is a completion/fail-open gate: it is also set when compile is skipped, after a timeout, and after a list that included compile failures. It does not guarantee that the drill-down types were compiled.

`PageStack.pushPage()` compiles with synchronous `Qt.createComponent()` and instantiates with `createObject()` before the fake x-slide. `CardViewLoader` and the Brief side-panel `Loader` are also synchronous (`asynchronous: false` on the side panel). `MainView.allowPageAnimations` is false only while the PageStack is transitioning or the main SwipeView is flicking (and while geometry is adjusting), not while those trees are being built. In-page animations resume when the slide is idle.

### UI navigation structure

```
Main.qml (Window)
└─ ApplicationContent.qml
   ├─ MainView
   │   ├─ StatusBar (top)
   │   ├─ SwipeView (main content, horizontal swipe between pages)
   │   │   ├─ BriefPage        — summary gauges
   │   │   ├─ OverviewPage     — energy flow diagram with widgets
   │   │   ├─ LevelsPage       — tanks and environment (conditional)
   │   │   ├─ NotificationsPage - list of notifications (alarms, warnings, infos)
   │   │   ├─ SettingsPage     — list navigation to sub-pages of application settings
   │   │   └─ (BoatPage)       — marine mode (conditional)
   │   ├─ NavBar (bottom navigation bar)
   │   ├─ PageStack (drill-down pages, slide in from right over the top of current view)
   │   └─ CardViewLoader (control cards overlay, triggered from StatusBar)
   ├─ DialogLayer (modal dialogs)
   └─ NotificationLayer (toast notifications, alarm banners)
```

### PageManager

`PageManager.qml` orchestrates navigation:
- `pushPage(url, properties)` — push a sub-page onto the PageStack
- `popPage()` / `popAllPages()` — navigate back
- `goToStartPage()` — navigate to user-configured start page
- Manages idle mode transitions (hide NavBar, full-screen page)

### PageStack

`components/PageStack.qml` (extends StackView) handles drill-down navigation with slide animations. `animationDuration` follows `Global.animationEnabled`, not `MainView.allowPageAnimations` (the latter is false while the stack is busy, which would skip the first fake x-slide). Used for:
- Overview widget drill-downs (e.g. clicking Battery widget → battery detail page)
- Settings sub-pages (e.g. Settings → Display → Brightness)

### SwipeViewPage

Each main page extends `SwipeViewPage.qml` which provides:
- `title`, `iconSource`, `url` — for NavBar display
- `topLeftButton` / `topRightButton` — StatusBar button configuration
- `fullScreenWhenIdle` — whether page expands when inactive

## UI component organization

### Component layers

```
components/
├── controls/        — Button, Switch, Slider, SpinBox, TextField, etc.
├── listitems/
│   ├── core/        — ListItem, ListSwitch, ListNavigation, ListSpinBox, etc.
│   └── (domain)     — ListCurrentLimitButton, ListFirmwareVersion, etc.
├── dialogs/         — ModalDialog and domain-specific dialogs
├── widgets/         — Overview page energy flow widgets (BatteryWidget, SolarYieldWidget, etc.)
├── switches/        — Toggle switch variants
├── shaders/         — GLSL shader effects
└── (top-level)      — Page.qml, QuantityLabel.qml, NavBar.qml, StatusBar.qml, etc.
```

### Page base type

All pages must extend `components/Page.qml` (a FocusScope):
- `title: string` — displayed in StatusBar breadcrumbs
- `isCurrentPage: bool` — true when this page is visible
- `animationEnabled: bool` — tracks whether animations should run
- `topLeftButton` / `topRightButton` — configure StatusBar buttons
- `tryPop: function` — optional guard called before page is popped

The `__is_venus_gui_page__` readonly property allows child components to detect they are inside a Page.

### List items

Settings pages are built using list item components from `components/listitems/`. See [Device and System Settings](.github/device-settings.md) for full details on the component hierarchy, access level system, and data binding patterns.

Core types (in `components/listitems/core/`):
- `ListItem` — base list row with left label and right content area
- `ListNavigation` — list row that pushes a sub-page when clicked
- `ListSwitch` — list row with a toggle switch
- `ListSpinBox` — list row with a numeric spinner
- `ListRadioButtonGroup` — list row with radio options
- `ListTextField` — list row with text input
- `ListQuantity` — list row showing a formatted quantity (value + unit)

Many list items have a `dataItem.uid` property to bind directly to a VeQuickItem path.

### Overview widgets

The Overview page displays an energy flow diagram with `OverviewWidget` components from `components/widgets/`:
- `BatteryWidget`, `SolarYieldWidget`, `AcInputWidget`, `DcLoadsWidget`, etc.
- In landscape layout, widgets are connected by `WidgetConnector` which draws animated power flow lines between widgets; in portrait layout, the power flow connections are visualised by `OverviewEnergyIndicator`.
- Widget visibility depends on which devices are present on the system

## Theme system

Theme values are defined in JSON files:
```
themes/
├── color/       — Dark.json, Light.json, ColorDesign.json
├── geometry/    — screen dimensions, margins, sizes per screen variant
├── animation/   — durations, easing curves
└── typography/  — font sizes, weights
```

`tools/themeparser.py` generates `src/themeobjects.h` at build time, creating the `Theme` C++ singleton with all properties accessible in QML as `Theme.color_*`, `Theme.geometry_*`, `Theme.animation_*`, `Theme.font_*`.

A value that names another key is an alias. In `Dark.json` / `Light.json`, an alias of another color scheme key reads that key's computed value (`color_button` is `color_brand`), so it follows that key's branding. Any other alias, for example of a `ColorDesign.json` palette color or a geometry key, is copied in as a literal. Data colors (tank, temperature and similar) must alias palette colors, not color scheme keys, so that they never follow branding. Aliases may be chained.

A color scheme value can also be a function call, such as `dim(color_red)` (red at 70% alpha, blended onto `color_background_primary`) or `text_color_on(color_brand)` (white if white has at least 3:1 contrast on every listed fill, otherwise a dark font color darkened toward black until it does). When no one text color can be read on every fill the text is drawn on, `fill_for_text()` darkens or lightens one fill until a chosen text color can be read on it. `readable_text_on()` instead moves the text color until it can be read on those fills. The functions are listed in `tools/themeparser.py` and implemented in `src/colorderivation.h`. The generated `Theme` computes every color scheme value whenever the branding or the color scheme changes, so all of them follow the branding.

When a color means something in the UI, use the color for that meaning, not a palette color: `color_brand` for controls and chrome, `color_info` for informative notifications and for quantities that are not a success, a warning or an alarm, `color_success` for success and feed-in, `color_warning` and `color_critical` for alarms, and their dark variants (`color_darkBrand`, `color_darkInfo`, `color_darkCritical` and so on). A gauge that picks a status color by level uses `Global.statusColor()`, which reads the Theme colors in QML so the binding updates when the theme changes. Palette colors (`color_blue`, `color_green`, ...) are for data, such as a tank fluid or a temperature, and do not follow branding.

Images must not have brand or status colors baked in. Tint single-color art with a Theme color: `CP.ColorImage` or `IconImage` for an image, and for a `BorderImage` the `image://tinted/<rrggbb>/<resource path>` image provider (`src/tintedimageprovider.cpp`), as `GlobalKeyNavigationHighlight` does with `color_focus_highlight`.

The theme supports multiple screen sizes (FiveInch, SevenInch, Portrait) with geometry values that adapt accordingly.

### Theme branding

Victron's own look is a `Branding` object, `VictronBranding.qml`. `Main.qml` adds it with `Theme.addBranding()` before showing the splash screen. The palette is not resolved until that object has been added. A branding plugin (see [GUI plugins](#gui-plugins)) can override the same values: ten colors (`color_brand`, `color_success`, `color_warning`, `color_critical`, `color_info`, `color_background_primary`, `color_background_secondary`, `color_background_page`, `color_font_primary` and `color_font_secondary`), `light_mode_background_factor`, the font families, and the splash logos.
- `GuiPluginLoader` creates each plugin's `Branding` object once, copies the values that it sets into a `BrandingData` struct, and destroys the object, so no plugin binding stays alive. Those values are given to `Theme::setPluginBranding()` in plugin-name order, and are applied after Victron's branding. When more than one entry sets a value, the last one is used, except that `light_mode_background_factor` is used only from the entry whose `color_background_primary` is used, and `color_background_secondary` and `color_background_page` only from that entry or a later one (see `ColorDerivation::resolveBrandingColors()`).
- The Branding colors are the Dark scheme's colors, whatever their lightness. The Light scheme's colors are computed from them: the brand and status colors are kept; `color_background_primary` and `color_background_secondary` have their lightness inverted (scaled by `light_mode_background_factor`); `color_font_primary` has its lightness inverted and is moved 15% toward the background; and the page background is computed from those. A color that an entry does not set is taken from an earlier entry, or is computed from the colors that are set. `Theme` logs a warning if a plugin's `color_font_primary` has too little contrast on `color_background_primary`.
- All other color scheme values are computed from these ten colors (see [Theme system](#theme-system)), so they follow the branding.
- `Theme.font_family` and `Theme.quantity_font_family` come from the same list: Victron's families, unless a later entry sets them. An empty `Theme.font_family` means the language font (`Global`'s `FontLoader`). A language that has its own font keeps it. A plugin family is not used for a language that it does not cover.
- `Theme.splash_logo_icon` and `Theme.splash_logo_text` come from the same list. `SplashView` tints them with the splash colors unless `splash_logo_*_preserve_colors` is set.
- `Theme.splash_gauge_animation` and `Theme.splash_gauge_animation_light` come from the same list. `SplashView` plays the light file in the Light scheme when it is set, otherwise the dark file, at the file's own size, to its last frame. If that file is also unset, Victron's size-specific animation is used, which pauses at a fixed frame.
- Every change to the branding or to the color scheme emits `Theme.themeValuesChanged`, which is the NOTIFY signal of the affected properties.

With no branding plugin installed, the values are Victron's, from `VictronBranding.qml`.

## Build variants

Three compile-time defines control platform-specific code:

| Define | Condition | Characteristics |
|--------|-----------|-----------------|
| `VENUS_DESKTOP_BUILD` | Native architecture match | Mock data, tests enabled, loads QML from resources (or filesystem when installed) |
| `VENUS_WEBASSEMBLY_BUILD` | Emscripten target | MQTT via WebSockets, no D-Bus, WASM VKB handling |
| `VENUS_GX_BUILD` | ARM cross-compile | D-Bus backend, loads QML from filesystem (allows modding), hardware screen blanker |

`UrlInterceptor` rewrites `qrc:/` QML paths to filesystem paths so that QML files can be edited without rebuilding. On GX builds this is always active; on desktop builds it activates automatically when the application has been installed (i.e. a `Victron/` directory exists next to the executable). When running directly from the build directory, QML is loaded from compiled-in resources as usual.

### Desktop installation

Desktop builds define `cmake install` rules so that `cmake --install` deploys the executable and QML source files. On Windows and macOS, `qt_generate_deploy_app_script()` runs as a post-install step to copy required Qt runtime libraries and QML modules alongside the executable. The MSVC compiler runtime is **not** included (`NO_COMPILER_RUNTIME`) because desktop installs are intended for developer machines that already have it.

## Mock system

For desktop development, the mock system provides simulated data:
- `VeQItemMockProducer` — in-memory VeQItem tree (no D-Bus/MQTT needed)
- `MockManager` (C++ singleton) — loads JSON configuration files to populate mock values
- `data/mock/MockSetup.qml` — instantiates domain-specific mock implementations
- `data/mock/*Impl.qml` — animate data values to simulate a working energy system
- `data/mock/conf/` — JSON configuration files defining mock device setups

Run with `--mock` flag to use mock backend. Mock configurations (e.g. "maximal", "minimal") define which devices are simulated.

## GUI plugins

`GuiPluginLoader` supports third-party UI extensions:
- Plugins are JSON-defined with QML components
- Integration types: settings pages, device list pages, navigation pages, quick access panes and cards, and branding (type 6)
- Plugins can be loaded from MQTT (VRM) or filesystem
- Hot-reloading supported via file system watcher

Plugins are built with `tools/gui-v2-plugin-compiler.py`. Its `--branding` option checks a `Branding.qml` file before packing it: `import Victron.Branding` is required, `QtQml` and `QtQuick` are allowed, and the file must not contain a few obvious calls such as `createQmlObject` or `XMLHttpRequest`. It does not check property values. It packs every `.svg`, `.png`, `.ttf` and `.otf` file under the plugin directory, and writes `requiredBrandingVersion` from properties assigned as `name:` on their own line, after indentation. The property names and versions come from `tools/branding-properties.json`, generated from `src/branding/branding.h` by `tools/brandingproperties.py`; the `tst_brandingproperties` test fails if it is out of date. The list is also the checked-in record of the `Victron.Branding` API, and the script will not remove a property from it, or change one, without a new major version.

### Branding module

The `Branding` type is in its own QML module, `Victron.Branding` (`src/branding/`, `cmake/ModuleBranding.cmake`), so that a branding plugin is checked against this one small module, and so that it has its own version. The module's `qmldir` and `qmltypes` are installed next to the plugin compiler, which runs `qmllint` against them.

## Translations

See [Internationalisation and Localisation](.github/i18n-l10n.md) for full details.

In brief: all user-visible strings use `qsTrId("id")` with `//% "Source text"` comments. `CommonWords.qml` centralizes reused strings. Dynamic language changes at runtime must continue to work — always use `qsTrId()` in binding expressions, never in imperative code.

## Unit tests

See [Unit Tests](.github/unit-tests.md) for full details on creating, running, and writing effective unit tests.

Tests use Qt's `QuickTest` framework with QML `TestCase` types. Each test has a C++ runner (`tst_<name>.cpp`) and QML test file (`tst_<name>.qml`). Tests that need data use the mock backend via `MockManager`.

## Visual regression tests

See [Visual Regression Tests](.github/visual-regression-tests.md) for the image-capture testing system.

The application runs in automated test mode (`--mock --ui-test <config>`), navigates through the UI, captures screenshots, and compares them to a known-good baseline using the `tools/uicompare` comparison tool. This ensures UI changes don't introduce unintended visual regressions.

## Key patterns

### Accessing device data from QML

```qml
// Direct path binding
VeQuickItem {
    uid: BackendConnection.serviceUidForType("system") + "/Dc/Battery/Power"
}

// Via data source singletons
Text { text: Global.system.battery.stateOfCharge }

// Via device model
FilteredDeviceModel {
    serviceTypes: ["solarcharger"]
}
```

### Creating a settings page

```qml
Page {
    title: "My Settings"

    GradientListView {
        model: VisibleItemModel {
            ListNavigation { text: "Sub-page"; onClicked: Global.pageManager.pushPage(subPageComponent) }
            ListSwitch { text: "Enable feature"; dataItem.uid: settingsUid + "/Path/To/Setting" }
            ListSpinBox { text: "Max value"; dataItem.uid: settingsUid + "/Path/To/Value" }
        }
    }
}
```

### Conditional UI based on backend data

```qml
Loader {
    active: Global.system.hasGridMeter  // only show when grid meter is detected
    sourceComponent: GridWidget { }
}
```
