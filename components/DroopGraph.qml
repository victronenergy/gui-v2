/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Shapes
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
    property point _origin: Qt.point(53.5, 138)
    property point _xAxis: Qt.point(53.5 + 283, 138)
    property point _yAxis: Qt.point(53.5, 0)

    // Define set points for the droop line
    property point _droopLineMax: Qt.point(53.5 + 30.5, 30)
    property point _droopLineMin: Qt.point(53.5 + 250, 120)

    // Define the reference guideline intersection.
    // This allows drawing the guidelines which are fixed
    // parallel to each axis and defined by the upper and
    // lower bounds of the power range.
    property real _guidelineIntersectionRatio: (yAxisReferenceValue + Math.abs(yAxisLowerReferenceValue))
                                                / Math.abs(yAxisUpperReferenceValue - yAxisLowerReferenceValue)
    // Using the above ratio this calculates the on
    // screen point to use
    property point _guidelineIntersection: Qt.point(_droopLineMax.x + (_droopLineMin.x - _droopLineMax.x)
                                                    * _guidelineIntersectionRatio,
                                                    _droopLineMax.y + (_droopLineMin.y - _droopLineMax.y)
                                                    * _guidelineIntersectionRatio)

    // Defines where the intersection of the indicator is
    // located. This is the indicator dot and defines the active/reactive
    // power values.
    property real _operationalDroop: Math.abs(xAxisReferenceValue - xAxisOperationValue) <= 0.1 // Theme.deadband_value
                                    ? 0
                                    : (xAxisReferenceValue - xAxisOperationValue) * root.droop
    // Using the operationalPercent align the indicator
    // against the reference guideline
    property real _indicatorRatio: 1 - (_guidelineIntersectionRatio + (_operationalDroop
                                   / Math.abs(yAxisUpperReferenceValue - yAxisLowerReferenceValue)))
    property point _indicator: Qt.point(_droopLineMax.x + (_droopLineMin.x - _droopLineMax.x) * _indicatorRatio,
                                        _droopLineMax.y + (_droopLineMin.y - _droopLineMax.y) * _indicatorRatio)

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
        strokeWidth: Theme.geometry_droopGraph_indicator_guideline_width
        strokeColor: Theme.color_droopGraph_indicator_guidelines
        fillColor: "transparent"
    }

    component Indicator: Rectangle {
        width: Theme.geometry_droopGraph_indicator_diameter
        height: Theme.geometry_droopGraph_indicator_diameter
        color: Theme.color_lightBlue
        border.color: Theme.color_background_primary
        border.width: Theme.geometry_droopGraph_indicator_border_width
        radius: width/2
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
        verticalAlignment: Text.AlignVCenter
    }
    component OperationQuantityLabel: QuantityLabel {
        valueColor: Theme.color_droopGraph_indicator_guidelines
        unitColor: Theme.color_droopGraph_indicator_guidelines
        font.pixelSize: Theme.font_size_body1
        verticalAlignment: Text.AlignVCenter
    }

    implicitWidth: Theme.geometry_droopGraph_width
    implicitHeight: Theme.geometry_droopGraph_height

    Shape {
        anchors.fill: parent

        // draw the fixed static background shapes
        GraphLine { // axes lines
            startX: _xAxis.x;startY: _xAxis.y
            PathLine { x: _origin.x; y: _origin.y }
            PathLine { x: _yAxis.x; y: _yAxis.y }
        }
        GraphLine { // y axis arrow
            startX: _yAxis.x - Theme.geometry_droopGraph_arrow_size; startY: _yAxis.y + Theme.geometry_droopGraph_arrow_size
            PathLine { x: _yAxis.x; y: _yAxis.y }
            PathLine { x: _yAxis.x + Theme.geometry_droopGraph_arrow_size; y: _yAxis.y + Theme.geometry_droopGraph_arrow_size }
        }
        GraphLine { // x axis arrow
            startX: _xAxis.x - Theme.geometry_droopGraph_arrow_size; startY: _xAxis.y - Theme.geometry_droopGraph_arrow_size
            PathLine { x: _xAxis.x; y: _xAxis.y }
            PathLine { x: _xAxis.x - Theme.geometry_droopGraph_arrow_size; y: _xAxis.y + Theme.geometry_droopGraph_arrow_size }
        }
        ReferenceGuideLine { // default reference vertical guideline
            startX: _guidelineIntersection.x; startY: _origin.y
            PathLine { x: _guidelineIntersection.x; y: _yAxis.y }
        }
        ReferenceGuideLine { // default reference horizontal guideline
            startX: _origin.x; startY: _guidelineIntersection.y
            PathLine { x: _xAxis.x - 15; y: _guidelineIntersection.y }
        }

        // draw the dynamic overlay elements
        ShapePath { // droop line
            strokeWidth: 0
            strokeColor: "transparent"
            fillGradient: LinearGradient {
                x1: _droopLineMin.x; y1: _droopLineMin.y
                x2: _droopLineMax.x; y2: _droopLineMax.y
                GradientStop { position: 0.0; color: Theme.color_droopGraph_gradient_edge }
                GradientStop { position: 0.3; color: Theme.color_droopGraph_gradient_centre }
                GradientStop { position: 0.6; color: Theme.color_droopGraph_gradient_centre }
                GradientStop { position: 1.0; color: Theme.color_droopGraph_gradient_edge }
            }
            // Offset each end of the line for design purposes (x Axis)
            startX: _origin.x + Theme.geometry_droopGraph_axis_width; startY: _droopLineMax.y - Theme.geometry_droopGraph_droopLine_half_width
            // One side of the main gradient line with slope ...
            PathLine { x: _droopLineMax.x; y: _droopLineMax.y - Theme.geometry_droopGraph_droopLine_half_width }
            PathLine { x: _droopLineMin.x; y: _droopLineMin.y - Theme.geometry_droopGraph_droopLine_half_width }
            // the lower right horizontal line
            PathLine { x: _xAxis.x - Theme.geometry_droopGraph_droopLine_xAxis_offset; y: _droopLineMin.y - Theme.geometry_droopGraph_droopLine_half_width }
            PathLine { x: _xAxis.x - Theme.geometry_droopGraph_droopLine_xAxis_offset; y: _droopLineMin.y + Theme.geometry_droopGraph_droopLine_half_width }
            // the other side of the main gradient line with slope
            PathLine { x: _droopLineMin.x; y: _droopLineMin.y + Theme.geometry_droopGraph_droopLine_half_width }
            PathLine { x: _droopLineMax.x; y: _droopLineMax.y + Theme.geometry_droopGraph_droopLine_half_width }
            // Complete the path back to the upper left
            PathLine { x: _origin.x + Theme.geometry_droopGraph_axis_width; y: _droopLineMax.y + Theme.geometry_droopGraph_droopLine_half_width  }
        }
        OperationGuideLine { // dynamic operation horizontal guideline
            // offset the end of the lines by the width of the graph axes
            startX: _indicator.x; startY: _origin.y - Theme.geometry_droopGraph_axis_width/2
            PathLine { x: _indicator.x; y: _indicator.y }
        }
        OperationGuideLine { // dynamic operation vertical guideline
            // offset the end of the lines by the width of the graph axes
            startX: _origin.x + Theme.geometry_droopGraph_axis_width/2; startY: _indicator.y
            PathLine { x: _indicator.x; y: _indicator.y }
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

        // This calculates the centre value between the two guidelines
        // and then sets a +/- adjustment to be applied to the two labels
        property real _yLabelHeight: Math.max(height, yAxisOperationQuantityLabel.height)
        property real _yAdjustment: Math.abs(_guidelineIntersection.y - _indicator.y) > _yLabelHeight
                                    ? 0
                                    : (_yLabelHeight - Math.abs(_guidelineIntersection.y - _indicator.y))/2

        anchors.left: parent.left
        y: _guidelineIntersection.y + _yAdjustment * Math.sign(_guidelineIntersection.y - _indicator.y)
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
        y: _indicator.y - yAxisReferenceQuantityLabel._yAdjustment * Math.sign(_guidelineIntersection.y - _indicator.y)
            - yAxisReferenceQuantityLabel._yLabelHeight/2
        width: Theme.geometry_droopGraph_yAxis_quantityLabel_width

        value: yAxisReferenceValue + _operationalDroop
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

        // This calculates the centre value between the two guidelines
        // and then sets a +/- adjustment to be applied to the two labels
        property real _xLabelWidth: Math.max(width, xAxisOperationQuantityLabel.width) + 4 // Padding
        property real _xAdjustment: Math.abs(_guidelineIntersection.x - _indicator.x) > _xLabelWidth
                                    ? 0
                                    : (_xLabelWidth - Math.abs(_guidelineIntersection.x - _indicator.x))/2

        anchors.bottom: parent.bottom
        x: _guidelineIntersection.x + _xAdjustment * Math.sign(_guidelineIntersection.x - _indicator.x)
            - _xLabelWidth/2

        value: root.xAxisReferenceValue
        unit: root.xAxisUnit
    }
    OperationQuantityLabel {
        id: xAxisOperationQuantityLabel

        anchors.bottom: parent.bottom
        x: _indicator.x - xAxisReferenceQuantityLabel._xAdjustment * Math.sign(_guidelineIntersection.x - _indicator.x)
            - xAxisReferenceQuantityLabel._xLabelWidth/2

        value: root.xAxisOperationValue
        unit: root.xAxisUnit
    }
    Indicator {
        id: indicator
        x: _indicator.x - width/2
        y: _indicator.y - height/2
    }
}

