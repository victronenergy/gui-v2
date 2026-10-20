SimpleTrExample: a plugin that adds a translated settings page

Like SimpleExample, but the switch text is translated, with the plugin's
own translation files. The page is written with the Victron.GuiPlugins types;
a plugin page must not import Victron.VenusOS. The rules that plugin pages
must follow are in .github/gui-plugins.md in the gui-v2 source.

1) Compile this plugin for gui-v2 using the gui-v2-plugin-compiler

Either: run the following in a terminal which has sourced the Venus OS SDK environment:

python3 ../../tools/gui-v2-plugin-compiler.py \
    --min-required-version v1.4.1 \
    --settings SimpleTrExample_PageSettingsSimple.qml

Alternatively: copy the contents of this directory to the device, ssh in, and compile it on device (requires Large image):

rsync -avc . root@gx.device.ip.address:/tmp/SimpleTrExample/
ssh root@gx.device.ip.address
cd /tmp/SimpleTrExample/
python3 /opt/victronenergy/gui-v2/gui-v2-plugin-compiler.py \
    --min-required-version v1.4.1 \
    --settings SimpleTrExample_PageSettingsSimple.qml

For a testing install on a GX device, add `--install <gx-host> --ssh-key <private-key>` to the command above. It connects as root and does steps 2 and 3. Or do them by hand:

2) Copy the output file `SimpleTrExample.json` to /data/apps/available/SimpleTrExample/gui-v2/SimpleTrExample.json on device: `mkdir -p /data/apps/available/SimpleTrExample/gui-v2/ && cp SimpleTrExample.json /data/apps/available/SimpleTrExample/gui-v2/SimpleTrExample.json`
3) Symlink the `SimpleTrExample` directory as follows: `ln -s /data/apps/available/SimpleTrExample /data/apps/enabled/SimpleTrExample` on device
4) Run gui-v2 in mock mode, e.g. `/opt/victronenergy/venus-gui-v2 --mock --no-mock-timers`
5) Navigate to Settings -> Integrations -> UI Plugins and confirm the SimpleTrExample plugin exists
6) Navigate to Settings -> Integrations -> UI Plugins -> SimpleTrExample to see the settings page
7) Navigate to Settings -> General -> Language and change to French language, before navigating back to Settings -> Integrations -> UI Plugins -> SimpleTrExample to see the text has changed from "Battery" to "Batterie".
