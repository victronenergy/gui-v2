/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextItem {
	id: root

	property string bindPrefix

	text: CommonWords.firmware_version
	secondaryText: FirmwareVersion.versionText(dataItem.value, FirmwareVersion.versionFormat(mgmtConnection.value, mgmtProcessName.value))
	dataItem.uid: root.bindPrefix + "/FirmwareVersion"

	VeQuickItem {
		id: mgmtConnection
		uid: root.bindPrefix + "/Mgmt/Connection"
	}

	VeQuickItem {
		id: mgmtProcessName
		uid: root.bindPrefix + "/Mgmt/ProcessName"
	}
}
