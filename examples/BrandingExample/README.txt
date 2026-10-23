BrandingExample: an OEM branding plugin

This plugin changes the GUI's colors and splash logos: a mid orange brand
color, very dark grey Dark backgrounds, mid grey Light backgrounds, an amber
warning color, and its own splash logos. It has no pages of its own.

The rules that a Branding file must follow, and the list of Branding
properties, are in .github/branding-plugins.md in the gui-v2 source.
examples/BrandingMinimalExample shows the smallest branding plugin: one color.

Files:
- Branding.qml: the branding values
- logo.svg: the splash icon, drawn on Victron's 285x54 logo canvas, in the
  left 54x54. It keeps its own colors (splash_logo_icon_preserve_colors), so
  it has a dark outline that shows on the Light background.
- wordmark.svg: the splash text "EXAMPLE", drawn as paths on the same canvas,
  to the right of the icon. The GUI tints it: white in Dark, dark grey in Light.

1) Compile this plugin for gui-v2 using the gui-v2-plugin-compiler

Either: run the following in a terminal which has sourced the Venus OS SDK environment:

python3 ../../tools/gui-v2-plugin-compiler.py --branding Branding.qml

Alternatively: copy the contents of this directory to the device, ssh in, and compile it on device (requires Large image):

rsync -avc . root@gx.device.ip.address:/tmp/BrandingExample/
ssh root@gx.device.ip.address
cd /tmp/BrandingExample/
python3 /opt/victronenergy/gui-v2/gui-v2-plugin-compiler.py --branding Branding.qml

The compiler first checks Branding.qml. Each value must be written out in
full: a quoted string, true or false, a number, or a list of quoted strings.
Fix each problem that it reports at file:line:column, and compile again. Then
it runs qmllint, if qmllint is installed. On the device it is not; the
compiler says that it skipped it. The compiler also packs logo.svg and
wordmark.svg, because Branding.qml names them.

2) Install the plugin. Either add `--install root@gx.device.ip.address` to the
compile command in step 1, which copies the plugin to the device and enables
it, or do that by hand:
- Copy the output file `BrandingExample.json` to /data/apps/available/BrandingExample/gui-v2/BrandingExample.json on device: `mkdir -p /data/apps/available/BrandingExample/gui-v2/ && cp BrandingExample.json /data/apps/available/BrandingExample/gui-v2/BrandingExample.json`
- Symlink the `BrandingExample` directory as follows: `ln -s /data/apps/available/BrandingExample /data/apps/enabled/BrandingExample` on device

3) The GUI reloads its plugins when /data/apps/enabled/ changes, so the colors
change straight away. The splash logos show only when the GUI starts, so
restart it to see them: `svc -d /service/start-gui && svc -u /service/start-gui`
4) Switch Settings -> General -> Display & Appearance -> GX display appearance
between Dark and Light, and compare with the expected result below.
5) To go back to Victron's colors and logos, remove the link:
`rm /data/apps/enabled/BrandingExample`

Expected result:
- Splash: the orange hexagon and "EXAMPLE", not Victron's logos.
- Dark: mid orange buttons, active navigation-bar button and selection, with
  dark labels, on very dark grey (#1A1A1A).
- Light: the same orange, with dark labels, on mid grey (#ADADAD). The Light
  colors are worked out from the Dark ones; light_mode_background_factor 0.45
  makes the Light backgrounds mid grey instead of near white.
- Warnings are amber in both schemes. Errors and success stay Victron red and
  green.
- The focus ring (when using keys or buttons) is Victron green in Dark and
  amber in Light.
- Colors that show data (tank, temperature, and similar) do not change.

Known weak spots of this example. They are left in on purpose, to show what to
look for:
- Light: the orange fill is barely lighter or darker than the mid grey
  background. Buttons still show by their label and shape, and by hue.
- Light: Victron's green and red, and the amber warning (which is also the
  Light focus ring), are weak on the mid grey background. A lighter Light
  background helps: raise light_mode_background_factor towards 1.
- Dark has no weak spots.
