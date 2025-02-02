/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	VeQuickItem {
		id: modelItem
		uid: Global.venusPlatform.serviceUid + "/Device/Model"
	}

	GradientListView {
		model: ObjectModel {
			ListLink {
				//% "Product support & manuals"
				text: qsTrId("settings_support_links_product_support_manuals")
				url: {
					let model = modelItem.isValid ? modelItem.value : ""
					if (model === "Cerbo GX") {
						return "https://ve3.nl/guidocs-cerbo-gx"
					} else if (model === "MultiPlus-II") {
						return "https://ve3.nl/guidocs-multiplus-ii"
					} else {
						return "https://ve3.nl/guidocs-support"
					}
				}
			}

			ListLink {
				//% "Victron Community"
				text: qsTrId("settings_support_links_community")
				url: "https://ve3.nl/guidoc-community"
			}

			ListLink {
				//% "Find a local distributor"
				text: qsTrId("settings_support_links_distributor")
				url: "https://ve3.nl/guidoc-find-distributor"
			}
		}
	}
}
