/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQml.Models
import Victron.GuiPlugins

/*
	A quick access pane with cards, laid out as in the Controls pane: side by side, scrolling
	sideways, or in portrait layout, one above the other, scrolling up and down. It must not import
	Victron.VenusOS.

	The cards are in a ListView, which gives the key focus to its current card. With key
	navigation, the Left and Right keys move to the next or previous card. In portrait layout, the
	Up and Down keys do, from the first or last list item in a card. In a card, the Up and Down keys
	move the key focus between its list items.
*/
PluginPage {
	id: root

	// gui-v2 uses its portrait layout when its window is taller than it is wide.
	readonly property bool portrait: Window.width < Window.height
	// The space between the cards, and around them. The plugin API does not give the spacing of
	// the Controls pane, so the pane uses its own.
	readonly property real cardSpacing: 16

	PluginDataItem {
		id: batteryPower

		serviceType: "system"
		path: "/Dc/Battery/Power"
	}

	ListView {
		id: cardsView

		anchors.fill: parent
		anchors.leftMargin: root.cardSpacing
		anchors.rightMargin: root.cardSpacing
		anchors.bottomMargin: root.cardSpacing
		spacing: root.cardSpacing
		orientation: root.portrait ? ListView.Vertical : ListView.Horizontal
		boundsBehavior: Flickable.StopAtBounds
		focus: true

		// Each card is as tall as the pane, as in the Controls pane. In portrait layout, it is as
		// wide as the pane instead.
		model: ObjectModel {
			PluginCard {
				id: batteryCard

				width: root.portrait ? cardsView.width : implicitWidth
				height: root.portrait ? implicitHeight : cardsView.height
				title: PluginWords.battery
				iconSource: PluginIcons.battery
				status: {
					const power = batteryPower.valid ? Number(batteryPower.value) : NaN
					if (isNaN(power)) {
						//% "No battery"
						return qsTrId("quickaccessexample_no_battery")
					}
					// Positive battery power is charging.
					if (power > 0) {
						//% "Charging"
						return qsTrId("quickaccessexample_charging")
					}
					if (power < 0) {
						//% "Discharging"
						return qsTrId("quickaccessexample_discharging")
					}
					//% "Idle"
					return qsTrId("quickaccessexample_idle")
				}

				PluginListQuantity {
					flat: true
					//% "State of charge"
					text: qsTrId("quickaccessexample_state_of_charge")
					unit: PluginUnit.Percentage
					dataItem.serviceType: "system"
					dataItem.path: "/Dc/Battery/Soc"
				}

				PluginListQuantity {
					flat: true
					text: PluginWords.voltage
					unit: PluginUnit.Volt_DC
					decimals: 2
					dataItem.serviceType: "system"
					dataItem.path: "/Dc/Battery/Voltage"
				}

				PluginListQuantity {
					flat: true
					text: PluginWords.power_watts
					unit: PluginUnit.Watt
					value: batteryPower.valid ? batteryPower.value : NaN
				}
			}

			// No list item in this card can take the key focus, so the card keeps it.
			PluginCard {
				id: solarCard

				width: root.portrait ? cardsView.width : implicitWidth
				height: root.portrait ? implicitHeight : cardsView.height
				//% "Solar"
				title: qsTrId("quickaccessexample_solar")
				// An icon of the plugin's own. Qt.resolvedUrl() makes the name a full url, which
				// points into this plugin.
				iconSource: Qt.resolvedUrl("icon_solar.svg")

				PluginQuantityLabel {
					x: solarCard.contentMargin
					unit: PluginUnit.Watt
					fontSize: PluginPalette.font_size_large
					dataItem.serviceType: "system"
					dataItem.path: "/Dc/Pv/Power"
				}

				PluginLabel {
					x: solarCard.contentMargin
					width: solarCard.width - 2 * solarCard.contentMargin
					//% "DC PV power"
					text: qsTrId("quickaccessexample_dc_pv")
					fontSize: PluginPalette.font_size_small
					color: PluginPalette.color_font_secondary
					wrapMode: Text.Wrap
				}
			}

			PluginCard {
				id: pumpCard

				// A local example: the pump is not real, and is off each time the pane opens.
				property bool pumpOn

				width: root.portrait ? cardsView.width : implicitWidth
				height: root.portrait ? implicitHeight : cardsView.height
				//% "Pump"
				title: qsTrId("quickaccessexample_pump")
				status: pumpOn ? PluginWords.on : PluginWords.off
				// The status bar icons of this plugin.
				iconSource: Qt.resolvedUrl(pumpOn ? "icon_brick_on.svg" : "icon_brick_off.svg")

				// The switch is not checkable, so a click does not change 'checked', and the
				// binding stays.
				PluginListSwitch {
					flat: true
					text: pumpCard.title
					//% "Local example. It does not control a pump."
					caption: qsTrId("quickaccessexample_pump_caption")
					checked: pumpCard.pumpOn
					writeAccessLevel: PluginAccessLevel.User
					onClicked: pumpCard.pumpOn = !pumpCard.pumpOn
				}
			}
		}

		// The mouse wheel scrolls the cards sideways, as in the Controls pane.
		WheelHandler {
			enabled: cardsView.orientation === ListView.Horizontal
			onWheel: (wheel) => {
				// One step of the wheel (120) adds a flick that lasts 2/3 of a second. A flick has
				// the opposite sign to the view's velocity, hence the minus.
				cardsView.flick(cardsView.flickDeceleration * wheel.angleDelta.y / 180
						- cardsView.horizontalVelocity, 0)
				wheel.accepted = true
			}
		}
	}
}
