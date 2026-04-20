/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Shapes
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: root

	property string xAxisLabel
	property string yAxisLabel

	property real xAxisReferenceValue
	property real xAxisOperationValue
	property real xAxisLowerReferenceValue
	property real xAxisUpperReferenceValue
	property int xAxisUnit

	property real yAxisReferenceValue
	property real yAxisOperationValue
	property real yAxisLowerReferenceValue
	property real yAxisUpperReferenceValue

	property real droop

	// Define graph point locations
	readonly property point _origin: Qt.point(Theme.geometry_droopGraph_leftMargin, height - Theme.geometry_droopGraph_bottomMargin)
	readonly property point _xAxisEnd: Qt.point(width, _origin.y)
	readonly property point _yAxisEnd: Qt.point(_origin.x, 0)

	// Define set points for the droop line
	readonly property point _droopLineUpper: Qt.point(_origin.x + (width - Theme.geometry_droopGraph_leftMargin) * Theme.geometry_droopGraph_upperSegmentXRatio,
										   _origin.y - (height - Theme.geometry_droopGraph_bottomMargin) * Theme.geometry_droopGraph_upperSegmentYRatio)
	readonly property point _droopLineLower: Qt.point(_origin.x + (width - Theme.geometry_droopGraph_leftMargin) * Theme.geometry_droopGraph_lowerSegmentXRatio,
										   _origin.y - (height - Theme.geometry_droopGraph_bottomMargin) * Theme.geometry_droopGraph_lowerSegmentYRatio)

	// Define the reference guideline intersection.
	// The reference guidelines intersection point represents the point
	// at which the system will deliver the reference active and reactive power.
	// (Note that the observed/instantaneous behaviour of the system is
	// separately visualised as the operation point - see below).
	// This allows drawing the guidelines which are fixed
	// parallel to each axis and defined by the upper and
	// lower bounds of the power range.
	readonly property real _guidelineIntersectionRatio: yAxisReferenceValue < yAxisLowerReferenceValue ? 0.0
											 : yAxisReferenceValue > yAxisUpperReferenceValue ? 1.0
											 : yAxisLowerReferenceValue == yAxisUpperReferenceValue ? 0.5
											 : (yAxisReferenceValue - yAxisLowerReferenceValue)
												/ (yAxisUpperReferenceValue - yAxisLowerReferenceValue)
	// This is the point (which will lie on the droop line)
	// where the reference value guidelines cross.
	readonly property point _guidelineIntersection: Qt.point(_droopLineUpper.x + (_droopLineLower.x - _droopLineUpper.x)
													* _guidelineIntersectionRatio,
													_droopLineUpper.y + (_droopLineLower.y - _droopLineUpper.y)
													* _guidelineIntersectionRatio)

	// y axis delta between the reference value and the observed value, multiplied by the droop graph slope.
	readonly property real _operationDroop: (xAxisReferenceValue - xAxisOperationValue) * root.droop
	// as above, described as a ratio (of the value bounded by [lower, upper] interval) on the droop graph line.
	readonly property real _operationDroopRatio: 1 - (_guidelineIntersectionRatio + (_operationDroop
								   / Math.abs(yAxisUpperReferenceValue - yAxisLowerReferenceValue)))
	// The operation point is the point on the graph which the system is
	// observed to exhibit (as measured by the /Ac/ActiveIn/L1/F + V values).
	// This visualises the instantaneous active/reactive power values of the microgrid.
	readonly property point _operationPoint: Qt.point(_droopLineUpper.x + (_droopLineLower.x - _droopLineUpper.x) * _operationDroopRatio,
									_droopLineUpper.y + (_droopLineLower.y - _droopLineUpper.y) * _operationDroopRatio)

	implicitWidth: Theme.geometry_droopGraph_leftMargin + Theme.geometry_droopGraph_defaultAxisWidth
	implicitHeight: Theme.geometry_droopGraph_bottomMargin + Theme.geometry_droopGraph_defaultAxisHeight

	component GraphLine: ShapePath {
		strokeWidth: Theme.geometry_droopGraph_axis_width
		strokeColor: Theme.color_droopGraph_axis_line
		fillColor: "transparent"
		strokeStyle: ShapePath.SolidLine
		capStyle: ShapePath.RoundCap
		joinStyle: ShapePath.RoundJoin
	}
	component ReferenceGuideLine: GraphLine {
		strokeWidth: Theme.geometry_droopGraph_guideline_width
		strokeStyle: ShapePath.DashLine
		dashPattern: [ 1, 2 ]
	}
	component OperationGuideLine: ReferenceGuideLine {
		strokeWidth: Theme.geometry_droopGraph_operationPoint_guideline_width
		strokeColor: Theme.color_droopGraph_operationPoint_guidelines
		fillColor: "transparent"
	}

	component AxisLabel: Label {
		width: Theme.geometry_droopGraph_axis_label_width
		height: Theme.geometry_droopGraph_axis_label_height
		color: Theme.color_droopGraph_axis_line
		font.pixelSize: Theme.font_size_tiny
		verticalAlignment: Text.AlignVCenter
		horizontalAlignment: Text.AlignHCenter
	}
	component ReferenceQuantityLabel: QuantityLabel {
		valueColor: Theme.color_droopGraph_axis_line
		unitColor: Theme.color_droopGraph_axis_line
		font.pixelSize: Theme.font_size_body1
	}
	component OperationQuantityLabel: QuantityLabel {
		valueColor: Theme.color_droopGraph_operationPoint_guidelines
		unitColor: Theme.color_droopGraph_operationPoint_guidelines
		font.pixelSize: Theme.font_size_body1
	}

	Shape {
		anchors.fill: parent
		preferredRendererType: Shape.CurveRenderer

		// draw the fixed static background shapes
		GraphLine { // axes lines
			startX: _xAxisEnd.x;startY: _xAxisEnd.y
			PathLine { x: _origin.x; y: _origin.y }
			PathLine { x: _yAxisEnd.x; y: _yAxisEnd.y }
		}
		GraphLine { // y axis arrow
			startX: _yAxisEnd.x - Theme.geometry_droopGraph_arrow_size; startY: _yAxisEnd.y + Theme.geometry_droopGraph_arrow_size
			PathLine { x: _yAxisEnd.x; y: _yAxisEnd.y }
			PathLine { x: _yAxisEnd.x + Theme.geometry_droopGraph_arrow_size; y: _yAxisEnd.y + Theme.geometry_droopGraph_arrow_size }
		}
		GraphLine { // x axis arrow
			startX: _xAxisEnd.x - Theme.geometry_droopGraph_arrow_size; startY: _xAxisEnd.y - Theme.geometry_droopGraph_arrow_size
			PathLine { x: _xAxisEnd.x; y: _xAxisEnd.y }
			PathLine { x: _xAxisEnd.x - Theme.geometry_droopGraph_arrow_size; y: _xAxisEnd.y + Theme.geometry_droopGraph_arrow_size }
		}
		ReferenceGuideLine { // default reference vertical guideline
			startX: _guidelineIntersection.x; startY: _origin.y
			PathLine { x: _guidelineIntersection.x; y: _yAxisEnd.y }
		}
		ReferenceGuideLine { // default reference horizontal guideline
			startX: _origin.x; startY: _guidelineIntersection.y
			PathLine { x: _xAxisEnd.x - Theme.geometry_droopGraph_droopLine_xAxis_offset; y: _guidelineIntersection.y }
		}

		// draw the dynamic overlay elements
		ShapePath { // droop line
			strokeWidth: 0
			strokeColor: "transparent"
			fillGradient: LinearGradient {
				x1: _droopLineLower.x; y1: _droopLineLower.y
				x2: _droopLineUpper.x; y2: _droopLineUpper.y
				GradientStop { position: 0.0; color: Theme.color_droopGraph_gradient_edge }
				GradientStop { position: 0.3; color: Theme.color_droopGraph_gradient_centre }
				GradientStop { position: 0.6; color: Theme.color_droopGraph_gradient_centre }
				GradientStop { position: 1.0; color: Theme.color_droopGraph_gradient_edge }
			}
			// Offset each end of the line for design purposes (x Axis)
			startX: _origin.x + Theme.geometry_droopGraph_axis_width; startY: _droopLineUpper.y - Theme.geometry_droopGraph_droopLine_half_width
			// One side of the main gradient line with slope ...
			PathLine { x: _droopLineUpper.x; y: _droopLineUpper.y - Theme.geometry_droopGraph_droopLine_half_width }
			PathLine { x: _droopLineLower.x; y: _droopLineLower.y - Theme.geometry_droopGraph_droopLine_half_width }
			// the lower right horizontal line
			PathLine { x: _xAxisEnd.x - Theme.geometry_droopGraph_droopLine_xAxis_offset; y: _droopLineLower.y - Theme.geometry_droopGraph_droopLine_half_width }
			PathLine { x: _xAxisEnd.x - Theme.geometry_droopGraph_droopLine_xAxis_offset; y: _droopLineLower.y + Theme.geometry_droopGraph_droopLine_half_width }
			// the other side of the main gradient line with slope
			PathLine { x: _droopLineLower.x; y: _droopLineLower.y + Theme.geometry_droopGraph_droopLine_half_width }
			PathLine { x: _droopLineUpper.x; y: _droopLineUpper.y + Theme.geometry_droopGraph_droopLine_half_width }
			// Complete the path back to the upper left
			PathLine { x: _origin.x + Theme.geometry_droopGraph_axis_width; y: _droopLineUpper.y + Theme.geometry_droopGraph_droopLine_half_width  }
		}
		OperationGuideLine { // dynamic operation horizontal guideline
			// offset the end of the lines by the width of the graph axes
			startX: _operationPoint.x; startY: _origin.y - Theme.geometry_droopGraph_axis_width/2
			PathLine { x: _operationPoint.x; y: _operationPoint.y }
		}
		OperationGuideLine { // dynamic operation vertical guideline
			// offset the end of the lines by the width of the graph axes
			startX: _origin.x + Theme.geometry_droopGraph_axis_width/2; startY: _operationPoint.y
			PathLine { x: _operationPoint.x; y: _operationPoint.y }
		}
	}

	AxisLabel {
		anchors {
			left: parent.left
			leftMargin: Theme.geometry_droopGraph_yAxis_label_leftMargin
			top: parent.top
		}
		text: root.yAxisLabel
	}
	ReferenceQuantityLabel {
		id: yAxisReferenceQuantityLabel

		// This calculates an adjustment +/- to apply to each y axis label
		property real _yLabelHeight: Math.max(height, yAxisOperationQuantityLabel.height)
									 + Theme.geometry_droopGraph_xAxis_label_padding
		property real _yAdjustment: Math.abs(_guidelineIntersection.y - _operationPoint.y) > _yLabelHeight
									? 0
									: (_yLabelHeight - Math.abs(_guidelineIntersection.y - _operationPoint.y))/2

		anchors.left: parent.left
		y: _guidelineIntersection.y + _yAdjustment * Math.sign(_guidelineIntersection.y - _operationPoint.y)
			- _yLabelHeight/2
		width: Theme.geometry_droopGraph_yAxis_quantityLabel_width

		value: root.yAxisReferenceValue
		unit: VenusOS.Units_Percentage
		decimals: 0
		alignment: Qt.AlignRight
	}
	OperationQuantityLabel {
		id: yAxisOperationQuantityLabel

		anchors.left: parent.left
		y: _operationPoint.y - yAxisReferenceQuantityLabel._yAdjustment * Math.sign(_guidelineIntersection.y - _operationPoint.y)
			- yAxisReferenceQuantityLabel._yLabelHeight/2
		width: Theme.geometry_droopGraph_yAxis_quantityLabel_width

		value: yAxisReferenceValue + _operationDroop
		unit: VenusOS.Units_Percentage
		decimals: 0
		alignment: Qt.AlignRight
	}

	AxisLabel {
		anchors {
			right: parent.right
			bottom: parent.bottom
		}
		text: root.xAxisLabel
	}
	ReferenceQuantityLabel {
		id: xAxisReferenceQuantityLabel

		// This calculates an adjustment +/- to apply to each x axis label
		property real _xLabelWidth: Math.max(width, xAxisOperationQuantityLabel.width)
									+ Theme.geometry_droopGraph_xAxis_label_padding
		property real _xAdjustment: Math.abs(_guidelineIntersection.x - _operationPoint.x) > _xLabelWidth
									? 0
									: (_xLabelWidth - Math.abs(_guidelineIntersection.x - _operationPoint.x))/2

		anchors.bottom: parent.bottom
		x: _guidelineIntersection.x + _xAdjustment * Math.sign(_guidelineIntersection.x - _operationPoint.x)
			- _xLabelWidth/2

		value: root.xAxisReferenceValue
		unit: root.xAxisUnit
	}
	OperationQuantityLabel {
		id: xAxisOperationQuantityLabel

		anchors.bottom: parent.bottom
		x: _operationPoint.x - xAxisReferenceQuantityLabel._xAdjustment * Math.sign(_guidelineIntersection.x - _operationPoint.x)
			- xAxisReferenceQuantityLabel._xLabelWidth/2

		value: root.xAxisOperationValue
		unit: root.xAxisUnit
	}
	// Preference is to use Rectangle with borders however we don't have MSAA on CerboGX.
	// So, use a pre-rendered (with QPainter doing manual AA) texture.
	CP.ColorImage {
		x: _operationPoint.x - width/2
		y: _operationPoint.y - height/2
		sourceSize: Qt.size(Theme.geometry_droopGraph_operationPoint_diameter,Theme.geometry_droopGraph_operationPoint_diameter)
		source: "qrc:/images/dot.svg"
		color: Theme.color_background_primary

		CP.ColorImage {
			anchors.centerIn: parent
			sourceSize: Qt.size(Theme.geometry_droopGraph_operationPoint_diameter - Theme.geometry_droopGraph_operationPoint_border_width*2,
								Theme.geometry_droopGraph_operationPoint_diameter - Theme.geometry_droopGraph_operationPoint_border_width*2)
			source: "qrc:/images/dot.svg"
			color: Theme.color_lightBlue
		}
	}
}

