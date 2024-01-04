/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	property string bindPrefix

	// wakespeedProductId should always be equal to VE_PROD_ID_WAKESPEED_WS500
	readonly property int wakespeedProductId: 0xB080

	VeQuickItem {
		id: productIdDataItem

		uid: root.bindPrefix + "/ProductId"
		onValueChanged: {
			if (value !== undefined && modelLoader.status === Loader.Null) {
				if (value === wakespeedProductId) {
					modelLoader.sourceComponent = wakespeedModelComponent
				} else {
					modelLoader.sourceComponent = dcMeterModelComponent
				}
			}
		}
	}

	GradientListView {
		id: settingsListView
		model: modelLoader.item
	}

	Loader {
		id: modelLoader
		asynchronous: true
	}

	Component {
		id: wakespeedModelComponent

		PageAlternatorModelWakespeed {
			bindPrefix: root.bindPrefix
		}
	}

	Component {
		id: dcMeterModelComponent

		PageDcMeterModel {
			bindPrefix: root.bindPrefix
		}
	}
}
