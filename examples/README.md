# gui-v2 Plugin Examples

Example plugins demonstrating each integration type supported by the
gui-v2 plugin system. See each example's README.txt for build and
deploy instructions.

## Integration Types

| Type | Name                       | Where it appears                                     | Example                              |
| ---- | -------------------------- | ---------------------------------------------------- | ------------------------------------ |
| 1    | **PluginSettingsPage**     | Settings > Integrations > UI Plugins > *your plugin* | `SimpleExample/`, `SimpleTrExample/` |
| 2    | **DeviceListSettingsPage** | Device list settings for a specific product ID       | `DeviceListExample/`                 |
| 3    | **NavigationPage**         | Main navigation bar (between Overview and Levels)    | `NavigationExample/`                 |
| 4    | **QuickAccessPane**        | Status bar icon that opens a full pane overlay       | `QuickAccessExample/`                |
| 5    | **QuickAccessPaneCard**    | Card injected into the Controls or Switches pane     | `CardExample/`                       |

A single plugin can combine multiple integration types (e.g. a settings
page and a navigation page in one JSON file).

## Building Plugins

All examples use `tools/gui-v2-plugin-compiler.py`. Requirements:
Python 3, Qt tools (`rcc`) in PATH.

```
cd examples/SimpleExample/
python3 ../../tools/gui-v2-plugin-compiler.py \
    --settings SimpleExample_PageSettingsSimple.qml
```

This produces a `.json` file containing the compiled QML resources.

## Deploying to Device

```
scp MyPlugin.json root@venus.local:/tmp/
ssh root@venus.local
mkdir -p /data/apps/available/MyPlugin/gui-v2/
cp /tmp/MyPlugin.json /data/apps/available/MyPlugin/gui-v2/
ln -sf /data/apps/available/MyPlugin /data/apps/enabled/MyPlugin
svc -t /service/start-gui
```

## Examples

### SimpleExample (Type 1)

Minimal plugin with a single settings page. Appears under
Settings > Integrations > UI Plugins.

### SimpleTrExample (Type 1)

Same as SimpleExample but with French translations via `.ts` files.

### DeviceListExample (Type 2)

Injects custom pages into the device list for devices matching
product ID `0x106` (Skylla-i 24/100).

### NavigationExample (Type 3)

Adds a new page to the main nav bar with a brick icon showing a
2x2 tile grid (battery, solar, water, fake water pump toggle).
Requires gui-v2 v1.3.11+.

### QuickAccessExample (Type 4)

Adds a brick icon to the status bar. Clicking it opens a full-screen
overlay pane (like the built-in Controls and Switches panes) showing
battery, solar, water, and a water pump toggle.

### CardExample (Type 5)

Injects a compact dashboard card into the Controls pane showing
battery, solar, water, and a toggleable water pump button alongside
the built-in ESS, EVCS, and inverter cards.
