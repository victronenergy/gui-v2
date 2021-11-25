/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Button {
	id: root

	width: 320
	height: 48

	backgroundColor: checked
		 ? (down ? Theme.criticalColor : Theme.criticalSecondaryColor)
		 : (down ? Theme.goColor : Theme.goSecondaryColor)
}
