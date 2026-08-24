/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: Services.generators.dcModel
		delegate: ListNavigation {
			required property Device device

			text: device.name
			secondaryText: Services.acInputs.gensetStatusCodeToText(gensetStatus.value)

			VeQuickItem {
				id: gensetStatus
				uid: device.serviceUid + "/StatusCode"
			}

			onClicked: Global.pageManager.pushPage("/pages/settings/PageDcGenset.qml", { device: device } )
		}
	}
}
