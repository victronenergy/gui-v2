CardExample - Type 5 (QuickAccessPaneCard) Plugin
==================================================

Injects a compact dashboard card into the Controls pane (the overlay
opened by the controls icon in the status bar). The card shows battery,
solar, and water status in a compact row layout, plus a toggleable
water pump button.

Card types:
  cardType 1 = Controls pane (appears alongside ESS, EVCS, inverter cards)
  cardType 2 = Switches pane (appears alongside switch group cards)

This example uses cardType 1 (Controls).


1) Build the plugin

  cd examples/CardExample/
  python3 ../../tools/gui-v2-plugin-compiler.py \
    --card CardExample_BatteryCard.qml 1

This produces CardExample.json.

2) Deploy to device

  scp CardExample.json root@venus.local:/tmp/
  ssh root@venus.local
  mkdir -p /data/apps/available/CardExample/gui-v2/
  cp /tmp/CardExample.json /data/apps/available/CardExample/gui-v2/
  ln -sf /data/apps/available/CardExample /data/apps/enabled/CardExample
  svc -t /service/start-gui

3) Verify

Tap the controls icon (top-left of the status bar) to open the Controls
pane. The Plugin Dashboard card appears after the built-in control cards,
showing battery, solar, water, and the water pump toggle.
