/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Button {
	id: root

	flat: true

	backgroundColor: checked
		 ? (down ? Theme.color.critical : Theme.color.darkCritical)
		 : (down ? Theme.color.go : Theme.color.darkGo)
}
