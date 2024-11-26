/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

AcWidget {
	id: root

	readonly property AcInputSystemInfo inputInfo: input?.inputInfo ?? null
	property AcInput input
	readonly property bool inputOperational: input && input.operational

	title: !!inputInfo ? Global.acInputs.sourceToText(inputInfo.source) : ""
	icon.source: !!inputInfo ? Global.acInputs.sourceIcon(inputInfo.source) : ""
	rightPadding: sideGaugeLoader.active ? Theme.geometry_overviewPage_widget_sideGauge_margins : 0
	quantityLabel.dataObject: inputOperational ? input : null
	quantityLabel.leftPadding: acInputDirectionIcon.visible ? (acInputDirectionIcon.width + Theme.geometry_acInputDirectionIcon_rightMargin) : 0
	quantityLabel.acInputMode: true
	phaseCount: inputOperational ? input.phases.count : 0
	enabled: !!inputInfo
	extraContentLoader.sourceComponent: ThreePhaseDisplay {
		width: parent.width
		model: root.input.phases
		widgetSize: root.size
		inputMode: true
	}

	onClicked: {
		const inputServiceUid = BackendConnection.serviceUidFromName(root.inputInfo.serviceName, root.inputInfo.deviceInstance)
		if (root.inputInfo.serviceType === "acsystem") {
			Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsSystem.qml",
					{ "bindPrefix": inputServiceUid })
		} else if (root.inputInfo.serviceType === "vebus") {
			Global.pageManager.pushPage( "/pages/vebusdevice/PageVeBus.qml", {
				"bindPrefix": inputServiceUid
			})
		} else {
			// Assume this is on a grid/genset service
			Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcIn.qml", {
				"bindPrefix": inputServiceUid
			})
		}
	}

	Loader {
		id: sideGaugeLoader

		anchors {
			top: parent.top
			bottom: parent.bottom
			right: parent.right
			margins: Theme.geometry_overviewPage_widget_sideGauge_margins
		}
		active: root.inputOperational && root.size >= VenusOS.OverviewWidget_Size_M
		sourceComponent: ThreePhaseBarGauge {
			valueType: VenusOS.Gauges_ValueType_NeutralPercentage
			phaseModel: root.input.phases
			phaseModelProperty: "current"
			minimumValue: root.inputInfo?.minimumCurrent ?? NaN
			maximumValue: root.inputInfo?.maximumCurrent ?? NaN
			inputMode: true
			animationEnabled: root.animationEnabled
			inOverviewWidget: true
		}
	}

	Label {
		anchors {
			top: root.extraContent.top
			topMargin: Theme.geometry_overviewPage_widget_extraContent_topMargin
			left: root.extraContent.left
			leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
			right: root.extraContent.right
			rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
		}
		elide: Text.ElideRight
		text: root.inputInfo && root.inputInfo.source === VenusOS.AcInputs_InputSource_Generator
				? CommonWords.stopped
				: CommonWords.disconnected
		visible: !root.inputOperational
	}

	AcInputDirectionIcon {
		id: acInputDirectionIcon
		parent: root.quantityLabel
		anchors.verticalCenter: parent.verticalCenter
		input: root.input
	}
}
