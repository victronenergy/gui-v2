/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

OverviewWidget {
	id: root

	FilteredDeviceModel {
		id: evDevicesModel
		serviceTypes: ["ev"]
		
		onCountChanged: {
			console.log("EV devices count changed to:", count)
			if (count > 0) {
				console.log("First EV device:", deviceAt(0).serviceUid)
			}
		}
	}

	readonly property var evDevice: evDevicesModel.count > 0
							? evDevicesModel.deviceAt(0)
							: null

	onEvDeviceChanged: {
		console.log("=== evDevice changed:", evDevice ? evDevice.serviceUid : "NULL")
	}

	// Store reference to EV area for position checking
	property var evArea: null
	
	// Add a custom MouseArea to capture precise click positions
	MouseArea {
		anchors.fill: parent
		z: 1
		
		onClicked: function(mouse) {
			console.log("=== CLICK DEBUG ===")
			console.log("evDevice:", evDevice)
			console.log("evArea:", evArea)
			console.log("evArea.visible:", evArea ? evArea.visible : "evArea is null")
			
			var navigateToEvMap = false
			
			// Simple approach: if evDevice exists and click is in bottom 40% of widget, go to map
			if (evDevice && evArea && evArea.visible) {
				const evAreaTop = evArea.mapToItem(root, 0, 0).y
				console.log("Click Y:", mouse.y, "EV area starts at Y:", evAreaTop)
				
				if (mouse.y >= evAreaTop) {
					navigateToEvMap = true
					console.log("Click IN EV area")
				} else {
					console.log("Click OUTSIDE EV area")
				}
			} else {
				console.log("Skipping EV check - evDevice:", !!evDevice, "evArea:", !!evArea, "visible:", evArea ? evArea.visible : "N/A")
			}
			
			// Navigate
			if (navigateToEvMap) {
				console.log("Navigating to EV map")
				Global.pageManager.pushPage("/pages/ev/EvMapPage.qml", {
					"evServiceUid": evDevice.serviceUid,
					"evName": evDevice.name || "EV"
				})
			} else {
				console.log("Navigating to EVCS page")
				if (Global.evChargers.model.count === 1) {
					Global.pageManager.pushPage("/pages/evcs/EvChargerPage.qml",
							{ bindPrefix: Global.evChargers.model.firstObject.serviceUid })
				} else {
					Global.pageManager.pushPage("/pages/evcs/EvChargerListPage.qml")
				}
			}
		}
	}

	//: Abbreviation of Electric Vehicle Charging Station
	//% "EVCS"
	title: qsTrId("overview_widget_evcs_title")
	icon.source: "qrc:/images/icon_charging_station_24.svg"
	type: VenusOS.OverviewWidget_Type_Evcs
	preferredSize: VenusOS.OverviewWidget_PreferredSize_LargeOnly
	enabled: true
	quantityLabel.dataObject: { "power": Global.evChargers.power, "current": Global.evChargers.current }
	quantityLabel.font.pixelSize: Theme.font_size_body2
	quantityLabel.alignment: Qt.AlignLeft

	extraContentChildren: [
		Loader {
			id: contentLoader
			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin + root.rightPadding
				bottom: parent.bottom
				bottomMargin: root.verticalMargin
			}
			active: true
			
			onActiveChanged: {
				console.log("Loader active changed to:", active, "size:", root.size)
			}
			
			sourceComponent: {
				console.log("=== Evaluating sourceComponent ===")
				console.log("EVCS count:", Global.evChargers.model.count)
				
				if (Global.evChargers.model.count > 1) {
					console.log("Returning multiEvChargerComponent")
					return multiEvChargerComponent
				}
				if (Global.evChargers.model.count > 0) {
					console.log("Returning singleEvChargerComponent")
					return singleEvChargerComponent
				}
				console.log("Returning null")
				return null
			}
			
			Component.onCompleted: {
				console.log("Loader completed - active:", active, "size:", root.size)
				console.log("EVCS count:", Global.evChargers.model.count)
				console.log("sourceComponent:", sourceComponent)
				console.log("status:", status)
			}
			
			onStatusChanged: {
				console.log("Loader status changed to:", status, "active:", active)
			}
		}
	]

	Component {
		id: singleEvChargerComponent

		Column {
			readonly property var evCharger: Global.evChargers.model.deviceAt(0)
			width: parent.width
			spacing: 3

			// Row 1: Energy and charging time
			Row {
				width: parent.width
				spacing: Theme.geometry_overviewPage_widget_content_horizontalMargin / 2

				ElectricalQuantityLabel {
					width: parent.width - chargingTimeLabel.width - parent.spacing
					height: chargingTimeLabel.height
					value: evCharger.energy
					valueColor: unitColor
					alignment: Qt.AlignLeft
					unit: VenusOS.Units_Energy_KiloWattHour
				}

				Label {
					id: chargingTimeLabel
					text: {
						if (isNaN(evCharger.chargingTime) || evCharger.chargingTime < 0) {
							return "--h --m"
						}
						const duration = Utils.decomposeDuration(evCharger.chargingTime)
						return duration.h + "h " + Utils.pad(duration.m, 2) + "m"
					}
					color: Theme.color_font_secondary
					font.pixelSize: Theme.font_size_caption
					horizontalAlignment: Text.AlignRight
				}
			}

			// Row 2: Status and mode
			Row {
				width: parent.width
				spacing: Theme.geometry_overviewPage_widget_content_horizontalMargin / 2

				Label {
					width: parent.width - modeLabel.width - parent.spacing
					elide: Text.ElideRight
					text: Global.evChargers.chargerStatusToText(evCharger.status)
					color: Theme.color_font_secondary
					font.pixelSize: Theme.font_size_caption
				}

				Label {
					id: modeLabel
					text: Global.evChargers.chargerModeToText(evCharger.mode)
					color: Theme.color_font_secondary
					font.pixelSize: Theme.font_size_caption
					horizontalAlignment: Text.AlignRight
				}
			}

			// Separator line - only show when there's an EV device
			Rectangle {
				width: parent.width
				height: 1
				color: Theme.color_listItem_separator
				visible: root.evDevice !== null
			}

			// EV Section - clean styling with subtle indication it's clickable
			Item {
				id: evAreaItem
				width: parent.width
				height: evInfoColumn.height
				visible: root.evDevice !== null

				onWidthChanged: console.log("EV area width changed to:", width)
				onHeightChanged: console.log("EV area height changed to:", height)

				// Subtle hover effect with visual indication this area is clickable
				MouseArea {
					anchors.fill: parent
					hoverEnabled: true
					acceptedButtons: Qt.NoButton  // Don't capture clicks, only hover

					// Visual feedback on hover
					Rectangle {
						anchors.fill: parent
						color: Theme.color_font_primary
						opacity: parent.containsMouse ? 0.08 : 0.0
						radius: 4
						
						// Subtle border to indicate clickable area (fixed - no opacity property)
						border.width: parent.containsMouse ? 1 : 0
						border.color: Qt.rgba(Theme.color_ok.r, Theme.color_ok.g, Theme.color_ok.b, 0.3)
					}

					onContainsMouseChanged: {
						console.log("EV area hover:", containsMouse)
					}
				}

				Column {
					id: evInfoColumn
					width: parent.width
					spacing: 3

					// Row 3: EV info header with proper EV icon and model name
					Row {
						width: parent.width
						spacing: 4

						CP.ColorImage {
							source: "qrc:/images/icon_ev_24.svg"
							width: 16
							height: 16
							anchors.verticalCenter: parent.verticalCenter
							color: Theme.color_font_secondary
						}

						Label {
							text: root.evDevice && customNameItem.valid && customNameItem.value
								  ? customNameItem.value
								  : root.evDevice && root.evDevice.name
								  ? root.evDevice.name
								  : "EV"
							color: Theme.color_font_secondary
							font.pixelSize: Theme.font_size_caption
							anchors.verticalCenter: parent.verticalCenter
							elide: Text.ElideRight
							width: parent.width - parent.spacing - 16 - gpsIndicator.width - 4
						}

						// GPS indicator - small dot
						Rectangle {
							id: gpsIndicator
							width: 8
							height: 8
							radius: 4
							anchors.verticalCenter: parent.verticalCenter
							color: (latitudeItem.valid && longitudeItem.valid) ? Theme.color_ok : Theme.color_font_secondary
							opacity: 0.7
						}
					}

					// Row 4: Range and SOC info
					Row {
						width: parent.width
						spacing: Theme.geometry_overviewPage_widget_content_horizontalMargin / 2

						Label {
							text: rangeItem.valid ? Math.round(rangeItem.value) + " km" : "-- km"
							color: Theme.color_font_secondary
							font.pixelSize: Theme.font_size_caption
						}

						Item {
							// Spacer to push SOC to the right
							width: parent.width - rangeLabel.implicitWidth - socLabel.implicitWidth - (2 * parent.spacing)
							height: 1
						}

						Label {
							id: socLabel
							text: {
								const soc = socItem.valid ? Math.round(socItem.value) : NaN
								const targetSoc = targetSocItem.valid ? Math.round(targetSocItem.value) : NaN

								if (!isNaN(soc) && !isNaN(targetSoc)) {
									return soc + "/" + targetSoc + " %"
								} else if (!isNaN(soc)) {
									return soc + " %"
								} else {
									return "-- %"
								}
							}
							color: Theme.color_font_secondary
							font.pixelSize: Theme.font_size_caption
							horizontalAlignment: Text.AlignRight
						}
						
						// Hidden label for width calculation
						Label {
							id: rangeLabel
							visible: false
							text: rangeItem.valid ? Math.round(rangeItem.value) + " km" : "-- km"
							font.pixelSize: Theme.font_size_caption
						}
					}
				}
			}

			// VeQuickItems for EV data
			VeQuickItem {
				id: customNameItem
				uid: root.evDevice ? root.evDevice.serviceUid + "/CustomName" : ""
			}

			VeQuickItem {
				id: rangeItem
				uid: root.evDevice ? root.evDevice.serviceUid + "/RangeToGo" : ""
			}

			VeQuickItem {
				id: socItem
				uid: root.evDevice ? root.evDevice.serviceUid + "/Soc" : ""
			}

			VeQuickItem {
				id: targetSocItem
				uid: root.evDevice ? root.evDevice.serviceUid + "/TargetSoc" : ""
			}

			VeQuickItem {
				id: latitudeItem
				uid: root.evDevice ? root.evDevice.serviceUid + "/Position/Latitude" : ""
			}

			VeQuickItem {
				id: longitudeItem
				uid: root.evDevice ? root.evDevice.serviceUid + "/Position/Longitude" : ""
			}
		}
	}

	Component {
		id: multiEvChargerComponent

		Column {
			width: parent.width

			Repeater {
				model: EvChargerStatusModel {}

				delegate: Row {
					width: parent.width

					Label {
						width: parent.width - chargerCountLabel.implicitWidth
						elide: Text.ElideRight
						text: Global.evChargers.chargerStatusToText(model.status)
						color: Theme.color_font_secondary
					}

					Label {
						id: chargerCountLabel
						text: model.statusCount || "-"
						color: Theme.color_font_secondary
					}
				}
			}
		}
	}
}
