DeviceListExample: a plugin that adds pages to a device's page

Each page's root is a PluginDevicePage, from Victron.GuiPlugins. The app sets
its serviceUid, productId and deviceName properties when it opens the page.
The rules that plugin pages must follow are in .github/gui-plugins.md in the
gui-v2 source. DeviceListExample_ComponentError.qml does not compile, on
purpose, to show that a broken plugin page does not break the GUI.

1) Compile this plugin for gui-v2 using the gui-v2-plugin-compiler

Either: run the following in a terminal which has sourced the Venus OS SDK environment:

python3 ../../tools/gui-v2-plugin-compiler.py \
    --min-required-version v1.4.1 \
    --devicelist 0x106 DeviceListExample_CellVoltages.qml devicelistexample_cellvoltages_title_cell_voltages \
    --devicelist 0x106 DeviceListExample_CellTemperatures.qml 'Cell Temperatures' \
    --devicelist 0x106 DeviceListExample_ComponentError.qml 'Invalid Customisation'

Alternatively: copy the contents of this directory to the device, ssh in, and compile it on device (requires Large image):

rsync -avc . root@gx.device.ip.address:/tmp/DeviceListExample/
ssh root@gx.device.ip.address
cd /tmp/DeviceListExample/
python3 /opt/victronenergy/gui-v2/gui-v2-plugin-compiler.py \
    --min-required-version v1.4.1 \
    --devicelist 0x106 DeviceListExample_CellVoltages.qml devicelistexample_cellvoltages_title_cell_voltages \
    --devicelist 0x106 DeviceListExample_CellTemperatures.qml 'Cell Temperatures' \
    --devicelist 0x106 DeviceListExample_ComponentError.qml 'Invalid Customisation'

For a testing install on a GX device, add `--install <gx-host> --ssh-key <private-key>` to the command above. It connects as root and does steps 2 and 3. Or do them by hand:

2) Copy the output file `DeviceListExample.json` to /data/apps/available/DeviceListExample/gui-v2/DeviceListExample.json on device: `mkdir -p /data/apps/available/DeviceListExample/gui-v2/ && cp DeviceListExample.json /data/apps/available/DeviceListExample/gui-v2/DeviceListExample.json`
3) Symlink the `DeviceListExample` directory as follows: `ln -s /data/apps/available/DeviceListExample /data/apps/enabled/DeviceListExample` on device
4) Run gui-v2 in mock mode, e.g. `/opt/victronenergy/venus-gui-v2 --mock --no-mock-timers`
5) Navigate to Settings -> Integrations -> UI Plugins and confirm the DeviceListExample plugin exists
6) Navigate to Settings -> Device List -> Skylla-i 24/100 and find the plugin-provided entries there

Note that the custom entries provided by the DeviceListExample plugin will only be displayed in the Device List page for "Skylla-i 24/100" devices which have product id "0x106".
