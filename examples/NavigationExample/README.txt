NavigationExample - Type 3 (NavigationPage) Plugin
===================================================

Adds a new page to the main navigation bar with a brick icon. The page
displays a configurable tile grid (default 3×2; switchable to 2×3 via
Settings > Integrations > UI Plugins > Example). Requires gui-v2 with
plugin UI lifecycle support (isPluginEnabled / pluginSetting). Those
calls are not in v1.3.11. The command below uses v1.3.22 because that
is this tree's project version; the loader rejects a plugin whose
minimum is newer than the running gui-v2. Stock v1.3.22 does not have
these calls, and the version check cannot tell the two apart.


1) Build the plugin

  cd examples/NavigationExample/
  python3 ../../tools/gui-v2-plugin-compiler.py \
    --min-required-version v1.3.22 \
    --settings NavigationExample_PageSettings.qml \
    --navigation NavigationExample_Page.qml icon_brick.svg "Example"

This produces NavigationExample.json.

2) Deploy to device

  scp NavigationExample.json root@venus.local:/tmp/
  ssh root@venus.local
  mkdir -p /data/apps/available/NavigationExample/gui-v2/
  cp /tmp/NavigationExample.json /data/apps/available/NavigationExample/gui-v2/
  ln -sf /data/apps/available/NavigationExample /data/apps/enabled/NavigationExample
  svc -t /service/start-gui

3) Verify

The navigation bar now shows:

  Boat | Brief | Overview | Example | Levels | Notifications | Settings

Tap the brick icon to see the tile grid with live data and the
interactive water pump toggle. Settings > Integrations > UI Plugins
opens this plugin's page, where Enabled hides the nav entry and
Tile grid switches between 2×3 and 3×2.
