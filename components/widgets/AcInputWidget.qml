/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

OverviewWidget {
	id: root

	property ActiveAcInput input: Global.acInputs.activeInput
	property ListModel phaseModel: input && input.connected ? input.phases : null

	readonly property bool _generatorStopped: input
		 && input.source === VenusOS.AcInputs_InputSource_Generator
		 && Global.generators.first
		 && Global.generators.first.state === VenusOS.Generators_State_Stopped

	type: VenusOS.OverviewWidget_Type_AcInput
	title: !!input ? Global.acInputs.sourceToText(input.source) : ""
	icon.source: !!input ? Global.acInputs.sourceIcon(input.source) : ""
	rightPadding: sideGaugeLoader.active ? Theme.geometry.overviewPage.widget.sideGauge.margins : 0
	quantityLabel.dataObject: input && input.connected && !_generatorStopped ? input : null
	enabled: true

	Loader {
		id: sideGaugeLoader

		anchors {
			top: parent.top
			bottom: parent.bottom
			right: parent.right
			margins: Theme.geometry.overviewPage.widget.sideGauge.margins
		}

		active: root.input && root.input.source !== VenusOS.AcInputs_InputSource_Generator
		sourceComponent: VerticalGauge {
			id: sideGauge

			width: Theme.geometry.overviewPage.widget.sideGauge.width
			radius: Theme.geometry.overviewPage.widget.sideGauge.radius
			backgroundColor: Theme.color.overviewPage.widget.sideGauge.background
			foregroundColor: Theme.color.overviewPage.widget.sideGauge.highlight
			animationEnabled: visible && root.animationEnabled
			value: valueRange.valueAsRatio
			visible: root.input && root.input.source !== VenusOS.AcInputs_InputSource_Generator

			ValueRange {
				id: valueRange

				value: sideGauge.visible ? root.quantityLabel.value : NaN
				maximumValue: Global.systemSettings.electricalQuantity.value === VenusOS.Units_Amp
					? Global.acInputs.currentLimit
					: NaN
			}
		}
	}

	Loader {
		parent: root.extraContent
		anchors.fill: parent
		active: root.input && root.size >= VenusOS.OverviewWidget_Size_L
		sourceComponent: root._generatorStopped
			 ? generatorStatusComponent
			 : root.phaseModel && root.phaseModel.count > 1 ? phaseDisplayComponent : null
	}

	Component {
		id: phaseDisplayComponent

		// This extra container is needed because of how Loader would otherwise auto-size the
		// ThreePhaseDisplay column and mess with its vertical alignment.
		Item {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin + root.rightPadding
				bottom: parent.bottom
			}
			height: phaseDisplay.height

			ThreePhaseDisplay {
				id: phaseDisplay

				anchors {
					bottom: parent.bottom
					bottomMargin: Theme.geometry.overviewPage.widget.extraContent.bottomMargin
				}
				width: parent.width
				model: root.phaseModel
			}
		}
	}

	Component {
		id: generatorStatusComponent

		Label {
			x: Theme.geometry.overviewPage.widget.content.horizontalMargin
			y: Theme.geometry.overviewPage.widget.extraContent.topMargin
			width: parent ? parent.width - 2*Theme.geometry.overviewPage.widget.content.horizontalMargin : 0
			elide: Text.ElideRight

			//: Shows the amount of time that has passed since the generator was stopped
			//% "Stopped %1"
			text: qsTrId("overview_acinputwidget_generator_stopped")
					.arg(Utils.formatAsHHMMSS(Global.generators.first ? Global.generators.first.runtime : 0))
			color: Theme.color.font.secondary
		}
	}

	MouseArea {
		anchors.fill: parent
		onClicked: {
			Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcIn.qml", {
				"title": root.input.name,
				"bindPrefix": root.input.serviceUid
			})
		}
	}
}
