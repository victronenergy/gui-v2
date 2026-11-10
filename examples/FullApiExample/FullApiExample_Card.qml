import QtQuick
import Victron.GuiPlugins

/*
	A card with an icon, a title and a status, and content of your own.

	The card draws the icon, title and status. The content is declared inside the card: a number
	and some text, drawn in the GUI's fonts and text sizes, and a bar drawn with a PluginPalette
	color. The card is not added to the Controls pane.
*/
PluginPage {
	PluginCard {
		anchors.top: parent.top
		anchors.horizontalCenter: parent.horizontalCenter

		title: "Pump"
		status: PluginWords.on
		iconSource: PluginIcons.battery

		PluginQuantityLabel {
			value: 1250
			unit: PluginUnit.Watt
			fontSize: PluginPalette.font_size_large
		}

		PluginLabel {
			width: parent.width
			text: "Filling the fresh water tank. This text wraps, because its width is set."
			fontSize: PluginPalette.font_size_small
			color: PluginPalette.color_font_secondary
			wrapMode: Text.Wrap
		}

		Rectangle {
			width: parent.width
			height: 8
			radius: 4
			color: PluginPalette.color_brand
		}
	}
}
