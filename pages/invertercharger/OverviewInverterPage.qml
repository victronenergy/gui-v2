/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string serviceUid

	readonly property bool isInverterCharger: isInverterChargerItem.value === 1

	VeQuickItem {
		id: isInverterChargerItem
		uid: root.serviceUid + "/IsInverterCharger"
	}

	VeQuickItem {
		id: dcCurrent

		uid: root.serviceUid + "/Dc/0/Current"
	}

	VeQuickItem {
		id: dcVoltage

		uid: root.serviceUid + "/Dc/0/Voltage"
	}

	VeQuickItem {
		id: stateOfCharge

		uid: root.serviceUid + "/Soc"
	}

	GradientListView {
		model: ObjectModel {

			ListTextItem {
				text: CommonWords.state
				secondaryText: Global.system.systemStateToText(dataItem.value)
				dataItem.uid: root.serviceUid + "/State"
			}

			ListButton {
				id: modeButton

				text: CommonWords.mode
				secondaryText: modeDialogLauncher.modeText
				onClicked: modeDialogLauncher.openDialog()

				InverterModeDialogLauncher {
					id: modeDialogLauncher
					serviceUid: root.serviceUid
				}
			}

			InverterAcOutQuantityGroup {
				bindPrefix: root.serviceUid
				isInverterCharger: root.isInverterCharger
			}

			ListTextGroup {
				readonly property quantityInfo voltage: Units.getDisplayText(VenusOS.Units_Volt, dcVoltage.value)
				readonly property quantityInfo current: Units.getDisplayText(VenusOS.Units_Amp, dcCurrent.value)
				readonly property quantityInfo soc: Units.getDisplayText(VenusOS.Units_Percentage, stateOfCharge.value)

				text: CommonWords.dc
				textModel: root.isInverterCharger
					? [ voltage.number + voltage.unit, current.number + current.unit, CommonWords.soc_with_prefix.arg(soc.number) ]
					: [ voltage.number + voltage.unit, current.number + current.unit ]
			}

			ListNavigationItem {
				text: CommonWords.product_page
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/inverter/PageInverter.qml",
						   { bindPrefix: root.serviceUid, title: root.title })
				}
			}
		}
	}
}
