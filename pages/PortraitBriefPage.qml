/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

SwipeViewPage {
	id: root

	navButtonText: CommonWords.brief_page
	navButtonIcon: "qrc:/images/brief.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/BriefPage.qml"
	backgroundColor: Theme.color_briefPage_background
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive

	GaugeModel {
		id: gaugeModel
	}

	Loader {
		id: mainGauge

		anchors {
			top: parent.top
			topMargin: Theme.geometry_page_content_verticalMargin
			horizontalCenter: parent.horizontalCenter
		}
		width: Math.min(3 * root.width / 4, root.height/2 - 2*Theme.geometry_page_content_verticalMargin)
		height: mainGauge.width
		sourceComponent: gaugeModel.count === 0 ? singleGauge : multiGauge
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load main gauge")
	}

	Component {
		id: multiGauge

		CircularMultiGauge {
			id: circularMultiGauge
			model: gaugeModel
			animationEnabled: root.animationEnabled

			BriefCenterDisplay {
				anchors.centerIn: parent
				width: parent.width - (gaugeModel.count * circularMultiGauge._stepSize) + Theme.geometry_circularMultiGauge_spacing
				showFullDetails: gaugeModel.count === 1
			}
		}
	}

	Component {
		id: singleGauge

		CircularSingleGauge {
			readonly property var properties: Gauges.tankProperties(VenusOS.Tank_Type_Battery)
			readonly property var battery: Global.system.battery

			value: visible && !isNaN(battery.stateOfCharge) ? battery.stateOfCharge : 0
			status: Theme.getValueStatus(value, properties.valueType)
			animationEnabled: root.animationEnabled
			shineAnimationEnabled: battery.mode === VenusOS.Battery_Mode_Charging && root.animationEnabled

			BriefCenterDisplay {
				anchors.centerIn: parent
				width: parent.width
				showFullDetails: true
			}
		}
	}

	ListView {
		id: gaugeListView

		anchors {
			top: mainGauge.bottom
			topMargin: spacing
			bottom: root.bottom
			left: root.left
			right: root.right
		}

		clip: true
		spacing: 10 // TODO: portrait theme constant
		model: 15

		delegate: Rectangle {
			width: parent?.width ?? 30
			height: 30
			color: "lightsteelblue"
		}
	}
}
