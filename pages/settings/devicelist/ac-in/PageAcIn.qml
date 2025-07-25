/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for an AC input device.

	The device could be one of the main AC inputs (i.e. a grid/shore or genset). It could also be,
	for example, an energy meter configured with a specific role (such as heatpump, genset,
	pvinverter, or evcharger) or a generic AC load.
*/
DevicePage {
	id: root

	property string bindPrefix

	serviceUid: bindPrefix
	settingsModel: modelLoader.item
	extraDeviceInfo: modelLoader.sourceComponent === acInModelComponent ? acInFooterComponent : null

	VeQuickItem {
		id: productIdDataItem

		uid: root.bindPrefix + "/ProductId"
		onValueChanged: {
			if (value !== undefined && modelLoader.status === Loader.Null) {
				if (ProductInfo.isGensetProduct(value)) {
					modelLoader.sourceComponent = gensetModelComponent
				} else {
					modelLoader.sourceComponent = acInModelComponent
				}
			}
		}
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
		id: acInModelComponent

		PageAcInModel {
			bindPrefix: root.bindPrefix
			productId: productIdDataItem.value
		}
	}

	Component {
		id: acInFooterComponent

		SettingsColumn {
			width: parent?.width ?? 0
			topPadding: spacing
			preferredVisible: dataManagerVersion.preferredVisible

			ListText {
				id: dataManagerVersion
				//% "Data manager version"
				text: qsTrId("ac-in-modeldefault_data_manager_version")
				dataItem.uid: root.bindPrefix + "/DataManagerVersion"
				preferredVisible: dataItem.valid
			}
		}
	}
}
