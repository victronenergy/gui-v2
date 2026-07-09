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
Global.dataManagerLoaded → true when all data sources initialized
Global.allPagesLoaded    → true when swipe view pages are loaded
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
  └─ Global.allPagesLoaded = true → Splash screen hidden, ApplicationContent displayed
```

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

`components/PageStack.qml` (extends StackView) handles drill-down navigation with slide animations. Used for:
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

The theme supports multiple screen sizes (FiveInch, SevenInch, Portrait) with geometry values that adapt accordingly.

## Build variants

Three compile-time defines control platform-specific code:

| Define | Condition | Characteristics |
|--------|-----------|-----------------|
| `VENUS_DESKTOP_BUILD` | Native architecture match | Mock data, tests enabled, loads QML from resources |
| `VENUS_WEBASSEMBLY_BUILD` | Emscripten target | MQTT via WebSockets, no D-Bus, WASM VKB handling |
| `VENUS_GX_BUILD` | ARM cross-compile | D-Bus backend, loads QML from filesystem (allows modding), hardware screen blanker |

On GX builds, `UrlInterceptor` rewrites `qrc:/` paths to filesystem paths, allowing customers to edit QML files on-device without rebuilding.

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
- Integration types: settings pages, device list pages, navigation pages, quick access cards
- Plugins can be loaded from MQTT (VRM) or filesystem
- Hot-reloading supported via file system watcher

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
