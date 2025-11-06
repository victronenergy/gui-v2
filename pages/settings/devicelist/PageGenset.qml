/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for a genset or dcgenset device.
*/
DevicePage {
	id: root

	property string bindPrefix

	function setPageModel() {
		if (ProductInfo.isGensetProduct(productIdDataItem.value)) {
			modelLoader.sourceComponent = pageGensetModel
		} else {
			modelLoader.sourceComponent = pageAcInModel
		}
	}

	serviceUid: bindPrefix
	settingsModel: modelLoader.item

	VeQuickItem {
		id: productIdDataItem

		uid: root.bindPrefix + "/ProductId"
		onValueChanged: {
			if (value !== undefined && modelLoader.status === Loader.Null) {
				setPageModel()
			}
		}
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
			deviceSettingsPage: root
		}
	}
}
