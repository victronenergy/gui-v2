# GUI plugins

A GUI plugin adds pages to gui-v2, without changing gui-v2. A plugin can add a:

- **plugin settings page**, opened from Settings -> Integrations -> UI Plugins
- **device sub-page**, opened from the page of a device in the Devices list
- **card in the Controls or Switches pane**, shown after gui-v2's own cards

A navigation page and a quick access pane (integration types 3 and 4) are not yet part of the plugin API. Plugin pages and cards are written with the types of the `Victron.GuiPlugins` module, which gui-v2 keeps stable for plugins.

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

   For a card, give the card file and the pane, `1` for Controls or `2` for Switches: `--card PluginNameCard.qml 1`.

   Alternatively, compile it on a GX device if a Large image is installed, using `/opt/victronenergy/gui-v2/gui-v2-plugin-compiler.py`.
4. The compiler packs every `.qml` file in the directory, so subpages need no option of their own. It writes `PluginName.json`.
5. To try it on a GX device, add `--install <gx-host> --ssh-key <private-key>` to the compile command. This is for testing only. The compiler connects as root with that key, copies `PluginName.json` to `/data/apps/available/PluginName/gui-v2/`, and symlinks that app directory to `/data/apps/enabled/PluginName`. A repeat install replaces that symlink. It will not replace a real directory. You can do the same copy and symlink by hand. On a desktop build of gui-v2, copy `PluginName.json` into the `plugins` directory next to the `venus-gui-v2` executable.

## Rules for plugin pages

The compiler does not check these rules. A page that breaks them may work today, and then break with any GUI update.

1. **Imports.** Import `Victron.GuiPlugins`, without a version, and Qt modules such as `QtQuick` and `QtQuick.Layouts`. Never import `Victron.VenusOS`, or any other Victron module: their types are gui-v2's own, and change without notice.
2. **The base type.** The base type of a plugin settings page, and of every subpage, is `PluginPage`. The base type of a device sub-page is `PluginDevicePage`. It may also be a type that your plugin defines in its own file, if that file's base type is one of these. The GUI refuses a page whose base type is a `Page` from the `Victron.VenusOS` module, or a type derived from it. It does not open it, and logs `Aborted attempt to push a plugin page whose base type is a Page`. It also refuses a page whose base type is not an item, such as `QtObject`, and logs `Aborted attempt to push a plugin page whose base type is not an item`. It also refuses a page whose base type is an item but not a `PluginPage`, such as a plain `Item`, and logs `Aborted attempt to push a plugin page whose base type is not a PluginPage`. Plugins written for older versions of gui-v2, with a `Page` base type, must be ported.
3. **List items.** Declare the list items as direct children of a `PluginItemListView`, in the order they are shown. Only the `Plugin*` list item types can be list items. The list items are fixed when the page is created: to hide a list item, set its `preferredVisible` to `false`, and the list item then takes no space, and key navigation skips it. If that list item has the key focus, focus moves to a visible list item. Never set `visible` on a list item. A list of devices is not fixed. Show it in a `PluginModelListView`, with a `PluginDeviceModel` as its `model` and a `Plugin*` list item as its `delegate`. See [Devices](#devices) and [Lists from a model](#lists-from-a-model).
4. **Subpages.** Open a subpage with a `PluginListNavigation` list item, and give its file as `pageUrl: Qt.resolvedUrl("SubPage.qml")`, so that it is found next to your page. A subpage must be a file of its own: a page written inline, as a `Component`, cannot be opened.
5. **Backend data values.** Read and write values with a `PluginDataItem`, which every list item with a value has as `dataItem`. To find the devices on the system, use a `PluginDeviceModel`, and to find the paths on a device or service, use a `PluginDataPathModel`. See [Backend data values](#backend-data-values), [Devices](#devices) and [Paths on a device or service](#paths-on-a-device-or-service).
6. **Access levels.** Use `PluginAccessLevel.User`, `.Installer`, `.SuperUser` and `.Service` for `showAccessLevel` and `writeAccessLevel`.
7. **Key navigation.** The GUI can be used with keys or buttons, as well as touch. The list item types handle this, in a `PluginItemListView`, in a `PluginModelListView`, or directly inside a `PluginCard`. A `PluginCardListView` moves the key focus between its cards. List items in a `ListView`, a `Repeater` or a layout have no key navigation. In a `PluginListSetting`, handle key presses on the list item, for example with `Keys.onSpacePressed`. Those handlers run only while key navigation is active. Call `checkWriteAccessLevel()` before changing a setting.
8. **Text.** For common words, such as "Status", "Voltage" or "On", use `PluginWords`: they are already translated, and change with the user's language. Translate other text with `qsTrId()`, with a `//% "Source text"` comment above it, and ship the translations in the plugin's own `.ts` files, as `examples/SimpleTrExample` does. See [Words and icons](#words-and-icons).
9. **Colors and fonts.** Draw your own text with `PluginLabel`, and a number with its unit with `PluginQuantityLabel`. See [Text and numbers](#text-and-numbers). Plugins can read the main colors, the font families and the main text sizes from `PluginPalette`. The families and the colors change with custom branding. The colors also change with light and dark mode, and the text sizes with the screen size. Prefer the list item types for text: set the list item's `text`, and its `caption` where it has one, rather than adding your own label. A `PluginCard` draws its icon, title and status: set those, rather than drawing them yourself. `PluginListSetting` has no `caption`. When you draw your own component, use a `PluginPalette` color, not a fixed color. Draw icons with `PluginIconImage`, which colors them by purpose. Other images that your plugin ships must be visible on both light and dark backgrounds, as in `examples/DeviceListExample`.

For example, a plugin settings page with a switch and a subpage:

```qml
import QtQuick
import Victron.GuiPlugins

PluginPage {
	title: "OemName"

	PluginItemListView {
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

`path` may start with `/` or not, so `"Settings/Gui/DemoMode"` and `"/Settings/Gui/DemoMode"` are the same. `deviceInstance` is `-1` when you leave it unset. Set it back to `-1` to stop naming a device. Do not set `uid` as well as `serviceType` and `path`. The order of those assignments is not defined, so the result can differ between machines.

Then read `value` and `valid`, and `min` and `max` (each is NaN when the system does not give it), and write the value with `setValue()`.

`setValue()` writes the value. It does not check `writeAccessLevel`. The list item types check that when the user clicks them. If your own code writes a value, and that write should follow the user's access level, call `checkWriteAccessLevel()` first.

To find which devices are on the system, and their service uids, use a `PluginDeviceModel`. See [Devices](#devices). To find which paths a device or service has, use a `PluginDataPathModel`. See [Paths on a device or service](#paths-on-a-device-or-service).

## Devices

**`PluginDeviceModel`** is the devices on the system, such as every tank or every solar charger. It is a list model. Show it in a `PluginModelListView`, or read the device at an index with `serviceUidAt()`, `serviceTypeAt()`, `deviceInstanceAt()`, `nameAt()` and `productIdAt()`.

Set `serviceTypes` to the short names, such as `["tank"]` or `["solarcharger", "multi"]`. The short name is `"tank"`, not `com.victronenergy.tank`. Leave `serviceTypes` empty to list every device. A service that is not a device, such as `settings`, `system` or `platform`, is never in the list. A device is in the list once it has a device instance and a name. The common service types are listed [below](#common-service-types).

`availableServiceTypes` is the service types of the devices on the system now, sorted. It does not depend on `serviceTypes`: it has the types that an empty `serviceTypes` would list. It changes when a device of a new type is found, or the last device of a type goes away. It can be empty while the GUI is still finding the devices.

Set `requiredPaths` to list only the devices that have a valid value at each of those paths, such as `["NrOfTrackers"]`. Each path is relative to the device's service uid. It may start with `/` or not, so `"NrOfTrackers"` and `"/NrOfTrackers"` are the same. It can have several parts, such as `"Pv/0/V"`. Leave `requiredPaths` empty to list the devices regardless of the paths that they have.

A valid value means the same as `valid` on a `PluginDataItem` for that path: the system has a value for the path. A path that the device does not have is not valid. Neither is a path that the device has, but whose value the system gives as invalid, for example a measurement that the device cannot make at the moment. The value itself is not checked: a `NrOfTrackers` of `0` is valid, and so is an empty text. The list changes when one of the values becomes valid or stops being valid, so a device can appear some time after it is found, once its values arrive.

The same `requiredPaths` are required of every type in `serviceTypes`. When different types need different paths, use one `PluginDeviceModel` for each group of types. See [Devices that need different paths](#devices-that-need-different-paths).

The list is sorted by name. When the list changes, a device that is still listed is not removed and added again, so a view keeps its delegate. `count` is the number of devices. The model has these role names, and those methods return the same values:

- `serviceUid`: the start of that device's uids. Read a value with a `PluginDataItem`, using this and a path.
- `serviceType`: the short name.
- `deviceInstance`: the instance. `0` is a real instance.
- `name`: the name the GUI shows. A custom name is used when it is set. Otherwise the product name is used. A tank with no custom name is named from its fluid type and its instance, as on the tanks page.
- `productId`: the product id, or `0` if the device has not given one.

Two devices can have the same service type and instance. They are both in the list. `serviceUid` tells them apart. A `PluginDataItem` that names a device by `serviceType` and `deviceInstance` uses the first device that matches, so use the service uid when more than one device matches.

The model lists the devices, not the values of their paths. For example, it lists each solar charger, but not the charger's solar inputs, and it does not give a tank's fluid type. To read a value, use a `PluginDataItem` whose `uid` is the device's `serviceUid` plus the path, such as `serviceUid + "/FluidType"`. To find which paths a device has, use a `PluginDataPathModel`. See [Paths on a device or service](#paths-on-a-device-or-service).

A delegate or a handler, such as `onCountChanged`, can change `serviceTypes` or `requiredPaths` while the list is being updated. The list is then updated again shortly afterwards. If every update leads to another one, for example because `onCountChanged` keeps switching `serviceTypes`, that is a loop: after three updates in a row, the model prints a warning and stops updating. It updates again at the next change from elsewhere, such as a new device.

For an index outside the list, `serviceUidAt()`, `serviceTypeAt()` and `nameAt()` return an empty string, and `deviceInstanceAt()` and `productIdAt()` return `-1`.

In a delegate, declare a required property for each role name that it uses. Also declare `index`.

```qml
PluginDeviceModel {
	id: tanks

	serviceTypes: ["tank"]
}

PluginModelListView {
	model: tanks

	delegate: PluginListText {
		required property int index
		required property string name
		required property string serviceUid

		text: name
		dataItem.uid: serviceUid + "/Level"
	}
}
```

### Common service types

These are the device service types that the GUI knows. Other types can appear, for example from a newer Venus OS or from a third-party driver. Use `availableServiceTypes` to see the types on a system.

- **Batteries and DC:** `battery`, `dcdc` (DC-DC charger), `dcload` (DC load), `dcsource` (DC source), `dcsystem` (DC system), `alternator`, `fuelcell` (fuel cell), `dcgenset` (DC generator).
- **Solar:** `solarcharger` (solar charger), `pvinverter` (PV inverter).
- **Inverters and chargers:** `vebus` (VE.Bus inverter/charger, such as a MultiPlus or Quattro), `acsystem` (RS system), `multi` (Multi RS), `inverter`, `charger` (AC charger).
- **AC:** `grid` (grid meter), `genset` (AC generator), `acload` (AC load), `heatpump` (heat pump), `evcharger` (EV charger).
- **Other:** `tank`, `temperature` (temperature sensor), `digitalinput` (digital input), `pulsemeter` (pulse meter), `switch` (switches and outputs), `gps`, `meteo` (weather sensor), `motordrive` (electric motor), `ev` (electric vehicle), `generator` (generator start/stop), `unsupported` (a device that the GUI does not support).

### Paths on a device or service

**`PluginDataPathModel`** lists the child paths of a uid. Set `uid` to a device's `serviceUid` to list the top-level paths of that device, such as `Dc`, `Mode` and `ProductName`. Set it to the uid of a path, such as `serviceUid + "/Pv"`, to list the child paths of that path, such as `0` and `1`. A `/` at the end of `uid` is ignored. An empty `uid` gives an empty list.

Or set `serviceType` and `path` instead, and `deviceInstance` for a device, as on a `PluginDataItem`. See [Backend data values](#backend-data-values). For example, `serviceType: "settings"` and `path: "/Settings/Gui"` lists the child paths of `/Settings/Gui`, and `serviceType: "solarcharger"`, `deviceInstance: 0` and `path: "/Pv"` lists the trackers of solar charger `0`, such as `0` and `1`. Set `path` to `"/"` to list the top-level paths of the service or device. As on a `PluginDataItem`, the `/` at the start of `path` is optional. `uid` is then the full uid that they name. It is empty while only one of `serviceType` and `path` is set, and, for a device, until that device is present. Do not set `uid` as well as `serviceType` and `path`. The order of those assignments is not defined, so the result can differ between machines.

It is a list model. Show it in a `PluginModelListView`, or read the child path at an index with `childNameAt()`, `childPathAt()` and `childUidAt()`. `count` is the number of child paths. The model has these role names, and those methods return the same values:

- `childName`: the name of the child path, such as `Dc` or `0`.
- `childPath`: the child path on the service, such as `/Pv/0`: the model's `path`, then `/`, then `childName`. Give it to the `path` of a `PluginDataItem` that has the same `serviceType` and `deviceInstance`. It is empty when you set `uid` yourself.
- `childUid`: the full uid of the child path: the model's `uid`, then `/`, then `childName`.

A path either has a value of its own, such as `Mode`, or has child paths, such as `Dc`. Read a value with a `PluginDataItem` that has the path's `childUid`, or the same `serviceType` and `deviceInstance` and the path's `childPath`. List the child paths of a path with another `PluginDataPathModel` that has the path's `childUid`, or its `childPath`; its `count` is more than `0` when the path has child paths. `examples/FullApiExample` uses this to show each path of a device, with its value.

For an index outside the list, `childNameAt()`, `childPathAt()` and `childUidAt()` return an empty string.

A path is listed when the system has it: when the system has given a value to it, or to one of its descendants, such as `Dc/0/Voltage` for `Dc`. The list changes shortly after the system adds or removes a path. Changes that come close together, such as when the GUI connects to the system, change the list once. While a service is gone, or while the remote console has lost its connection, the paths of that service are not listed. A path that the GUI has only asked for is not listed. For example, a `PluginDataItem` whose `uid` names a path that the device does not have does not add that path to the list. A listed path can still have an invalid value, so check `valid` on a `PluginDataItem` before you use its value. `requiredPaths` on a `PluginDeviceModel` needs a valid value, so a listed path is not always enough for it.

Names that are numbers come first, in the order of their value, so `2` comes before `10`. The other names follow, in alphabetical order, ignoring case.

This document does not list the paths of each type of device: they depend on the product and its firmware. While you write your plugin, use a `PluginDataPathModel` to see the paths available for the devices on a system, and then use the paths that you need. For example, this logs the top-level paths of each solar charger, as they arrive:

```qml
PluginDeviceModel {
	id: solarChargers

	serviceTypes: ["solarcharger"]
}

Repeater {
	model: solarChargers

	delegate: Repeater {
		id: device

		required property string name
		required property string serviceType
		required property int deviceInstance

		model: PluginDataPathModel {
			serviceType: device.serviceType
			deviceInstance: device.deviceInstance
			path: "/"
		}

		delegate: Item {
			id: child

			required property string childPath

			Component.onCompleted: console.log(device.name, child.childPath)
		}
	}
}
```

Each delegate reads its required properties through its `id`, so that it is clear which delegate each property belongs to.

### Devices that need different paths

`requiredPaths` applies to every type in `serviceTypes`. When the types need different paths, use one `PluginDeviceModel` for each group of types, each with its own `requiredPaths`. A `PluginModelListView` shows one model, so show each model in a list of its own, for example each on its own subpage.

For example, to list the devices that have solar trackers: every solar charger has at least one tracker, but an older solar charger with one tracker does not have `NrOfTrackers`. A Multi RS (`multi`) or an inverter (`inverter`) has trackers only if it has a valid `NrOfTrackers`. So `NrOfTrackers` is required only of the second group:

```qml
PluginDeviceModel {
	id: solarChargers

	serviceTypes: ["solarcharger"]
}

PluginDeviceModel {
	id: otherSolarDevices

	serviceTypes: ["multi", "inverter"]
	requiredPaths: ["NrOfTrackers"]
}
```

`requiredPaths` does not check the value, and `NrOfTrackers` can be `0`. Read it with a `PluginDataItem` for each device in `otherSolarDevices`, and hide the list item of a device whose value is `0`, with `preferredVisible: false`. To see the paths of the trackers, use a `PluginDataPathModel` with `uid: serviceUid + "/Pv"`: a device with more than one tracker lists each tracker by its number.

## Lists from a model

**`PluginModelListView`** is a scrolling list with one list item for each entry in a model, such as a `PluginDeviceModel` or a `PluginDataPathModel`. It fills its parent. Set:

- `model`: the list model.
- `delegate`: the list item for each entry in the model. It must be a `Plugin*` list item. In it, declare a required property for each role name that it uses. See [Devices](#devices).
- `header`: optional. An item above the list items, such as a `PluginPrimaryListLabel`. It scrolls with the list items. Keep it shorter than the list: key navigation scrolls to show all of it, which can hide the list items below it.

`count` is the number of list items, including hidden ones.

Key navigation moves through the list items, as in a `PluginItemListView`. To hide a list item, set its `preferredVisible` to `false`: it then takes no space, and key navigation skips it. If the list item with the key focus is hidden, or its entry is removed from the model, focus moves to a visible list item.

```qml
PluginModelListView {
	model: PluginDeviceModel {
		serviceTypes: ["tank"]
	}

	header: PluginPrimaryListLabel {
		text: "The tanks on this system."
	}

	delegate: PluginListText {
		required property string name

		text: name
	}
}
```

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

**`PluginPalette`** has the main colors of the GUI, its font families, its main text sizes, and its layout orientation. The colors are the ten colors that custom branding can change, and the color of disabled text. They also change with light and dark mode. Use them when you draw your own component, for example `color: PluginPalette.color_font_primary`, `font.family: PluginPalette.font_family` and `font.pixelSize: PluginPalette.font_size_medium`. The color and font family names match a branding file, except `color_font_disabled`. A name stays the same, even if gui-v2 renames it.

- Backgrounds: `color_background_primary`, `color_background_secondary`, `color_background_page`.
- Text: `color_font_primary`, `color_font_secondary`, `color_font_disabled`.
- Roles: `color_brand`, `color_info`, `color_success`, `color_warning`, `color_critical`.
- Fonts: `font_family`, `quantity_font_family`.
- Text sizes: `font_size_small`, `font_size_medium`, `font_size_large`.
- Layout: `orientation`.

`color_background_page` is the page background. Theme calls that color `color_page_background`.

`color_font_disabled` is the color of disabled text. It is not in a branding file: Theme works it out from the text and background colors, so it follows custom branding too.

`font_family` is the font family for text. It is empty when the current language uses its own font, or when a branding family does not cover the current language. `quantity_font_family` is the font for numbers with their units. A branding file uses that family for every language.

The text sizes are pixel sizes. `font_size_small` is the size of a list item's caption, and of a card's title. `font_size_medium` is the size of a list item's text, and of its value. `font_size_large` is the size of a card's status. They change with the screen size, as the GUI's own text does. For example, text is smaller in portrait layout.

`orientation` is `Qt.PortraitOrientation` when the GUI uses its portrait layout, which it does when its window is taller than it is wide, as in a remote console on a phone. Otherwise, it is `Qt.LandscapeOrientation`. Use it to lay out your own components, for example `orientation: PluginPalette.orientation === Qt.PortraitOrientation ? ListView.Vertical : ListView.Horizontal`. A `PluginCardListView` follows it already.

These are not every color in the GUI. A computed color, such as a button color or the focus highlight, is not here. Use a color from this list, or let a list item, `PluginButton` or `PluginIconImage` draw it.

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

## Text and numbers

**`PluginLabel`** draws text in the GUI's font. **`PluginQuantityLabel`** draws a number with its unit, such as "230 V", in the GUI's font for numbers, as the GUI draws its own numbers. Use them in your own components, such as the content of a `PluginCard` or of a `PluginListSetting`. In a list, prefer a list item type, which draws its text for you.

`fontSize` is the size of the text, in pixels. It is `PluginPalette.font_size_medium` by default. Set it to another `PluginPalette` text size, such as `PluginPalette.font_size_large`, so that the text changes with the screen size, as the GUI's own text does. See [Colors](#colors).

Each label is as big as its text, unless you set its width or height. In a label that is bigger than its text, `horizontalAlignment` (`Text.AlignLeft`, `Text.AlignHCenter` or `Text.AlignRight`) and `verticalAlignment` (`Text.AlignTop`, `Text.AlignVCenter` or `Text.AlignBottom`) place the text. The default is the top left.

`PluginLabel` draws `text` in `color`, which is the primary font color by default. For long text, set the label's width, and set `wrapMode: Text.Wrap` to show the text on several lines, or `elide: Text.ElideRight` to end it with "…".

`PluginQuantityLabel` has `value`, `unit`, `decimals` and `dataItem`, as `PluginListQuantity` has. The value is `value`, which is the value of `dataItem` by default; if it is not a number, the label shows "--". The number is drawn in `valueColor`, the primary font color by default, and the unit in `unitColor`, the secondary font color by default. It does not wrap.

```qml
PluginCard {
	id: card

	title: "Pump"

	PluginQuantityLabel {
		x: card.contentMargin
		dataItem.serviceType: "oemname"
		dataItem.path: "/Pump/Power"
		unit: PluginUnit.Watt
		fontSize: PluginPalette.font_size_large
	}

	PluginLabel {
		x: card.contentMargin
		width: card.width - 2 * card.contentMargin
		text: "Running since 08:00"
		fontSize: PluginPalette.font_size_small
		color: PluginPalette.color_font_secondary
		wrapMode: Text.Wrap
	}
}
```

## Cards

**`PluginCard`** is a card with an icon, a title and a status, drawn like the cards in the Controls pane. Put it on your own page, in a `PluginCardListView` (see [Lists of cards](#lists-of-cards)), or add it to the Controls or Switches pane: compile its file with `--card`, as in the [quick start](#quick-start). The base type of that file is `PluginCard`, or a type that your plugin defines in its own file, if that file's base type is `PluginCard`. The GUI does not check that base type, but a card must still follow this rule. The pane shows the card after its own cards, and sets the card's size to match them. When gui-v2 loads the plugin, it compiles the card's file. If the file has an error, such as a syntax error or an unknown type, the card is left out, and gui-v2 logs a warning. If the card compiles, but cannot be created, the pane leaves it out, and logs a warning.

Set `title` and `status` to the text. Set `iconSource` to a single-color image, such as one of the `PluginIcons`. The card tints the icon with the primary font color, and draws the title and status in the current theme. `title` and `status` are the text, not the labels that draw them.

Declare any other content directly inside the card. It is placed in a column below the status, or below the title when `status` is empty. The column is as wide as the card, as in gui-v2's own cards. Every list item in the card must be flat, and a flat list item adds its own margins: see below. Content that is not a list item, such as a `PluginLabel` or a `PluginButton`, starts at the left edge of the card, so set its `x` to the card's `contentMargin`, as gui-v2's own cards do, so that it lines up with the icon and the status. If it wraps, or fills the line, also set its `width` to the card's `width` minus twice `contentMargin`. Color that content with `PluginPalette`. The card is the usual control-card size, and grows if the content needs more room. Set its width or height to change that. A `PluginCardListView`, and the Controls and Switches panes, set the card's size. In portrait layout, the card still grows to fit its content. Otherwise, it is as tall as the list or pane, so the content must fit in that height.

For a line with a label and a switch, a button or a slider, use `PluginListSwitch`, `PluginListButton` or `PluginListSlider`, or another list item type. Every list item in a card must be flat: set `flat: true` on it. A list item that is not flat draws its own background, inset by the page margins, as in a list on a page. A flat list item is drawn as in gui-v2's own cards: without a background, and as wide as the card. Its key navigation highlight spans the card. The list item checks the user's access level, as it does in a list. gui-v2's own cards let every user use their controls, so set `writeAccessLevel: PluginAccessLevel.User` if that suits your plugin. In a card, use a `PluginLabel` rather than a `PluginSettingsListHeader` or a `PluginPrimaryListLabel`, which ignore `flat`.

Key navigation works as in gui-v2's own cards. When the card has the key focus, the Up and Down keys move the focus between the list items and `PluginButton`s declared directly inside the card. They skip labels, and other items that cannot take the key focus. At the first or last of them, the key goes to the item that holds the card. Items inside a `Row`, a `Column` or another layout in the card are not reached, so declare each list item directly inside the card. If nothing inside the card can take the key focus, the card keeps it, and shows the key navigation highlight.

```qml
PluginCard {
	id: pumpCard

	property bool pumpOn: true

	title: "Pump"
	status: pumpOn ? PluginWords.on : PluginWords.off
	iconSource: PluginIcons.battery

	PluginQuantityLabel {
		x: pumpCard.contentMargin
		dataItem.serviceType: "oemname"
		dataItem.path: "/Pump/Power"
		unit: PluginUnit.Watt
		fontSize: PluginPalette.font_size_large
	}

	PluginListSwitch {
		flat: true
		text: "Pump"
		checked: pumpCard.pumpOn
		writeAccessLevel: PluginAccessLevel.User
		onClicked: pumpCard.pumpOn = !pumpCard.pumpOn
	}

	PluginListSlider {
		flat: true
		text: "Speed"
		dataItem.serviceType: "oemname"
		dataItem.path: "/Pump/Speed"
		interactive: pumpCard.pumpOn && dataItem.valid
		writeAccessLevel: PluginAccessLevel.User
	}
}
```

### Lists of cards

**`PluginCardListView`** shows the cards declared directly inside it, laid out as in the Controls pane, and fills its parent. The cards stand side by side, and scroll sideways. In portrait layout, they stand one above the other, and scroll up and down. With key navigation, the list scrolls to show the card with the key focus, or, in a card that is larger than the list, the control with the key focus. The cards are fixed when the list is created.

The list sets the width and height of each card, as in the Controls pane, so do not set them on the card. In portrait layout, each card is as wide as the list. Otherwise, each card is as tall as the list, and does not grow to fit its content.

With key navigation, the Left and Right keys move the key focus to the previous or next card, and the Up and Down keys move it between the items inside a card. In portrait layout, the Up and Down keys also move to the previous or next card, from the first or last item in a card.

```qml
PluginPage {
	PluginCardListView {
		PluginCard {
			title: "Pump"
			iconSource: PluginIcons.battery

			PluginListSwitch {
				flat: true
				text: "Pump"
				dataItem.serviceType: "oemname"
				dataItem.path: "/Pump/On"
				writeAccessLevel: PluginAccessLevel.User
			}
		}

		PluginCard {
			title: "Tank"
			iconSource: PluginIcons.devices

			PluginListQuantity {
				flat: true
				text: "Level"
				unit: PluginUnit.Percentage
				dataItem.serviceType: "oemname"
				dataItem.path: "/Tank/Level"
			}
		}
	}
}
```

## Buttons

**`PluginButton`** is a push button, drawn like gui-v2's own, for an action that needs a large button of its own, such as the button that starts and stops a generator on gui-v2's generator card. For a line with a label and a button, use a `PluginListButton` instead. Unlike the list items, `PluginButton` does not check the user's access level.

It shows `text`, and `iconSource` if it is set. `iconSource` is a single-color image, such as one of the `PluginIcons`. A click emits `clicked()`. Set `enabled: false` to grey it out, so that it ignores touches and keys.

With key navigation, Space clicks the button when it has the key focus. In a card, declare the button directly inside the card, so that the Up and Down keys reach it. In a `PluginListSetting`, the list item has the key focus, not its content, so handle the keys on the list item. See [Rules for plugin pages](#rules-for-plugin-pages).

```qml
PluginCard {
	id: pumpCard

	property bool pumpOn

	title: "Pump"
	status: pumpOn ? PluginWords.on : PluginWords.off

	PluginButton {
		x: pumpCard.contentMargin
		width: pumpCard.width - 2 * pumpCard.contentMargin
		text: pumpCard.pumpOn ? "Stop" : "Start"
		onClicked: pumpCard.pumpOn = !pumpCard.pumpOn
	}
}
```

## Asking the user to confirm

**`PluginConfirmationDialog`** asks the user to confirm a change, such as "Turn off the pump?", in a dialog drawn like the GUI's own. Declare it in a page or in a list item, and call `open()` to show it. If it is already shown, `open()` does nothing.

- `title`: the question.
- `description`: more text below the question, such as what the change will do.
- `acceptText`: the text of the button that confirms. The default is "OK".
- `rejectText`: the text of the button that cancels. The default is "Cancel". In portrait layout, the dialog has no such button. It has a close button at the top instead.

`accepted()` is emitted when the user confirms, and `rejected()` when the user cancels. The dialog can also close without either signal: when the user drags it away in portrait layout, when the page changes, when the screen blanks, or when the screen changes between portrait and landscape. So make the change in `onAccepted`, and change nothing before then. If the `PluginConfirmationDialog` is destroyed while the dialog is shown, for example with its page, the dialog closes.

For example, a switch that asks before it turns the pump off, and turns it on without asking:

```qml
PluginListSwitch {
	id: pumpSwitch

	text: "Pump"
	dataItem.serviceType: "oemname"
	dataItem.path: "/Pump/Enabled"
	updateDataOnClick: false
	onClicked: {
		if (checked) {
			confirmDialog.open()
		} else {
			dataItem.setValue(1)
		}
	}

	PluginConfirmationDialog {
		id: confirmDialog

		title: "Turn off the pump?"
		description: "The tank will stop filling."
		acceptText: "Turn off"
		onAccepted: pumpSwitch.dataItem.setValue(0)
	}
}
```

`clicked()` is emitted only if the user has the switch's `writeAccessLevel`, so the dialog is not shown to a user who cannot make the change.

## Type reference

All of these are in `Victron.GuiPlugins`.

### Pages

- **`PluginPage`**: the base type of a plugin page. `title` is shown in the status bar. If it is empty, the list item that opened the page supplies the title, until the page sets one. The GUI provides the back button, and sizes the page.
- **`PluginDevicePage`**: a `PluginPage` for a device sub-page. The GUI sets `serviceUid` (the start of the device's uids), `productId` and `deviceName` when it opens the page.
- **`PluginItemListView`**: a scrolling list of the list items declared inside it, which fills its parent.
- **`PluginModelListView`**: a scrolling list with one list item for each entry in a model, which fills its parent. See [Lists from a model](#lists-from-a-model).
- **`PluginCardListView`**: a scrolling list of the cards declared inside it, laid out as in the Controls pane, which fills its parent. See [Lists of cards](#lists-of-cards).

### List items

Every list item derives from `PluginListItem`, which you do not use directly. So every list item has:

- `preferredVisible`: set it to `false` to hide the list item. If the list item has the key focus, focus moves to a visible list item.
- `showAccessLevel`: the lowest access level that shows the list item. The default is `PluginAccessLevel.User`.
- `effectiveVisible` (read only): whether the list item is shown.
- `flat`: every list item declared inside a `PluginCard` must set it to `true`. The list item is then drawn as in gui-v2's own cards: without a background, and as wide as the card. See [Cards](#cards). `PluginSettingsListHeader` and `PluginPrimaryListLabel` ignore it.

The list item types:

- **`PluginListSwitch`**: a label and a toggle switch. Either set `dataItem`, and the switch shows whether the value is `valueTrue` (default 1), and a click writes `valueFalse` (default 0) or `valueTrue`; or set `checkable: true`, and use `checked` and `onClicked`. A click on a checkable switch writes a new value to `checked`, which replaces any binding on it. Without `dataItem` or `checkable`, a click only emits `clicked()`: bind `checked`, and change the bound value in `onClicked`. Set `updateDataOnClick: false` to handle the click yourself, for example to ask before writing, with a [`PluginConfirmationDialog`](#asking-the-user-to-confirm). Also: `text`, `caption`, `secondaryText`, `writeAccessLevel`, `interactive`, `click()`, `checkWriteAccessLevel()`.
- **`PluginListTextField`**: a label and an editable text field. The field shows `secondaryText`, which is the value of `dataItem` by default; when the user finishes editing, the new text is written to `dataItem`. Also: `text`, `caption`, `placeholderText`, `maximumLength`, `writeAccessLevel`, `checkWriteAccessLevel()`.
- **`PluginListNavigation`**: a list item with an arrow, which opens `pageUrl` when clicked, with `pageProperties` set on the new page. The host shows the page's `title`, or this list item's `text` while that title is empty. `pageProperties.title`, if set, replaces the page's title binding. Or leave `pageUrl` empty and handle `onClicked`. Also: `caption`, `secondaryText`, `interactive`, `click()`.
- **`PluginListText`**: a label, and read-only text on the right. The text is `secondaryText`, which is the value of `dataItem` by default. Also: `text`, `caption`.
- **`PluginListQuantity`**: a label, and a value with its unit on the right, such as "12.35 V". The value is `value`, which is the value of `dataItem` by default; if it is not a number, the list item shows "--". Set `unit` to a `PluginUnit`, and `decimals` to the number of decimal places (by default, the default number of decimals for the specified unit and value will be used). Also: `text`, `caption`. For a temperature, use `PluginListTemperature`.
- **`PluginListTemperature`**: a label, and a temperature on the right, in the unit the user chose (Celsius or Fahrenheit). The temperature is the value of `dataItem`, which must be in degrees Celsius. Also: `text`, `caption`, `decimals`.
- **`PluginListSpinBox`**: a label, and a clickable number on the right. A click opens a dialog in which the user picks a new number, from `from` to `to` (by default, the `min` and `max` of `dataItem`, if the system gives them), in steps of `stepSize` (default 1). The number shown is the `value` property. By default, that is the value of `dataItem`, and the picked number is written to `dataItem`. Without a `dataItem`, the dialog's accepted handler writes the picked number to `value`, which replaces any binding on it. Also: `text`, `caption`, `suffix` (shown after the number, such as `" A"`), `decimals` (default 0), `writeAccessLevel`, `interactive`, `click()`, `checkWriteAccessLevel()`.
- **`PluginListSlider`**: a label and a horizontal slider, with - and + buttons on either side of it. In portrait layout, the slider is below the label. The slider moves from `from` to `to` (by default, the `min` and `max` of `dataItem`, if the system gives them, or else 0 and 1), in steps of `stepSize` (by default, a tenth of the range), which is also how much the - and + buttons change the number. The slider shows the `value` property. By default, that is the value of `dataItem`, and moving the slider writes the new number to `dataItem`. Without a `dataItem`, moving the slider writes the new number to `value`, which replaces any binding on it. With key navigation, Space starts changing the number: Left and Right change it, and Return, Enter or Escape stop. Also: `text`, `writeAccessLevel`, `interactive`, `checkWriteAccessLevel()`.
- **`PluginListRadioButtonGroup`**: a label, and the current option on the right. A click opens a page that lists the options, and the user picks one. `optionModel` is an array of options, each an object with `display` (the option's text) and `value`, for example `[ { display: "Off", value: 0 }, { display: "On", value: 1 } ]`. `currentIndex` is the index of the current option, or -1 for none, when the list item shows `defaultSecondaryText` ("Unknown" by default). By default, `currentIndex` is the option whose `value` is equal to `dataItem.value`, and picking an option writes its `value` to `dataItem`. Without a `dataItem`, set `currentIndex` yourself in `onOptionClicked(index)`. Set `updateDataOnClick: false` to handle the pick yourself, for example to ask before writing, with a [`PluginConfirmationDialog`](#asking-the-user-to-confirm). Also: `text`, `caption`, `writeAccessLevel`, `interactive`, `click()`, `checkWriteAccessLevel()`.
- **`PluginListButton`**: a label, and a button on the right that shows `secondaryText`. A click emits `clicked()`, if the user has `writeAccessLevel`. Also: `text`, `caption`, `interactive`, `click()`, `checkWriteAccessLevel()`.
- **`PluginSettingsListHeader`**: a heading, `text`, above a group of list items. Key navigation skips it.
- **`PluginPrimaryListLabel`**: explanatory text, `text`, across the width of the list, without a list item background. Key navigation skips it.
- **`PluginListSetting`**: a list item with your own content, for list items that the other types do not cover. Declare the content inside it; the list item gives it the standard background, the key navigation highlight, and access handling. If you set `text`, the list item shows it and puts your content on the right, at the content's own size; if the content does not fit beside the text, it goes below it. If `text` is empty, your content fills the width of the list item. Set `interactive: true` if the content can be clicked, and enable it with `clickable`. Also: `writeAccessLevel`, `checkWriteAccessLevel()`.

### Other types

- **`PluginCard`**: a card with an icon, a title and a status. See [Cards](#cards).
- **`PluginConfirmationDialog`**: a dialog that asks the user to confirm a change. Set `title`, `description`, `acceptText` and `rejectText`, call `open()`, and handle `onAccepted` and `onRejected`. See [Asking the user to confirm](#asking-the-user-to-confirm).
- **`PluginLabel`**: text in the GUI's font. Set `text`, `fontSize`, `color`, `horizontalAlignment`, `verticalAlignment`, `wrapMode` and `elide`. See [Text and numbers](#text-and-numbers).
- **`PluginQuantityLabel`**: a number with its unit, such as "230 V". Set `value` or `dataItem`, `unit`, `decimals`, `fontSize`, `valueColor`, `unitColor`, `horizontalAlignment` and `verticalAlignment`. See [Text and numbers](#text-and-numbers).
- **`PluginButton`**: a large push button. Set `text` and `iconSource`, and handle `onClicked`. See [Buttons](#buttons).
- **`PluginDataItem`**: a value on the system. `serviceType` and `path` name it; set `deviceInstance` to name one device. See [Backend data values](#backend-data-values).
- **`PluginDeviceModel`**: the devices on the system, filtered by `serviceTypes` and `requiredPaths` and sorted by name, and the service types on the system, in `availableServiceTypes`. See [Devices](#devices).
- **`PluginDataPathModel`**: the child paths of a `uid`, such as the top-level paths of a device, or of `path` on the service or device named by `serviceType` and `deviceInstance`. See [Paths on a device or service](#paths-on-a-device-or-service).
- **`PluginAccessLevel`**: `User`, `Installer`, `SuperUser`, `Service`.
- **`PluginUnit`**: the units for `PluginListQuantity` and `PluginQuantityLabel`: `None`, `Amp`, `AmpHour`, `Energy_KiloWattHour`, `Hectopascal`, `Hertz`, `Kilopascal`, `Percentage`, `PowerFactor` (a number with no unit), `RevolutionsPerMinute`, `Time_Day`, `Time_Hour`, `Time_Minute`, `Time_Second`, `VoltAmpere`, `VoltAmpereReactive`, `Volt_AC`, `Volt_DC`, `Watt`, `WattsPerSquareMetre`. The units of temperature, volume, speed and distance are not here, because the user picks which of those the GUI shows. For a temperature, use `PluginListTemperature`.
- **`PluginPalette`**: the main GUI colors, the font families, the main text sizes, and the layout orientation. See [Colors](#colors).
- **`PluginWords`**, **`PluginIcons`** and **`PluginIconImage`**: see [Words and icons](#words-and-icons).

### Versions

The version of `Victron.GuiPlugins` that added each type. A type's members came with it, unless they are listed after it with a later version. See [Versioning](#versioning).

<!-- BEGIN versions. tools/guipluginsapi.py writes this part from tools/guiplugins-api.json: do not edit it. -->

- `PluginAccessLevel`: 1.0
- `PluginButton`: 1.0
- `PluginCard`: 1.0
- `PluginCardListView`: 1.0
- `PluginConfirmationDialog`: 1.0
- `PluginDataItem`: 1.0
- `PluginDataPathModel`: 1.0
- `PluginDeviceModel`: 1.0
- `PluginDevicePage`: 1.0
- `PluginIconImage`: 1.0
- `PluginIcons`: 1.0
- `PluginItemListView`: 1.0
- `PluginLabel`: 1.0
- `PluginListButton`: 1.0
- `PluginListItem`: 1.0
- `PluginListNavigation`: 1.0
- `PluginListQuantity`: 1.0
- `PluginListRadioButtonGroup`: 1.0
- `PluginListSetting`: 1.0
- `PluginListSlider`: 1.0
- `PluginListSpinBox`: 1.0
- `PluginListSwitch`: 1.0
- `PluginListTemperature`: 1.0
- `PluginListText`: 1.0
- `PluginListTextField`: 1.0
- `PluginModelListView`: 1.0
- `PluginPage`: 1.0
- `PluginPalette`: 1.0
- `PluginPrimaryListLabel`: 1.0
- `PluginQuantityLabel`: 1.0
- `PluginSettingsListHeader`: 1.0
- `PluginUnit`: 1.0
- `PluginWords`: 1.0

<!-- END versions -->

## Versioning

`Victron.GuiPlugins` has its own version, `major.minor`, separate from gui-v2's version.

- **Minor versions add types and members.** The [versions](#versions) list in the type reference says which version added each one.
- **The required version.** The compiler writes `requiredGuiPluginsVersion` into the plugin's JSON file, and prints it: the lowest `Victron.GuiPlugins` version that has every type and member that your files use. A plugin that uses only types and members from 1.0 needs 1.0, even if the compiler was built for a newer version, so it still runs on older GX devices. If none of your files imports `Victron.GuiPlugins`, the compiler writes no `requiredGuiPluginsVersion`. Write `import Victron.GuiPlugins` with no version. The compiler rejects a version on that import: it is not the required version, and an older GUI could accept the plugin and then fail to load the file.
- **How the compiler finds what you use.** It goes by names. A member counts as used if its name appears in your files, outside comments and plain strings, and it belongs to a type that you use, to that type's base type, or to the type of another member that you use. A model's role names count as members, so a delegate's `required property string serviceUid` uses the `serviceUid` role name of a `PluginDeviceModel`. `PluginWords.reset` and `PluginWords["reset"]` both use `reset`; `PluginWords[word]` does not, because the key is not a constant. A handler such as `onToggled` or `onCheckedChanged` uses `toggled` or `checked`. So does a direct connection, such as `checkedChanged.connect(...)`. So if one of your own properties or functions has the same name as a newer member, the version can be newer than needed. The compiler prints the members that need the version it writes; if one of them is really your own property or function, rename yours.
- **What the GUI does with it.** If the GUI's `Victron.GuiPlugins` has a different major version, or an older minor version, than `requiredGuiPluginsVersion`, the GUI ignores the plugin's pages and logs why, for example `Ignoring integration at index 0 in plugin OemName - type: 1 - it needs Victron.GuiPlugins 1.2, but this GUI only has 1.1`. A plugin without `requiredGuiPluginsVersion` is not checked.
- **Older GUIs.** Versions of gui-v2 without `Victron.GuiPlugins` do not check `requiredGuiPluginsVersion`, and cannot open the plugin's pages. So also pass `--min-required-version` to the compiler, with the first gui-v2 version that has `Victron.GuiPlugins`, as the examples do.
- **Deprecation.** A type or member that is to be removed is marked deprecated in the type reference. The compiler warns when a plugin uses it. The GUI does not. It is removed only in the next major version. Nothing is deprecated yet. The warning uses the same name matching as the required version, so one of your own properties can cause it if it has the same name.
- **Major versions** remove or change types and members. When a new major version is announced, plugin authors must port their plugins to the new API.

## Changing Victron.GuiPlugins (gui-v2 contributors)

- The module is in `guiplugins/`, and its files are listed in `cmake/ModuleGuiPlugins_Sources.cmake`. Its types wrap `Victron.VenusOS` types, and may use them in their own code. `Victron.VenusOS` must never use `Victron.GuiPlugins`; the `tst_moduledependencies` test fails if it does, and CMake stops at configure time if the VenusOS library links it. See [Module dependencies](architecture.md#module-dependencies).
- Every promised member is declared on the wrapper's root object, so that the inner `Victron.VenusOS` type can change without changing the plugin API. A list item type's base type is `PluginListItem`, and the inner item (`id: inner`) takes `preferredVisible` and `showAccessLevel` from it.
- `tools/guiplugins-api.json` is the checked-in record of the API: every type in the module, and each type's properties, signals, methods, role names and enums, with the version that added each one. `tools/guipluginsapi.py` writes it from the files in `cmake/ModuleGuiPlugins_Sources.cmake`, and writes the [versions](#versions) list from it. The `tst_guipluginsapi` test fails if either is out of date. Every file in the module is part of the API. A QML file's API is its base type and the declarations directly inside its root object; a header's API is the class or namespace that it registers with `QML_ELEMENT`. A list model's role names are the names that its `roleNames()` returns. The script reads `roleNames()` from the class, or from the `.cpp` file with the same name, so write its body as `return { { <role>, "<name>" }, ... };`. Each role name needs a `Q_INVOKABLE <type> <name>At(int index)` method, which gives the role name's type. A declaration whose name starts and ends with `__` is not recorded. It is not part of the API. `PluginPage` has `__is_plugin_page__` so the page stack can recognise a plugin page without importing this module.
- The script refuses:
  - a change that could break a plugin, unless `VICTRON_GUIPLUGINS_VERSION_MAJOR` goes up: removing or renaming a type, member or role name, changing a type's base or the type of a property or role name, making a property read-only or required, changing the default property, changing a signal's or method's parameters or return type, or changing an enum value's number. Only for a type or member that no released GUI has, `--allow-breaking-changes` lets you make such a change;
  - a new type or member, unless the version in `cmake/ModuleGuiPlugins.cmake` is already higher than the version in `tools/guiplugins-api.json`. It writes nothing, and prints what to do;
  - a type that plugins cannot use, anywhere in the API. Plugins import only `Victron.GuiPlugins`, `QtQml` and `QtQuick`, so the API may use only QML's basic types, `QtObject`, `Item`, `FocusScope`, `Component`, `QAbstractListModel`, and the module's own types. `QAbstractListModel` is a Qt list model, so a plugin can pass it to a `Repeater`. This keeps `Victron.VenusOS` types out of it;
  - a declaration that it cannot read, such as an inline component, a slot, a `Q_PROPERTY` written over several lines, more than one statement on a declaration's line, or a list model whose role names it cannot read. A function expression in a property initializer is part of that property. Members of nested objects do not contribute to the API of the type, so they are not recorded;
  - a regular expression literal. The script does not read one. Do not use one in a file in this module.
- Version 1.0 stays open until the first GUI with `Victron.GuiPlugins` is released. Until then, to add to the API, add the type or member and run `python3 tools/guipluginsapi.py`, without increasing `VICTRON_GUIPLUGINS_VERSION_MINOR`. New types and members get 1.0. When that GUI is released, set `UNRELEASED_VERSION` in `tools/guipluginsapi.py` to `None`, so that the next two rules apply.
- After the first release, to add to the API: first increase `VICTRON_GUIPLUGINS_VERSION_MINOR` in `cmake/ModuleGuiPlugins.cmake`. Then add the type or member, and run `python3 tools/guipluginsapi.py`. New types and members get that version, and the script adds them to the [versions](#versions) list. If you did not increase the version, the script stops and does not change `tools/guiplugins-api.json`. Increase the minor version, then run it again.
- After the first release, each update that adds to the API needs its own minor version, even if the previous one has not been released. Two additions in one release cycle are 1.1 and 1.2, not both 1.1.
- Removing or changing a type or member needs a new major version. See [Versioning](#versioning). The script cannot see a change to a property's initial value, or to what a function does. Those can still break a plugin, and they need a new major version too.
- To deprecate a type or member, add `"deprecated": true` to it in `tools/guiplugins-api.json`, say so in the type reference, and run `python3 tools/guipluginsapi.py`. The script keeps the flag. The compiler then warns a plugin that uses it; the GUI does not. Removing it still needs a new major version.
- The compiler reads `tools/guiplugins-api.json`, which is installed next to it, to work out each plugin's `requiredGuiPluginsVersion` and to warn about deprecated types and members (see [Versioning](#versioning)). The plugin loader, in `src/guiplugins.cpp`, gets the module version from `cmake/ModuleGuiPlugins.cmake` as two compile definitions, and drops a plugin's pages if it needs a version that the GUI does not have. The `tst_plugincompiler` and `tst_guipluginloader` tests cover both.
- The enums for plugins, `PluginAccessLevel` and `PluginUnit`, are C++ namespaces with explicit values, equal to the `VenusOS` values that the wrappers pass them to. `pluginaccesslevel.cpp` and `pluginunit.cpp` check this at build time. If a `VenusOS` value changes, keep the plugin value, and map it in the wrapper instead. `PluginUnit` leaves out the units that the user picks in the settings (temperature, volume, speed and distance), because the wrappers show the unit they are given, not the user's unit.
- `PluginLabel` wraps `Label`, and `PluginQuantityLabel` wraps `QuantityLabel`. Each exposes only its own properties, not the inner label or its `font`, so that the text keeps the GUI's font family. `PluginConfirmationDialog` is a `QtObject` that opens a `ModalWarningDialog` with OK and Cancel options in `Global.dialogLayer`. It keeps the GUI's warning icon, and does not expose the dialog. It destroys the dialog when it is destroyed, so that the dialog never calls the handlers of a destroyed object. Its private parts are in its `__private__` property, because a `QtObject` cannot have child objects.
- `PluginWords` copies `CommonWords`, and `PluginIcons` points at the images in `qrc:/images`. Both are promises: never rename or remove one of their properties. If a `CommonWords` word or an image is renamed, point the existing property at the new one; for a word, also add the old and new names to `renamedWords` in `tst_pluginwordsandicons`. That test checks that each word has the text of the `CommonWords` word with the same (or new) name, and that each icon loads. `PluginPalette` exposes the ten branding colors, and `font_family` and `quantity_font_family`, with the branding names, and `color_font_disabled`, with its `Theme` name. It is the same kind of promise: if `Theme` renames one, keep the existing name and point the existing property at the new one. `color_background_page` already does this: Theme calls it `color_page_background`. Add such a pair to `renamedColors` in `tst_pluginpalette`. That test checks that each color matches the `Theme` color, in both color schemes, and that each font family matches `Theme`. `PluginPalette` also exposes `font_size_small`, `font_size_medium` and `font_size_large`, which are `Theme` font sizes chosen by purpose: the list item caption size, the list item text size, and the control card status size. If `Theme` renames or changes those sizes, point each one at the nearest size with the same purpose, and update `fontSizes` in `tst_pluginpalette`, which checks them in each screen size. `PluginIconImage` tints an icon by purpose, with `PluginPalette` colors. Its `Success` tint is `color_success`, and its `Brand` tint is `color_brand`, the color of a switch that is on. `tst_pluginwordsandicons` checks each tint. The Plugin* types take their colors and text sizes from `PluginPalette`, not from `Theme`, so that a `Theme` rename needs a change only in `PluginPalette`. Their spacing and other sizes still come from `Theme`, and are not part of the API. `PluginCard` wraps `ControlCard`. It exposes `title`, `status`, `iconSource` and `contentMargin`, and a default `content` item, not the inner label or image. If `ControlCard` changes, keep those properties and map them to the new inner items. `PluginCard` puts its content in a `SettingsColumn`, so that the Up and Down keys move the key focus between the card's children as in gui-v2's own cards. The column is not part of the API. The column is as wide as the card, as in gui-v2's own cards, so a flat list item spans the card, and adds its own margins. `contentMargin` is `geometry_controlCard_contentMargins`, which gui-v2's own cards use to inset content that is not a list item. Only its purpose is promised, not its value. `PluginCardListView` wraps `BaseListView`, with the layout of `ControlCardsPage`: its margins, spacing, card sizes, orientation and scrolling. If `ControlCardsPage` changes its layout, change `PluginCardListView` to match. `PluginPalette.orientation` follows `Theme.screenSize`, and `tst_pluginpalette` checks it in each screen size. `PluginButton` wraps `Button`. The root item takes the key focus and draws the key navigation highlight, and the inner button never takes the focus itself (`focusPolicy: Qt.NoFocus`), so the plugin sees one focusable item. `PluginListSlider` wraps `ListSlider`, and syncs `value` both ways, as `PluginListSpinBox` does. `PluginDeviceModel` wraps `FilteredDeviceModel`, and reads `availableServiceTypes` from `AllDevicesModel`. It applies `requiredPaths` itself, with a `VeQuickItem` for each required path on each device, so that "valid" means what it means for `PluginDataItem`. It follows the inner model by inserting, removing and moving rows, rather than resetting the model, so that views keep their delegates. A change made during an update, such as a delegate setting `serviceTypes`, is applied by one more update from the event loop. After two such extra updates in a row, it warns about a loop and stops, until a change comes from elsewhere. It exposes `serviceTypes`, `requiredPaths`, `availableServiceTypes`, `count`, and the role names `serviceUid`, `serviceType`, `deviceInstance`, `name` and `productId`. It does not expose the GUI's device object, or the child filter. If `FilteredDeviceModel` changes, keep those and map them. `PluginDataPathModel` reads the children of the backend item (`VeQItem`) at its `uid`. It lists a child when the state of the child, or of one of its descendants, shows that the system gave it a value, so that an item that the GUI only asked for is not listed. It never asks the system for a value. A change to a descendant of `uid` starts a 100 ms timer, and the list is updated once when it fires, so that a burst of changes is one update. If the item at `uid` is deleted, as the mock backend does when it removes a device, the model creates it again, so that it lists the paths if they come back. It builds `uid` from `serviceType`, `deviceInstance` and `path` as `PluginDataItem` does. Both use the internal `DeviceWatcher` (`guiplugins/devicewatcher.h`), which reads `AllDevicesModel`, to find the service uid of a device. It exposes `uid`, `serviceType`, `deviceInstance`, `path`, `count`, and the role names `childName`, `childPath` and `childUid`. The role names start with `child`, so that they differ from the `uid` and `path` properties: in a delegate, a nested model's `uid: uid` would bind its `uid` to itself.
- `PageStack.pushPluginPage()` (reached through `Global.pageManager.pushPluginPage()`) opens a plugin page. It creates a `PluginHostPage` (defined in `PageStack.qml`), which is a `Page`, and then the plugin page with the host page as its parent, so the two are destroyed together. The host shows the plugin page's title, or `defaultTitle` while that title is empty. A list item that opens the page passes its text as `defaultTitle`. Callers must not assign `pluginPage.title`: that replaces the page's title binding. A page whose base type is a `Page` from `Victron.VenusOS`, is not an item, or is not a `PluginPage`, is destroyed with the host and is not opened. `PageStack.pushPage()` is for gui-v2's own pages, and refuses a page whose base type is not a `Page`.
