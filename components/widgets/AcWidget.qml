/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	property int phaseCount
	readonly property alias extraContentLoader: extraContentLoader

	function openDevicePage(serviceUid) {
		Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcIn.qml", { bindPrefix: serviceUid })
	}

	function openDevicePageOrList(deviceModel) {
		if (deviceModel.count > 1) {
			Global.pageManager.pushPage(inputListComponent, { model: deviceModel })
		} else if (deviceModel.count === 1) {
			openDevicePage(deviceModel.firstObject.serviceUid)
		}
	}

	quantityLabel.visible: !!quantityLabel.dataObject
	preferredSize: phaseCount > 1 ? VenusOS.OverviewWidget_PreferredSize_PreferLarge : VenusOS.OverviewWidget_PreferredSize_Any

	extraContentChildren: Loader {
		id: extraContentLoader

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin + root.rightPadding
			bottom: parent.bottom
			bottomMargin: root.verticalMargin
		}
		active: root.phaseCount > 1
		states: [
			State {
				name: "extrasmall"
				when: root.size === VenusOS.OverviewWidget_Size_XS
				PropertyChanges {
					target: root.quantityLabel
					visible: !!quantityLabel.dataObject && extraContentLoader.status !== Loader.Ready // hide the total power
					font.pixelSize: Theme.font_overviewPage_widget_quantityLabel_minimumSize
				}
				PropertyChanges {
					target: extraContentLoader
					anchors.bottomMargin: root.verticalMargin / 3
				}
			},
			State {
				name: "small"
				when: root.size === VenusOS.OverviewWidget_Size_S
				PropertyChanges {
					target: root.quantityLabel
					font.pixelSize: Theme.font_overviewPage_widget_quantityLabel_smallSizeWithExtraContent
				}
				PropertyChanges {
					target: extraContentLoader
					anchors.bottomMargin: root.verticalMargin / 3
				}
			},
			State {
				name: "medium"
				when: root.size === VenusOS.OverviewWidget_Size_M
				PropertyChanges {
					target: root.quantityLabel
					font.pixelSize: extraContentLoader.status === Loader.Ready
							   ? Theme.font_overviewPage_widget_quantityLabel_minimumSize
							   : Theme.font_overviewPage_widget_quantityLabel_maximumSize
				}
			},
			State {
				name: "large"
				when: root.size === VenusOS.OverviewWidget_Size_L || root.size === VenusOS.OverviewWidget_Size_XL
				PropertyChanges {
					target: root.quantityLabel
					font.pixelSize: Theme.font_overviewPage_widget_quantityLabel_maximumSize
				}
			}
		]
	}

	Component {
		id: inputListComponent

		Page {
			property alias model: deviceListView.model

			title: root.title

			GradientListView {
				id: deviceListView

				header: QuantityGroupListHeader {
					quantityTitleModel: [
						{ text: CommonWords.power_watts, unit: VenusOS.Units_Watt },
					]
				}

				delegate: ListQuantityGroupNavigation {
					required property Device device

					text: device.name
					tableMode: true
					quantityModel: QuantityObjectModel {
						QuantityObject { object: power; unit: VenusOS.Units_Watt }
					}

					VeQuickItem {
						id: power
						uid: device.serviceUid + "/Ac/Power"
					}

					onClicked: root.openDevicePage(device.serviceUid)
				}
			}
		}
	}
}
