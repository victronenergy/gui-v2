/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Button {
	id: root

	flat: true

	color: enabled ? Theme.color.font.primary : Theme.color.gray2

	backgroundColor: checked
		 ? (pressed ? Theme.color.dimRed : Theme.color.red)
		 : (pressed ? Theme.color.dimGreen : Theme.color.green)
}
