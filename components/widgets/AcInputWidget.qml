/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcIn.qml", {
			"title": root.input.name,
			"bindPrefix": root.input.serviceUid
		})
	}

	// If this is the currently active AC input, then fetch the measurements and phase data from
	// Global.acInputs.activeInput. Otherwise, just show the icon and title.
	property AcInputSystemInfo inputInfo
	property ActiveAcInput input: inputInfo && inputInfo.isActiveInput ? Global.acInputs.activeInput : null
	property ListModel phaseModel: input && input.connected ? input.phases : null

	type: VenusOS.OverviewWidget_Type_AcGenericInput
	title: !!inputInfo ? Global.acInputs.sourceToText(inputInfo.source) : ""
	icon.source: !!inputInfo ? Global.acInputs.sourceIcon(inputInfo.source) : ""
	rightPadding: sideGaugeLoader.active ? Theme.geometry_overviewPage_widget_sideGauge_margins : 0
	quantityLabel.dataObject: input && input.connected ? input : null
	quantityLabel.visible: input && input.connected
	enabled: true

	Loader {
		id: sideGaugeLoader

		anchors {
			top: parent.top
			bottom: parent.bottom
			right: parent.right
			margins: Theme.geometry_overviewPage_widget_sideGauge_margins
		}

		active: root.input && root.input.source !== VenusOS.AcInputs_InputSource_Generator
		sourceComponent: VerticalGauge {
			id: sideGauge

			width: Theme.geometry_overviewPage_widget_sideGauge_width
			radius: Theme.geometry_overviewPage_widget_sideGauge_radius
			backgroundColor: Theme.color_overviewPage_widget_sideGauge_background
			foregroundColor: Theme.color_overviewPage_widget_sideGauge_highlight
			animationEnabled: visible && root.animationEnabled
			value: valueRange.valueAsRatio
			visible: root.input && root.input.source !== VenusOS.AcInputs_InputSource_Generator

			ValueRange {
				id: valueRange

				value: sideGauge.visible ? root.quantityLabel.value : NaN
				maximumValue: Global.systemSettings.electricalQuantity === VenusOS.Units_Amp
					? Global.acInputs.currentLimit
					: NaN
			}
		}
	}

	extraContentChildren: [
		Loader {
			anchors.fill: parent
			active: root.input && root.size >= VenusOS.OverviewWidget_Size_L
			sourceComponent: root._generatorStopped
				 ? generatorStatusComponent
				 : root.phaseModel && root.phaseModel.count > 1 ? phaseDisplayComponent : null
		}
	]

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
					bottomMargin: root.verticalMargin
				}
				width: parent.width
				model: root.phaseModel
			}
		}
	}

	Component {
		id: generatorStatusComponent

		Label {
			x: Theme.geometry_overviewPage_widget_content_horizontalMargin
			y: Theme.geometry_overviewPage_widget_extraContent_topMargin
			width: parent ? parent.width - 2*Theme.geometry_overviewPage_widget_content_horizontalMargin : 0
			elide: Text.ElideRight
			text: CommonWords.stopped
			color: Theme.color_font_secondary
		}
	}
}
