/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	// wakespeedProductId should always be equal to VE_PROD_ID_WAKESPEED_WS500
	readonly property int wakespeedProductId: 0xB080    
	readonly property int arcoProductId: 0xB090
	readonly property int mgAfcProductId: 0xB0F0
	readonly property int genericProductId: 0xB091
	readonly property int integrelProductId: 0xB092
	readonly property int orionXsProductIdMin: 0xA3F0
	readonly property int orionXsProductIdMax: 0xA3FF

	function isRealAlternator(productId) {
		const alternators = [arcoProductId, wakespeedProductId, mgAfcProductId, genericProductId integrelProductId]
		return alternators.indexOf(productId) > -1
	}

	function isOrionXsAlternator(productId) {
		return productId >= orionXsProductIdMin && productId <= orionXsProductIdMax
	}

	VeQuickItem {
		id: productIdDataItem

		uid: root.bindPrefix + "/ProductId"
		onValueChanged: {
			if (value !== undefined && modelLoader.status === Loader.Null) {
				if (isRealAlternator(value) || isOrionXsAlternator(value)) {
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
		}
	}

	Component {
		id: dcMeterModelComponent

		PageDcMeterModel {
			bindPrefix: root.bindPrefix
		}
	}
}
