/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

ArcGauge {
	id: root

	property alias label: quantityLabel
	property alias icon: quantityLabel.icon
	property alias quantityLabel: quantityLabel.quantityLabel

	ArcGaugeQuantityLabel {
		id: quantityLabel

		alignment: root.alignment
	}
}
