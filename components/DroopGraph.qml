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

    property alias xAxisReferenceValue: xAxisReferenceQuantityLabel.value
    property alias xAxisOperationValue: xAxisOperationQuantityLabel.value
    property int xAxisUnit
    property real xAxisLowerReferenceValue
    property real xAxisUpperReferenceValue

    property alias yAxisReferenceValue: yAxisReferenceQuantityLabel.value
    property alias yAxisOperationValue: yAxisOperationQuantityLabel.value
    property real yAxisLowerReferenceValue
    property real yAxisUpperReferenceValue

    // Define graph point locations
    property point _origin: Qt.point(53.5, 138)
    property point _xAxis: Qt.point(53.5 + 283, 138)
    property point _yAxis: Qt.point(53.5, 0)

    // Define set points for the droop line
    property point _droopLineMin: Qt.point(53.5 + 30.5, 30)
    property point _droopLineMax: Qt.point(53.5 + 250, 120)

    // Define the reference guideline intersection
    // This allows drawing the guidelines which are fixed
    // parallel to each axis
    property point _guidelineIntersection: Qt.point(53.5, 0)

    // Defines where the
    property real _indicatorRatio: 0.5 //xAxisOperationValue/xAxisReferenceValue - 1

    property point _indicator: Qt.point(_droopLineMin.x + (_droopLineMax.x - _droopLineMin.x) * _indicatorRatio,
                                        _droopLineMin.y + (_droopLineMax.y - _droopLineMin.y) * _indicatorRatio)

    component GraphLine: ShapePath {
        strokeWidth: Theme.geometry_droopGraph_axis_width
        strokeColor: Theme.color_droopGraph_axis_line
        fillColor: "transparent"
        strokeStyle: ShapePath.SolidLine
        capStyle: ShapePath.RoundCap
        joinStyle: ShapePath.RoundJoin
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

    width: Theme.geometry_droopGraph_width
    height: Theme.geometry_droopGraph_height

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
        GraphLine { // default vertical guideline
            strokeWidth: Theme.geometry_droopGraph_guideline_width
            strokeStyle: ShapePath.DashLine
            dashPattern: [ 1, 2 ]
            startX: _origin.x + (_xAxis.x - _origin.x)/2 - 15; startY: _origin.y
            PathLine { x: _origin.x + (_xAxis.x - _origin.x)/2 - 15; y: _yAxis.y }
        }
        GraphLine { // default horizontal guideline
            strokeWidth: Theme.geometry_droopGraph_guideline_width
            strokeStyle: ShapePath.DashLine
            dashPattern: [ 1, 2 ]
            startX: _origin.x; startY: _origin.y + (_yAxis.y - _origin.y)/2
            PathLine { x: _xAxis.x - 15; y: _origin.y  + (_yAxis.y - _origin.y)/2 }
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
            // offset each end of the line for design purposes (x Axis)
            startX: _origin.x + Theme.geometry_droopGraph_axis_width; startY: _droopLineMin.y - Theme.geometry_droopGraph_droopLine_half_width
            PathLine { x: _droopLineMin.x; y: _droopLineMin.y - Theme.geometry_droopGraph_droopLine_half_width }
            PathLine { x: _droopLineMax.x; y: _droopLineMax.y - Theme.geometry_droopGraph_droopLine_half_width }
            PathLine { x: _xAxis.x - Theme.geometry_droopGraph_droopLine_xAxis_offset; y: _droopLineMax.y - Theme.geometry_droopGraph_droopLine_half_width }
            PathLine { x: _xAxis.x - Theme.geometry_droopGraph_droopLine_xAxis_offset; y: _droopLineMax.y + Theme.geometry_droopGraph_droopLine_half_width }
            PathLine { x: _droopLineMax.x; y: _droopLineMax.y + Theme.geometry_droopGraph_droopLine_half_width }
            PathLine { x: _droopLineMin.x; y: _droopLineMin.y + Theme.geometry_droopGraph_droopLine_half_width }
            PathLine { x: _origin.x + Theme.geometry_droopGraph_axis_width; y: _droopLineMin.y + Theme.geometry_droopGraph_droopLine_half_width  }
        }
        ShapePath { // dynamic horizontal guideline
            strokeWidth: Theme.geometry_droopGraph_indicator_guideline_width
            strokeColor: Theme.color_droopGraph_indicator_guidelines
            fillColor: "transparent"
            strokeStyle: ShapePath.DashLine
            dashPattern: [ 1, 2 ]
            // offset the end of the lines by the width of the graph axes
            startX: _indicator.x; startY: _origin.y - Theme.geometry_droopGraph_axis_width/2
            PathLine { x: _indicator.x; y: _indicator.y }
        }
        ShapePath { // dynamic vertical guideline
            strokeWidth: Theme.geometry_droopGraph_indicator_guideline_width
            strokeColor: Theme.color_droopGraph_indicator_guidelines
            fillColor: "transparent"
            strokeStyle: ShapePath.DashLine
            dashPattern: [ 1, 2 ]
            // offset the end of the lines by the width of the graph axes
            startX: _origin.x + Theme.geometry_droopGraph_axis_width/2; startY: _indicator.y
            PathLine { x: _indicator.x; y: _indicator.y }
        }
    }

    AxisLabel {
        id: yAxisLabel
        anchors {
            left: parent.left
            leftMargin: 27.5
            top: parent.top
        }
        text: root.yAxisLabel
    }
    QuantityLabel {
        id: yAxisReferenceQuantityLabel

        property real _yCalculated: _origin.y + (_yAxis.y - _origin.y)/2 - height/2

        anchors.left: parent.left
        y: _yCalculated // + abs(yCalulated - xAxisOperationQuantityLabel._yCalculated) < 20 ?
//           + (Math.abs(root.indicatorPercent) < 5) ? root.indicatorPercent /10 : 0
        width: Theme.geometry_droopGraph_yAxis_quantityLabel_width

        unit: VenusOS.Units_Percentage
        precision: 0
        valueColor: Theme.color_droopGraph_axis_line
        unitColor: Theme.color_droopGraph_axis_line
        font.pixelSize: Theme.font_size_body1
        verticalAlignment: Text.AlignVCenter
    }
    QuantityLabel {
        id: yAxisOperationQuantityLabel

        property real _yCalculated: _indicator.y - height/2

        anchors.left: parent.left
        y: _yCalculated
        width: Theme.geometry_droopGraph_yAxis_quantityLabel_width

        unit: VenusOS.Units_Percentage
        precision: 0
        valueColor: Theme.color_droopGraph_indicator_guidelines
        unitColor: Theme.color_droopGraph_indicator_guidelines
        font.pixelSize: Theme.font_size_body1
        verticalAlignment: Text.AlignVCenter
    }

    AxisLabel {
        id: xAxisLabel
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        text: root.xAxisLabel
    }
    QuantityLabel {
        id: xAxisReferenceQuantityLabel
        anchors.bottom: parent.bottom
        x: _origin.x + (_yAxis.x - _origin.x)/2 - width/2

        unit: root.xAxisUnit
        valueColor: Theme.color_droopGraph_axis_line
        unitColor: Theme.color_droopGraph_axis_line
        font.pixelSize: Theme.font_size_body1
        verticalAlignment: Text.AlignVCenter
    }
    QuantityLabel {
        id: xAxisOperationQuantityLabel
        anchors.bottom: parent.bottom
        x: _indicator.x - width/2

        unit: root.xAxisUnit
        valueColor: Theme.color_droopGraph_indicator_guidelines
        unitColor: Theme.color_droopGraph_indicator_guidelines
        font.pixelSize: Theme.font_size_body1
        verticalAlignment: Text.AlignVCenter
    }

    Indicator {
        id: indicator
        x: _indicator.x - width/2
        y: _indicator.y - height/2
    }
}

