/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

SwipeViewPage {
	id: root

	property var _leftWidgets: []
	readonly property var _centerWidgets: [inverterChargerWidget, batteryWidget]
	property var _rightWidgets: []

	property Item _lastFocusedWidget
	property Item _lastFocusedLeftWidget
	property Item _lastFocusedCenterWidget
	property Item _lastFocusedRightWidget

	// Preferred order for the input widgets on the left hand side. When placing widgets, avoid / minimize connectors crossing each other.
	readonly property var _leftWidgetOrder: [
		// Top widgets: these widgets have to be up the top, as they connect to the 'inverter/charger widget', which is at the top of the center column.
		VenusOS.OverviewWidget_Type_AcInputPriority,
		VenusOS.OverviewWidget_Type_AcInputOther,
		// End top widgets

		// Middle widgets: these widgets can connect to both the inverter/charger widget and the battery widget in the center column.
		// They need to be in the middle so as to avoid connectors crossing.
		VenusOS.OverviewWidget_Type_Solar,
		// End middle widgets

		// Bottom widgets: these widgets only connect to the battery, which is at the bottom of the center column.
		VenusOS.OverviewWidget_Type_DcGenerator,
		VenusOS.OverviewWidget_Type_Alternator,
		VenusOS.OverviewWidget_Type_FuelCell,
		VenusOS.OverviewWidget_Type_Wind
		// End bottom widgets
	]

	// Set a counter that updates whenever the layout should change.
	// Use a delayed binding to avoid repopulating the model unnecessarily.
	readonly property int _shouldResetWidgets: Global.dcInputs.model.count
			+ Global.acInputs.activeInSource
			+ (Global.acInputs.input1?.operational ? 1 : 0)
			+ (Global.acInputs.input2?.operational ? 1 : 0)
			+ (Global.system.showInputLoads ? 1 : 0)
			+ (Global.system.hasAcOutSystem ? 1 : 0)
			+ (Global.allDevicesModel.combinedDcLoadDevices.count > 0 || !isNaN(Global.system.dc.power) ? 1 : 0)
			+ (Global.solarDevices.model.count === 0 ? 0 : 1)
			+ (Global.evChargers.model.count === 0 ? 0 : 1)
			+ Global.evChargers.acInputPositionCount
			+ Global.evChargers.acOutputPositionCount
			+ (Global.pvInverters.model.count === 0 ? 0 : 1)
	on_ShouldResetWidgetsChanged: Qt.callLater(_resetWidgets)
	Component.onCompleted: Qt.callLater(_resetWidgets)

	property var _createdWidgets: ({})

	property bool _expandLayout: !!Global.pageManager && Global.pageManager.expandLayout
	property bool _animateGeometry: root.isCurrentPage && !!Global.pageManager && Global.pageManager.animatingIdleResize
	property int _evcsChangeToken

	// Resets the layout, setting the y pos and height for all overview widgets. This is done once
	// imperatively, instead of using anchors or y/height bindings, so that widget connector path
	// calculations are also only done once; otherwise, the recalculation/repainting of the paths
	//  and path animations is very expensive and creates jerky animations on device.
	function _resetWidgets() {
		width = Theme.geometry_screen_width

		// Reset the left/right widgets that should be shown
		for (let widgetType in _createdWidgets) {
			_createdWidgets[widgetType].size = VenusOS.OverviewWidget_Size_Zero
		}
		_resetLeftWidgets()
		_resetRightWidgets()

		// Set the widget sizes
		_resetWidgetSizes(_leftWidgets)
		_resetWidgetSizes(_rightWidgets)

		// Set the widget positions
		resetWidgetPositions(_leftWidgets)
		resetWidgetPositions(_centerWidgets)
		resetWidgetPositions(_rightWidgets)

		// Initialize the widget connector geometry
		resetWidgetConnectors(_leftWidgets)
		resetWidgetConnectors(_centerWidgets)
		resetWidgetConnectors(_rightWidgets)

		// Set the key navigation bindings
		resetWidgetKeyNavigation(_leftWidgets)
		resetWidgetKeyNavigation(_centerWidgets)
		resetWidgetKeyNavigation(_rightWidgets)
	}

	function _resetWidgetSizes(widgets) {
		let i = 0
		let preferLargeWidgetCount = 0
		let largeOnlyWidgetCount = 0
		let widget = null
		for (i = 0; i < widgets.length; ++i) {
			if (widgets[i].preferredSize === VenusOS.OverviewWidget_PreferredSize_PreferLarge) {
				preferLargeWidgetCount++
			} else if (widgets[i].preferredSize === VenusOS.OverviewWidget_PreferredSize_LargeOnly) {
				largeOnlyWidgetCount++
			}
		}
		if (largeOnlyWidgetCount > 1) {
			console.warn("Warning: layout does not handle > 1 widget with OverviewWidget_PreferredSize_LargeOnly")
		}

		for (i = 0; i < widgets.length; ++i) {
			widget = widgets[i]
			switch (widgets.length) {
			case 1:
				widget.size = VenusOS.OverviewWidget_Size_XL
				break
			case 2:
				widget.size = VenusOS.OverviewWidget_Size_L
				break
			case 3:
			case 4:
				if (largeOnlyWidgetCount === 1 || preferLargeWidgetCount === 1) {
					// One widget must have L size, or only one widget prefers L size.
					// In this case, use L for that one widget, and S/XS for the others.
					const smallWidgetSize = widgets.length === 3 ? VenusOS.OverviewWidget_Size_S : VenusOS.OverviewWidget_Size_XS
					if (largeOnlyWidgetCount === 1) {
						widget.size = widget.preferredSize === VenusOS.OverviewWidget_PreferredSize_LargeOnly
								? VenusOS.OverviewWidget_Size_L
								: smallWidgetSize
					} else {
						widget.size = widget.preferredSize === VenusOS.OverviewWidget_PreferredSize_PreferLarge
								? VenusOS.OverviewWidget_Size_L
								: smallWidgetSize
					}
				} else if (preferLargeWidgetCount === 2) {
					// If two prefer L size, then use M for those, and X/XS otherwise.
					widget.size = widget.preferredSize === VenusOS.OverviewWidget_PreferredSize_PreferLarge
							? VenusOS.OverviewWidget_Size_M
							: (widgets.length === 3 ? VenusOS.OverviewWidget_Size_S : VenusOS.OverviewWidget_Size_XS)
				} else {
					// There are no size preferences, or all three prefer L size, so use the same
					// size for all of them.
					widget.size = widgets.length === 3 ? VenusOS.OverviewWidget_Size_M : VenusOS.OverviewWidget_Size_S
				}
				break
			default:
				// If there are more than four widgets, then size preferences are ignored.
				widget.size = VenusOS.OverviewWidget_Size_XS
				break
			}
		}
	}

	function resetWidgetConnectors(widgets) {
		for (let i = 0; i < widgets.length; ++i) {
			const connectors = widgets[i].connectors
			for (let j = 0; j < connectors.length; ++j) {
				connectors[j].reset()
			}
		}
	}

	function resetWidgetPositions(widgets) {
		let compactWidgetHeights = 0
		let expandedWidgetHeights = 0
		let i = 0
		let widget = null

		for (i = 0; i < widgets.length; ++i) {
			widget = widgets[i]
			compactWidgetHeights += widget.getCompactHeight(widget.size)
			expandedWidgetHeights += widget.getExpandedHeight(widget.size)
		}

		const compactPageHeight = Theme.geometry_screen_height
				- Theme.geometry_statusBar_height
				- Theme.geometry_navigationBar_height
		const compactWidgetsTopMargin = Math.max(0, (compactPageHeight - compactWidgetHeights) / Math.max(1, widgets.length - 1))
		const expandedPageHeight = Theme.geometry_screen_height
				- Theme.geometry_statusBar_height
				- Theme.geometry_overviewPage_layout_expanded_bottomMargin

		const expandedWidgetsTopMargin = Math.max(0, (expandedPageHeight - expandedWidgetHeights) / Math.max(1, widgets.length - 1))

		// Set widget y and height
		let prevWidget = null
		for (i = 0; i < widgets.length; ++i) {
			// Position each widget below the previous widget in this set.
			widget = widgets[i]
			if (i > 0) {
				prevWidget = widgets[i-1]
				widget.compactY = prevWidget.compactY + prevWidget.getCompactHeight(prevWidget.size) + compactWidgetsTopMargin
				widget.expandedY = prevWidget.expandedY + prevWidget.getExpandedHeight(prevWidget.size) + expandedWidgetsTopMargin
			} else {
				widget.compactY = 0
				widget.expandedY = 0
			}
		}

		// Set widget x and width
		for (i = 0; i < widgets.length; ++i) {
			widget = widgets[i]
			if (widgets === _leftWidgets) {
				widget.width = Theme.geometry_overviewPage_widget_leftWidgetWidth
				widget.x = Theme.geometry_page_content_horizontalMargin
			} else if (widgets === _centerWidgets) {
				widget.width = Theme.geometry_overviewPage_widget_centerWidgetWidth
				widget.x = root.width/2 - widget.width/2
			} else if (widgets === _rightWidgets) {
				widget.width = Theme.geometry_overviewPage_widget_rightWidgetWidth
				widget.x = root.width - widget.width - Theme.geometry_page_content_horizontalMargin
			}
		}
	}

	function resetWidgetKeyNavigation(widgets) {
		for (let i = 0; i < widgets.length - 1; ++i) {
			if (widgets[i].acceptsKeyNavigation()) {
				widgets[i].KeyNavigation.down = widgets[i + 1]
			} else {
				widgets[i].KeyNavigation.down = null
			}
		}
	}

	function _createWidget(type, args) {
		if (_createdWidgets[type] !== undefined) {
			return _createdWidgets[type]
		}

		// Some Overview widgets do not have a default type, so assign it here.
		// E.g. AcInputWidget may have be created with AcInput1 or AcInput2 type.
		args = Object.assign(args || {}, { type: type })

		let widget = null
		switch (type) {
		case VenusOS.OverviewWidget_Type_AcInputPriority:
		case VenusOS.OverviewWidget_Type_AcInputOther:
			widget = acInputComponent.createObject(root, args)
			break
		case VenusOS.OverviewWidget_Type_Alternator:
		case VenusOS.OverviewWidget_Type_DcGenerator:
		case VenusOS.OverviewWidget_Type_FuelCell:
		case VenusOS.OverviewWidget_Type_Wind:
			widget = dcInputComponent.createObject(root, args)
			break
		case VenusOS.OverviewWidget_Type_DcLoads:
			widget = dcLoadsComponent.createObject(root, args)
			break
		case VenusOS.OverviewWidget_Type_Evcs:
			widget = evcsComponent.createObject(root, args)
			break
		case VenusOS.OverviewWidget_Type_Solar:
			widget = solarComponent.createObject(root, args)
			break
		default:
			console.warn('Cannot create widget of unsupported type:', type)
			return null
		}
		_createdWidgets[type] = widget
		return widget
	}

	function _resetLeftWidgets() {
		let widgetType = -1
		let widgetCandidates = []
		let widget
		let i

		// Add AC-in widgets.
		const acInputConfigs = [
			{ input: Global.acInputs.input1, widgetType: VenusOS.OverviewWidget_Type_AcInputPriority },
			{ input: Global.acInputs.input2, widgetType: VenusOS.OverviewWidget_Type_AcInputOther },
		]
		if (Global.acInputs.isGridOrShore(Global.acInputs.input2)
				&& !Global.acInputs.isGridOrShore(Global.acInputs.input1)) {
			// Prefer to show the Grid/Shore AC input first, so swap the display order if needed.
			acInputConfigs[0].widgetType = VenusOS.OverviewWidget_Type_AcInputOther
			acInputConfigs[1].widgetType = VenusOS.OverviewWidget_Type_AcInputPriority
		}
		for (const inputConfig of acInputConfigs) {
			widget = _createWidget(inputConfig.widgetType)
			if (!!inputConfig.input) {
				widget.input = inputConfig.input
				widgetCandidates.splice(_leftWidgetInsertionIndex(inputConfig.widgetType, widgetCandidates), 0, widget)
			} else {
				widget.input = null
			}
		}

		// Add DC widgets. Only one widget is added per DC type, regardless of the number of inputs
		// for that type.
		let clearedWidgets = []
		for (i = 0; i < Global.dcInputs.model.count; ++i) {
			// Add the input to the DC widget
			const dcInput = Global.dcInputs.model.deviceAt(i)
			widgetType = _dcWidgetTypeForInputType(dcInput.inputType)
			widget = _createWidget(widgetType)
			if (clearedWidgets.indexOf(widget) < 0) {
				// Ensure the layout starts with a clean list of inputs for this widget.
				widget.inputs.clear()
				clearedWidgets.push(widget)
			}
			widget.inputs.addDevice(dcInput)
			if (widgetCandidates.indexOf(widget) < 0) {
				// Only show one widget for each DC input type.
				widgetCandidates.splice(_leftWidgetInsertionIndex(widgetType, widgetCandidates), 0, widget)
			}
		}

		// Add solar widget
		if (Global.solarDevices.model.count > 0 || Global.pvInverters.model.count > 0) {
			widgetCandidates.splice(_leftWidgetInsertionIndex(VenusOS.OverviewWidget_Type_Solar, widgetCandidates),
					0, _createWidget(VenusOS.OverviewWidget_Type_Solar))
		}
		_leftWidgets = widgetCandidates
	}

	function _dcWidgetTypeForInputType(dcInputType) {
		switch (dcInputType) {
		case VenusOS.DcInputs_InputType_Alternator:
			return VenusOS.OverviewWidget_Type_Alternator
		case VenusOS.DcInputs_InputType_FuelCell:
			return VenusOS.OverviewWidget_Type_FuelCell
		case VenusOS.DcInputs_InputType_Wind:
			return VenusOS.OverviewWidget_Type_Wind
		default:
			// Use DC Generator as the catch-all type for any DC power source that isn't
			// specifically handled.
			return VenusOS.OverviewWidget_Type_DcGenerator
		}
	}

	function _leftWidgetInsertionIndex(widgetType, candidateArray) {
		const orderedIndex = _leftWidgetOrder.indexOf(widgetType)
		for (let i = 0; i < candidateArray.length; ++i) {
			if (orderedIndex < _leftWidgetOrder.indexOf(candidateArray[i].type)) {
				return i
			}
		}
		return candidateArray.length
	}

	function _resetRightWidgets() {
		let widgets = [acLoadsWidget]
		if (Global.evChargers.model.count > 0) {
			widgets.push(_createWidget(VenusOS.OverviewWidget_Type_Evcs))
		}
		if (Global.system.showInputLoads && Global.system.hasAcOutSystem) {
			widgets.push(essentialLoadsWidget)
		} else {
			essentialLoadsWidget.size = VenusOS.OverviewWidget_Size_Zero
		}
		if (Global.allDevicesModel.combinedDcLoadDevices.count > 0 || !isNaN(Global.system.dc.power)) {
			widgets.push(_createWidget(VenusOS.OverviewWidget_Type_DcLoads))
		}
		_rightWidgets = widgets
	}

	function _findWidget(widgets, widgetType) {
		for (let i = 0; i < widgets.length; ++i) {
			if (widgets[i].type === widgetType) {
				return widgets[i]
			}
		}
		return null
	}

	function _inputConnectorAnimationMode(connectorWidget) {
		if (!isCurrentPage) {
			return VenusOS.WidgetConnector_AnimationMode_NotAnimated
		}
		// Assumes startWidget is the AC/DC input widget.
		// Use the displayed power to calculate whether the connector should be animated.
		const power = !connectorWidget.startWidget.quantityLabel.dataObject ? NaN
				: connectorWidget.startWidget.quantityLabel.dataObject.power
		if (isNaN(power) || Math.abs(power) <= Theme.geometry_overviewPage_connector_animationPowerThreshold) {
			return VenusOS.WidgetConnector_AnimationMode_NotAnimated
		}

		if (connectorWidget.endWidget === inverterChargerWidget) {
			// Only the connection to the "preferred" AC input should be animated.
			if (connectorWidget.startWidget.input !== Global.acInputs.highlightedInput) {
				return VenusOS.WidgetConnector_AnimationMode_NotAnimated
			}

			// For AC inputs, positive power means energy is flowing towards inverter/charger,
			// and negative power means energy is flowing towards the input.
			return power > Theme.geometry_overviewPage_connector_animationPowerThreshold
					? VenusOS.WidgetConnector_AnimationMode_StartToEnd
					: VenusOS.WidgetConnector_AnimationMode_EndToStart
		} else if (connectorWidget.endWidget === batteryWidget) {
			// For DC inputs, positive power means energy is flowing towards battery.
			return power > Theme.geometry_overviewPage_connector_animationPowerThreshold
					? VenusOS.WidgetConnector_AnimationMode_StartToEnd
					: VenusOS.WidgetConnector_AnimationMode_NotAnimated
		} else {
			console.warn("Unrecognised connector end widget:",
						 connectorWidget, connectorWidget.endWidget)
			return VenusOS.WidgetConnector_AnimationMode_NotAnimated
		}
	}

	// For left/right key navigation, prefer to navigate to:
	// 1. The last focused widget in the target direction, if it is connected to the current widget
	// 2. Any widget in the target direction that is connected to the current widget
	// 3. The last focused widget in the target direction
	// 4. Any widget in the target direction
	function _horizontalKeyNavigation(fromWidget, toWidgets, preferredTargetWidget) {
		const target = _findKeyNavigationTarget(fromWidget, toWidgets, preferredTargetWidget)
		if (target) {
			fromWidget.focus = false
			target.focus = true
		}
	}

	function _findKeyNavigationTarget(fromWidget, toWidgets, preferredTargetWidget) {
		if (preferredTargetWidget?.acceptsKeyNavigation() && preferredTargetWidget?.connectedTo(fromWidget)) {
			return preferredTargetWidget
		}
		let widget
		for (widget of toWidgets) {
			if (widget.acceptsKeyNavigation() && widget.connectedTo(fromWidget)) {
				return widget
			}
		}
		if (preferredTargetWidget) {
			return preferredTargetWidget
		}
		for (widget of toWidgets) {
			if (widget.acceptsKeyNavigation()) {
				return widget
			}
		}
		return null
	}

	function _findFocusableItem(widgetList, searchFromEnd) {
		for (let i = searchFromEnd ? widgetList.length - 1 : 0; searchFromEnd ? i >= 0 : i < widgetList.length; searchFromEnd ? --i : ++i) {
			if (widgetList[i].acceptsKeyNavigation()) {
				return widgetList[i]
			}
		}
		return null
	}

	//% "Overview"
	navButtonText: qsTrId("nav_overview")
	navButtonIcon: "qrc:/images/overview.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/OverviewPage.qml"
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
	fullScreenWhenIdle: true
	activeFocusOnTab: true

	onActiveFocusChanged: {
		if (Global.keyNavigationEnabled
				&& activeFocus
				&& (!root._lastFocusedWidget || !root._lastFocusedWidget.acceptsKeyNavigation())) {
			// Set the initial focus widget.
			const searchFromEnd = root.view.focusEdgeHint === Qt.BottomEdge
			for (const widgetList of [_centerWidgets, _leftWidgets, _rightWidgets]) {
				const widget = root._findFocusableItem(widgetList, searchFromEnd)
				if (widget) {
					widget.focus = true
					break
				}
			}
		}
	}

	Connections {
		target: Global.main
		enabled: Global.keyNavigationEnabled && root.isCurrentPage

		function onActiveFocusItemChanged() {
			const focusItem = Global.main.activeFocusItem
			if (focusItem instanceof OverviewWidget) {
				// Set the last focused widget in each column, so that left/right keys can be used
				// to move between them.
				root._lastFocusedWidget = focusItem
				if (_centerWidgets.indexOf(focusItem) >= 0) {
					root._lastFocusedCenterWidget = focusItem
				} else if (_rightWidgets.indexOf(focusItem) >= 0) {
					root._lastFocusedRightWidget = focusItem
				} else if (_leftWidgets.indexOf(focusItem) >= 0) {
					root._lastFocusedLeftWidget = focusItem
				}
			}
		}
	}

	Component {
		id: acInputComponent

		AcInputWidget {
			id: acInputWidget

			expanded: root._expandLayout
			animateGeometry: root._animateGeometry
			animationEnabled: root.animationEnabled
			connectors: [ acInputWidgetConnector ]

			Keys.onRightPressed: root._horizontalKeyNavigation(acInputWidget, root._centerWidgets, root._lastFocusedCenterWidget)

			WidgetConnectorAnchor {
				location: VenusOS.WidgetConnector_Location_Right
				visible: acInputWidgetConnector.visible
			}

			WidgetConnector {
				id: acInputWidgetConnector

				parent: root
				startWidget: acInputWidget
				startLocation: VenusOS.WidgetConnector_Location_Right
				endWidget: inverterChargerWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled
				animationMode: root._inputConnectorAnimationMode(acInputWidgetConnector)
			}
		}
	}

	Component {
		id: dcInputComponent

		DcInputWidget {
			id: dcInputWidget

			expanded: root._expandLayout
			animateGeometry: root._animateGeometry
			animationEnabled: root.animationEnabled
			connectors: [ dcInputConnector ]

			Keys.onRightPressed: root._horizontalKeyNavigation(dcInputWidget, root._centerWidgets, root._lastFocusedCenterWidget)

			WidgetConnectorAnchor {
				location: VenusOS.WidgetConnector_Location_Right
				visible: dcInputConnector.visible
			}

			WidgetConnector {
				id: dcInputConnector

				parent: root
				startWidget: dcInputWidget
				startLocation: VenusOS.WidgetConnector_Location_Right
				endWidget: batteryWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled
				animationMode: root._inputConnectorAnimationMode(dcInputConnector)
			}
		}
	}

	CpuInfo {
		id: cpuInfo

		enabled: root.animationEnabled
		upperLimit: 85
		lowerLimit: 50
	}

	FrameAnimation {
		id: overviewPageRootAnimation

		paused: cpuInfo.overLimit || Global.pauseElectronAnimations
		running: root.animationEnabled
		property real previousElapsed

		// Limit the frame rate of widget connector animations
		// to 20fps on the GX products
		property bool limitFps: Global.isGxDevice
		property real animationElapsed
		onTriggered: if (!limitFps || (currentFrame % 3 == 0)) animationElapsed = elapsedTime

		onRunningChanged: {
			if (!running) {
				previousElapsed = previousElapsed + elapsedTime
			}
		}
	}

	Component {
		id: solarComponent

		SolarYieldWidget {
			id: solarWidget

			expanded: root._expandLayout
			animateGeometry: root._animateGeometry
			animationEnabled: root.animationEnabled
			connectors: [ acSolarConnector, dcSolarConnector ]

			Keys.onRightPressed: root._horizontalKeyNavigation(solarWidget, root._centerWidgets, root._lastFocusedCenterWidget)

			WidgetConnectorAnchor {
				location: VenusOS.WidgetConnector_Location_Right
				visible: acSolarConnector.visible || dcSolarConnector.visible
			}

			WidgetConnector {
				id: acSolarConnector

				parent: root
				startWidget: solarWidget
				startLocation: VenusOS.WidgetConnector_Location_Right
				endWidget: inverterChargerWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				visible: defaultVisible && Global.pvInverters.model.count > 0
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled

				// Energy flows to Inverter/Charger if there is any PV Inverter power (i.e. AC)
				animationMode: root.isCurrentPage
						&& !isNaN(Global.system.solar.acPower)
						&& Math.abs(Global.system.solar.acPower || 0) > Theme.geometry_overviewPage_connector_animationPowerThreshold
							   ? VenusOS.WidgetConnector_AnimationMode_StartToEnd
							   : VenusOS.WidgetConnector_AnimationMode_NotAnimated
			}
			WidgetConnector {
				id: dcSolarConnector

				parent: root
				startWidget: solarWidget
				startLocation: VenusOS.WidgetConnector_Location_Right
				endWidget: batteryWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				visible: defaultVisible && Global.solarDevices.model.count > 0
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled

				// Energy flows to battery if there is any PV Charger power (i.e. DC, so solar is charging battery)
				animationMode: root.isCurrentPage
						&& !isNaN(Global.system.solar.dcPower)
						&& Math.abs(Global.system.solar.dcPower) > Theme.geometry_overviewPage_connector_animationPowerThreshold
							   ? VenusOS.WidgetConnector_AnimationMode_StartToEnd
							   : VenusOS.WidgetConnector_AnimationMode_NotAnimated
			}
		}
	}

	// the two central widgets are always laid out, even if they are not visible
	InverterChargerWidget {
		id: inverterChargerWidget

		size: VenusOS.OverviewWidget_Size_L
		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled
		connectors: [ inverterToAcLoadsConnector, inverterToBatteryConnector ]

		Keys.onLeftPressed: root._horizontalKeyNavigation(inverterChargerWidget, root._leftWidgets, root._lastFocusedLeftWidget)
		Keys.onRightPressed: root._horizontalKeyNavigation(inverterChargerWidget, root._rightWidgets, root._lastFocusedRightWidget)

		WidgetConnectorAnchor {
			id: inverterLeftConnectorAnchor
			location: VenusOS.WidgetConnector_Location_Left
			visible: Global.acInputs.findValidSource() !== VenusOS.AcInputs_InputSource_NotAvailable
					|| Global.pvInverters.model.count > 0
		}
		WidgetConnectorAnchor {
			id: inverterToAcLoadsAnchor
			location: VenusOS.WidgetConnector_Location_Right
			visible: inverterToAcLoadsConnector.visible
			y: inverterToAcLoadsConnector.straighten === VenusOS.WidgetConnector_Straighten_None ? defaultY
				   : acLoadsToInverterAnchor.y
		}
		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Bottom
			visible: inverterToBatteryConnector.visible
		}
	}
	WidgetConnector {
		id: inverterToAcLoadsConnector

		startWidget: inverterChargerWidget
		startLocation: VenusOS.WidgetConnector_Location_Right
		straighten: _rightWidgets.length === 1 ? VenusOS.WidgetConnector_Straighten_None : VenusOS.WidgetConnector_Straighten_EndToStart
		endWidget: acLoadsWidget
		endLocation: VenusOS.WidgetConnector_Location_Left
		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled

		// If load power is positive (i.e. consumed energy), energy flows to load.
		animationMode: root.isCurrentPage
				&& !isNaN(Global.system.load.ac.power)
				&& Global.system.load.ac.power > 0
				&& Math.abs(Global.system.load.ac.power) > Theme.geometry_overviewPage_connector_animationPowerThreshold
					? VenusOS.WidgetConnector_AnimationMode_StartToEnd
					: VenusOS.WidgetConnector_AnimationMode_NotAnimated
	}
	WidgetConnector {
		id: inverterToBatteryConnector

		startWidget: inverterChargerWidget
		startLocation: VenusOS.WidgetConnector_Location_Bottom
		endWidget: batteryWidget
		endLocation: VenusOS.WidgetConnector_Location_Top
		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled

		// If inverter/charger power is positive: battery is charging, so energy flows to battery.
		// If inverter/charger power is negative: battery is discharging, so energy flows to inverter/charger.
		animationMode: root.isCurrentPage
				&& Math.abs(inverterChargerPower.value) > Theme.geometry_overviewPage_connector_animationPowerThreshold
						? (inverterChargerPower.value > 0
								? VenusOS.WidgetConnector_AnimationMode_StartToEnd
								: VenusOS.WidgetConnector_AnimationMode_EndToStart)
						: VenusOS.WidgetConnector_AnimationMode_NotAnimated
	}

	BatteryWidget {
		id: batteryWidget

		size: VenusOS.OverviewWidget_Size_L
		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled && !overviewPageRootAnimation.paused

		Keys.onLeftPressed: root._horizontalKeyNavigation(batteryWidget, root._leftWidgets, root._lastFocusedLeftWidget)
		Keys.onRightPressed: root._horizontalKeyNavigation(batteryWidget, root._rightWidgets, root._lastFocusedRightWidget)

		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Left
			visible: Global.dcInputs.model.count > 0 || Global.solarDevices.model.count > 0
		}
		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Top
		}
	}

	AcLoadsWidget {
		id: acLoadsWidget

		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled

		WidgetConnectorAnchor {
			id: acLoadsToInverterAnchor
			location: VenusOS.WidgetConnector_Location_Left
		}
	}

	EssentialLoadsWidget {
		id: essentialLoadsWidget

		expanded: root._expandLayout
		animateGeometry: root._animateGeometry
		animationEnabled: root.animationEnabled
		connectors: [ inverterToEssentialLoadsConnector ]

		WidgetConnectorAnchor {
			id: inverterToEssentialLoadsStartAnchor
			parent: inverterChargerWidget
			location: VenusOS.WidgetConnector_Location_Right
			visible: inverterToEssentialLoadsConnector.visible
			offsetY: height + Theme.geometry_overviewPage_connector_anchor_spacing
		}

		WidgetConnectorAnchor {
			location: VenusOS.WidgetConnector_Location_Left
		}

		WidgetConnector {
			id: inverterToEssentialLoadsConnector

			parent: root
			startWidget: inverterChargerWidget
			startLocation: VenusOS.WidgetConnector_Location_Right
			startOffsetY: inverterToEssentialLoadsStartAnchor.offsetY
			endWidget: essentialLoadsWidget
			endLocation: VenusOS.WidgetConnector_Location_Left
			expanded: root._expandLayout
			animateGeometry: root._animateGeometry
			animationEnabled: root.animationEnabled

			// If load power is positive (i.e. consumed energy), energy flows to load.
			animationMode: root.isCurrentPage
					&& !isNaN(Global.system.load.acOut.power)
					&& Global.system.load.acOut.power > 0
					&& Math.abs(Global.system.load.acOut.power) > Theme.geometry_overviewPage_connector_animationPowerThreshold
						? VenusOS.WidgetConnector_AnimationMode_StartToEnd
						: VenusOS.WidgetConnector_AnimationMode_NotAnimated
		}
	}

	Component {
		id: dcLoadsComponent

		DcLoadsWidget {
			id: dcLoadsWidget

			expanded: root._expandLayout
			animateGeometry: root._animateGeometry
			animationEnabled: root.animationEnabled
			connectors: [ batteryToDcLoadsConnector ]

			Keys.onLeftPressed: root._horizontalKeyNavigation(dcLoadsWidget, root._centerWidgets, root._lastFocusedCenterWidget)

			WidgetConnectorAnchor {
				parent: batteryWidget
				location: VenusOS.WidgetConnector_Location_Right
				visible: batteryToDcLoadsConnector.visible
			}

			WidgetConnectorAnchor {
				location: VenusOS.WidgetConnector_Location_Left
			}

			WidgetConnector {
				id: batteryToDcLoadsConnector

				parent: root
				startWidget: batteryWidget
				startLocation: VenusOS.WidgetConnector_Location_Right
				endWidget: dcLoadsWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled

				// If load power is positive (i.e. consumed energy), energy flows to load.
				// If load power is negative (i.e. devices generating power but not directly managed by GX), energy flows to battery.
				animationMode: root.isCurrentPage
								&& !isNaN(Global.system.dc.power)
								&& (Math.abs(Global.system.dc.power) > Theme.geometry_overviewPage_connector_animationPowerThreshold)
							? (Global.system.dc.power > 0
								? VenusOS.WidgetConnector_AnimationMode_StartToEnd
								: VenusOS.WidgetConnector_AnimationMode_EndToStart)
							: VenusOS.WidgetConnector_AnimationMode_NotAnimated
			}
		}
	}

	Component {
		id: evcsComponent

		EvcsWidget {
			id: evcsWidget

			// The EVCS widget may have connectors to the AC Loads or Essential Loads, depending on
			// whether AC loads are split into AC Loads + Essential Loads, and also depending on the
			// "Position" configuration of the EV chargers on the system.
			//
			// If showing combined AC loads:
			//  - connect to AC Loads
			// If splitting loads into (input) AC Loads and (output) Essential Loads:
			//  - connect to AC Loads, if there are any EV chargers with /Position=1 (AC-In)
			//  - connect to Essential Loads, if there are any EV chargers with /Position=0 (AC-Out)
			readonly property bool connectToCombinedAcLoads: visible && !Global.system.showInputLoads
			readonly property bool connectToSplitAcLoads: visible
					&& Global.system.showInputLoads                 // AC loads are split
					&& Global.evChargers.acInputPositionCount > 0   // AC-in position is in use
			readonly property bool connectToEssentialLoads: visible
					&& Global.system.showInputLoads     // AC loads are split
					&& Global.system.hasAcOutSystem     // Essential Loads should be visible
					&& Global.evChargers.acOutputPositionCount > 0  // AC-out position is in use

			// When connecting the EVCS widget to the AC Loads and Essential Loads widgets, the
			// connector line should not travel vertically in a straight line. Instead, move the
			// midpoint of this line to the left, by a distance that is one-quarter of the way
			// between the EVCS widget and the centre widgets.
			readonly property real loadsConnectorsXDistance: (evcsWidget.x - (inverterChargerWidget.x + inverterChargerWidget.width)) / 4

			visible: Global.evChargers.model.count > 0
			expanded: root._expandLayout
			animateGeometry: root._animateGeometry
			animationEnabled: root.animationEnabled
			connectors: [ acLoadsToEvcsConnector, essentialLoadsToEvcsConnector ]

			Keys.onLeftPressed: root._horizontalKeyNavigation(evcsWidget, root._centerWidgets, root._lastFocusedCenterWidget)

			// Connector for AC Loads -> EVCS
			WidgetConnectorAnchor {
				id: acLoadsToEvcsStartAnchor
				parent: acLoadsWidget
				location: VenusOS.WidgetConnector_Location_Left
				offsetY: height + Theme.geometry_overviewPage_connector_anchor_spacing
				visible: evcsWidget.connectToCombinedAcLoads || evcsWidget.connectToSplitAcLoads
			}
			WidgetConnectorAnchor {
				id: acLoadsToEvcsEndAnchor
				location: VenusOS.WidgetConnector_Location_Left
				offsetY: -(height + Theme.geometry_overviewPage_connector_anchor_spacing)
				visible: evcsWidget.connectToCombinedAcLoads || evcsWidget.connectToSplitAcLoads
			}
			WidgetConnector {
				id: acLoadsToEvcsConnector
				parent: root
				visible: evcsWidget.connectToCombinedAcLoads || evcsWidget.connectToSplitAcLoads
				startWidget: acLoadsWidget
				startLocation: VenusOS.WidgetConnector_Location_Left
				startOffsetY: acLoadsToEvcsStartAnchor.offsetY
				endWidget: evcsWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				endOffsetY: acLoadsToEvcsEndAnchor.offsetY
				midpointOffsetX: -evcsWidget.loadsConnectorsXDistance
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled
				animationMode: root.isCurrentPage
						&& ( (evcsWidget.connectToCombinedAcLoads && Global.evChargers.power > Theme.geometry_overviewPage_connector_animationPowerThreshold)
						  || (evcsWidget.connectToSplitAcLoads && Global.evChargers.acInputPositionPower > Theme.geometry_overviewPage_connector_animationPowerThreshold) )
					? VenusOS.WidgetConnector_AnimationMode_StartToEnd
					: VenusOS.WidgetConnector_AnimationMode_NotAnimated
			}

			// Connector for Essential Loads -> EVCS
			WidgetConnectorAnchor {
				id: essentialLoadsToEvcsStartAnchor
				parent: essentialLoadsWidget
				location: VenusOS.WidgetConnector_Location_Left
				offsetY: -(height + Theme.geometry_overviewPage_connector_anchor_spacing)
				visible: evcsWidget.connectToEssentialLoads
			}
			WidgetConnectorAnchor {
				id: essentialLoadsToEvcsEndAnchor
				location: VenusOS.WidgetConnector_Location_Left
				offsetY: height + Theme.geometry_overviewPage_connector_anchor_spacing
				visible: evcsWidget.connectToEssentialLoads
			}
			WidgetConnector {
				id: essentialLoadsToEvcsConnector
				parent: root
				visible: evcsWidget.connectToEssentialLoads
				startWidget: essentialLoadsWidget
				startLocation: VenusOS.WidgetConnector_Location_Left
				startOffsetY: essentialLoadsToEvcsStartAnchor.offsetY
				endWidget: evcsWidget
				endLocation: VenusOS.WidgetConnector_Location_Left
				endOffsetY: essentialLoadsToEvcsEndAnchor.offsetY
				midpointOffsetX: -evcsWidget.loadsConnectorsXDistance
				expanded: root._expandLayout
				animateGeometry: root._animateGeometry
				animationEnabled: root.animationEnabled
				animationMode: root.isCurrentPage
						&& Global.evChargers.acOutputPositionPower > Theme.geometry_overviewPage_connector_animationPowerThreshold
					? VenusOS.WidgetConnector_AnimationMode_StartToEnd
					: VenusOS.WidgetConnector_AnimationMode_NotAnimated
			}
		}
	}

	VeQuickItem {
		id: inverterChargerPower
		uid: Global.system.serviceUid + "/Dc/InverterCharger/Power"
	}
}
