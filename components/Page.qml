/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Templates as CT
import Victron.VenusOS

Item {
	id: root

	property string title
	property bool hasSidePanel
	property int navigationButton

	width: parent ? parent.width : 0
	height: parent ? parent.height : 0
}
