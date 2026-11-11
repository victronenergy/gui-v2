import QtQuick
import Victron.GuiPlugins

/*
	Cards with an icon, a title and a status, and content of your own, in a list of cards laid out
	as in the Controls pane.

	A plugin card is meant to be shown in the Controls pane or the Switches pane, beside gui-v2's
	own cards. That is not supported yet, so this example shows the cards on a page, in a
	PluginCardListView. The list sets the size of each card. With key navigation, the Left and Right
	keys move between the cards, or in portrait layout, the Up and Down keys do, from the first or
	last list item in a card.

	The pump card shows the pump's power, drawn in gui-v2's font for numbers, and three flat list
	items that control the pump: a switch, a button and a slider. The flat list items have their
	own margins. The power is not a list item, so it sets its x to the card's contentMargin, which
	lines it up with the status. With key navigation, the Up and Down keys move the key focus
	between the three list items. Nothing in the energy card can take the key focus, so the card
	keeps it, and shows the key navigation highlight.
*/
PluginPage {
	id: root

	// The pump's state. A real plugin would read and write it with PluginDataItems.
	property bool pumpOn: true

	PluginCardListView {
		PluginCard {
			id: pumpCard

			title: "Pump"
			status: root.pumpOn ? PluginWords.on : PluginWords.off
			iconSource: PluginIcons.battery

			PluginQuantityLabel {
				x: pumpCard.contentMargin
				value: root.pumpOn ? speedSlider.value * 20 : 0
				unit: PluginUnit.Watt
				fontSize: PluginPalette.font_size_large
			}

			// The switch is not checkable, so a click does not change 'checked', and the binding
			// stays.
			PluginListSwitch {
				flat: true
				text: "Pump"
				checked: root.pumpOn
				writeAccessLevel: PluginAccessLevel.User
				onClicked: root.pumpOn = !root.pumpOn
			}

			PluginListButton {
				flat: true
				text: "Pump settings"
				secondaryText: PluginWords.reset
				writeAccessLevel: PluginAccessLevel.User
				onClicked: {
					root.pumpOn = true
					speedSlider.value = 60
				}
			}

			PluginListSlider {
				id: speedSlider

				flat: true
				text: "Speed"
				to: 100
				value: 60
				interactive: root.pumpOn
				writeAccessLevel: PluginAccessLevel.User
			}
		}

		PluginCard {
			id: energyCard

			title: "Pump energy"
			iconSource: PluginIcons.info

			PluginQuantityLabel {
				x: energyCard.contentMargin
				value: 1.25
				unit: PluginUnit.Energy_KiloWattHour
				fontSize: PluginPalette.font_size_large
			}

			PluginLabel {
				x: energyCard.contentMargin
				width: energyCard.width - 2 * energyCard.contentMargin
				text: "Used today"
				fontSize: PluginPalette.font_size_small
				color: PluginPalette.color_font_secondary
				wrapMode: Text.Wrap
			}
		}
	}
}
