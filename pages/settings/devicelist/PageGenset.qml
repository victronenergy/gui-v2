/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	function setPageModel() {
		if (ProductInfo.isGensetProduct(productIdDataItem.value)) {
			modelLoader.sourceComponent = pageGensetModel
		} else {
			modelLoader.sourceComponent = pageAcInModel
		}
	}

	VeQuickItem {
		id: productIdDataItem

		uid: root.bindPrefix + "/ProductId"
		onValueChanged: {
			if (value !== undefined && modelLoader.status === Loader.Null) {
				setPageModel()
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
		id: pageGensetModel

		PageGensetModel {
			bindPrefix: root.bindPrefix
		}
	}

	Component {
		id: pageAcInModel

		PageAcInModel {
			bindPrefix: root.bindPrefix
			productId: productIdDataItem.value
		}
	}
}
