/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	// Get the first EV device from the global device model
	readonly property var evDevice: Global.allDevicesModel.evDevices.count > 0
									? Global.allDevicesModel.evDevices.deviceAt(0)
									: null

	onClicked: {
		// Navigate to EV device page when clicked
		if (evDevice) {
			Global.pageManager.pushPage("/pages/settings/devicelist/PageDeviceList.qml")
		}
	}

	//: Abbreviation of Electric Vehicle
	//% "EV"
	title: customNameItem.valid && customNameItem.value ? customNameItem.value : qsTrId("overview_widget_ev_title")
	// Reusing EVCS icon for now as requested
	icon.source: "qrc:/images/icon_charging_station_24.svg"
	type: VenusOS.OverviewWidget_Type_Ev
	enabled: evDevice !== null

	// Show Range as the main quantity so it's visible even in small widget sizes
	quantityLabel.value: rangeItem.valid ? rangeItem.value : NaN
	quantityLabel.unit: VenusOS.Units_None
	quantityLabel.unitText: "km"

	// VeQuickItem to access the custom name
	VeQuickItem {
		id: customNameItem
		uid: evDevice ? evDevice.serviceUid + "/CustomName" : ""
	}

	// VeQuickItem to access the range data
	VeQuickItem {
		id: rangeItem
		uid: evDevice ? evDevice.serviceUid + "/RangeToGo" : ""
	}

	// VeQuickItem to access the SOC data
	VeQuickItem {
		id: socItem
		uid: evDevice ? evDevice.serviceUid + "/Soc" : ""
	}

	extraContentChildren: [
		Loader {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin + root.rightPadding
				bottom: parent.bottom
				bottomMargin: root.verticalMargin
			}
			active: root.size >= VenusOS.OverviewWidget_Size_M && evDevice
			sourceComponent: evInfoComponent
		}
	]

	Component {
		id: evInfoComponent

		Column {
			width: parent.width
			spacing: Theme.geometry_listItem_spacing / 2

			// VeQuickItems for EV data (socItem and targetSocItem are already defined above)
			VeQuickItem {
				id: chargingStateItem
				uid: evDevice ? evDevice.serviceUid + "/ChargingState" : ""
			}

			VeQuickItem {
				id: atSiteItem
				uid: evDevice ? evDevice.serviceUid + "/AtSite" : ""
			}

			// Row 1: State of Charge
			Row {
				width: parent.width
				spacing: Theme.geometry_overviewPage_widget_content_horizontalMargin / 2

				Label {
					text: CommonWords.state_of_charge || "SoC"
					color: Theme.color_font_secondary
					width: parent.width / 2
				}

				Label {
					text: socItem.valid ? Math.round(socItem.value) + "%" : "--"
					color: Theme.color_font_primary
					horizontalAlignment: Text.AlignRight
					width: parent.width / 2 - parent.spacing
				}
			}

			// Row 2: Charging state
			Row {
				width: parent.width
				spacing: Theme.geometry_overviewPage_widget_content_horizontalMargin / 2

				Label {
					text: CommonWords.state || "State"
					color: Theme.color_font_secondary
					width: parent.width / 2
				}

				Label {
					text: {
						if (!chargingStateItem.valid) return "--"
						switch(chargingStateItem.value) {
						case 0: return "Not charging"
						case 1: return "Low power"
						case 3: return "Charging"
						case 244: return "Sustain"
						case 245: return "Wake up"
						case 256: return "Discharging"
						case 259: return "Scheduled"
						default: return "Unknown"
						}
					}
					color: Theme.color_font_primary
					horizontalAlignment: Text.AlignRight
					width: parent.width / 2 - parent.spacing
				}
			}

			// Row 3: At site indicator (if available)
			Row {
				width: parent.width
				spacing: Theme.geometry_overviewPage_widget_content_horizontalMargin / 2
				visible: atSiteItem.valid

				Label {
					text: "At site"
					color: Theme.color_font_secondary
					width: parent.width / 2
				}

				Label {
					text: atSiteItem.valid ? (atSiteItem.value === 1 ? "Yes" : "No") : "--"
					color: Theme.color_font_primary
					horizontalAlignment: Text.AlignRight
					width: parent.width / 2 - parent.spacing
				}
			}
		}
	}
}
