/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.GuiPlugins

// A navigation page provided by the plugin. It must not import Victron.VenusOS.
// It draws its own tiles, with PluginPalette colors and text sizes, so that they follow light and
// dark mode, custom branding and the screen size. The tiles are in two rows and two columns in
// landscape layout, and in one column in portrait layout.
PluginPage {
	id: root

	readonly property bool portrait: PluginPalette.orientation === Qt.PortraitOrientation

	//% "Example"
	title: qsTrId("navigationexample_title")

	// A box with a title, a system value with its unit, and an optional line of text.
	// Items declared inside a Tile are placed below them.
	component Tile: Rectangle {
		id: tile

		default property alias content: tileColumn.data
		property string title
		property string path
		property int unit
		property int decimals: -1
		property string detail

		radius: 8
		// A dark brand color: the brand color at 30%, laid over the background color. This is how
		// gui-v2 makes its own dark brand color, so it follows light and dark mode and branding.
		color: Qt.tint(PluginPalette.color_background_primary, Qt.alpha(PluginPalette.color_brand, 0.3))

		Column {
			id: tileColumn

			anchors {
				left: parent.left
				right: parent.right
				verticalCenter: parent.verticalCenter
				margins: 16
			}
			spacing: 8

			PluginLabel {
				width: parent.width
				text: tile.title
				fontSize: PluginPalette.font_size_small
				color: PluginPalette.color_font_secondary
				elide: Text.ElideRight
			}

			PluginQuantityLabel {
				dataItem.serviceType: "system"
				dataItem.path: tile.path
				unit: tile.unit
				decimals: tile.decimals
				fontSize: PluginPalette.font_size_large
			}

			PluginLabel {
				width: parent.width
				visible: text.length > 0
				text: tile.detail
				fontSize: PluginPalette.font_size_small
				color: PluginPalette.color_font_secondary
				elide: Text.ElideRight
			}
		}
	}

	PluginDataItem {
		id: batterySoc

		serviceType: "system"
		path: "/Dc/Battery/Soc"
	}

	PluginDataItem {
		id: batteryPower

		serviceType: "system"
		path: "/Dc/Battery/Power"
	}

	Grid {
		id: grid

		// The Grid works out its rows from its columns. Setting rows too would warn while the
		// orientation changes, as columns and rows do not change at the same time.
		readonly property int rowCount: Math.ceil(4 / columns)
		readonly property real tileWidth: (width - (columns - 1) * spacing) / columns
		readonly property real tileHeight: (height - (rowCount - 1) * spacing) / rowCount

		anchors {
			fill: parent
			margins: root.portrait ? 16 : 24
		}
		columns: root.portrait ? 1 : 2
		spacing: root.portrait ? 8 : 16

		Tile {
			width: grid.tileWidth
			height: grid.tileHeight
			title: PluginWords.battery
			path: "/Dc/Battery/Soc"
			unit: PluginUnit.Percentage
			detail: {
				const power = batteryPower.valid ? Number(batteryPower.value) : NaN
				if (isNaN(power)) {
					//% "No battery"
					return qsTrId("navigationexample_no_battery")
				}
				// A positive battery power means that the battery is charging.
				if (power > 0) {
					//% "Charging"
					return qsTrId("navigationexample_charging")
				}
				if (power < 0) {
					//% "Discharging"
					return qsTrId("navigationexample_discharging")
				}
				//% "Idle"
				return qsTrId("navigationexample_idle")
			}

			// The state of charge, as a bar, drawn over the background color so that it stands out
			// from the tile.
			Rectangle {
				width: parent.width
				height: 12
				radius: 6
				color: PluginPalette.color_background_primary

				Rectangle {
					width: parent.width * Math.max(0, Math.min(100, batterySoc.valid ? batterySoc.value : 0)) / 100
					height: parent.height
					radius: parent.radius
					color: PluginPalette.color_brand
				}
			}
		}

		Tile {
			width: grid.tileWidth
			height: grid.tileHeight
			//% "Battery power"
			title: qsTrId("navigationexample_battery_power")
			path: "/Dc/Battery/Power"
			unit: PluginUnit.Watt
		}

		Tile {
			width: grid.tileWidth
			height: grid.tileHeight
			//% "Solar"
			title: qsTrId("navigationexample_solar")
			path: "/Dc/Pv/Power"
			unit: PluginUnit.Watt
			//% "DC PV power"
			detail: qsTrId("navigationexample_dc_pv")
		}

		Tile {
			width: grid.tileWidth
			height: grid.tileHeight
			//% "DC system"
			title: qsTrId("navigationexample_dc_system")
			path: "/Dc/System/Power"
			unit: PluginUnit.Watt
		}
	}
}