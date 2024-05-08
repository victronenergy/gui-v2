/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Column {
	id: root

	property bool animationEnabled
	property string dcInputIconSource

	spacing: Theme.geometry_briefPage_sidePanel_columnSpacing

	BriefMonitorWidget {
		//% "Solar yield"
		title: qsTrId("brief_solar_yield")
		icon.source: "qrc:/images/solaryield.svg"
		active: Global.solarChargers.model.count > 0 && Global.pvInverters.model.count === 0
		visible: active
		quantityLabel.dataObject: Global.system.solar
		sideComponent: SolarYieldGraph {}
	}

	// In most cases there is only 1 generator, so don't worry about other ones here.
	BriefMonitorWidget {
		id: generatorWidget
		title: Global.generators.model.count === 1 ? Global.generators.model.firstObject.name : CommonWords.generator
		icon.source: "qrc:/images/generator.svg"
		active: Global.acInputs.activeInputInfo
				&& Global.acInputs.activeInputInfo.source === VenusOS.AcInputs_InputSource_Generator
				&& Global.acInputs.activeInput
		visible: active
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

	BriefMonitorWidget {
		 title: active ? Global.acInputs.sourceToText(Global.acInputs.activeInputInfo.source) : ""
		 icon.source: active ? Global.acInputs.sourceIcon(Global.acInputs.activeInputInfo.source) : ""
		 quantityLabel.dataObject: Global.acInputs.activeInput
		 active: Global.acInputs.activeInputInfo
				 && Global.acInputs.activeInputInfo.source !== VenusOS.AcInputs_InputSource_Generator
				 && Global.acInputs.activeInput
		 visible: active
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
					&& Global.systemSettings.essFeedbackToGridEnabled()
			property real _prevGraphMin
			property real _prevGraphMax

			function scaleHistoricalData(prevMin, prevMax, newMin, newMax) {
				for (let i = 0; i < model.length; ++i) {
					// Scale each amps value in the model from the old range to the new range.
					const averagePhaseCurrentAsRatio = model[i]
					const currentInAmps = Utils.scaleNumber(averagePhaseCurrentAsRatio, 0, 1, prevMin, prevMax)
					model[i] = Utils.scaleNumber(currentInAmps, prevMin, prevMax, newMin, newMax)
				}
			}

			active: root.animationEnabled
			aboveThresholdFillColor: Theme.color_blue   // warning color is not needed for inputs
			belowThresholdFillColor: _graphShowsFeedIn ? Theme.color_green : Theme.color_blue
			initialModelValue: 0
			threshold: {
				// For a system with a min current below zero (i.e. it sometimes exports), the
				// threshold is the 0 amp mark within the min/max range.
				if (acInputGraphRange.minimumCurrent < 0) {
					const range = acInputGraphRange.maximumCurrent - acInputGraphRange.minimumCurrent
					if (range !== 0) {
						return Math.abs(acInputGraphRange.minimumCurrent) / range
					}
				}
				// For a system that only imports, no threshold is required.
				return 0
			}

			onNextValueRequested: {
				const graphMin = acInputGraphRange.minimumCurrent || 0
				const graphMax = acInputGraphRange.maximumCurrent || 0

				if (_prevGraphMin !== graphMin || _prevGraphMax !== graphMax) {
					scaleHistoricalData(_prevGraphMin, _prevGraphMax, graphMin, graphMax)
					_prevGraphMin = graphMin
					_prevGraphMax = graphMax
				}
				addValue(acInputGraphRange.averagePhaseCurrentAsRatio)
			}

			AcPhasesCurrentRange {
				id: acInputGraphRange

				phaseModel: root.visible ? Global.acInputs.activeInput.phases : null
				minimumCurrent: Global.acInputs.activeInputInfo.minimumCurrent
				maximumCurrent: Global.acInputs.activeInputInfo.maximumCurrent
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

	BriefMonitorWidget {
		title: Global.dcInputs.model.count === 1
				? Global.dcInputs.inputTypeToText(Global.dcInputs.model.firstObject.inputType)
				  //% "DC input"
				: qsTrId("brief_dc_input")
		icon.source: Global.dcInputs.model.count === 1
				? Global.dcInputs.inputTypeIcon(Global.dcInputs.model.firstObject.inputType)
				: Global.dcInputs.multiInputIcon
		active: Global.dcInputs.model.count > 0
		visible: active
		quantityLabel.dataObject: Global.dcInputs
		sideComponent: LoadGraph {
			active: root.animationEnabled
			threshold: 0    // no threshold needed for inputs
			aboveThresholdFillColor: Theme.color_blue   // warning color is not needed for inputs
			onNextValueRequested: addValue(dcInputRange.valueAsRatio)
		}
		bottomComponent: BarGauge {
			orientation: Qt.Horizontal
			value: dcInputRange.valueAsRatio
			animationEnabled: root.animationEnabled
		}

		ValueRange {
			id: dcInputRange
			value: root.visible ? Global.dcInputs.power : NaN
			maximumValue: Global.dcInputs.maximumPower
		}
	}

	BriefMonitorWidget {
		//% "AC Loads"
		title: qsTrId("brief_ac_loads")
		icon.source: "qrc:/images/acloads.svg"
		quantityLabel.dataObject: Global.system.ac.consumption
		active: true
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

	BriefMonitorWidget {
		//% "DC Loads"
		title: qsTrId("brief_dc_loads")
		icon.source: "qrc:/images/dcloads.svg"
		active: !isNaN(Global.system.dc.power)
		visible: active
		quantityLabel.dataObject: Global.system.dc
		sideComponent: LoadGraph {
			active: root.animationEnabled
			onNextValueRequested: addValue(dcLoadRange.valueAsRatio)
		}
		bottomComponent: BarGauge {
			orientation: Qt.Horizontal
			valueType: VenusOS.Gauges_ValueType_RisingPercentage
			value: dcLoadRange.valueAsRatio
			animationEnabled: root.animationEnabled
		}

		ValueRange {
			id: dcLoadRange
			value: root.visible ? Global.system.dc.power : NaN
			maximumValue: Global.system.dc.maximumPower
		}
	}
}
