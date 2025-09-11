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

	// Hide the default quantity label - we'll show our custom layout instead
	quantityLabel.visible: false

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

	// VeQuickItem to access the target SOC data
	VeQuickItem {
		id: targetSocItem
		uid: evDevice ? evDevice.serviceUid + "/TargetSoc" : ""
	}

	extraContentChildren: [
		Loader {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin + root.rightPadding
				top: parent.top
				topMargin: root.verticalMargin
			}
			active: evDevice  // Always show when EV device is present
			sourceComponent: evInfoComponent
		}
	]

	Component {
		id: evInfoComponent

		// Single row showing both range and SOC info side by side
		Row {
			width: parent.width

			Row {
				id: rangeDisplay
				spacing: 4
				anchors.verticalCenter: parent.verticalCenter

				Label {
					text: rangeItem.valid ? Math.round(rangeItem.value).toString() : "--"
					color: Theme.color_font_primary  // White number
					font.pixelSize: Theme.font_size_body1
					anchors.verticalCenter: parent.verticalCenter
				}

				Label {
					text: "km"
					color: Theme.color_font_secondary  // Grey unit
					font.pixelSize: Theme.font_size_body1
					anchors.verticalCenter: parent.verticalCenter
				}
			}

			Item {
				// Spacer to push SOC info to the right
				width: parent.width - rangeDisplay.width - socDisplay.width
				height: 1
			}

			Row {
				id: socDisplay
				spacing: 0
				anchors.verticalCenter: parent.verticalCenter

				Label {
					text: socItem.valid ? Math.round(socItem.value).toString() : "--"
					color: Theme.color_font_primary  // White number
					font.pixelSize: Theme.font_size_body1
					anchors.verticalCenter: parent.verticalCenter
				}

				Label {
					text: "/"
					color: Theme.color_font_secondary  // Grey separator
					font.pixelSize: Theme.font_size_body1
					anchors.verticalCenter: parent.verticalCenter
				}

				Label {
					text: targetSocItem.valid ? Math.round(targetSocItem.value).toString() : "--"
					color: Theme.color_font_primary  // White number
					font.pixelSize: Theme.font_size_body1
					anchors.verticalCenter: parent.verticalCenter
				}

				Label {
					text: "%"
					color: Theme.color_font_secondary  // Grey unit
					font.pixelSize: Theme.font_size_body1
					anchors.verticalCenter: parent.verticalCenter
				}
			}
		}
	}
}