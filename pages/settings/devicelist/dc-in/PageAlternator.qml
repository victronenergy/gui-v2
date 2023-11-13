/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string serviceType
	property string bindPrefix

	// wakespeedProductId should always be equal to VE_PROD_ID_WAKESPEED_WS500
	readonly property int wakespeedProductId: 0xB080

	DataPoint {
		id: productIdDataPoint

		source: root.bindPrefix + "/ProductId"
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
			serviceType: root.serviceType
		}
	}
}
