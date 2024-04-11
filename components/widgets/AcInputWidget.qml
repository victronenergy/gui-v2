/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	// If this is the currently active AC input, then fetch the measurements and phase data from
	// Global.acInputs.activeInput. Otherwise, just show icon and title with 'Disconnected' status.
	property AcInputSystemInfo inputInfo
	property ActiveAcInput input: inputInfo && inputInfo.isActiveInput ? Global.acInputs.activeInput : null
	property ListModel phaseModel: connected ? input.phases : null
	readonly property bool connected: input && input.connected
	readonly property bool isConnectedSinglePhase: connected && phaseModel && phaseModel.count === 1

	type: VenusOS.OverviewWidget_Type_AcGenericInput
	title: !!inputInfo ? Global.acInputs.sourceToText(inputInfo.source) : ""
	secondaryTitle: root.size <= VenusOS.OverviewWidget_Size_S && extraContentLoader.sourceComponent === phaseDisplayComponent
			? "(%1)".arg(Units.defaultUnitString(Global.systemSettings.electricalQuantity))
			: ""
	icon.source: !!inputInfo ? Global.acInputs.sourceIcon(inputInfo.source) : ""
	rightPadding: sideGaugeLoader.active ? Theme.geometry_overviewPage_widget_sideGauge_margins : 0
	quantityLabel.dataObject: connected ? input : null
	quantityLabel.visible: connected && (size >= VenusOS.OverviewWidget_Size_M || isConnectedSinglePhase)
	quantityLabel.font.pixelSize: size <= VenusOS.OverviewWidget_Size_S
		|| (size === VenusOS.OverviewWidget_Size_M && extraContentLoader.sourceComponent === phaseDisplayComponent)
			  ? Theme.font_overviewPage_widget_quantityLabel_minimumSize
			  : Theme.font_overviewPage_widget_quantityLabel_maximumSize
	preferLargeSize: !!phaseModel && phaseModel.count > 1
	enabled: true

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

		active: root.isConnectedSinglePhase && root.input.source !== VenusOS.AcInputs_InputSource_Generator
		sourceComponent: VerticalGauge {
			id: sideGauge

			width: Theme.geometry_overviewPage_widget_sideGauge_width
			radius: Theme.geometry_overviewPage_widget_sideGauge_radius
			backgroundColor: Theme.color_overviewPage_widget_sideGauge_background
			foregroundColor: Theme.color_overviewPage_widget_sideGauge_highlight
			animationEnabled: visible && root.animationEnabled
			value: valueRange.valueAsRatio
			visible: root.input && root.input.source !== VenusOS.AcInputs_InputSource_Generator

			DynamicValueRange {
				id: valueRange

				value: sideGauge.visible ? root.quantityLabel.value : NaN
				maximumValue: Global.systemSettings.electricalQuantity === VenusOS.Units_Amp
					? Global.acInputs.currentLimit
					: NaN
			}
		}
	}

	extraContentChildren: Loader {
		id: extraContentLoader
		anchors.fill: parent
		sourceComponent: root.connected
				? root.phaseModel && root.phaseModel.count > 1 ? phaseDisplayComponent : null
				: disconnectedComponent
	}

	Component {
		id: phaseDisplayComponent

		// This extra container is needed because of how Loader would otherwise auto-size the
		// ThreePhaseDisplay column and mess with its vertical alignment.
		Item {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin + root.rightPadding
				bottom: parent.bottom
			}
			height: phaseDisplay.height

			ThreePhaseDisplay {
				id: phaseDisplay

				anchors {
					bottom: parent.bottom
					bottomMargin: root.size <= VenusOS.OverviewWidget_Size_M
						  ? Theme.geometry_overviewPage_widget_content_small_verticalMargin
						  : root.verticalMargin
				}
				width: parent.width
				model: root.phaseModel
				widgetSize: root.size
			}
		}
	}

	Component {
		id: disconnectedComponent

		Label {
			x: Theme.geometry_overviewPage_widget_content_horizontalMargin
			y: Theme.geometry_overviewPage_widget_extraContent_topMargin
			width: parent ? parent.width - 2*Theme.geometry_overviewPage_widget_content_horizontalMargin : 0
			elide: Text.ElideRight
			text: root.inputInfo && root.inputInfo.source === VenusOS.AcInputs_InputSource_Generator
					? CommonWords.stopped
					: CommonWords.disconnected
		}
	}
}
