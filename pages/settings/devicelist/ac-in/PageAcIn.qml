/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	// Genset productids
	readonly property int fisherPandaProductId: 0xB040
	readonly property int comApProductId: 0xB044
	readonly property int dseProductId: 0xB046

	DataPoint {
		id: productIdDataPoint

		source: root.bindPrefix + "/ProductId"
		onValueChanged: {
			if (value !== undefined && modelLoader.status === Loader.Null) {
				if ([fisherPandaProductId, comApProductId, dseProductId].indexOf(value) > -1) {
					modelLoader.sourceComponent = gensetModelComponent
				} else {
					modelLoader.sourceComponent = defaultModelComponent
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
		id: gensetModelComponent

		PageAcInModelGenset {
			bindPrefix: root.bindPrefix
		}
	}

	Component {
		id: defaultModelComponent

		PageAcInModelDefault {
			bindPrefix: root.bindPrefix
			productId: productIdDataPoint.value
		}
	}
}
