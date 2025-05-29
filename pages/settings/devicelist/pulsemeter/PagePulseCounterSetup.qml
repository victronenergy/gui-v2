/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	property int inputNumber

	GradientListView {
		model: VisibleItemModel {
			ListVolumeUnitRadioButtonGroup {}

			ListSwitch {
				//% "Inverted"
				text: qsTrId("pulsecounter_setup_inverted")
				dataItem.uid: root.bindPrefix + "/Settings/InvertTranslation"
			}

			ListSpinBox {
				//% "Multiplier"
				text: qsTrId("pulsecounter_setup_multiplier")
				dataItem.uid: root.bindPrefix + "/Settings/Multiplier"
				decimals: 6
				stepSize: Math.pow(10, -decimals)
			}

			ListButton {
				//% "Reset counter"
				text: qsTrId("pulsecounter_setup_reset_counter")
				secondaryText: itemCount_readonly.value || 0
				onClicked: itemCount_internal.setValue(0)
				interactive: itemCount_internal.valid

				VeQuickItem {
					id: itemCount_readonly
					uid: root.bindPrefix + "/Count"
				}

				// Not valid for GX I/O Extender paths, see #2139
				VeQuickItem {
					id: itemCount_internal
					uid: Global.systemSettings.serviceUid + "/Settings/DigitalInput/" + root.inputNumber + "/Count"
				}
			}
		}
	}
}
