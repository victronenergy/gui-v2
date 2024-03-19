/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ArcGaugeQuantityRow {
	id: root

	// When ESS feedback to grid is enabled, show an arrow indicating the flow direction.
	CP.ColorImage {
		id: flowIcon

		parent: root.iconRow
		visible: !isNaN(root.quantityLabel.value)
				 && hubSetting.value === 4
				 && overvoltageFeedIn.value === 1
				 && preventFeedback.value === 0
		source: !visible ? ""
				: root.quantityLabel.value >= 0 ? "qrc:/images/icon_from_grid.svg" : "qrc:/images/icon_to_grid.svg"
		color: !visible ? ""
				: root.quantityLabel.value >= 0 ? Theme.color_blue : Theme.color_green
	}

	VeQuickItem {
		id: hubSetting
		uid: Global.system.serviceUid + "/Hub"
	}

	VeQuickItem {
		id: overvoltageFeedIn
		uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/OvervoltageFeedIn"
	}

	VeQuickItem {
		id: preventFeedback
		uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/PreventFeedback"
	}
}
