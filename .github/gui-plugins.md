# GUI plugins

A GUI plugin adds pages to gui-v2, without changing gui-v2. A plugin can add a:

- **plugin settings page**, opened from Settings -> Integrations -> UI Plugins
- **device sub-page**, opened from the page of a device in the Devices list

A navigation page, a quick access pane, and a card in a quick access pane (integration types 3, 4 and 5) are not yet part of the plugin API. Plugin pages are written with the types of the `Victron.GuiPlugins` module, which gui-v2 keeps stable for plugins.

This document is for OEM and third-party developers, and for AI agents that write or check a plugin. It is complete on its own: you do not need to read gui-v2's internals. Branding plugins, which change the GUI's colors, fonts and logos, are a separate kind of plugin and are not covered here.

Four example plugins show the rules in practice:

- `examples/SimpleExample`: a plugin settings page with one switch.
- `examples/SimpleTrExample`: the same, with the switch text translated.
- `examples/DeviceListExample`: device sub-pages.
- `examples/FullApiExample`: a plugin settings page and a device sub-page that, between them, show every type in the [type reference](#type-reference).

`Victron.GuiPlugins` is not finished yet. It has the types in the [type reference](#type-reference); more list item types will be added.

## Quick start

1. Make a directory named after your plugin, for example `OemName`. The compiler names the plugin after the directory.
2. Write the page, for example `OemName/OemNameSettings.qml`, following the [rules for plugin pages](#rules-for-plugin-pages). Start from one of the examples.
3. Compile it, from that directory:

   ```
   python3 <gui-v2>/tools/gui-v2-plugin-compiler.py --settings OemNameSettings.qml
   ```

   For a device sub-page, give the product id, the page file and the list item text instead: `--devicelist 0x106 OemNameDevice.qml "Cell Voltages"`.

   Alternatively, compile it on a GX device if a Large image is installed, using `/opt/victronenergy/gui-v2/gui-v2-plugin-compiler.py`.
4. The compiler packs every `.qml` file in the directory, so subpages need no option of their own. It writes `OemName.json`.
5. Install it on a GX device by hand: copy `OemName.json` to `/data/apps/available/OemName/gui-v2/`, then `ln -s /data/apps/available/OemName /data/apps/enabled/OemName`. On a desktop build of gui-v2, copy `OemName.json` into the `plugins` directory next to the `venus-gui-v2` executable.

## Rules for plugin pages

The compiler does not check these rules. A page that breaks them may work today, and then break with any GUI update.

1. **Imports.** Import `Victron.GuiPlugins`, and Qt modules such as `QtQuick` and `QtQuick.Layouts`. Never import `Victron.VenusOS`, or any other Victron module: their types are gui-v2's own, and change without notice.
2. **The base type.** The base type of a plugin settings page, and of every subpage, is `PluginPage`. The base type of a device sub-page is `PluginDevicePage`. It may also be a type that your plugin defines in its own file, if that file's base type is one of these. The GUI refuses a page whose base type is a `Page` from the `Victron.VenusOS` module, or a type derived from it. It does not open it, and logs `Aborted attempt to push a plugin page whose base type is a Page`. It also refuses a page whose base type is not an item, such as `QtObject`, and logs `Aborted attempt to push a plugin page whose base type is not an item`. It also refuses a page whose base type is an item but not a `PluginPage`, such as a plain `Item`, and logs `Aborted attempt to push a plugin page whose base type is not a PluginPage`. Plugins written for older versions of gui-v2, with a `Page` base type, must be ported.
3. **List items.** Declare the list items as direct children of a `PluginGradientListView`, in the order they are shown. Only the `Plugin*` list item types can be list items. The list items are fixed when the page is created: to hide a list item, set its `preferredVisible` to `false`, and the list item then takes no space, and key navigation skips it. If that list item has the key focus, focus moves to a visible list item. Never set `visible` on a list item.
4. **Subpages.** Open a subpage with a `PluginListNavigation` list item, and give its file as `pageUrl: Qt.resolvedUrl("SubPage.qml")`, so that it is found next to your page. A subpage must be a file of its own: a page written inline, as a `Component`, cannot be opened.
5. **Backend data values.** Read and write values with a `PluginDataItem`, which every list item with a value has as `dataItem`. See [Backend data values](#backend-data-values).
6. **Access levels.** Use `PluginAccessLevel.User`, `.Installer`, `.SuperUser` and `.Service` for `showAccessLevel` and `writeAccessLevel`.
7. **Key navigation.** The GUI can be used with keys or buttons, as well as touch. The list item types handle this. In a `PluginListSetting`, handle key presses on the list item, for example with `Keys.onSpacePressed`. Those handlers run only while key navigation is active. Call `checkWriteAccessLevel()` before changing a setting.
8. **Text.** For common words, such as "Status", "Voltage" or "On", use `PluginWords`: they are already translated, and change with the user's language. Translate other text with `qsTrId()`, with a `//% "Source text"` comment above it, and ship the translations in the plugin's own `.ts` files, as `examples/SimpleTrExample` does. See [Words and icons](#words-and-icons).
9. **Colors and fonts.** Plugins cannot read the GUI's colors and fonts, which change with light and dark mode, the screen size, and OEM branding. The list item types draw their text with them, so let the list items draw text: set the list item's `text`, and its `caption` where it has one, rather than adding your own label. `PluginListSetting` has no `caption`. Draw icons with `PluginIconImage`, which colors them by purpose. Other images that your plugin ships must be visible on both light and dark backgrounds, as in `examples/DeviceListExample`.

For example, a plugin settings page with a switch and a subpage:

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

## Backend data values

A `PluginDataItem` is one value on the system, such as a setting or a measurement. It builds the full `uid` for the connection in use: D-Bus on the device, MQTT in the remote console, or the mock system on a desktop. Point it at the value in one of these ways:

- **One service.** Set `serviceType` and `path`. Leave `deviceInstance` unset. Use this for `settings`, `system`, `platform`, or your plugin's own service. For example, `serviceType: "settings"` and `path: "/Settings/Gui/DemoMode"`.
- **One device.** Set `serviceType`, `deviceInstance` and `path`. `serviceType` is the short name, such as `"battery"`, not `com.victronenergy.battery`. `0` is a real instance. For example, `serviceType: "battery"`, `deviceInstance: 1` and `path: "/Dc/0/Voltage"`. `uid` is empty, and `valid` is false, until that device is present. `uid` changes if the device disappears or its service uid changes. If two devices match, the first one is used.
- **A full uid.** Set `uid` yourself. On a `PluginDevicePage`, `serviceUid` is the device that opened the page. Use `uid: root.serviceUid + "/Dc/0/Voltage"` for that device. You do not need `deviceInstance` there.

`path` starts with `/`. `deviceInstance` is `-1` when you leave it unset. Set it back to `-1` to stop naming a device. Do not set `uid` as well as `serviceType` and `path`. The order of those assignments is not defined, so the result can differ between machines.

Then read `value` and `valid`, and `min` and `max` (each is NaN when the system does not give it), and write the value with `setValue()`.

`setValue()` writes the value. It does not check `writeAccessLevel`. The list item types check that when the user clicks them. If your own code writes a value, and that write should follow the user's access level, call `checkWriteAccessLevel()` first.

## Words and icons

**`PluginWords`** has common words, already translated into the user's language, so your plugin does not need to translate them. They change when the user changes the language. Use them like any text, for example `text: PluginWords.status`. A word keeps its name, even if it is renamed in gui-v2. The words, with their English text where the name does not make it clear, are:

- Answers and actions: `yes`, `no`, `reset`, `remove`.
- Setting values: `on`, `off`, `auto`, `enabled`, `disabled`.
- Statuses: `error`, `unknown`.
- Labels: `status`, `state`, `mode`, `type`, `settings`, `setup`, `alarms`, `history`, `total`.
- Quantities: `temperature`, `voltage`, `current_amps` ("Current"), `power_watts` ("Power").
- Devices: `battery`, `manufacturer`, `model_name`, `serial_number`, `firmware_version`, `custom_name`.

For any other text, use your own translations (rule 8).

**`PluginIcons`** has the urls of common icons: `alarm`, `warning`, `info`, `checkmark`, `close`, `plus`, `minus`, `trash`, `refresh`, `open_link`, `battery`, `temperature`, `humidity`, `devices`. An icon keeps its name, even if the image behind it changes.

**`PluginIconImage`** draws an icon in one of the GUI's colors. Its `source` is one of the `PluginIcons`, or a single-color image that your plugin ships. Set `tint` to choose the color by its purpose: `PluginIconImage.Text` (the default), `SecondaryText`, `Warning`, `Critical`, `Success` or `Disabled`. When the icon is disabled (`enabled: false`), it is drawn in the `Disabled` color, whatever its `tint`. The icon is the GUI's usual icon size, unless you set its `width` and `height`; the image keeps its shape, and is centred. Do not draw the `PluginIcons` with an `Image`: they have a single color, which may not show on the background.

```qml
PluginListSetting {
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

- **`PluginPage`**: the base type of a plugin page. `title` is shown in the status bar. If it is empty, the list item that opened the page supplies the title, until the page sets one. The GUI provides the back button, and sizes the page.
- **`PluginDevicePage`**: a `PluginPage` for a device sub-page. The GUI sets `serviceUid` (the start of the device's uids), `productId` and `deviceName` when it opens the page.
- **`PluginGradientListView`**: a scrolling list of list items, which fills its parent.

### List items

Every list item derives from `PluginListItem`, which you do not use directly. So every list item has:

- `preferredVisible`: set it to `false` to hide the list item. If the list item has the key focus, focus moves to a visible list item.
- `showAccessLevel`: the lowest access level that shows the list item. The default is `PluginAccessLevel.User`.
- `effectiveVisible` (read only): whether the list item is shown.

The list item types:

- **`PluginListSwitch`**: a label and a toggle switch. Either set `dataItem`, and the switch shows whether the value is `valueTrue` (default 1), and a click writes `valueFalse` (default 0) or `valueTrue`; or set `checkable: true`, and use `checked` and `onClicked`. Set `updateDataOnClick: false` to handle the click yourself, for example to ask before writing. Also: `text`, `caption`, `secondaryText`, `writeAccessLevel`, `interactive`, `click()`, `checkWriteAccessLevel()`.
- **`PluginListTextField`**: a label and an editable text field. The field shows `secondaryText`, which is the value of `dataItem` by default; when the user finishes editing, the new text is written to `dataItem`. Also: `text`, `caption`, `placeholderText`, `maximumLength`, `writeAccessLevel`, `checkWriteAccessLevel()`.
- **`PluginListNavigation`**: a list item with an arrow, which opens `pageUrl` when clicked, with `pageProperties` set on the new page. The host shows the page's `title`, or this list item's `text` while that title is empty. `pageProperties.title`, if set, replaces the page's title binding. Or leave `pageUrl` empty and handle `onClicked`. Also: `caption`, `secondaryText`, `interactive`, `click()`.
- **`PluginListText`**: a label, and read-only text on the right. The text is `secondaryText`, which is the value of `dataItem` by default. Also: `text`, `caption`.
- **`PluginListQuantity`**: a label, and a value with its unit on the right, such as "12.35 V". The value is `value`, which is the value of `dataItem` by default; if it is not a number, the list item shows "--". Set `unit` to a `PluginUnit`, and `decimals` to the number of decimal places (by default, the default number of decimals for the specified unit and value will be used). Also: `text`, `caption`. For a temperature, use `PluginListTemperature`.
- **`PluginListTemperature`**: a label, and a temperature on the right, in the unit the user chose (Celsius or Fahrenheit). The temperature is the value of `dataItem`, which must be in degrees Celsius. Also: `text`, `caption`, `decimals`.
- **`PluginListSpinBox`**: a label, and a clickable number on the right. A click opens a dialog in which the user picks a new number, from `from` to `to` (by default, the `min` and `max` of `dataItem`, if the system gives them), in steps of `stepSize` (default 1). The number shown is the `value` property. By default, that is the value of `dataItem`, and the picked number is written to `dataItem`. Without a `dataItem`, the dialog's accepted handler writes the picked number to `value`, which replaces any binding on it. Also: `text`, `caption`, `suffix` (shown after the number, such as `" A"`), `decimals` (default 0), `writeAccessLevel`, `interactive`, `click()`, `checkWriteAccessLevel()`.
- **`PluginListRadioButtonGroup`**: a label, and the current option on the right. A click opens a page that lists the options, and the user picks one. `optionModel` is an array of options, each an object with `display` (the option's text) and `value`, for example `[ { display: "Off", value: 0 }, { display: "On", value: 1 } ]`. `currentIndex` is the index of the current option, or -1 for none, when the list item shows `defaultSecondaryText` ("Unknown" by default). By default, `currentIndex` is the option whose `value` is equal to `dataItem.value`, and picking an option writes its `value` to `dataItem`. Without a `dataItem`, set `currentIndex` yourself in `onOptionClicked(index)`. Set `updateDataOnClick: false` to handle the pick yourself, for example to ask before writing. Also: `text`, `caption`, `writeAccessLevel`, `interactive`, `click()`, `checkWriteAccessLevel()`.
- **`PluginListButton`**: a label, and a button on the right that shows `secondaryText`. A click emits `clicked()`, if the user has `writeAccessLevel`. Also: `text`, `caption`, `interactive`, `click()`, `checkWriteAccessLevel()`.
- **`PluginSettingsListHeader`**: a heading, `text`, above a group of list items. Key navigation skips it.
- **`PluginPrimaryListLabel`**: explanatory text, `text`, across the width of the list, without a list item background. Key navigation skips it.
- **`PluginListSetting`**: a list item with your own content, for list items that the other types do not cover. Declare the content inside it; the list item gives it the standard background, the key navigation highlight, and access handling. If you set `text`, the list item shows it and puts your content on the right, at the content's own size; if the content does not fit beside the text, it goes below it. If `text` is empty, your content fills the width of the list item. Set `interactive: true` if the content can be clicked, and enable it with `clickable`. Also: `writeAccessLevel`, `checkWriteAccessLevel()`.

### Other types

- **`PluginDataItem`**: a value on the system. `serviceType` and `path` name it; set `deviceInstance` to name one device. See [Backend data values](#backend-data-values).
- **`PluginAccessLevel`**: `User`, `Installer`, `SuperUser`, `Service`.
- **`PluginUnit`**: the units for `PluginListQuantity`: `None`, `Amp`, `AmpHour`, `Energy_KiloWattHour`, `Percentage`, `RevolutionsPerMinute`, `VoltAmpere`, `Volt_AC`, `Volt_DC`, `Watt`.
- **`PluginWords`**, **`PluginIcons`** and **`PluginIconImage`**: see [Words and icons](#words-and-icons).

## Changing Victron.GuiPlugins (gui-v2 contributors)

- The module is in `guiplugins/`, and its files are listed in `cmake/ModuleGuiPlugins_Sources.cmake`. Its types wrap `Victron.VenusOS` types, and may use them in their own code. `Victron.VenusOS` must never use `Victron.GuiPlugins`; the `tst_moduledependencies` test fails if it does, and CMake stops at configure time if the VenusOS library links it. See [Module dependencies](architecture.md#module-dependencies).
- Every promised member is declared on the wrapper's root object, so that the inner `Victron.VenusOS` type can change without changing the plugin API. A list item type's base type is `PluginListItem`, and the inner item (`id: inner`) takes `preferredVisible` and `showAccessLevel` from it.
- The enums for plugins, `PluginAccessLevel` and `PluginUnit`, are C++ namespaces with explicit values, equal to the `VenusOS` values that the wrappers pass them to. `pluginaccesslevel.cpp` and `pluginunit.cpp` check this at build time. If a `VenusOS` value changes, keep the plugin value, and map it in the wrapper instead.
- `PluginWords` copies `CommonWords`, and `PluginIcons` points at the images in `qrc:/images`. Both are promises: never rename or remove one of their properties. If a `CommonWords` word or an image is renamed, point the existing property at the new one; for a word, also add the old and new names to `renamedWords` in `tst_pluginwordsandicons`. That test checks that each word has the text of the `CommonWords` word with the same (or new) name, and that each icon loads. `PluginIconImage` is the only way that plugins get the GUI's colors, and it gives only the colors named by its `tint` values.
- `PageStack.pushPluginPage()` (reached through `Global.pageManager.pushPluginPage()`) opens a plugin page. It creates a `PluginHostPage` (defined in `PageStack.qml`), which is a `Page`, and then the plugin page with the host page as its parent, so the two are destroyed together. The host shows the plugin page's title, or `defaultTitle` while that title is empty. A list item that opens the page passes its text as `defaultTitle`. Callers must not assign `pluginPage.title`: that replaces the page's title binding. A page whose base type is a `Page` from `Victron.VenusOS`, is not an item, or is not a `PluginPage`, is destroyed with the host and is not opened. `PageStack.pushPage()` is for gui-v2's own pages, and refuses a page whose base type is not a `Page`.
