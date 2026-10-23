/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

/*
	An icon, drawn in one of the GUI's colors, which change with light and dark mode and with OEM
	branding. The source is one of the PluginIcons, or a single-color image that the plugin ships.

	tint chooses the color by its purpose. When the icon is disabled (enabled is false), it uses
	the Disabled color, whatever the tint. The icon is the GUI's usual icon size, unless its width
	and height are set; the image keeps its shape, and is centred.
*/
Item {
	id: root

	enum Tint {
		Text,
		SecondaryText,
		Warning,
		Critical,
		Success,
		Disabled
	}

	property url source
	property int tint: PluginIconImage.Text

	implicitWidth: Theme.geometry_icon_size_medium
	implicitHeight: Theme.geometry_icon_size_medium

	CP.ColorImage {
		anchors.fill: parent
		source: root.source
		// Draw scalable images at the icon's size, so that they stay sharp.
		sourceSize.width: width
		sourceSize.height: height
		fillMode: Image.PreserveAspectFit
		color: !root.enabled || root.tint === PluginIconImage.Disabled ? Theme.color_font_disabled
			: root.tint === PluginIconImage.SecondaryText ? Theme.color_font_secondary
			: root.tint === PluginIconImage.Warning ? Theme.color_warning
			: root.tint === PluginIconImage.Critical ? Theme.color_critical
			: root.tint === PluginIconImage.Success ? Theme.color_success
			: Theme.color_font_primary
	}
}
