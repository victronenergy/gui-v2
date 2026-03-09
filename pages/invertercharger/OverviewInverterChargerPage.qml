/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	// serviceUid can be for an inverter, vebus or acsystem service.
	property string serviceUid
	readonly property string serviceType: BackendConnection.serviceTypeFromUid(serviceUid)

	title: device.name

	Device {
		id: device
		serviceUid: root.serviceUid
	}

	VeQuickItem {
		id: dcCurrent

		uid: root.serviceUid + "/Dc/0/Current"
	}

	VeQuickItem {
		id: dcPower

		uid: root.serviceUid + "/Dc/0/Power"
	}

	VeQuickItem {
		id: dcVoltage

		uid: root.serviceUid + "/Dc/0/Voltage"
	}

	VeQuickItem {
		id: stateOfCharge

		uid: root.serviceUid + "/Soc"
	}

	VeQuickItem {
		id: isInverterChargerItem
		uid: root.serviceUid + "/IsInverterCharger"
	}

	GradientListView {
		model: VisibleItemModel {
			ListInverterChargerModeButton {
				serviceUid: root.serviceUid
			}

			ListText {
				text: CommonWords.state
				secondaryText: Global.system.systemStateToText(dataItem.value)
				dataItem.uid: root.serviceUid + "/State"
			}

			SettingsColumn {
				width: parent ? parent.width : 0
				preferredVisible: inputSettingsModel.count > 0

				Repeater {
					model: AcInputSettingsModel {
						id: inputSettingsModel
						serviceUid: root.serviceUid
					}
					delegate: ListCurrentLimitButton {
						required property AcInputSettings inputSettings

						serviceUid: root.serviceUid
						inputNumber: inputSettings.inputNumber
						inputType: inputSettings.inputType
					}
				}
			}

			BaseListLoader {
				width: parent ? parent.width : 0
				sourceComponent: root.serviceType === "inverter" ? inverterAcOutQuantityGroup
						: root.serviceType === "vebus" ? veBusAcIODisplay
						: root.serviceType === "acsystem" ? rsSystemAcIODisplay
						: null

				Component {
					id: inverterAcOutQuantityGroup
					InverterAcOutSettings {
						bindPrefix: root.serviceUid
					}
				}

				Component {
					id: veBusAcIODisplay
					VeBusAcIODisplay {
						serviceUid: root.serviceUid
					}
				}

				Component {
					id: rsSystemAcIODisplay
					RsSystemAcIODisplay {
						serviceUid: root.serviceUid
					}
				}
			}

			ListActiveAcInput {
				bindPrefix: root.serviceUid
				preferredVisible: root.serviceType !== "inverter"
			}

			ListQuantityGroup {
				text: CommonWords.dc
				model: QuantityObjectModel {
					// Power is only shown for non-inverter services.
					QuantityObject { object: root.serviceType !== "inverter" ? dcPower : null; unit: VenusOS.Units_Watt }

					QuantityObject { object: dcVoltage; unit: VenusOS.Units_Volt_DC }
					QuantityObject { object: dcCurrent; unit: VenusOS.Units_Amp }

					// SOC is shown for non-inverter services, or inverter services with IsInverterCharger=1.
					QuantityObject { object: root.serviceType !== "inverter" || isInverterChargerItem.value === 1 ? socObject : null }
				}

				QtObject {
					id: socObject
					readonly property string value: CommonWords.soc_with_prefix.arg(stateOfCharge.valid ? Units.getCombinedDisplayText(VenusOS.Units_Percentage, stateOfCharge.value) : "--")
				}
			}

			ListNavigation {
				text: CommonWords.ess
				preferredVisible: root.serviceType === "acsystem"
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsSystemEss.qml",
							{ "title": text, "bindPrefix": root.serviceUid })
				}
			}

			ListNavigation {
				text: CommonWords.product_page
				onClicked: {
					let pageUrl = ""
					if (root.serviceType === "inverter") {
						pageUrl = "/pages/settings/devicelist/inverter/PageInverter.qml"
					} else if (root.serviceType === "vebus") {
						pageUrl = "/pages/vebusdevice/PageVeBus.qml"
					} else if (root.serviceType === "acsystem") {
						pageUrl = "/pages/settings/devicelist/rs/PageRsSystem.qml"
					} else {
						console.warn("Unsupported service:", root.serviceUid)
						return
					}
					Global.pageManager.pushPage(pageUrl, { title: text, bindPrefix: root.serviceUid })
				}
			}
		}
	}
}
