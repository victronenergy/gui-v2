/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Label {
	font.pixelSize: Theme.font.size.body2
	text: parent.text
	verticalAlignment: Text.AlignVCenter
	color: parent.enabled ? Theme.color.font.primary : Theme.color.font.disabled
}
