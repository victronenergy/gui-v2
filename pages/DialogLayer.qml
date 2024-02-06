/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	function open(dialogComponent, properties) {
		const dialog = dialogComponent.createObject(Global.dialogLayer, properties)
		dialog.closed.connect(function() {
			dialog.destroy()
		})
		dialog.open()
	}

	anchors.fill: parent
}
