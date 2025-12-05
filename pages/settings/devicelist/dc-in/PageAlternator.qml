/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for an alternator device.

	It shows different settings depending on whether the alternator is acting as a DC source or a
	DC load.
*/
DevicePage {
	id: root

	property string bindPrefix

	serviceUid: root.bindPrefix
	settingsModel: modelLoader.item

	VeQuickItem {
		id: productIdDataItem

		uid: root.bindPrefix + "/ProductId"
		onValueChanged: {
			if (value !== undefined && modelLoader.status === Loader.Null) {
				if (ProductInfo.isRealAlternatorProduct(value) || ProductInfo.isOrionXsProduct(value)) {
					modelLoader.sourceComponent = alternatorModelComponent
				} else {
					modelLoader.sourceComponent = dcMeterModelComponent
				}
			}
		}
	}

	Loader {
		id: modelLoader
	}

	Component {
		id: alternatorModelComponent

		PageAlternatorModel {
			bindPrefix: root.bindPrefix
			page: root
		}
	}

	Component {
		id: dcMeterModelComponent

		PageDcMeterModel {
			bindPrefix: root.bindPrefix
		}
	}
}
