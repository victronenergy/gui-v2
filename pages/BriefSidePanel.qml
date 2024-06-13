/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ColumnLayout {
	id: root

	property bool animationEnabled
	property string dcInputIconSource

	BriefSidePanelWidget {
		//% "Solar yield"
		title: qsTrId("brief_solar_yield")
		icon.source: "qrc:/images/solaryield.svg"
		loadersActive: Global.solarChargers.model.count > 0 && Global.pvInverters.model.count === 0
		visible: Global.solarChargers.model.count || Global.pvInverters.model.count
		quantityLabel.dataObject: Global.system.solar
		sideComponent: SolarYieldGraph {}
	}

	// In most cases there is only 1 generator, so don't worry about other ones here.
	BriefSidePanelWidget {
		id: generatorWidget
		title: Global.generators.model.count === 1 ? Global.generators.model.firstObject.name : CommonWords.generator
		icon.source: "qrc:/images/generator.svg"
		loadersActive: Global.acInputs.activeInputInfo
				&& Global.acInputs.activeInputInfo.source === VenusOS.AcInputs_InputSource_Generator
				&& Global.acInputs.activeInput
		visible: loadersActive
		quantityLabel.dataObject: Global.acInputs.generatorInput
		sideComponent: Item {
			width: generatorLabel.width
			height: generatorLabel.height

			GeneratorIconLabel {
				id: generatorLabel

				anchors {
					right: parent.right
					bottom: parent.bottom
				}
				generator: Global.generators.model.firstObject
			}
		}
		bottomComponent: ThreePhaseBarGauge {
			width: parent.width
			height: Theme.geometry_barGauge_vertical_width_large
			orientation: Qt.Horizontal
			phaseModel: root.visible ? Global.acInputs.activeInput.phases : null
			phaseModelProperty: "current"
			minimumValue: Global.acInputs.activeInputInfo.minimumCurrent
			maximumValue: Global.acInputs.activeInputInfo.maximumCurrent
			animationEnabled: root.animationEnabled
			inputMode: true
		}
	}

	BriefSidePanelWidget {
		id: acInputWidget

		 title: loadersActive ? Global.acInputs.sourceToText(Global.acInputs.activeInputInfo.source) : ""
		 icon.source: loadersActive ? Global.acInputs.sourceIcon(Global.acInputs.activeInputInfo.source) : ""
		 quantityLabel.dataObject: Global.acInputs.activeInput
		 quantityLabel.leftPadding: acInputDirectionIcon.visible ? (acInputDirectionIcon.width + Theme.geometry_acInputDirectionIcon_rightMargin) : 0
		 quantityLabel.acInputMode: true
		 loadersActive: Global.acInputs.activeInputInfo
				 && Global.acInputs.activeInputInfo.source !== VenusOS.AcInputs_InputSource_Generator
				 && Global.acInputs.activeInput
		 visible: loadersActive

		 AcInputDirectionIcon {
			 id: acInputDirectionIcon
			 parent: acInputWidget.quantityLabel
			 anchors.verticalCenter: parent.verticalCenter
		 }

		 sideComponent: LoadGraph {
				/*
			This graph shows the current/amps that is imported/exported by the AC input. On a
			multi-phase system, the graph shows the average current per phase.

			If feed-in to grid is enabled, the graph shows imported and exported current, as in
			Graph B. Otherwise, we only show imported current, as in Graph A.

				   Graph A
				   <Current>
	Max current   1.0 |
				  0.9 |
				  0.8 |
				  0.7 |
				  0.6 |
				  0.5 |
				  0.4 |      ___________
				  0.3 |     /           \_________        (only shows imported current. '_graphShowsFeedIn' is false)
				  0.2 |____/
imported power ^  0.1 |
			 0W   0.0 |---------------------------> <Time>



				   Graph B
				   <Current>
	Max current   1.0 |
				  0.9 |
				  0.8 |       ___________ (e.g. +60A)
				  0.7 |      /           \_______
imported power ^  0.6 |     /
			  0W  0.5 |..../.......................       (shows imported and exported current. '_graphShowsFeedIn' is true)
exported power v  0.4 |   /
				  0.3 |__/  (e.g. -40A)
				  0.2 |
				  0.1 |
	Min current   0.0 |----------------------------> <Time>

				  */

			readonly property bool _graphShowsFeedIn: acInputGraphRange.minimumCurrent < 0
					&& Global.systemSettings.essFeedbackToGridEnabled
			property real _prevGraphMin
			property real _prevGraphMax

			function scaleHistoricalData(prevMin, prevMax, newMin, newMax) {
				for (let i = 0; i < model.length; ++i) {
					// Scale each amps value in the model from the old range to the new range.
					const averagePhaseCurrentAsRatio = model[i]
					const currentInAmps = Units.scaleNumber(averagePhaseCurrentAsRatio, 0, 1, prevMin, prevMax)
					model[i] = Units.scaleNumber(currentInAmps, prevMin, prevMax, newMin, newMax)
				}
			}

			active: root.animationEnabled
			aboveThresholdFillColor: Theme.color_blue   // warning color is not needed for inputs
			belowThresholdFillColor: _graphShowsFeedIn ? Theme.color_green : Theme.color_blue
			initialModelValue: _graphShowsFeedIn ? 0.5 : 0
			zeroCentered: _graphShowsFeedIn

			// For a system that only imports, no threshold is required.
			// For a system that sometimes exports (i.e. can have values below zero), the threshold
			// is the mid-point, which should be zero.
			threshold: isNaN(acInputGraphRange.maximumAboveZeroMidPoint) ? 0 : 0.5

			onNextValueRequested: {
				const graphMin = acInputGraphRange.minimumCurrent || 0
				const graphMax = acInputGraphRange.maximumCurrent || 0

				if (_prevGraphMin !== graphMin || _prevGraphMax !== graphMax) {
					// don't scale historical data if the prevMin=prevMax=0 i.e. uninitialized.
					if (_prevGraphMin !== 0 || _prevGraphMax !== 0) {
						scaleHistoricalData(_prevGraphMin, _prevGraphMax, graphMin, graphMax)
					}
					_prevGraphMin = graphMin
					_prevGraphMax = graphMax
				}
				addValue(acInputGraphRange.averagePhaseCurrentAsRatio)
			}

			AcPhasesCurrentRange {
				id: acInputGraphRange

				// If the graph values may go below zero (i.e. it shows both import and export
				// values) then use a min/max range that allows the mid-point to be zero. To do
				// this, find the maximum range to be shown above or below the mid-point.
				readonly property real maximumAboveZeroMidPoint: Global.acInputs.activeInputInfo.minimumCurrent < 0
						&& Global.acInputs.activeInputInfo.maximumCurrent > 0
					? Math.max(Math.abs(Global.acInputs.activeInputInfo.minimumCurrent), Global.acInputs.activeInputInfo.maximumCurrent)
					: NaN

				phaseModel: root.visible ? Global.acInputs.activeInput.phases : null
				minimumCurrent: isNaN(maximumAboveZeroMidPoint)
								? Global.acInputs.activeInputInfo.minimumCurrent
								: -maximumAboveZeroMidPoint
				maximumCurrent: isNaN(maximumAboveZeroMidPoint)
								? Global.acInputs.activeInputInfo.maximumCurrent
								: maximumAboveZeroMidPoint
			}
		}

		bottomComponent: ThreePhaseBarGauge {
			width: parent.width
			height: Theme.geometry_barGauge_vertical_width_large
			orientation: Qt.Horizontal
			phaseModel: root.visible ? Global.acInputs.activeInput.phases : null
			phaseModelProperty: "current"
			minimumValue: Global.acInputs.activeInputInfo.minimumCurrent
			maximumValue: Global.acInputs.activeInputInfo.maximumCurrent
			animationEnabled: root.animationEnabled
			inputMode: true
		}
	}

	BriefSidePanelWidget {
		title: Global.dcInputs.model.count === 1
				? Global.dcInputs.inputTypeToText(Global.dcInputs.model.firstObject.inputType)
				  //% "DC input"
				: qsTrId("brief_dc_input")
		icon.source: root.dcInputIconSource
		loadersActive: Global.dcInputs.model.count > 0
		visible: loadersActive
		quantityLabel.dataObject: Global.dcInputs
		sideComponent: LoadGraph {
			active: root.animationEnabled
			threshold: 0    // no threshold needed for inputs
			aboveThresholdFillColor: Theme.color_blue   // warning color is not needed for inputs
			onNextValueRequested: addValue(dcInputRange.valueAsRatio)
		}

		bottomComponent: Global.isGxDevice ? cheapGaugeDcInput : prettyGaugeDcInput

		ValueRange {
			id: dcInputRange
			value: root.visible ? Global.dcInputs.power : NaN
			maximumValue: Global.dcInputs.maximumPower
		}

		Component {
			id: cheapGaugeDcInput
			CheapBarGauge {
				orientation: Qt.Horizontal
				value: dcInputRange.valueAsRatio
				animationEnabled: root.animationEnabled
			}
		}

		Component {
			id : prettyGaugeDcInput
			BarGauge {
				orientation: Qt.Horizontal
				value: dcInputRange.valueAsRatio
				animationEnabled: root.animationEnabled
			}
		}
	}

	BriefSidePanelWidget {
		//% "AC Loads"
		title: qsTrId("brief_ac_loads")
		icon.source: "qrc:/images/acloads.svg"
		quantityLabel.dataObject: Global.system.ac.consumption
		loadersActive: true
		sideComponent: LoadGraph {
			active: root.animationEnabled
			onNextValueRequested: addValue(acLoadGraphRange.averagePhaseCurrentAsRatio)

			AcPhasesCurrentRange {
				id: acLoadGraphRange
				phaseModel: root.visible ? Global.system.ac.consumption.phases : null
				maximumCurrent: Global.system.ac.consumption.maximumCurrent
			}
		}
		bottomComponent: ThreePhaseBarGauge {
			width: parent.width
			height: Theme.geometry_barGauge_vertical_width_large
			orientation: Qt.Horizontal
			valueType: VenusOS.Gauges_ValueType_RisingPercentage
			phaseModel: root.visible ? Global.system.ac.consumption.phases : null
			phaseModelProperty: "current"
			maximumValue: Global.system.ac.consumption.maximumCurrent
			animationEnabled: root.animationEnabled
		}
	}

	BriefSidePanelWidget {
		//% "DC Loads"
		title: qsTrId("brief_dc_loads")
		icon.source: "qrc:/images/dcloads.svg"
		loadersActive: !isNaN(Global.system.dc.power)
		visible: loadersActive
		quantityLabel.dataObject: Global.system.dc
		sideComponent: LoadGraph {
			active: root.animationEnabled
			onNextValueRequested: addValue(dcLoadRange.valueAsRatio)
		}

		bottomComponent: Global.isGxDevice ? cheapGaugeDcLoad : prettyGaugeDcLoad

		ValueRange {
			id: dcLoadRange
			value: root.visible ? Global.system.dc.power : NaN
			maximumValue: Global.system.dc.maximumPower
		}

		Component {
			id: cheapGaugeDcLoad
			CheapBarGauge {
				orientation: Qt.Horizontal
				valueType: VenusOS.Gauges_ValueType_RisingPercentage
				value: dcLoadRange.valueAsRatio
				animationEnabled: root.animationEnabled
			}
		}

		Component {
			id : prettyGaugeDcLoad
			BarGauge {
				orientation: Qt.Horizontal
				valueType: VenusOS.Gauges_ValueType_RisingPercentage
				value: dcLoadRange.valueAsRatio
				animationEnabled: root.animationEnabled
			}
		}
	}
}
