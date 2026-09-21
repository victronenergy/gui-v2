NavigationExample - Type 3 (NavigationPage) Plugin
===================================================

Adds a new page to the main navigation bar with a brick icon. The page
displays a configurable tile grid (default 3×2; switchable to 2×3 via
Settings > Integrations > UI Plugins > Example). Requires gui-v2 with
plugin UI lifecycle support (enable/disable + settings).


1) Build the plugin

  cd examples/NavigationExample/
  python3 ../../tools/gui-v2-plugin-compiler.py \
    --min-required-version v1.3.11 \
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
interactive water pump toggle. Under Settings > Integrations > UI Plugins,
toggle the plugin off to hide the nav entry, or open Settings to change
the grid between 2×3 and 3×2.
