# Landscape and portrait mode

**All UI features must support both landscape and portrait mode.** Portrait mode is primarily used for WASM access on phones and tablets, while landscape is the native mode for GX Touch 5" and 7" displays.

## Screen size variants

The `Theme.screenSize` property (type `Theme.ScreenSize`) determines the current layout mode:

| Value | Constant | Context |
|-------|----------|---------|
| 0 | `Theme.FiveInch` | GX Touch 50 (800×480 landscape) |
| 1 | `Theme.SevenInch` | GX Touch 70 / Ekrano (1024×600 landscape), WASM landscape |
| 2 | `Theme.Portrait` | WASM on phone/tablet (width < height) |

The value is set automatically in `Main.qml` based on window dimensions (width < height → Portrait) and platform (WASM defaults to SevenInch in landscape).

## Geometry system

Each screen size has its own geometry JSON file:
```
themes/geometry/FiveInch.json   — 800×480 landscape
themes/geometry/SevenInch.json  — 1024×600 landscape
themes/geometry/Portrait.json   — variable-width portrait
```

The `Theme` singleton dynamically provides the correct `Theme.geometry_*` values for the current screen size. When `Theme.screenSize` changes, all geometry-dependent properties update automatically.

## Layout patterns

Most pages use one of these patterns to adapt to portrait/landscape:

### 1. Loader with separate components (preferred for complex pages)

```qml
Loader {
    sourceComponent: Theme.screenSize === Theme.Portrait ? portraitComponent : landscapeComponent

    Component {
        id: landscapeComponent
        OverviewPage_Landscape { }
    }
    Component {
        id: portraitComponent
        OverviewPage_Portrait { }
    }
}
```

Used by: `OverviewPage`, `BriefPage`, `StatusBar`, `ModalDialog`

### 2. Conditional properties (for simpler adaptations)

```qml
BaseListView {
    orientation: Theme.screenSize === Theme.Portrait ? ListView.Vertical : ListView.Horizontal
}

Item {
    width: Theme.screenSize === Theme.Portrait
        ? Theme.geometry_screen_width - (2 * margin)
        : fixedLandscapeWidth
}
```

Used by: `ControlCardsPage`, `AuxCardsPage`, `LevelsPage`

### 3. Theme geometry values (for dimension-only differences)

```qml
// Automatically gets the correct value for the current screen size
anchors.margins: Theme.geometry_page_content_horizontalMargin
```

## Portrait mode behaviors

In portrait mode:
- The NavBar remains at the bottom; StatusBar at the top (but omits clock, WiFi indicator, and other UI indicators which might duplicate those which are already provided by the system on a mobile platform)
- Card views (control/aux) use vertical list orientation instead of horizontal
- Overview widgets use a vertical stacked layout (`OverviewPage_Portrait`) rather than the three-column energy-flow layout
- List items get smaller insets (`geometry_page_content_horizontalMargin` is 16px vs landscape values)
- The idle mode (fullScreenWhenIdle) is disabled — `PageManager` skips idle transitions when `Theme.screenSize === Theme.Portrait`
- Dialogs typically use different header layouts (`DialogHeader_Portrait`) and are placed on the bottom rather than the center of the screen
- When the application is resized, the UI is dynamically stretched rather than scaled

## Rules for new code

- Always test both orientations — check `Theme.screenSize === Theme.Portrait` where layouts need to differ
- Use `Theme.geometry_*` values instead of hardcoded dimensions — they adapt to screen size automatically
- For pages with fundamentally different layouts, create `*_Landscape.qml` and `*_Portrait.qml` variants loaded by a Loader
- List views that are horizontal in landscape should become vertical in portrait (use conditional `orientation`)
- Widget sizes must account for the available height being much larger (and width smaller) in portrait
- Do not assume fixed screen dimensions — portrait width varies by device/browser

## Naming convention for orientation variants

When a page or component needs separate implementations per orientation:
```
ComponentName.qml              — entry point with Loader
ComponentName_Landscape.qml    — landscape implementation
ComponentName_Portrait.qml     — portrait implementation
```

Examples in the codebase:
- `OverviewPage.qml` → `OverviewPage_Landscape.qml`, `OverviewPage_Portrait.qml`
- `BriefPage.qml` → `BriefPage_Landscape.qml`, `BriefPage_Portrait.qml`
- `StatusBar.qml` → `StatusBar_Landscape.qml`, `StatusBar_Portrait.qml`
