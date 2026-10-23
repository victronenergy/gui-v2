# GUI plugins

A GUI plugin adds pages to gui-v2, without changing gui-v2: a settings page, under Settings -> Integrations -> UI Plugins, or pages on the page of a device in the device list. Plugin pages are written with the types of the `Victron.GuiPlugins` module, which gui-v2 keeps stable for plugins.

This document is for OEM and third-party developers, and for AI agents that write or check a plugin. It is complete on its own: you do not need to read gui-v2's internals. Branding plugins, which change the GUI's colors, fonts and logos, are a separate kind of plugin and are not covered here.

Four example plugins show the rules in practice:

- `examples/SimpleExample`: a settings page with one switch.
- `examples/SimpleTrExample`: the same, with the switch text translated.
- `examples/DeviceListExample`: pages on the page of a device.
- `examples/FullApiExample`: a settings page and a device page that, between them, use every type in the [type reference](#type-reference), and every member at least once.

`Victron.GuiPlugins` is not finished yet. It has the types in the [type reference](#type-reference); more row types will be added.

## Quick start

1. Make a directory named after your plugin, for example `OemName`. The compiler names the plugin after the directory.
2. Write the page, for example `OemName/OemNameSettings.qml`, following the rules below. Start from one of the examples.
3. Compile it, from that directory:

   ```
   python3 <gui-v2>/tools/gui-v2-plugin-compiler.py --settings OemNameSettings.qml
   ```

   For a page on the page of a device, give the product id, the page file and the row title instead: `--devicelist 0x106 OemNameDevice.qml "Cell Voltages"`. On a GX device with the Large image, the compiler is `/opt/victronenergy/gui-v2/gui-v2-plugin-compiler.py`.
4. The compiler packs every `.qml` file in the directory, so subpages need no option of their own. It writes `OemName.json`.
5. Install it on a GX device by adding `--install root@<gx-host>` to the compile command, or by hand: copy `OemName.json` to `/data/apps/available/OemName/gui-v2/`, then `ln -s /data/apps/available/OemName /data/apps/enabled/OemName`. On a desktop build of gui-v2, copy `OemName.json` into the `plugins` directory next to the `venus-gui-v2` executable.

## Rules for plugin pages

The compiler does not check these rules. A page that breaks them may work today, and then break with any GUI update.

1. **Imports.** Import `Victron.GuiPlugins`, and Qt modules such as `QtQuick` and `QtQuick.Layouts`. Never import `Victron.VenusOS`, or any other Victron module: their types are gui-v2's own, and change without notice.
2. **The root type.** The root of a settings page, and of every subpage, is a `PluginPage`. The root of a page on the page of a device is a `PluginDevicePage`. The root may also be a type that your plugin defines in its own file, if that file's root is one of these. The GUI refuses a page whose root is a `Page` (the type that gui-v2's own pages use): it does not open it, and logs `Aborted attempt to push plugin page whose root is a Page`. Plugins written for older versions of gui-v2, with a `Page` root, must be ported.
3. **Rows.** Declare the rows directly inside a `PluginGradientListView`, in the order they are shown. Only the `Plugin*` row types can be rows. The rows are fixed when the page is created: to hide a row, set its `preferredVisible` to `false`, and the row then takes no space, and key navigation skips it. Never set `visible` on a row.
4. **Subpages.** Open a subpage with a `PluginListNavigation` row, and give its file as `pageUrl: Qt.resolvedUrl("SubPage.qml")`, so that it is found next to your page. A subpage must be a file of its own: a page written inline, as a `Component`, cannot be opened.
5. **Values on the system.** Read and write values with a `PluginDataItem`, which every row with a value has as `dataItem`. See [Values](#values).
6. **Access levels.** Use `PluginAccessLevel.User`, `.Installer`, `.SuperUser` and `.Service` for `showAccessLevel` and `writeAccessLevel`.
7. **Key navigation.** The GUI can be used with keys or buttons, as well as touch. The row types handle this. In a `PluginListItem`, handle key presses on the row, for example with `Keys.onSpacePressed`, and call `checkWriteAccessLevel()` before changing a setting.
8. **Text.** For common words, such as "Status", "Voltage" or "On", use `PluginWords`: they are already translated, and change with the user's language. Translate other text with `qsTrId()`, with a `//% "Source text"` comment above it, and ship the translations in the plugin's own `.ts` files, as `examples/SimpleTrExample` does. See [Words and icons](#words-and-icons).
9. **Colors and fonts.** Plugins cannot read the GUI's colors and fonts, which change with light and dark mode, the screen size, and OEM branding. The row types draw their text with them, so let the rows draw text: in a `PluginListItem`, set the row's `text` and `caption` rather than adding your own label. Draw icons with `PluginIconImage`, which colors them by purpose. Other images that your plugin ships must be visible on both light and dark backgrounds, as in `examples/DeviceListExample`.

For example, a settings page with a switch and a subpage:

```qml
import QtQuick
import Victron.GuiPlugins

PluginPage {
	title: "OemName"

	PluginGradientListView {
		PluginListSwitch {
			text: "Enabled"
			dataItem.serviceType: "settings"
			dataItem.path: "/Settings/OemName/Enabled"
		}

		PluginListNavigation {
			text: "Advanced"
			pageUrl: Qt.resolvedUrl("OemNameAdvanced.qml")
			showAccessLevel: PluginAccessLevel.Installer
		}
	}
}
```

## Values

A `PluginDataItem` is one value on the system, such as a setting or a measurement. Point it at the value in one of two ways:

- **`serviceType` and `path`**, for a service that has a single instance: `settings`, `system`, `platform`, or your plugin's own service. For example, `serviceType: "settings"` and `path: "/Settings/Gui/DemoMode"`. The data item builds the full `uid` for the connection in use (D-Bus on the device, MQTT in the remote console, or the mock system on a desktop), and `uid` then returns it.
- **`uid`**, the full uid of the value. On a `PluginDevicePage`, build it from the page's `serviceUid`, for example `uid: root.serviceUid + "/Dc/0/Voltage"`.

Set one or the other, not both. Then read `value` and `valid`, and `min` and `max` (each is NaN when the system does not give it), and write the value with `setValue()`.

## Words and icons

**`PluginWords`** has common words, already translated into the user's language, so your plugin does not need to translate them. They change when the user changes the language. Use them like any text, for example `text: PluginWords.status`. The names are those of gui-v2's own `CommonWords`, so a gui-v2 page can be ported by replacing `CommonWords.` with `PluginWords.`. A word keeps its name, even if it is renamed in gui-v2. The words, with their English text where the name does not make it clear:

- Answers and actions: `yes`, `no`, `reset`, `remove`.
- Setting values: `on`, `off`, `auto`, `enabled`, `disabled`.
- States: `error`, `unknown_status` ("Unknown").
- Labels: `status`, `state`, `mode`, `type`, `settings`, `setup`, `alarms`, `history`, `total`.
- Quantities: `temperature`, `voltage`, `current_amps` ("Current"), `power_watts` ("Power").
- Devices: `battery`, `manufacturer`, `model_name`, `serial_number`, `firmware_version`, `custom_name`.

For any other text, use your own translations (rule 8).

**`PluginIcons`** has the urls of common icons: `alarm`, `warning`, `info`, `checkmark`, `close`, `plus`, `minus`, `trash`, `refresh`, `open_link`, `battery`, `temperature`, `humidity`, `devices`. An icon keeps its name, even if the image behind it changes.

**`PluginIconImage`** draws an icon in one of the GUI's colors. Its `source` is one of the `PluginIcons`, or a single-color image that your plugin ships. Set `tint` to choose the color by its purpose: `PluginIconImage.Text` (the default), `SecondaryText`, `Warning`, `Critical`, `Success` or `Disabled`. When the icon is disabled (`enabled: false`), it is drawn in the `Disabled` color, whatever its `tint`. The icon is the GUI's usual icon size, unless you set its `width` and `height`; the image keeps its shape, and is centred. Do not draw the `PluginIcons` with an `Image`: they have a single color, which may not show on the background.

```qml
PluginListItem {
	text: PluginWords.status

	PluginIconImage {
		source: PluginIcons.warning
		tint: PluginIconImage.Warning
	}
}
```

## Type reference

All of these are in `Victron.GuiPlugins`.

### Pages

- **`PluginPage`**: the root of a plugin page. `title` is shown in the status bar. The GUI provides the back button, and sizes the page.
- **`PluginDevicePage`**: a `PluginPage` for the page of a device. The GUI sets `serviceUid` (the start of the device's uids), `productId` and `deviceName` when it opens the page.
- **`PluginGradientListView`**: a scrolling list of rows, which fills its parent.

### Rows

Every row derives from `PluginListRow`, which you do not use directly. So every row has:

- `preferredVisible`: set it to `false` to hide the row.
- `showAccessLevel`: the lowest access level that shows the row. The default is `PluginAccessLevel.User`.
- `effectiveVisible` (read only): whether the row is shown.

The row types:

- **`PluginListSwitch`**: a label and a toggle switch. Either set `dataItem`, and the switch shows whether the value is `valueTrue` (default 1), and a click writes `valueFalse` (default 0) or `valueTrue`; or set `checkable: true`, and use `checked` and `onClicked`. Set `updateDataOnClick: false` to handle the click yourself, for example to ask before writing. Also: `text`, `caption`, `secondaryText`, `writeAccessLevel`, `interactive`, `click()`, `checkWriteAccessLevel()`.
- **`PluginListTextField`**: a label and an editable text field. The field shows `secondaryText`, which is the value of `dataItem` by default; when the user finishes editing, the new text is written to `dataItem`. Also: `text`, `caption`, `placeholderText`, `maximumLength`, `writeAccessLevel`, `checkWriteAccessLevel()`.
- **`PluginListNavigation`**: a row with an arrow, which opens `pageUrl` when clicked, with `pageProperties` set on the new page. The subpage's title is the row's `text`, unless `pageProperties` gives another one. Or leave `pageUrl` empty and handle `onClicked`. Also: `caption`, `secondaryText`, `interactive`, `click()`.
- **`PluginListText`**: a label, and read-only text on the right. The text is `secondaryText`, which is the value of `dataItem` by default. Also: `text`, `caption`.
- **`PluginListQuantity`**: a label, and a value with its unit on the right, such as "12.35 V". The value is `value`, which is the value of `dataItem` by default; if it is not a number, the row shows "--". Set `unit` to a `PluginUnit`, and `decimals` to the number of decimal places (by default, the usual number for the unit and the size of the value). Also: `text`, `caption`. For a temperature, use `PluginListTemperature`.
- **`PluginListTemperature`**: a label, and a temperature on the right, in the unit the user chose (Celsius or Fahrenheit). The temperature is the value of `dataItem`, which must be in degrees Celsius. Also: `text`, `caption`, `decimals`.
- **`PluginListSpinBox`**: a label, and a number on the right. A click opens a dialog in which the user picks a new number, from `from` to `to` (by default, the `min` and `max` of `dataItem`, if the system gives them), in steps of `stepSize` (default 1). The number is `value`, which is the value of `dataItem` by default, and the picked number is written to `dataItem`. Without a `dataItem`, the picked number is set as `value`, which replaces any binding on it. Also: `text`, `caption`, `suffix` (shown after the number, such as `" A"`), `decimals` (default 0), `writeAccessLevel`, `interactive`, `click()`, `checkWriteAccessLevel()`.
- **`PluginListRadioButtonGroup`**: a label, and the current option on the right. A click opens a page that lists the options, and the user picks one. `optionModel` is an array of options, each an object with `display` (the option's text) and `value`, for example `[ { display: "Off", value: 0 }, { display: "On", value: 1 } ]`. `currentIndex` is the index of the current option, or -1 for none, when the row shows `defaultSecondaryText` ("Unknown" by default). By default, `currentIndex` is the option whose `value` is the value of `dataItem`, and picking an option writes its `value` to `dataItem`. Without a `dataItem`, set `currentIndex` yourself in `onOptionClicked(index)`. Set `updateDataOnClick: false` to handle the pick yourself, for example to ask before writing. Also: `text`, `caption`, `writeAccessLevel`, `interactive`, `click()`, `checkWriteAccessLevel()`.
- **`PluginListButton`**: a label, and a button on the right that shows `secondaryText`. A click emits `clicked()`, if the user has `writeAccessLevel`. Also: `text`, `caption`, `interactive`, `click()`, `checkWriteAccessLevel()`.
- **`PluginSettingsListHeader`**: a heading, `text`, above a group of rows. Key navigation skips it.
- **`PluginPrimaryListLabel`**: explanatory text, `text`, across the width of the list, without a row background. Key navigation skips it.
- **`PluginListItem`**: a row with your own content, for rows that the other types do not cover. Declare the content inside it; the row gives it the standard background, the key navigation highlight, and access handling. If you set `text`, the row shows it, and `caption`, like the other rows do, and puts your content on the right, at the content's own size; if the content does not fit beside the text, it goes below it. If `text` is empty, your content fills the width of the row. Set `interactive: true` if the content can be clicked, and enable it with `clickable`. Also: `writeAccessLevel`, `checkWriteAccessLevel()`.

### Other types

- **`PluginDataItem`**: a value on the system. See [Values](#values).
- **`PluginAccessLevel`**: `User`, `Installer`, `SuperUser`, `Service`.
- **`PluginUnit`**: the units for `PluginListQuantity`: `None`, `Amp`, `AmpHour`, `Energy_KiloWattHour`, `Percentage`, `RevolutionsPerMinute`, `VoltAmpere`, `Volt_AC`, `Volt_DC`, `Watt`.
- **`PluginWords`**, **`PluginIcons`** and **`PluginIconImage`**: see [Words and icons](#words-and-icons).

### Versions

The version of `Victron.GuiPlugins` that added each type. A type's members came with it, unless they are listed after it with a later version. See [Versioning](#versioning).

<!-- BEGIN versions. tools/guipluginsapi.py writes this part from tools/guiplugins-api.json: do not edit it. -->

- `PluginAccessLevel`: 1.0
- `PluginDataItem`: 1.0
- `PluginDevicePage`: 1.0
- `PluginGradientListView`: 1.0
- `PluginIconImage`: 1.0
- `PluginIcons`: 1.0
- `PluginListButton`: 1.0
- `PluginListItem`: 1.0
- `PluginListNavigation`: 1.0
- `PluginListQuantity`: 1.0
- `PluginListRadioButtonGroup`: 1.0
- `PluginListRow`: 1.0
- `PluginListSpinBox`: 1.0
- `PluginListSwitch`: 1.0
- `PluginListTemperature`: 1.0
- `PluginListText`: 1.0
- `PluginListTextField`: 1.0
- `PluginPage`: 1.0
- `PluginPrimaryListLabel`: 1.0
- `PluginSettingsListHeader`: 1.0
- `PluginUnit`: 1.0
- `PluginWords`: 1.0

<!-- END versions -->

## Versioning

`Victron.GuiPlugins` has its own version, `major.minor`, separate from gui-v2's version.

- **Minor versions add types and members.** The [versions](#versions) list in the type reference says which version added each one.
- **The required version.** The compiler writes `requiredGuiPluginsVersion` into the plugin's JSON file, and prints it: the lowest `Victron.GuiPlugins` version that has every type and member that your files use. A plugin that uses only types and members from 1.0 needs 1.0, even if the compiler was built for a newer version, so it still runs on older GX devices. If none of your files imports `Victron.GuiPlugins`, the compiler writes no `requiredGuiPluginsVersion`.
- **How the compiler finds what you use.** It goes by names. A member counts as used if its name appears in your files, outside comments and plain strings, and it belongs to a type that you use, to that type's base type, or to the type of another member that you use. A handler such as `onToggled` or `onCheckedChanged` uses `toggled` or `checked`. So if one of your own properties or functions has the same name as a newer member, the version can be newer than needed. The compiler prints the members that need the version it writes; if one of them is really your own property or function, rename yours.
- **What the GUI does with it.** If the GUI's `Victron.GuiPlugins` has a different major version, or an older minor version, than `requiredGuiPluginsVersion`, the GUI ignores the plugin's pages and logs why, for example `Ignoring integration at index 0 in plugin OemName - type: 1 - it needs Victron.GuiPlugins 1.2, but this GUI only has 1.1`. A plugin without `requiredGuiPluginsVersion` is not checked.
- **Older GUIs.** Versions of gui-v2 without `Victron.GuiPlugins` do not check `requiredGuiPluginsVersion`, and cannot open the plugin's pages. So also pass `--min-required-version` to the compiler, with the first gui-v2 version that has `Victron.GuiPlugins`, as the examples do.
- **Deprecation.** A type or member that is to be removed is first marked as deprecated in the type reference, and from then on the GUI logs a warning, once, when a plugin uses it. It is removed only in the next major version. Nothing is deprecated yet.
- **Major versions** remove or change types and members. When a new major version is announced, plugin authors must port their plugins to the new API.

## Changing Victron.GuiPlugins (gui-v2 contributors)

- The module is in `guiplugins/`, and its files are listed in `cmake/ModuleGuiPlugins_Sources.cmake`. Its types wrap `Victron.VenusOS` types, and may use them in their own code. `Victron.VenusOS` must never use `Victron.GuiPlugins`; the `tst_moduledependencies` test fails if it does. See [Module dependencies](architecture.md#module-dependencies).
- Every promised member is declared on the wrapper's root, so that the inner `Victron.VenusOS` type can change without changing the plugin API. A row type's root is `PluginListRow`, and the inner row (`id: inner`) takes `preferredVisible` and `showAccessLevel` from it.
- `tools/guiplugins-api.json` is the checked-in record of the API: every type in the module, and each type's properties, signals, methods and enums, with the version that added each one. `tools/guipluginsapi.py` writes it from the files in `cmake/ModuleGuiPlugins_Sources.cmake`, and writes the [versions](#versions) list from it. The `tst_guipluginsapi` test fails if either is out of date. Every file in the module is part of the API. A QML file's API is its root type and the declarations directly inside its root object; a header's API is the class or namespace that it registers with `QML_ELEMENT`.
- The script refuses:
  - a change that could break a plugin, unless `VICTRON_GUIPLUGINS_VERSION_MAJOR` goes up: removing or renaming a type or member, changing a type's base or a property's type, making a property read-only or required, changing the default property, changing a signal's or method's parameters or return type, or changing an enum value's number. Only for a type or member that no released GUI has, `--allow-breaking-changes` lets you make such a change;
  - a type that plugins cannot use, anywhere in the API. Plugins import only `Victron.GuiPlugins`, `QtQml` and `QtQuick`, so the API may use only QML's basic types, `QtObject`, `Item`, `FocusScope`, `Component`, and the module's own types. This keeps `Victron.VenusOS` types out of it;
  - a declaration that it cannot read, such as an inline component, a slot, or a `Q_PROPERTY` written over several lines.
- To add to the API: if the current version has been released, first increase `VICTRON_GUIPLUGINS_VERSION_MINOR` in `cmake/ModuleGuiPlugins.cmake`. Then add the type or member, and run `python3 tools/guipluginsapi.py`. New types and members get the current version, and the script adds them to the [versions](#versions) list.
- Removing or changing a type or member needs a new major version. See [Versioning](#versioning).
- The compiler reads `tools/guiplugins-api.json`, which is installed next to it, to work out each plugin's `requiredGuiPluginsVersion` (see [Versioning](#versioning)). The plugin loader, in `src/guiplugins.cpp`, gets the module version from `cmake/ModuleGuiPlugins.cmake` as two compile definitions, and drops a plugin's pages if it needs a version that the GUI does not have. The `tst_plugincompiler` and `tst_guipluginloader` tests cover both.
- The enums for plugins, `PluginAccessLevel` and `PluginUnit`, are C++ namespaces with explicit values, equal to the `VenusOS` values that the wrappers pass them to. `pluginaccesslevel.cpp` and `pluginunit.cpp` check this at build time. If a `VenusOS` value changes, keep the plugin value, and map it in the wrapper instead.
- `PluginWords` copies `CommonWords`, and `PluginIcons` points at the images in `qrc:/images`. Both are promises: never rename or remove one of their properties. If a `CommonWords` word or an image is renamed, point the existing property at the new one; for a word, also add the old and new names to `renamedWords` in `tst_pluginwordsandicons`. That test checks that each word has the text of the `CommonWords` word with the same (or new) name, and that each icon loads. `PluginIconImage` is the only way that plugins get the GUI's colors, and it gives only the colors named by its `tint` values.
- `PageStack.pushPluginPage()` (reached through `Global.pageManager.pushPluginPage()`) opens a plugin page. It creates a `PluginHostPage`, which is a `Page`, and then the plugin page with the host page as its parent, so the two are destroyed together. `PageStack.pushPage()` is for gui-v2's own pages, and refuses a page whose root is not a `Page`.
