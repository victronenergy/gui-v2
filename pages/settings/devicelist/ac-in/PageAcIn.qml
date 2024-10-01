/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: productIdDataItem

		uid: root.bindPrefix + "/ProductId"
		onValueChanged: {
			if (value !== undefined && modelLoader.status === Loader.Null) {
				if (ProductInfo.isGensetProduct(value)) {
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

		PageGensetModel {
			bindPrefix: root.bindPrefix
		}
	}

	Component {
		id: defaultModelComponent

		PageAcInModel {
			bindPrefix: root.bindPrefix
			productId: productIdDataItem.value
		}
	}
}
