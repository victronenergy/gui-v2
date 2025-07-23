1) Compile this plugin for gui-v2 using the gui-v2-plugin-compiler

Either: run the following in a terminal which has sourced the Venus OS SDK environment:

python3 ../../tools/gui-v2-plugin-compiler.py \
    --name SimpleExample \
    --min-required-version v1.2.13 \
    --settings SimpleExample_PageSettingsSimple.qml

Alternatively: copy the contents of this directory to the device, ssh in, and compile it on device:

rsync -avc . root@gx.device.ip.address:/tmp/Simple/
ssh root@gx.device.ip.address
cd /tmp/Simple/
python3 /opt/victronenergy/gui-v2/gui-v2-plugin-compiler.py \
    --name SimpleExample \
    --min-required-version v1.2.13 \
    --settings SimpleExample_PageSettingsSimple.qml

2) Copy the output file `SimpleExample.json` to /data/apps/available/SimpleExample/gui-v2/SimpleExample.json on device
3) Symlink the `SimpleExample` directory as follows: `ln -s /data/apps/available/SimpleExample /data/apps/enabled/SimpleExample` on device
4) Run gui-v2 in mock mode, e.g. `/opt/victronenergy/venus-gui-v2 --mock --no-mock-timers`
5) Navigate to Settings -> Integrations -> UI Plugins and confirm the SimpleExample plugin exists
6) Navigate to Settings -> Integrations -> UI Plugins -> SimpleExample to see the settings page
