NavigationExample - Type 3 (NavigationPage) Plugin
===================================================

Adds a new page to the main navigation bar with a brick icon. The page
shows a tile grid (battery, solar, propane, water, pump, DC). Turning
the plugin on or off is the Venus applications symlink under
/data/apps/enabled, the same as any other GUI plugin. The command
below uses v1.3.22 because that is this tree's project version; the
loader rejects a plugin whose minimum is newer than the running gui-v2.


1) Build the plugin

  cd examples/NavigationExample/
  python3 ../../tools/gui-v2-plugin-compiler.py \
    --min-required-version v1.3.22 \
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
interactive water pump toggle.
