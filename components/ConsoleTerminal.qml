/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import jhofstee.nl.VTerm

Item {
	id: root
	signal finished(int ret)

	Terminal {
		id: term
		objectName: "terminal"
		focus: true
		anchors.fill: parent
		onFinished: ret => root.finished(ret)
	}
}
