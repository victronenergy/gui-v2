/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

AcWidget {
	id: root

	readonly property AcInputInfo inputInfo: input?.inputInfo ?? null
	readonly property bool inputOperational: input && input.operational

	readonly property bool _showSideGauge: inputOperational && size >= VenusOS.OverviewWidget_Size_M

	rightPadding: _showSideGauge ? Theme.geometry_overviewPage_widget_sideGauge_margins
			: Theme.geometry_overviewPage_widget_content_horizontalMargin
	title: !!inputInfo ? Services.acInputs.sourceToText(inputInfo.source) : ""
	quantitySourceType: VenusOS.ElectricalQuantity_Source_AcInputOnly
	quantityDataObject: inputOperational ? input : null
	phaseModel: inputOperational && (input.phases?.count ?? 0) > 1 ? input.phases : null
	enabled: !!inputInfo

	contentItem: Item {
		implicitWidth: Theme.geometry_overviewPage_widget_leftWidgetWidth
		implicitHeight: contentLayout.implicitHeight

		AcWidgetContent {
			id: contentLayout

			width: parent.width - (sideGaugeLoader.active ? sideGaugeLoader.width + Theme.geometry_overviewPage_widget_sideGauge_margins : 0)
			height: parent.height
			widget: root
			iconSource: !!root.inputInfo ? Services.acInputs.sourceIcon(root.inputInfo.source) : ""
			stateText: root.inputOperational ? ""
					: root.inputInfo && root.inputInfo.source === VenusOS.AcInputs_InputSource_Generator ? CommonWords.stopped
					: CommonWords.disconnected
		}

		Loader {
			id: sideGaugeLoader

			anchors {
				top: parent.top
				bottom: parent.bottom
				right: parent.right
			}
			active: root._showSideGauge
			sourceComponent: ThreePhaseBarGauge {
				valueType: VenusOS.Gauges_ValueType_NeutralPercentage
				phaseModel: root.input.phases
				minimumValue: root.inputInfo?.minimumCurrent ?? NaN
				maximumValue: root.inputInfo?.maximumCurrent ?? NaN
				inputMode: true
				animationEnabled: root.animationEnabled
						&& !Global.isGxDevice // reduce Overview animations on GX
				inOverviewWidget: true
			}
		}
	}

	onClicked: {
		if (Services.system.chargerOnly
				&& root.input.serviceType === "charger"
				&& Services.inverterChargers.chargerModel.count > 1) {
			// In a "Charger only" system configuration, if this widget is showing the charger
			// details and there are multiple chargers, show a list instead of a single device.
			Global.pageManager.pushPage("/pages/invertercharger/InverterChargerListPage.qml")
		} else {
			Global.openDevicePage(root.input.serviceUid)
		}
	}
}
