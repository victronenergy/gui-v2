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
				onClicked: itemCount.setValue(0)
				interactive: itemCount.valid

				VeQuickItem {
					id: itemCount_readonly
					uid: root.bindPrefix + "/Count"
				}

				VeQuickItem {
					id: itemCount
					uid: Global.systemSettings.serviceUid + "/Settings/DigitalInput/"
						+ (mgmtConnection.ioextId.length > 0 ? mgmtConnection.ioextId : root.inputNumber)
						+ "/Count"
				}

				// Determine settings prefix for GX I/O Extender paths, see #2139
				VeQuickItem {
					id: mgmtConnection
					uid: root.bindPrefix + "/Mgmt/Connection"
					readonly property string inputPath: mgmtConnection.valid ? mgmtConnection.value : ""
					readonly property string ioextPrefix: "/run/io-ext/"
					readonly property string ioextId: (inputPath.length > 0 && inputPath.indexOf(ioextPrefix) >= 0)
						? inputPath.substring(ioextPrefix.length).replace("/", "_")
						: ""
				}
			}
		}
	}
}
