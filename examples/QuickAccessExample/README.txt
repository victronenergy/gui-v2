QuickAccessExample - Type 4 (QuickAccessPane) Plugin
=====================================================

Adds a brick icon to the status bar. Pressing it opens a full-screen
overlay pane (like the built-in Controls and Switches panes) showing a
2x2 grid: battery, solar, water level, and a fake water pump toggle.


1) Build the plugin

  cd examples/QuickAccessExample/
  python3 ../../tools/gui-v2-plugin-compiler.py \
    --quickaccess QuickAccessExample_Pane.qml icon_brick_off.svg icon_brick_on.svg

This produces QuickAccessExample.json.

2) Deploy to device

  scp QuickAccessExample.json root@venus.local:/tmp/
  ssh root@venus.local
  mkdir -p /data/apps/available/QuickAccessExample/gui-v2/
  cp /tmp/QuickAccessExample.json /data/apps/available/QuickAccessExample/gui-v2/
  ln -sf /data/apps/available/QuickAccessExample /data/apps/enabled/QuickAccessExample
  svc -t /service/start-gui

3) Verify

The status bar gains a brick icon (outlined). Tapping it slides in the
pane showing battery, solar, water, and a water pump toggle. The icon
switches to the filled variant (icon_brick_on.svg) while the pane is
open. Tap the icon again (or press Escape) to dismiss.
