/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextItem {
	id: root

	text: CommonWords.firmware_version
	secondaryText: dataItem.value ? FirmwareVersion.versionText(dataItem.value, BackendConnection.serviceTypeFromUid(dataItem.uid)) : ""
}
