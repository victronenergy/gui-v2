QuickAccessExample - Type 4 (QuickAccessPane) Plugin
=====================================================

Adds a brick icon to the status bar. Pressing it opens a full-screen
overlay pane (like the built-in Controls and Switches panes) with three
cards, laid out as in the Controls pane: a battery card with the state
of charge, voltage and power, a solar card with DC PV power, and a pump
card with a local toggle. The pane imports only Victron.GuiPlugins. To
show devices, such as tanks, use a PluginDeviceModel, as FullApiExample
does.


1) Build the plugin

  cd examples/QuickAccessExample/
  python3 ../../tools/gui-v2-plugin-compiler.py \
    --quickaccess QuickAccessExample_Pane.qml icon_brick_off.svg icon_brick_on.svg

This produces QuickAccessExample.json. The compiler also packs the
other images in the directory, such as icon_solar.svg, the solar
card's icon.

2) Deploy to device

  scp QuickAccessExample.json root@venus.local:/tmp/
  ssh root@venus.local
  mkdir -p /data/apps/available/QuickAccessExample/gui-v2/
  cp /tmp/QuickAccessExample.json /data/apps/available/QuickAccessExample/gui-v2/
  ln -sf /data/apps/available/QuickAccessExample /data/apps/enabled/QuickAccessExample
  svc -t /service/start-gui

3) Verify

The status bar gains a brick icon (outlined). Tapping it slides in the
pane. The cards stand side by side, and scroll sideways; in portrait
layout, they stand one above the other, and scroll up and down. The
battery card shows the state of charge, voltage and power, and whether
the battery is charging. The solar card shows DC PV power. The pump
card has a local toggle: it does not control a pump. With key
navigation, the Left and Right keys move between the cards (in portrait
layout, the Up and Down keys do, past the first or last item in a
card), and the Up and Down keys move between the items in a card.
The icon switches to the filled variant (icon_brick_on.svg) while the
pane is open. Tap the icon again (or press Escape) to dismiss.

This pane needs a gui-v2 that can open a quick access pane. Do not set
--min-required-version to an older gui-v2 release: those builds do not
have this pane.
