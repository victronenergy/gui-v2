/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

pragma Singleton

import QtQml
import Victron.VenusOS

/*
	The main colors of the GUI, its font families, its main text sizes, and its layout orientation,
	for a plugin that draws its own component. For example: color: PluginPalette.color_font_primary

	The color and font family names match a branding file, except color_font_disabled. The colors
	come from gui-v2's Theme. They change with light and dark mode, and with custom branding. If a
	color is renamed in Theme, it keeps its name here. color_background_page is the page
	background. Theme calls that color color_page_background. color_font_disabled is the color of
	disabled text. It is not in a branding file: Theme works it out from the text and background
	colors.

	font_family is Theme.font_family. It is empty when the current language uses its own font, or
	when a branding family does not cover the current language. quantity_font_family is
	Theme.quantity_font_family, the font for numbers with their units. A branding file uses that
	family for every language.

	font_size_small, font_size_medium and font_size_large are the sizes of a list item's caption, a
	list item's text, and a card's status. They change with the screen size.

	orientation is Qt.PortraitOrientation when gui-v2 uses its portrait layout, which it does when
	its window is taller than it is wide, and Qt.LandscapeOrientation otherwise.
*/
QtObject {
	readonly property color color_background_primary: Theme.color_background_primary
	readonly property color color_background_secondary: Theme.color_background_secondary
	readonly property color color_background_page: Theme.color_page_background

	readonly property color color_font_primary: Theme.color_font_primary
	readonly property color color_font_secondary: Theme.color_font_secondary
	readonly property color color_font_disabled: Theme.color_font_disabled

	readonly property color color_brand: Theme.color_brand
	readonly property color color_info: Theme.color_info
	readonly property color color_success: Theme.color_success
	readonly property color color_warning: Theme.color_warning
	readonly property color color_critical: Theme.color_critical

	readonly property string font_family: Theme.font_family
	readonly property string quantity_font_family: Theme.quantity_font_family

	readonly property int font_size_small: Theme.font_listItem_caption_size
	readonly property int font_size_medium: Theme.font_listItem_primary_size
	readonly property int font_size_large: Theme.font_controlCard_status

	readonly property int orientation: Theme.screenSize === Theme.Portrait
			? Qt.PortraitOrientation : Qt.LandscapeOrientation
}
