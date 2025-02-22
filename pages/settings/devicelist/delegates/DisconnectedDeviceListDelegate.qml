/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListText {
	property string cachedDeviceName

	text: cachedDeviceName
	secondaryText: CommonWords.not_connected
}
