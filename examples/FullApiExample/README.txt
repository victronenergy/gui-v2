FullApiExample: a plugin that uses every type in Victron.GuiPlugins

It adds a settings page with five subpages, and a page on the page of a
Skylla-i charger (product id 0x106):

- FullApiExample_Main.qml: the settings page, with navigation rows.
- FullApiExample_Readings.qml: text, quantities in each unit, and
  temperatures.
- FullApiExample_Settings.qml: switches, text fields, numbers, options and
  buttons, with and without data items.
- FullApiExample_CustomRows.qml: rows with content of their own.
- FullApiExample_AccessLevels.qml: rows shown, or changed, only from an
  access level.
- FullApiExample_WordsAndIcons.qml: the common words, already translated,
  and the icons, drawn in the GUI's colors.
- FullApiExample_Device.qml: the device page.

Between them, the pages use every type, and every member at least once.
Members that several types share, such as preferredVisible, showAccessLevel,
writeAccessLevel, click() and checkWriteAccessLevel(), work the same way on
each type, so they are shown on some of the types only. Apart from the
common words in PluginWords, the text is not translated, to keep the pages
short: SimpleTrExample shows how to translate a plugin. The rules that
plugin pages must follow, and a reference for each type, are in
.github/gui-plugins.md in the gui-v2 source.

1) Compile this plugin for gui-v2 using the gui-v2-plugin-compiler

Either: run the following in a terminal which has sourced the Venus OS SDK environment:

python3 ../../tools/gui-v2-plugin-compiler.py \
    --min-required-version v1.4.1 \
    --settings FullApiExample_Main.qml \
    --devicelist 0x106 FullApiExample_Device.qml 'Full API example'

Alternatively: copy the contents of this directory to the device, ssh in, and compile it on device (requires Large image):

rsync -avc . root@gx.device.ip.address:/tmp/FullApiExample/
ssh root@gx.device.ip.address
cd /tmp/FullApiExample/
python3 /opt/victronenergy/gui-v2/gui-v2-plugin-compiler.py \
    --min-required-version v1.4.1 \
    --settings FullApiExample_Main.qml \
    --devicelist 0x106 FullApiExample_Device.qml 'Full API example'

2) Copy the output file `FullApiExample.json` to /data/apps/available/FullApiExample/gui-v2/FullApiExample.json on device: `mkdir -p /data/apps/available/FullApiExample/gui-v2/ && cp FullApiExample.json /data/apps/available/FullApiExample/gui-v2/FullApiExample.json`
3) Symlink the `FullApiExample` directory as follows: `ln -s /data/apps/available/FullApiExample /data/apps/enabled/FullApiExample` on device
4) Run gui-v2 in mock mode, e.g. `/opt/victronenergy/venus-gui-v2 --mock --no-mock-timers`
5) Navigate to Settings -> Integrations -> UI Plugins -> FullApiExample to see the settings page
6) Open the Settings subpage, and click Reset to defaults to create the example's settings (see below)
7) Navigate to Settings -> Device List -> Skylla-i 24/100 -> Full API example to see the device page

The example's settings

The Settings and Custom rows subpages change the plugin's own settings,
under /Settings/FullApiExample/ in com.victronenergy.settings. A plugin's
settings must exist before the GUI can change them. On a GX device, the
plugin's own service normally creates them when it starts.

In mock mode, the settings do not exist until Reset to defaults, on the
Settings subpage, writes them.

When gui-v2 is not in mock mode, create the settings on the GX device with:

dbus -y com.victronenergy.settings /Settings AddSettings '%[
    {"path": "FullApiExample/Enabled", "default": 1, "min": 0, "max": 1},
    {"path": "FullApiExample/ReportDays", "default": 1, "min": 1, "max": 7},
    {"path": "FullApiExample/Name", "default": ""},
    {"path": "FullApiExample/CurrentLimit", "default": 16.0, "min": 0.0, "max": 32.0},
    {"path": "FullApiExample/Mode", "default": 1, "min": 0, "max": 2},
    {"path": "FullApiExample/Level", "default": 3, "min": 1, "max": 5}]'

An existing setting keeps its value. Remove the settings again with:

dbus -y com.victronenergy.settings /Settings RemoveSettings '%["FullApiExample/Enabled", "FullApiExample/ReportDays", "FullApiExample/Name", "FullApiExample/CurrentLimit", "FullApiExample/Mode", "FullApiExample/Level"]'
