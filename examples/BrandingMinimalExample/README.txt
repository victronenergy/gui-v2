BrandingMinimalExample: the smallest OEM branding plugin

This plugin sets one branding color, color_brand, and nothing else. Buttons,
the active navigation-bar button, and selection become mid orange, in both
Dark and Light. Informative notifications stay Victron blue. Everything else
stays as Victron's: the backgrounds, text colors, fonts, status colors, and
logos.

The rules that a Branding file must follow, and the list of Branding
properties, are in .github/branding-plugins.md in the gui-v2 source.
examples/BrandingExample shows a fuller branding plugin, with backgrounds and
logos.

1) Compile this plugin for gui-v2 using the gui-v2-plugin-compiler

Either: run the following in a terminal which has sourced the Venus OS SDK environment:

python3 ../../tools/gui-v2-plugin-compiler.py --branding Branding.qml

Alternatively: copy the contents of this directory to the device, ssh in, and compile it on device (requires Large image):

rsync -avc . root@gx.device.ip.address:/tmp/BrandingMinimalExample/
ssh root@gx.device.ip.address
cd /tmp/BrandingMinimalExample/
python3 /opt/victronenergy/gui-v2/gui-v2-plugin-compiler.py --branding Branding.qml

The compiler first checks Branding.qml: the imports, and a few names that
must not appear (see .github/branding-plugins.md). It does not check the
color. Fix each problem that it reports at file:line:column, and compile
again.

2) Install the plugin. Either add `--install root@gx.device.ip.address` to the
compile command in step 1, which copies the plugin to the device and enables
it, or do that by hand:
- Copy the output file `BrandingMinimalExample.json` to /data/apps/available/BrandingMinimalExample/gui-v2/BrandingMinimalExample.json on device: `mkdir -p /data/apps/available/BrandingMinimalExample/gui-v2/ && cp BrandingMinimalExample.json /data/apps/available/BrandingMinimalExample/gui-v2/BrandingMinimalExample.json`
- Symlink the `BrandingMinimalExample` directory as follows: `ln -s /data/apps/available/BrandingMinimalExample /data/apps/enabled/BrandingMinimalExample` on device

3) The GUI reloads its plugins when /data/apps/enabled/ changes, so the colors
change straight away.
4) Switch Settings -> General -> Display & Appearance -> GX display appearance
between Dark and Light: the brand color is orange in both.
5) To go back to Victron's colors, remove the link:
`rm /data/apps/enabled/BrandingMinimalExample`
