/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property Device device

	GradientListView {
		model: VisibleItemModel {
			ListQuantityField {
				unit: VenusOS.Units_Watt
				//% "Maximum charging power limit"
				text: qsTrId("pagecontrollableloads_evcs_maximum_charging_power_limit")
				// dataItem.uid: TBD
				//% "Limiting the maximum charging power can improve simultaneity with other controllable devices."
				caption: qsTrId("pagecontrollableloads_limiting_the_maximum")
				bottomContentSizeMode: VenusOS.ListItem_BottomContentSizeMode_Compact
				captionLabel.font.pixelSize: Theme.font_size_caption
			}
		}
	}
}
