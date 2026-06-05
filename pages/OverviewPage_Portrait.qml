/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	Shows the Overview layout vertically, in three sections.

	- Top section: inputs (AC/DC inputs, solar)
	- Middle section: battery and inverter/charger
	- Bottom section: loads and consumption (AC/Essential/DC loads, EVCS)
*/
FocusScope {
	id: root

	required property bool animationEnabled

	// The maximum number of widgets currently shown in the vertical space. This is the sum of the
	// max column count from all three sections.
	readonly property int maximumColumnCount: inputLayout.maximumColumnCount
			+ 1 // middle section
			+ loadsLayout.maximumColumnCount

	// Returns the ideal widget size based on the number of widgets in a column of a section.
	// For example, if the AC input column has two widgets, this returns a smaller size than if
	// there was only one widget.
	function _widgetSizeForSectionColumnCount(widgetColumnCount, stretchHorizontally) {
		// If all widgets could be L size and they would all still fit within the vertical space,
		// then use L size for all of them.
		if (Theme.geometry_overviewPage_widget_height_l * maximumColumnCount
				+ (2 * Theme.geometry_overviewPage_energyIndicator_height) < root.height) {
			return VenusOS.OverviewWidget_Size_L
		}

		// When stretching a widget horizontally, use L size so that the phase measurements
		// on the right fill up the available space.
		if (stretchHorizontally) {
			return VenusOS.OverviewWidget_Size_M
		}

		// Return widget size based on widget count in the column.
		if (widgetColumnCount > 2) {
			return VenusOS.OverviewWidget_Size_XS
		} else if (widgetColumnCount > 1) {
			return VenusOS.OverviewWidget_Size_M
		} else {
			return VenusOS.OverviewWidget_Size_L
		}
	}

	function _widgetHeightForSize(widgetSize) {
		switch (widgetSize) {
		case VenusOS.OverviewWidget_Size_Zero: return 0
		case VenusOS.OverviewWidget_Size_XS: return Theme.geometry_overviewPage_widget_height_xs
		case VenusOS.OverviewWidget_Size_S: return Theme.geometry_overviewPage_widget_height_s
		case VenusOS.OverviewWidget_Size_M: return Theme.geometry_overviewPage_widget_height_m
		case VenusOS.OverviewWidget_Size_L: return Theme.geometry_overviewPage_widget_height_l
		case VenusOS.OverviewWidget_Size_XL: return 0 // unused in portrait
		}
	}

	// For the columns with phase measurements (i.e. the AC input column and the AC/Essential loads
	// and EVCS column), if the adjacent column is empty, then this column will horizontally be
	// stretched across the whole section. In this case, if this column has more than one widget,
	// then set the widget orientation to Qt.Horizontal so that phase measurements are shown on the
	// right of the widget, rather than below the widget's QuantityLabel.
	function _stretchWidgetHorizontally(widgetColumnCount, adjacentColumnCount) {
		if (maximumColumnCount <= 4) {
			// There are not many widgets on the page, so use a vertical widget orientation,
			// otherwise the phases will be on the right and there will be too much space at the
			// bottom of the widget (since they stretch vertically to fill the available space).
			return false
		}
		if (adjacentColumnCount === 0 && widgetColumnCount > 1) {
			return true
		}
		return false
	}

	// Cannot bind to mainLayout.height for this, as that value refers to the theoretical height
	// where widgets are expanded to their full heights.
	implicitHeight: inputLayout.height + centreLayout.height + loadsLayout.height
			+ (2 * Theme.geometry_overviewPage_energyIndicator_height)

	OverviewLayoutConditions {
		id: layoutConditions
	}

	ColumnLayout {
		id: mainLayout

		x: Theme.geometry_page_content_horizontalMargin
		width: parent.width - (2 * Theme.geometry_page_content_horizontalMargin)
		height: parent.height
		spacing: 0

		// Input layout contains:
		// |  DC inputs, Solar  |  AC inputs (Grid/Shore/Genset)  |
		RowLayout {
			id: inputLayout

			readonly property int maximumColumnCount: Math.max(leftInputColumn.widgetCount, rightInputColumn.widgetCount)

			spacing: Theme.geometry_overviewPage_widget_spacing
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.verticalStretchFactor: maximumColumnCount
					// If the AC inputs are compressed, reduce the stretch factor.
					- (rightInputColumn.stretchHorizontally ? 1 : 0)

			ColumnLayout {
				id: leftInputColumn

				readonly property int widgetCount: widgetCountWithoutDcsource + (combineDcSources ? 1 : dcSourceModel.count)
				readonly property int widgetSize: root._widgetSizeForSectionColumnCount(widgetCount)

				// For dcsource inputs, if we can create one widget per meter type and still fit
				// them into the left hand side (i.e. if there are no more than 3 widgets overall),
				// then do that. Otherwise, combine them into the one widget.
				readonly property int widgetCountWithoutDcsource: (layoutConditions.showSolar ? 1 : 0)
						  // There is only one widget per service type.
						+ (dcgensetModel.count ? 1 : 0)
						+ (alternatorModel.count ? 1 : 0)
						+ (fuelcellModel.count ? 1 : 0)
				readonly property bool combineDcSources: dcSourceModel.count > 0
						&& widgetCountWithoutDcsource + dcSourceModel.count > 3

				spacing: Theme.geometry_overviewPage_widget_spacing
				visible: widgetCount > 0

				Loader {
					id: solarWidgetLoader

					active: layoutConditions.showSolar
					visible: active
					sourceComponent: SolarYieldWidget {
						size: leftInputColumn.widgetSize
						animationEnabled: root.animationEnabled
					}
					onStatusChanged: if (status === Loader.Error) console.warn("Unable to load solar widget")

					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.minimumHeight: root._widgetHeightForSize(leftInputColumn.widgetSize)
				}

				// For non-dcsource DC inputs, show one widget per service type.
				DcMeterDeviceModel {
					id: dcgensetModel
					serviceTypes: ["dcgenset"]
				}
				DcMeterDeviceModel {
					id: alternatorModel
					serviceTypes: ["alternator"]
				}
				DcMeterDeviceModel {
					id: fuelcellModel
					serviceTypes: ["fuelcell"]
				}
				Repeater {
					model: [dcgensetModel, alternatorModel, fuelcellModel]
					delegate: Loader {
						required property DcMeterDeviceModel modelData

						active: modelData.count > 0
						visible: active
						sourceComponent: DcInputWidget {
							type: root.Global.dcInputs.overviewWidgetTypeForService(serviceType, modelData.commonMeterType)
							serviceType: modelData.serviceTypes[0] || ""
							inputTypeFilter: modelData.commonMeterType
							size: leftInputColumn.widgetSize
							animationEnabled: root.animationEnabled
						}
						onStatusChanged: if (status === Loader.Error) console.warn("Unable to load dc input widget for type " + modelData.commonMeterType)

						Layout.fillWidth: true
						Layout.fillHeight: true
						Layout.minimumHeight: root._widgetHeightForSize(leftInputColumn.widgetSize)
					}
				}

				DcMeterDeviceModel {
					id: dcSourceModel
					serviceTypes: ["dcsource"]
				}
				Loader {
					id: combinedDcsourceWidgetLoader

					active: leftInputColumn.combineDcSources
					visible: active
					sourceComponent: DcInputWidget {
						type: root.Global.dcInputs.overviewWidgetTypeForService(serviceType, dcSourceModel.commonMeterType)
						serviceType: "dcsource"
						inputTypeFilter: dcSourceModel.commonMeterType
						size: leftInputColumn.widgetSize
						animationEnabled: root.animationEnabled
					}
					onStatusChanged: if (status === Loader.Error) console.warn("Unable to load combined dc input widget")

					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.minimumHeight: root._widgetHeightForSize(leftInputColumn.widgetSize)
				}
				Repeater {
					id: individualDcsourcesRepeater

					model: leftInputColumn.combineDcSources ? null : dcSourceModel
					delegate: Loader {
						id: dcsourceWidgetLoader

						required property Device device
						required property int meterType

						sourceComponent: DcInputWidget {
							type: root.Global.dcInputs.overviewWidgetTypeForService(serviceType, dcsourceWidgetLoader.meterType)
							serviceType: dcsourceWidgetLoader.device.serviceType
							inputTypeFilter: dcsourceWidgetLoader.meterType
							size: leftInputColumn.widgetSize
							animationEnabled: root.animationEnabled
						}
						onStatusChanged: if (status === Loader.Error) console.warn("Unable to load dc source widget for type " + dcsourceWidgetLoader.meterType)

						Layout.fillWidth: true
						Layout.fillHeight: true
						Layout.minimumHeight: root._widgetHeightForSize(leftInputColumn.widgetSize)
					}
				}
			}

			// Use a GridLayout instead of a ColumnLayout so that the item order can be swapped
			// easily when swapInputs=true.
			GridLayout {
				id: rightInputColumn

				readonly property int widgetCount: (!!Global.acInputs.input1 ? 1 : 0) + (!!Global.acInputs.input2 ? 1 : 0)

				readonly property bool stretchHorizontally: root._stretchWidgetHorizontally(widgetCount, leftInputColumn.widgetCount)
				readonly property int displayWidgetSize: root._widgetSizeForSectionColumnCount(widgetCount, stretchHorizontally)

				// If widgets are stretched horizontally, compress the height to standard XS size
				// so other widgets can expand more vertically.
				readonly property real minimumWidgetHeight: stretchHorizontally
						? root._widgetHeightForSize(VenusOS.OverviewWidget_Size_XS)
						: root._widgetHeightForSize(displayWidgetSize)

				// Prefer to show the Grid/Shore AC input first, so swap the display order if needed.
				readonly property bool swapInputs: (Global.acInputs.isGridOrShore(Global.acInputs.input2)
													&& !Global.acInputs.isGridOrShore(Global.acInputs.input1))

				rowSpacing: Theme.geometry_overviewPage_widget_spacing
				columns: 1
				visible: widgetCount > 0

				Loader {
					id: acInput1Loader

					active: !!Global.acInputs.input1
					visible: active
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.minimumHeight: rightInputColumn.minimumWidgetHeight
					Layout.row: rightInputColumn.swapInputs ? 1 : 0

					sourceComponent: AcInputWidget {
						input: Global.acInputs.input1
						type: VenusOS.OverviewWidget_Type_AcInputPriority
						size: rightInputColumn.displayWidgetSize
						stretchHorizontally: rightInputColumn.stretchHorizontally
						animationEnabled: root.animationEnabled
					}
					onStatusChanged: if (status === Loader.Error) console.warn("Unable to load ac input widget")
				}

				Loader {
					id: acInput2Loader

					active: !!Global.acInputs.input2
					visible: active
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.minimumHeight: rightInputColumn.minimumWidgetHeight
					Layout.row: rightInputColumn.swapInputs ? 0 : 1

					sourceComponent: AcInputWidget {
						input: Global.acInputs.input2
						type: VenusOS.OverviewWidget_Type_AcInputOther
						size: rightInputColumn.displayWidgetSize
						stretchHorizontally: rightInputColumn.stretchHorizontally
						animationEnabled: root.animationEnabled
					}
					onStatusChanged: if (status === Loader.Error) console.warn("Unable to load ac input2 widget")
				}
			}
		}

		// Energy indicators between the top and middle widgets.
		RowLayout {
			spacing: Theme.geometry_overviewPage_widget_spacing
			visible: leftInputColumn.widgetCount > 0 || rightInputColumn.widgetCount > 0

			// Energy from DC inputs or PV chargers to battery.
			OverviewEnergyIndicator {
				// Show indicator when DC inputs or PV chargers are present.
				opacity: Global.dcInputs.model.count > 0 || Global.solarInputs.devices.count > 0 ? 1 : 0

				// Positive power means energy is flowing towards battery (downwards). It never
				// flows in the opposite direction.
				animationMode: !root.animationEnabled
						|| (Global.dcInputs.power <= Theme.geometry_overviewPage_connector_animationPowerThreshold
						   && Global.system.solar.dcPower <= Theme.geometry_overviewPage_connector_animationPowerThreshold)
					? VenusOS.WidgetConnector_AnimationMode_NotAnimated
					: VenusOS.WidgetConnector_AnimationMode_StartToEnd
				Layout.fillWidth: true
			}

			// Energy between AC inputs or PV inverters and the Inverter/charger.
			OverviewEnergyIndicator {
				// Prefer to monitor the power of the highlighted AC input, or otherwise any
				// connected input.
				readonly property AcInput monitoredAcInput: Global.acInputs.highlightedInput?.connected ? Global.acInputs.highlightedInput
						: Global.acInputs.input1?.connected ? Global.acInputs.input1
						: Global.acInputs.input2?.connected ? Global.acInputs.input2
						: null
				readonly property real acInputPower: monitoredAcInput?.power ?? NaN

				// Show indicator when highlighted AC input or PV inverters are present.
				opacity: !!Global.acInputs.highlightedInput || Global.solarInputs.pvInverterDevices.count > 0 ? 1 : 0

				// Positive power means energy is flowing towards inverter/charger (downwards) and
				// negative power means energy is flowing towards the input (upwards, only
				// applicable for AC inputs, not for PV inverters).
				// (If AC input has negative energy, flow upwards and ignore the PV inverter power.)
				animationMode: !root.animationEnabled
						|| (Math.abs(acInputPower) <= Theme.geometry_overviewPage_connector_animationPowerThreshold
						   && Global.system.solar.acPower <= Theme.geometry_overviewPage_connector_animationPowerThreshold)
					? VenusOS.WidgetConnector_AnimationMode_NotAnimated
					: acInputPower < 0 ? VenusOS.WidgetConnector_AnimationMode_EndToStart
					: VenusOS.WidgetConnector_AnimationMode_StartToEnd
				Layout.fillWidth: true
			}
		}

		RowLayout {
			id: centreLayout

			spacing: Theme.geometry_overviewPage_widget_spacing
			Layout.fillHeight: true
			Layout.verticalStretchFactor: 1

			BatteryWidget {
				id: batteryWidget

				size: VenusOS.OverviewWidget_Size_L
				animationEnabled: root.animationEnabled

				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.minimumHeight: Theme.geometry_overviewPage_widget_height_l
			}

			InverterChargerWidget {
				id: inverterChargerWidget

				size: VenusOS.OverviewWidget_Size_L
				animationEnabled: root.animationEnabled

				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.minimumHeight: Theme.geometry_overviewPage_widget_height_l
			}
		}

		// Energy indicators between the middle and bottom widgets.
		RowLayout {
			spacing: Theme.geometry_overviewPage_widget_spacing

			// Energy between Battery and DC loads.
			OverviewEnergyIndicator {
				// Show indicator when DC loads are shown.
				opacity: layoutConditions.showDcLoads ? 1 : 0

				// If load power is positive (i.e. consumed energy), energy flows to load (downwards).
				// If load power is negative (i.e. devices generating power but not directly managed
				// by GX), energy flows to battery (upwards).
				animationMode: root.animationEnabled
						&& !isNaN(Global.system.dc.power)
						&& (Math.abs(Global.system.dc.power) > Theme.geometry_overviewPage_connector_animationPowerThreshold)
					? (Global.system.dc.power > 0
						? VenusOS.WidgetConnector_AnimationMode_StartToEnd
						: VenusOS.WidgetConnector_AnimationMode_EndToStart)
					: VenusOS.WidgetConnector_AnimationMode_NotAnimated
				Layout.fillWidth: true
			}

			// Energy between Inverter/Charger and AC/Essential loads.
			OverviewEnergyIndicator {
				// Show indicator when AC/Essential loads or EVCS widget are shown.
				opacity: layoutConditions.showAcLoads
						 || layoutConditions.showEssentialLoads
						 || layoutConditions.showEvChargers ? 1 : 0

				// If load power is positive (i.e. consumed energy), energy flows to load (downwards).
				// In portrait, there is only one energy indicator for AC/Essential loads and EVCS,
				// so do not distinguish between AC-in/AC-out loads; just use the overall AC load.
				animationMode: !root.animationEnabled
						|| Math.abs(Global.system.load.ac.power) <= Theme.geometry_overviewPage_connector_animationPowerThreshold
					? VenusOS.WidgetConnector_AnimationMode_NotAnimated
					: VenusOS.WidgetConnector_AnimationMode_StartToEnd
				Layout.fillWidth: true
			}
		}

		RowLayout {
			id: loadsLayout

			readonly property int maximumColumnCount: Math.max(layoutConditions.showDcLoads ? 1 : 0, rightLoadsColumn.widgetCount)

			spacing: Theme.geometry_overviewPage_widget_spacing
			Layout.fillHeight: true
			Layout.verticalStretchFactor: maximumColumnCount

			Loader {
				id: dcLoadsWidgetLoader

				active: layoutConditions.showDcLoads
				visible: active
				sourceComponent: DcLoadsWidget {
					size: VenusOS.OverviewWidget_Size_L
					animationEnabled: root.animationEnabled
				}
				onStatusChanged: if (status === Loader.Error) console.warn("Unable to load dc loads widget")

				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.minimumHeight: root._widgetHeightForSize(VenusOS.OverviewWidget_Size_L)
			}

			ColumnLayout {
				id: rightLoadsColumn

				readonly property int widgetCount: (layoutConditions.showAcLoads ? 1 : 0)
						+ (layoutConditions.showEssentialLoads ? 1 : 0)
						+ (layoutConditions.showEvChargers ? 1 : 0)

				readonly property bool stretchHorizontally: root._stretchWidgetHorizontally(widgetCount, layoutConditions.showDcLoads ? 1 : 0)
				readonly property int displayWidgetSize: root._widgetSizeForSectionColumnCount(widgetCount, stretchHorizontally)

				// If widgets are stretched horizontally, compress the height to standard XS size
				// so other widgets can expand more vertically.
				readonly property real minimumWidgetHeight: stretchHorizontally
						? root._widgetHeightForSize(VenusOS.OverviewWidget_Size_XS)
						: root._widgetHeightForSize(displayWidgetSize)

				spacing: Theme.geometry_overviewPage_widget_spacing

				Loader {
					id: acLoadsWidgetLoader

					active: layoutConditions.showAcLoads
					visible: active
					sourceComponent: AcLoadsWidget {
						size: rightLoadsColumn.displayWidgetSize
						stretchHorizontally: rightLoadsColumn.stretchHorizontally
						animationEnabled: root.animationEnabled
					}
					onStatusChanged: if (status === Loader.Error) console.warn("Unable to load ac loads widget")

					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.minimumHeight: rightLoadsColumn.minimumWidgetHeight
				}
				Loader {
					id: essentialLoadsWidgetLoader

					active: layoutConditions.showEssentialLoads
					visible: active
					sourceComponent: EssentialLoadsWidget {
						size: rightLoadsColumn.displayWidgetSize
						stretchHorizontally: rightLoadsColumn.stretchHorizontally
						animationEnabled: root.animationEnabled
					}
					onStatusChanged: if (status === Loader.Error) console.warn("Unable to load essential loads widget")

					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.minimumHeight: rightLoadsColumn.minimumWidgetHeight
				}

				Loader {
					id: evcsWidgetLoader

					active: layoutConditions.showEvChargers
					visible: active
					sourceComponent: EvcsWidget {
						size: rightLoadsColumn.displayWidgetSize
						stretchHorizontally: rightLoadsColumn.stretchHorizontally
						animationEnabled: root.animationEnabled
					}
					onStatusChanged: if (status === Loader.Error) console.warn("Unable to load evcs widget")

					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.minimumHeight: rightLoadsColumn.minimumWidgetHeight
				}
			}
		}
	}
}
