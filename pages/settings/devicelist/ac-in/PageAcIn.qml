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

	// Genset productids
	readonly property int fisherPandaProductId: 0xB040
	readonly property int comApProductId: 0xB044
	readonly property int dseProductId: 0xB046

	VeQuickItem {
		id: productIdDataItem

		uid: root.bindPrefix + "/ProductId"
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
			productId: productIdDataItem.value
		}
	}
}
