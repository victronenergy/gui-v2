# GUI plugins

A GUI plugin adds pages to gui-v2, without changing gui-v2. A plugin can add a:

- **plugin settings page**, opened from Settings -> Integrations -> UI Plugins
- **device sub-page**, opened from the page of a device in the Devices list

A navigation page, a quick access pane, and a card in a quick access pane (integration types 3, 4 and 5) are not yet part of the plugin API. Plugin pages are written with the types of the `Victron.GuiPlugins` module, which gui-v2 keeps stable for plugins.

This document is for OEM and third-party developers, and for AI agents that write or check a plugin. It is complete on its own: you do not need to read gui-v2's internals. Custom branding plugins, which change the GUI's colors, fonts and logos, are a separate kind of plugin and are not covered here.

Four example plugins show the rules in practice:

- `examples/SimpleExample`: a plugin settings page with one switch.
- `examples/SimpleTrExample`: the same, with the switch text translated.
- `examples/DeviceListExample`: device sub-pages.
- `examples/FullApiExample`: a plugin settings page and a device sub-page that, between them, show every type in the [type reference](#type-reference).

`Victron.GuiPlugins` is not finished yet. It has the types in the [type reference](#type-reference); more list item types will be added.

## Quick start

1. Make a directory named after your plugin, for example `PluginName`. The compiler names the plugin after the directory. The name must start with a letter, then contain only letters, digits and underscores, and be at most 64 characters. A hyphen is not allowed. The compiler rejects any other name, and so does the GUI when it loads the plugin.
2. Write the page, for example `PluginName/PluginNameSettings.qml`, following the [rules for plugin pages](#rules-for-plugin-pages). Start from one of the examples.
3. Compile it, from that directory:

   ```
   python3 <gui-v2>/tools/gui-v2-plugin-compiler.py --settings PluginNameSettings.qml
   ```

   For a device sub-page, give the product id, the page file and the list item text instead: `--devicelist 0x106 PluginNameDevice.qml "Cell Voltages"`.

   Alternatively, compile it on a GX device if a Large image is installed, using `/opt/victronenergy/gui-v2/gui-v2-plugin-compiler.py`.
4. The compiler packs every `.qml` file in the directory, so subpages need no option of their own. It writes `PluginName.json`.
5. To try it on a GX device, add `--install <gx-host> --ssh-key <private-key>` to the compile command. This is for testing only. The compiler connects as root with that key, copies `PluginName.json` to `/data/apps/available/PluginName/gui-v2/`, and symlinks that app directory to `/data/apps/enabled/PluginName`. A repeat install replaces that symlink. It will not replace a real directory. You can do the same copy and symlink by hand. On a desktop build of gui-v2, copy `PluginName.json` into the `plugins` directory next to the `venus-gui-v2` executable.

## Rules for plugin pages

The compiler does not check these rules. A page that breaks them may work today, and then break with any GUI update.

1. **Imports.** Import `Victron.GuiPlugins`, without a version, and Qt modules such as `QtQuick` and `QtQuick.Layouts`. Never import `Victron.VenusOS`, or any other Victron module: their types are gui-v2's own, and change without notice.
2. **The base type.** The base type of a plugin settings page, and of every subpage, is `PluginPage`. The base type of a device sub-page is `PluginDevicePage`. It may also be a type that your plugin defines in its own file, if that file's base type is one of these. The GUI refuses a page whose base type is a `Page` from the `Victron.VenusOS` module, or a type derived from it. It does not open it, and logs `Aborted attempt to push a plugin page whose base type is a Page`. It also refuses a page whose base type is not an item, such as `QtObject`, and logs `Aborted attempt to push a plugin page whose base type is not an item`. It also refuses a page whose base type is an item but not a `PluginPage`, such as a plain `Item`, and logs `Aborted attempt to push a plugin page whose base type is not a PluginPage`. Plugins written for older versions of gui-v2, with a `Page` base type, must be ported.
3. **List items.** Declare the list items as direct children of a `PluginGradientListView`, in the order they are shown. Only the `Plugin*` list item types can be list items. The list items are fixed when the page is created: to hide a list item, set its `preferredVisible` to `false`, and the list item then takes no space, and key navigation skips it. If that list item has the key focus, focus moves to a visible list item. Never set `visible` on a list item.
4. **Subpages.** Open a subpage with a `PluginListNavigation` list item, and give its file as `pageUrl: Qt.resolvedUrl("SubPage.qml")`, so that it is found next to your page. A subpage must be a file of its own: a page written inline, as a `Component`, cannot be opened.
5. **Backend data values.** Read and write values with a `PluginDataItem`, which every list item with a value has as `dataItem`. See [Backend data values](#backend-data-values).
6. **Access levels.** Use `PluginAccessLevel.User`, `.Installer`, `.SuperUser` and `.Service` for `showAccessLevel` and `writeAccessLevel`.
7. **Key navigation.** The GUI can be used with keys or buttons, as well as touch. The list item types handle this. In a `PluginListSetting`, handle key presses on the list item, for example with `Keys.onSpacePressed`. Those handlers run only while key navigation is active. Call `checkWriteAccessLevel()` before changing a setting.
8. **Text.** For common words, such as "Status", "Voltage" or "On", use `PluginWords`: they are already translated, and change with the user's language. Translate other text with `qsTrId()`, with a `//% "Source text"` comment above it, and ship the translations in the plugin's own `.ts` files, as `examples/SimpleTrExample` does. See [Words and icons](#words-and-icons).
9. **Colors and fonts.** Plugins can read the main colors, the font families and the main text sizes from `PluginPalette`. The families and the colors change with custom branding. The colors also change with light and dark mode, and the text sizes with the screen size. Prefer the list item types for text: set the list item's `text`, and its `caption` where it has one, rather than adding your own label. `PluginListSetting` has no `caption`. When you draw your own component, use a `PluginPalette` color, not a fixed color. Draw icons with `PluginIconImage`, which colors them by purpose. Other images that your plugin ships must be visible on both light and dark backgrounds, as in `examples/DeviceListExample`.

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

**`PluginIconImage`** draws an icon in one of the GUI's colors. Its `source` is one of the `PluginIcons`, or a single-color image that your plugin ships. Set `tint` to choose the color by its purpose: `PluginIconImage.Text` (the default), `SecondaryText`, `Warning`, `Critical`, `Success`, `Brand` or `Disabled`. `Brand` is the brand color, the color of a switch that is on. When the icon is disabled (`enabled: false`), it is drawn in the `Disabled` color, regardless of its `tint`. The icon is the GUI's usual icon size, unless you set its `width` and `height`; the image keeps its shape, and is centred. Do not draw the `PluginIcons` with an `Image`: they have a single color, which may not show on the background.

```qml
PluginListSetting {
	text: PluginWords.status

	PluginIconImage {
		source: PluginIcons.warning
		tint: PluginIconImage.Warning
	}
}
```

## Colors

**`PluginPalette`** has the main colors of the GUI, its font families, and its main text sizes. The colors are the ten colors that custom branding can change, and the color of disabled text. They also change with light and dark mode. Use them when you draw your own component, for example `color: PluginPalette.color_font_primary`, `font.family: PluginPalette.font_family` and `font.pixelSize: PluginPalette.font_size_medium`. The color and font family names match a branding file, except `color_font_disabled`. A name stays the same, even if gui-v2 renames it.

- Backgrounds: `color_background_primary`, `color_background_secondary`, `color_background_page`.
- Text: `color_font_primary`, `color_font_secondary`, `color_font_disabled`.
- Roles: `color_brand`, `color_info`, `color_success`, `color_warning`, `color_critical`.
- Fonts: `font_family`, `quantity_font_family`.
- Text sizes: `font_size_small`, `font_size_medium`, `font_size_large`.

`color_background_page` is the page background. Theme calls that color `color_page_background`.

`color_font_disabled` is the color of disabled text. It is not in a branding file: Theme works it out from the text and background colors, so it follows custom branding too.

`font_family` is the font family for text. It is empty when the current language uses its own font, or when a branding family does not cover the current language. `quantity_font_family` is the font for numbers with their units. A branding file uses that family for every language.

The text sizes are pixel sizes. `font_size_small` is the size of a list item's caption, and of a card's title. `font_size_medium` is the size of a list item's text, and of its value. `font_size_large` is the size of a card's status. They change with the screen size, as the GUI's own text does. For example, text is smaller in portrait layout.

These are not every color in the GUI. A computed color, such as a button color or the focus highlight, is not here. Use a color from this list, or let a list item or `PluginIconImage` draw it.

For a fainter version of a color, such as the background of a bar, build it from the colors in this list, so that it still follows light and dark mode and custom branding. `Qt.alpha(color, 0.3)` gives the color at 30% opacity. `Qt.tint(background, color)` lays a see-through color over a background color, and gives a solid color, which looks the same regardless of what is behind it. `examples/FullApiExample` draws its battery bar this way:

```qml
Rectangle {
	width: parent.width
	height: 12
	radius: 6
	// A faint brand color: the brand color at 30%, laid over the background.
	color: Qt.tint(PluginPalette.color_background_primary, Qt.alpha(PluginPalette.color_brand, 0.3))

	Rectangle {
		width: parent.width * 0.6
		height: parent.height
		radius: parent.radius
		color: PluginPalette.color_brand
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
- **`PluginPalette`**: the main GUI colors, the font families, and the main text sizes. See [Colors](#colors).
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
- `PluginListSetting`: 1.0
- `PluginListSpinBox`: 1.0
- `PluginListSwitch`: 1.0
- `PluginListTemperature`: 1.0
- `PluginListText`: 1.0
- `PluginListTextField`: 1.0
- `PluginPage`: 1.0
- `PluginPalette`: 1.0
- `PluginPrimaryListLabel`: 1.0
- `PluginSettingsListHeader`: 1.0
- `PluginUnit`: 1.0
- `PluginWords`: 1.0

<!-- END versions -->

## Versioning

`Victron.GuiPlugins` has its own version, `major.minor`, separate from gui-v2's version.

- **Minor versions add types and members.** The [versions](#versions) list in the type reference says which version added each one.
- **The required version.** The compiler writes `requiredGuiPluginsVersion` into the plugin's JSON file, and prints it: the lowest `Victron.GuiPlugins` version that has every type and member that your files use. A plugin that uses only types and members from 1.0 needs 1.0, even if the compiler was built for a newer version, so it still runs on older GX devices. If none of your files imports `Victron.GuiPlugins`, the compiler writes no `requiredGuiPluginsVersion`. Write `import Victron.GuiPlugins` with no version. The compiler rejects a version on that import: it is not the required version, and an older GUI could accept the plugin and then fail to load the file.
- **How the compiler finds what you use.** It goes by names. A member counts as used if its name appears in your files, outside comments and plain strings, and it belongs to a type that you use, to that type's base type, or to the type of another member that you use. `PluginWords.reset` and `PluginWords["reset"]` both use `reset`; `PluginWords[word]` does not, because the key is not a constant. A handler such as `onToggled` or `onCheckedChanged` uses `toggled` or `checked`. So does a direct connection, such as `checkedChanged.connect(...)`. So if one of your own properties or functions has the same name as a newer member, the version can be newer than needed. The compiler prints the members that need the version it writes; if one of them is really your own property or function, rename yours.
- **What the GUI does with it.** If the GUI's `Victron.GuiPlugins` has a different major version, or an older minor version, than `requiredGuiPluginsVersion`, the GUI ignores the plugin's pages and logs why, for example `Ignoring integration at index 0 in plugin OemName - type: 1 - it needs Victron.GuiPlugins 1.2, but this GUI only has 1.1`. A plugin without `requiredGuiPluginsVersion` is not checked.
- **Older GUIs.** Versions of gui-v2 without `Victron.GuiPlugins` do not check `requiredGuiPluginsVersion`, and cannot open the plugin's pages. So also pass `--min-required-version` to the compiler, with the first gui-v2 version that has `Victron.GuiPlugins`, as the examples do.
- **Deprecation.** A type or member that is to be removed is marked deprecated in the type reference. The compiler warns when a plugin uses it. The GUI does not. It is removed only in the next major version. Nothing is deprecated yet. The warning uses the same name matching as the required version, so one of your own properties can cause it if it has the same name.
- **Major versions** remove or change types and members. When a new major version is announced, plugin authors must port their plugins to the new API.

## Changing Victron.GuiPlugins (gui-v2 contributors)

- The module is in `guiplugins/`, and its files are listed in `cmake/ModuleGuiPlugins_Sources.cmake`. Its types wrap `Victron.VenusOS` types, and may use them in their own code. `Victron.VenusOS` must never use `Victron.GuiPlugins`; the `tst_moduledependencies` test fails if it does, and CMake stops at configure time if the VenusOS library links it. See [Module dependencies](architecture.md#module-dependencies).
- Every promised member is declared on the wrapper's root object, so that the inner `Victron.VenusOS` type can change without changing the plugin API. A list item type's base type is `PluginListItem`, and the inner item (`id: inner`) takes `preferredVisible` and `showAccessLevel` from it.
- `tools/guiplugins-api.json` is the checked-in record of the API: every type in the module, and each type's properties, signals, methods and enums, with the version that added each one. `tools/guipluginsapi.py` writes it from the files in `cmake/ModuleGuiPlugins_Sources.cmake`, and writes the [versions](#versions) list from it. The `tst_guipluginsapi` test fails if either is out of date. Every file in the module is part of the API. A QML file's API is its base type and the declarations directly inside its root object; a header's API is the class or namespace that it registers with `QML_ELEMENT`. A declaration whose name starts and ends with `__` is not recorded. It is not part of the API. `PluginPage` has `__is_plugin_page__` so the page stack can recognise a plugin page without importing this module.
- The script refuses:
  - a change that could break a plugin, unless `VICTRON_GUIPLUGINS_VERSION_MAJOR` goes up: removing or renaming a type or member, changing a type's base or a property's type, making a property read-only or required, changing the default property, changing a signal's or method's parameters or return type, or changing an enum value's number. Only for a type or member that no released GUI has, `--allow-breaking-changes` lets you make such a change;
  - a new type or member, unless the version in `cmake/ModuleGuiPlugins.cmake` is already higher than the version in `tools/guiplugins-api.json`. It writes nothing, and prints what to do;
  - a type that plugins cannot use, anywhere in the API. Plugins import only `Victron.GuiPlugins`, `QtQml` and `QtQuick`, so the API may use only QML's basic types, `QtObject`, `Item`, `FocusScope`, `Component`, and the module's own types. This keeps `Victron.VenusOS` types out of it;
  - a declaration that it cannot read, such as an inline component, a slot, a `Q_PROPERTY` written over several lines, or more than one statement on a declaration's line. A function expression in a property initializer is part of that property. Members of nested objects do not contribute to the API of the type, so they are not recorded;
  - a regular expression literal. The script does not read one. Do not use one in a file in this module.
- Version 1.0 stays open until the first GUI with `Victron.GuiPlugins` is released. Until then, to add to the API, add the type or member and run `python3 tools/guipluginsapi.py`, without increasing `VICTRON_GUIPLUGINS_VERSION_MINOR`. New types and members get 1.0. When that GUI is released, set `UNRELEASED_VERSION` in `tools/guipluginsapi.py` to `None`, so that the next two rules apply.
- After the first release, to add to the API: first increase `VICTRON_GUIPLUGINS_VERSION_MINOR` in `cmake/ModuleGuiPlugins.cmake`. Then add the type or member, and run `python3 tools/guipluginsapi.py`. New types and members get that version, and the script adds them to the [versions](#versions) list. If you did not increase the version, the script stops and does not change `tools/guiplugins-api.json`. Increase the minor version, then run it again.
- After the first release, each update that adds to the API needs its own minor version, even if the previous one has not been released. Two additions in one release cycle are 1.1 and 1.2, not both 1.1.
- Removing or changing a type or member needs a new major version. See [Versioning](#versioning). The script cannot see a change to a property's initial value, or to what a function does. Those can still break a plugin, and they need a new major version too.
- To deprecate a type or member, add `"deprecated": true` to it in `tools/guiplugins-api.json`, say so in the type reference, and run `python3 tools/guipluginsapi.py`. The script keeps the flag. The compiler then warns a plugin that uses it; the GUI does not. Removing it still needs a new major version.
- The compiler reads `tools/guiplugins-api.json`, which is installed next to it, to work out each plugin's `requiredGuiPluginsVersion` and to warn about deprecated types and members (see [Versioning](#versioning)). The plugin loader, in `src/guiplugins.cpp`, gets the module version from `cmake/ModuleGuiPlugins.cmake` as two compile definitions, and drops a plugin's pages if it needs a version that the GUI does not have. The `tst_plugincompiler` and `tst_guipluginloader` tests cover both.
- The enums for plugins, `PluginAccessLevel` and `PluginUnit`, are C++ namespaces with explicit values, equal to the `VenusOS` values that the wrappers pass them to. `pluginaccesslevel.cpp` and `pluginunit.cpp` check this at build time. If a `VenusOS` value changes, keep the plugin value, and map it in the wrapper instead.
- `PluginWords` copies `CommonWords`, and `PluginIcons` points at the images in `qrc:/images`. Both are promises: never rename or remove one of their properties. If a `CommonWords` word or an image is renamed, point the existing property at the new one; for a word, also add the old and new names to `renamedWords` in `tst_pluginwordsandicons`. That test checks that each word has the text of the `CommonWords` word with the same (or new) name, and that each icon loads. `PluginPalette` exposes the ten branding colors, and `font_family` and `quantity_font_family`, with the branding names, and `color_font_disabled`, with its `Theme` name. It is the same kind of promise: if `Theme` renames one, keep the existing name and point the existing property at the new one. `color_background_page` already does this: Theme calls it `color_page_background`. Add such a pair to `renamedColors` in `tst_pluginpalette`. That test checks that each color matches the `Theme` color, in both color schemes, and that each font family matches `Theme`. `PluginPalette` also exposes `font_size_small`, `font_size_medium` and `font_size_large`, which are `Theme` font sizes chosen by purpose: the list item caption size, the list item text size, and the control card status size. If `Theme` renames or changes those sizes, point each one at the nearest size with the same purpose, and update `fontSizes` in `tst_pluginpalette`, which checks them in each screen size. `PluginIconImage` tints an icon by purpose, with `PluginPalette` colors. Its `Success` tint is `color_success`, and its `Brand` tint is `color_brand`, the color of a switch that is on. `tst_pluginwordsandicons` checks each tint. The Plugin* types take their colors and text sizes from `PluginPalette`, not from `Theme`, so that a `Theme` rename needs a change only in `PluginPalette`. Their spacing and other sizes still come from `Theme`, and are not part of the API.
- `PageStack.pushPluginPage()` (reached through `Global.pageManager.pushPluginPage()`) opens a plugin page. It creates a `PluginHostPage` (defined in `PageStack.qml`), which is a `Page`, and then the plugin page with the host page as its parent, so the two are destroyed together. The host shows the plugin page's title, or `defaultTitle` while that title is empty. A list item that opens the page passes its text as `defaultTitle`. Callers must not assign `pluginPage.title`: that replaces the page's title binding. A page whose base type is a `Page` from `Victron.VenusOS`, is not an item, or is not a `PluginPage`, is destroyed with the host and is not opened. `PageStack.pushPage()` is for gui-v2's own pages, and refuses a page whose base type is not a `Page`.
