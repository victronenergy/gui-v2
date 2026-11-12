NavigationExample - a navigation page

Adds a page to the main navigation bar, with a brick icon. The page is
a PluginPage. It imports only Victron.GuiPlugins. The rules are in
.github/gui-plugins.md.

The page draws four tiles of its own: battery state of charge (with a
bar, and whether the battery is charging), battery power, DC PV power,
and DC system power. A positive battery power value means charging.
The tiles take their colors and text sizes from PluginPalette, so they
follow light and dark mode and custom branding. The tile background is
a dark brand color, made with Qt.tint() and Qt.alpha(). The tiles are
in two rows and two columns in landscape layout, and in one column in
portrait layout (PluginPalette.orientation). The page only shows
values. To list devices, such as tanks, use a PluginDeviceModel, as
FullApiExample does.

The bar title is the compiler argument below, navigationexample_title.
It is the translation id of the page title, so it is translated, and
shows "Example" in English. It is shown in the navigation bar, and in
the status bar in portrait layout.


1) Compile

  cd examples/NavigationExample/
  python3 ../../tools/gui-v2-plugin-compiler.py \
    --min-required-version v1.4.1 \
    --navigation NavigationExample_Page.qml \
      icon_brick.svg navigationexample_title BeforeNotifications

This writes NavigationExample.json. The location BeforeNotifications
inserts the page after Levels. If the location is omitted, the page is
inserted before Levels. The location, if given, must be the last
argument and one of: BeforeBoat, BeforeBrief, BeforeOverview,
BeforeLevels, BeforeNotifications, BeforeSettings or AfterSettings. An
integer is an error. A title may be a location name only when another
location name follows it. The gap is not a visible button. BeforeBoat
is still first when Boat is hidden. The page file name must be unique
and must not match a built-in page. The navbar matches the file name
only.

Other examples use v1.4.1 because that is the Victron.GuiPlugins
minimum they need. This page also needs a gui-v2 that loads navigation
pages. The loader rejects a plugin whose minimum is newer than the
running gui-v2.

2) Deploy to a GX device

  scp NavigationExample.json root@venus.local:/tmp/
  ssh root@venus.local
  mkdir -p /data/apps/available/NavigationExample/gui-v2/
  cp /tmp/NavigationExample.json /data/apps/available/NavigationExample/gui-v2/
  ln -sf /data/apps/available/NavigationExample /data/apps/enabled/NavigationExample
  svc -t /service/start-gui

Or add --install <gx-host> --ssh-key <private-key> to the compile
command. That is for testing only.

3) Verify

The navigation bar now shows:

  Boat | Brief | Overview | Levels | Example | Notifications | Settings

Tap the brick icon. The page shows the four tiles, in a grid of two by
two in landscape layout, or in one column in portrait layout.
