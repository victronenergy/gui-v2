/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	title: device.name

	Device {
		id: device
		serviceUid: root.bindPrefix
	}

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

	GradientListView {
		id: settingsListView
		model: modelLoader.item
	}

	Loader {
		id: modelLoader
		asynchronous: true
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
