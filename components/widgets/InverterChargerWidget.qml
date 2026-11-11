/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

OverviewWidget {
	id: root

	onClicked: {
		if (Services.inverterChargers.deviceCount > 1) {
			Global.pageManager.pushPage("/pages/invertercharger/InverterChargerListPage.qml")
		} else if (!!Services.inverterChargers.chargerModel.firstObject) {
			// Show page for chargers
			Global.openDevicePage(Services.inverterChargers.chargerModel.firstObject.serviceUid)
		} else {
			// Show page for inverter, vebus and acsystem services
			const device = Services.inverterChargers.firstObject
			Global.pageManager.pushPage("/pages/invertercharger/OverviewInverterChargerPage.qml",
					{ "serviceUid": device.serviceUid })
		}
	}

	title: Services.system.chargerOnly ? CommonWords.charger : CommonWords.inverter_charger
	type: VenusOS.OverviewWidget_Type_VeBusDevice
	enabled: !!Services.inverterChargers.firstObject
	rightPadding: Theme.geometry_overviewPage_widget_sideGauge_margins

	contentItem: Item {
		implicitWidth: Theme.geometry_overviewPage_widget_centerWidgetWidth
		implicitHeight: contentLayout.implicitHeight

		ColumnLayout {
			id: contentLayout

			width: parent.width - sideGaugeLoader.width - Theme.geometry_overviewPage_widget_sideGauge_margins
			height: parent.height
			spacing: Theme.geometry_overviewPage_widget_content_spacing

			WidgetHeader {
				text: root.title
				icon.source: "qrc:/images/inverter_charger.svg"
				Layout.fillWidth: true
			}

			OverviewElectricalQuantityLabel {
				id: chargerQuantityLabel
				widgetSize: root.size
				visible: Services.system.chargerOnly
				dataObject: Services.system.dc.charger
				sourceType: VenusOS.ElectricalQuantity_Source_Dc
				Layout.fillWidth: true
			}

			Label {
				text: VenusOS.system_stateToText(Services.system.state)
				font.pixelSize: chargerQuantityLabel.visible ? root.secondaryFontSize
						: Theme.font_overviewPage_widget_quantityLabel_medium
				minimumPixelSize: Theme.font_overviewPage_widget_quantityLabel_small
				fontSizeMode: Text.Fit
				wrapMode: Text.WordWrap
				maximumLineCount: 4
				elide: Text.ElideRight

				Layout.fillWidth: true
				Layout.fillHeight: true // push reason text to bottom of layout
			}

			Label {
				text: systemReason.text
				wrapMode: Text.WordWrap
				color: Theme.color_font_secondary
				font.pixelSize: root.secondaryFontSize

				SystemReason {
					id: systemReason
				}
			}
		}

		Loader {
			id: sideGaugeLoader

			anchors {
				top: parent.top
				bottom: parent.bottom
				right: parent.right
			}
			sourceComponent: ThreePhaseBarGauge {
				valueType: VenusOS.Gauges_ValueType_RisingPercentage
				phaseModel: Services.system.load.ac.phases
				maximumValue: Services.acInputs.maximumAcCurrent
				animationEnabled: root.animationEnabled
						&& !Global.isGxDevice // reduce Overview animations on GX
				inOverviewWidget: true
			}
		}
	}
}
