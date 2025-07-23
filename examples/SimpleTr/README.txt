1) Compile this plugin for gui-v2 using the gui-v2-plugin-compiler

Either: run the following in a terminal which has sourced the Venus OS SDK environment:

python3 ../../tools/gui-v2-plugin-compiler.py \
    --name SimpleTrExample \
    --min-required-version v1.2.13 \
    --settings SimpleTrExample_PageSettingsSimple.qml

Alternatively: copy the contents of this directory to the device, ssh in, and compile it on device:

rsync -avc . root@gx.device.ip.address:/tmp/SimpleTr/
ssh root@gx.device.ip.address
cd /tmp/SimpleTr/
python3 /opt/victronenergy/gui-v2/gui-v2-plugin-compiler.py \
    --name SimpleTrExample \
    --min-required-version v1.2.13 \
    --settings SimpleTrExample_PageSettingsSimple.qml

2) Copy the output file `SimpleTrExample.json` to /data/apps/available/SimpleTrExample/gui-v2/SimpleTrExample.json on device
3) Symlink the `SimpleTrExample` directory as follows: `ln -s /data/apps/available/SimpleTrExample /data/apps/enabled/SimpleTrExample` on device
4) Run gui-v2 in mock mode, e.g. `/opt/victronenergy/venus-gui-v2 --mock --no-mock-timers`
5) Navigate to Settings -> Integrations -> UI Plugins and confirm the SimpleTrExample plugin exists
6) Navigate to Settings -> Integrations -> UI Plugins -> SimpleTrExample to see the settings page
7) Navigate to Settings -> General -> Language and change to French language, before navigating back to Settings -> Integrations -> UI Plugins -> SimpleTrExample to see the text has changed from "Battery" to "Batterie".
