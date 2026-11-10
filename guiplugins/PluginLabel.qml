/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Text drawn in the GUI's font.

	fontSize is a pixel size, by default PluginPalette.font_size_medium. Use one of the
	PluginPalette sizes, so the label changes with the screen size, as the GUI's own text does. The
	label is as big as its text, unless its width or height is set.
*/
Item {
	id: root

	property string text
	property int fontSize: PluginPalette.font_size_medium
	property color color: PluginPalette.color_font_primary
	property int horizontalAlignment: Text.AlignLeft
	property int verticalAlignment: Text.AlignTop
	property int wrapMode: Text.NoWrap
	property int elide: Text.ElideNone

	implicitWidth: inner.implicitWidth
	implicitHeight: inner.implicitHeight

	Label {
		id: inner

		anchors.fill: parent
		text: root.text
		color: root.color
		font.pixelSize: root.fontSize
		horizontalAlignment: root.horizontalAlignment
		verticalAlignment: root.verticalAlignment
		wrapMode: root.wrapMode
		elide: root.elide
	}
}
