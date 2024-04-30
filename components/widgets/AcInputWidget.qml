/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

AcWidget {
	id: root

	// If this is the currently active AC input, then fetch the measurements and phase data from
	// Global.acInputs.activeInput. Otherwise, just show icon and title with 'Disconnected' status.
	property AcInputSystemInfo inputInfo
	property ActiveAcInput input: inputInfo && inputInfo.isActiveInput ? Global.acInputs.activeInput : null
	readonly property bool connected: input && input.connected

	type: VenusOS.OverviewWidget_Type_AcGenericInput
	title: !!inputInfo ? Global.acInputs.sourceToText(inputInfo.source) : ""
	icon.source: !!inputInfo ? Global.acInputs.sourceIcon(inputInfo.source) : ""
	rightPadding: sideGaugeLoader.active ? Theme.geometry_overviewPage_widget_sideGauge_margins : 0
	quantityLabel.dataObject: connected ? input : null
	phaseCount: connected ? input.phases.count : 0
	enabled: true
	extraContentLoader.sourceComponent: ThreePhaseDisplay {
		width: parent.width
		model: root.input.phases
		widgetSize: root.size
		inputMode: true
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcIn.qml", {
			"title": root.input.name,
			"bindPrefix": root.input.serviceUid
		})
	}

	Loader {
		id: sideGaugeLoader

		anchors {
			top: parent.top
			bottom: parent.bottom
			right: parent.right
			margins: Theme.geometry_overviewPage_widget_sideGauge_margins
		}
		active: root.connected && root.size >= VenusOS.OverviewWidget_Size_M
		sourceComponent: ThreePhaseBarGauge {
			valueType: VenusOS.Gauges_ValueType_NeutralPercentage
			phaseModel: root.input.phases
			phaseModelProperty: "current"
			minimumValue: Global.acInputs.activeInputInfo.minimumCurrent
			maximumValue: Global.acInputs.activeInputInfo.maximumCurrent
			inputMode: true
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
		visible: !root.connected
	}
}
