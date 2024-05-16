/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
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
	readonly property int creProductId: 0xB048
	readonly property int deifProductId: 0xB049

	VeQuickItem {
		id: productIdDataItem

		uid: root.bindPrefix + "/ProductId"
		onValueChanged: {
			if (value !== undefined && modelLoader.status === Loader.Null) {
				if ([fisherPandaProductId, comApProductId, dseProductId, creProductId, deifProductId].indexOf(value) > -1) {
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
