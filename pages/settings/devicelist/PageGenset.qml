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

	function setPageModel() {
		if (ProductInfo.isGensetProduct(productIdDataItem.value)) {
			modelLoader.sourceComponent = pageGensetModel
		} else {
			modelLoader.sourceComponent = pageAcInModel
		}
	}

	settingsModel: modelLoader.item

	VeQuickItem {
		id: productIdDataItem

		uid: root.serviceUid + "/ProductId"
		onValueChanged: {
			if (value !== undefined && modelLoader.status === Loader.Null) {
				setPageModel()
			}
		}
	}

	Loader {
		id: modelLoader
	}

	Component {
		id: pageGensetModel

		PageGensetModel {
			bindPrefix: root.serviceUid
		}
	}

	Component {
		id: pageAcInModel

		PageAcInModel {
			bindPrefix: root.serviceUid
			productId: productIdDataItem.value
			deviceSettingsPage: root
		}
	}
}
