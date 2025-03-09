/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Column {
	property bool preferredVisible: true
	readonly property bool effectiveVisible: preferredVisible

	spacing: Theme.geometry_gradientList_spacing
}
