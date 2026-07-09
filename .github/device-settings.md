# Device and system settings

This document describes how device and system settings are displayed and modified in the GUI, including the VeQuickItem data binding, access level controls, and the ListSetting component hierarchy.

## Settings data layer

All device and system settings are backed by `VeQuickItem` bindings to Venus OS data paths. The data resides on the Venus OS platform and is accessed via D-Bus (on device) or MQTT (over network/WASM).

### Path structure

Settings paths follow the Venus OS conventions:

```
# System-wide settings (via "settings" service)
Settings/Gui/Language
Settings/Gui/DisplayOff
Settings/SystemSetup/HasDcSystem

# Per-device settings (via device service UID)
com.victronenergy.solarcharger.ttyO1/Settings/ChargeCurrentLimit
com.victronenergy.battery.lynx/Settings/Alarm/LowVoltage
```

The `BackendConnection.serviceUidForType("settings")` helper provides the correct prefix for system settings. Per-device settings use the device's `serviceUid`.

### Reading and writing settings

```qml
// Read-only display of a setting value
VeQuickItem {
    id: settingItem
    uid: Global.systemSettings.serviceUid + "/Settings/Gui/DisplayOff"
    // settingItem.value — current value
    // settingItem.valid — true when connected and value received
    // settingItem.min / settingItem.max — value bounds (if defined by backend)
}

// Writing a value
settingItem.setValue(newValue)
```

The `VeQuickItem` automatically handles:
- Subscribing to value changes from the backend
- Reporting `valid` as false when disconnected or path doesn't exist
- Providing `min`/`max` bounds from the backend (used by spinboxes/sliders)

## Access level system

Venus OS uses an access level hierarchy to control which settings are visible and/or writable:

| Level | Constant | Typical User |
|-------|----------|--------------|
| 0 | `VenusOS.User_AccessType_User` | End user (default) |
| 1 | `VenusOS.User_AccessType_Installer` | Certified installer |
| 2 | `VenusOS.User_AccessType_SuperUser` | Advanced access |
| 3 | `VenusOS.User_AccessType_Service` | Victron service technician |

The current access level is stored at `Settings/System/AccessLevel` and exposed via `Global.systemSettings.accessLevel.value`. The helper function `Global.systemSettings.canAccess(level)` returns true if the user's access level is >= the requested level.

### How access levels affect UI

Each `ListSetting` item has two access-level properties:

- **`showAccessLevel`** (default: `User`) — minimum level required to **see** the item. If the user's level is below this, the item is hidden entirely (`effectiveVisible` becomes false).
- **`writeAccessLevel`** (default: `Installer`) — minimum level required to **modify** the setting. If the user's level is below this, the item is visible but not clickable, and attempting to interact shows a toast notification: "Setting locked for access level".

### Visual indicator

Items with `showAccessLevel >= SuperUser` display a colored strip on the left edge of the background (`ListSettingBackground.indicatorColor`), giving a visual cue that the setting requires elevated access. Custom indicators can also be set via the `indicatorColor` property.

## ListSetting component hierarchy

All settings UI is built from a hierarchy of list item components in `components/listitems/core/`:

```
ListItem (base: focusable row with background and key navigation)
└── ListSetting (adds: text, caption, access control, interactive state)
    ├── ListText         — read-only display of a text value
    ├── ListQuantity     — read-only display of a numeric value with units
    ├── ListSwitch       — toggle switch (on/off setting)
    ├── ListButton       — button that triggers an action
    ├── ListNavigation   — arrow icon, opens a sub-page on click
    ├── ListSpinBox      — numeric value edited via a number selector dialog
    ├── ListSlider       — continuous value edited via a slider control
    ├── ListTextField    — text value edited inline
    ├── ListRadioButtonGroup — opens a radio button page for option selection
    ├── ListTemperature  — temperature display with unit conversion
    ├── ListRangeSlider  — dual-handle slider for min/max range
    ├── ListDateSelector — date picker
    ├── ListTimeSelector — time picker
    └── (others)
```

### ListSetting base properties

Every `ListSetting`-derived item inherits:

| Property | Purpose |
|----------|---------|
| `text` | Primary label shown on the left |
| `caption` | Optional secondary description below the label |
| `showAccessLevel` | Minimum access level to see this item |
| `writeAccessLevel` | Minimum access level to modify this item |
| `interactive` | Whether the item can be interacted with (typically bound to `dataItem.valid`) |
| `clickable` | Computed: `enabled && interactive && userHasWriteAccess` |
| `indicatorColor` | Custom left-edge indicator color |

### The `dataItem` pattern

Most setting items expose a `dataItem` property (a `VeQuickItem`) that connects the UI to the backend:

```qml
ListSwitch {
    text: "Enable feature"
    dataItem.uid: deviceServiceUid + "/Settings/FeatureEnabled"
    // Automatically reads current value, shows checked/unchecked, writes on toggle
}

ListSpinBox {
    text: "Maximum current"
    suffix: "A"
    decimals: 1
    dataItem.uid: deviceServiceUid + "/Settings/MaxCurrent"
    // Reads min/max from backend, shows current value, opens number dialog on click
}

ListRadioButtonGroup {
    text: "Operating mode"
    dataItem.uid: deviceServiceUid + "/Mode"
    optionModel: [
        { display: "Off", value: 0 },
        { display: "On", value: 1 },
        { display: "Charger only", value: 2 },
        { display: "Inverter only", value: 3 },
    ]
}
```

When `dataItem.uid` is set:
- `interactive` defaults to true only when `dataItem.valid` is true (item appears disabled until backend data arrives)
- Value changes from the backend automatically update the UI
- User interactions write back to the backend via `dataItem.setValue()`

### Interaction rules

From the `ListSetting` source — these rules **must** be followed by all derived types:

1. **Set `interactive=true`** when part/all of the item is clickable
2. **Use `clickable`** to determine whether child items should be enabled
3. **Call `checkWriteAccessLevel()`** before invoking any write action — this shows the toast notification and returns false if the user lacks permission
4. **Never set `enabled=false`** on the list item itself — it must remain enabled so the key navigation highlight appears when navigating over it, even when the item is not writable

### Domain-specific list items

`components/listitems/` (outside `core/`) contains domain-specific settings items that combine core types with domain logic:

- `ListCurrentLimitButton` — AC input current limit with multi-step button
- `ListFirmwareVersion` — firmware version display with update check
- `ListInverterChargerModeButton` — mode selector specific to inverter/chargers
- `ListAlarmLevelRadioButtonGroup` — alarm level selection (disabled/alarm/alarm+relay)
- `ListGeneratorManualControlButton` — generator start/stop control
- `ListTemperatureRelay` — temperature relay threshold with enable switch

These demonstrate the pattern: combine a core list item type with domain-specific VeQuickItem paths and business logic.

## Typical settings page structure

The typical settings page is a Page which contains a GradientListView whose item model is a VisibleItemModel (which ensures that settings are only visible if the user meets the required access level), which itself contains a variety of controls to display or set values in the backend.

```qml
Page {
    title: "Device Settings"

    GradientListView {
        model: VisibleItemModel {
            ListNavigation {
                text: "General"
                onClicked: Global.pageManager.pushPage("/path/to/GeneralSettingsPage.qml")
            }

            ListSwitch {
                text: "Enable monitoring"
                dataItem.uid: device.serviceUid + "/Settings/MonitoringEnabled"
            }

            ListSpinBox {
                text: "Update interval"
                suffix: "s"
                dataItem.uid: device.serviceUid + "/Settings/UpdateInterval"
            }

            ListRadioButtonGroup {
                text: "Mode"
                dataItem.uid: device.serviceUid + "/Mode"
                optionModel: [
                    { display: CommonWords.off, value: 0 },
                    { display: CommonWords.on, value: 1 },
                ]
                writeAccessLevel: VenusOS.User_AccessType_Installer
            }

            ListText {
                text: "Serial number"
                dataItem.uid: device.serviceUid + "/Serial"
                showAccessLevel: VenusOS.User_AccessType_SuperUser
            }
        }
    }
}
```

## Rules for new settings UI

- Always use `ListSetting`-derived types from `components/listitems/core/` — do not create ad-hoc settings rows
- Bind `dataItem.uid` to connect UI to backend data — avoid manual value management where possible
- Set appropriate `showAccessLevel` and `writeAccessLevel` for each item
- Check `dataItem.valid` / use the default `interactive` binding to handle disconnected states gracefully
- Use `GradientListView` (a `BaseListView` subclass) with a `VisibleItemModel` for settings page content
- Respect the interaction rules: never disable the item itself, always call `checkWriteAccessLevel()` before writes
- Items that only display data (no user writes) should use `ListText` or `ListQuantity`
- Items that navigate to sub-pages should use `ListNavigation` — it does not require write access to click
