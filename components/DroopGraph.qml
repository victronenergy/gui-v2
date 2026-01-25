/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import QtQuick.Shapes
import Victron.VenusOS

Item {
    id: root

    property string xAxisLabel
    property string yAxisLabel

    property alias xAxisUnit: xAxisQuantity.unit
    property alias yAxisUnit: yAxisQuantity.unit

    property point _origin: Qt.point(53.5, 138)
    property point _xAxis: Qt.point(53.5 + 283, 138)
    property point _yAxis: Qt.point(53.5, 0)

    property point _droopLineMin: Qt.point(53.5 + 30.5, 30)
    property point _droopLineMax: Qt.point(53.5 + 250, 120)

    property real indicatorPercent: 50

    property point _indicator: Qt.point(_droopLineMin.x + (_droopLineMax.x - _droopLineMin.x) * indicatorPercent/100,
                                        _droopLineMin.y + (_droopLineMax.y - _droopLineMin.y) * indicatorPercent/100)

    component GraphLine: ShapePath {
        strokeWidth: Theme.geometry_droopGraph_axis_width
        strokeColor: Theme.color_droop_graph_axis_line
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
        color: Theme.color_droop_graph_axis_line
        font.pixelSize: Theme.font_size_tiny
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    implicitWidth: Theme.geometry_droopGraph_width
    implicitHeight: Theme.geometry_droopGraph_height

    Shape {
        anchors.fill: parent

        // draw the fixed static background shapes
        GraphLine { // axes lines
            startX: _xAxis.x; startY: _xAxis.y
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
            strokeWidth: 1.5
            strokeStyle: ShapePath.DashLine
            dashPattern: [ 1, 2 ]
            startX: _origin.x + (_xAxis.x - _origin.x)/2 - 15; startY: _origin.y
            PathLine { x: _origin.x + (_xAxis.x - _origin.x)/2 - 15; y: _yAxis.y }
        }
        GraphLine { // default horizontal guideline
            strokeWidth: 1.5
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
                GradientStop { position: 0.0; color: Theme.color_droop_graph_gradient_edge }
                GradientStop { position: 0.3; color: Theme.color_droop_graph_gradient_centre }
                GradientStop { position: 0.6; color: Theme.color_droop_graph_gradient_centre }
                GradientStop { position: 1.0; color: Theme.color_droop_graph_gradient_edge }
            }
            startX: _origin.x + 2; startY: _droopLineMin.y - Theme.geometry_droopGraph_droopLine_half_width
            PathLine { x: _droopLineMin.x; y: _droopLineMin.y - Theme.geometry_droopGraph_droopLine_half_width }
            PathLine { x: _droopLineMax.x; y: _droopLineMax.y - Theme.geometry_droopGraph_droopLine_half_width }
            PathLine { x: _xAxis.x - 15; y: _droopLineMax.y - Theme.geometry_droopGraph_droopLine_half_width }
            PathLine { x: _xAxis.x - 15; y: _droopLineMax.y + Theme.geometry_droopGraph_droopLine_half_width }
            PathLine { x: _droopLineMax.x; y: _droopLineMax.y + Theme.geometry_droopGraph_droopLine_half_width }
            PathLine { x: _droopLineMin.x; y: _droopLineMin.y + Theme.geometry_droopGraph_droopLine_half_width }
            PathLine { x: _origin.x + 2; y: _droopLineMin.y + Theme.geometry_droopGraph_droopLine_half_width  }
        }
        ShapePath { // dynamic vertical guideline
            strokeWidth: 2
            strokeColor: Theme.color_droop_graph_indicator_guidelines
            fillColor: "transparent"
            strokeStyle: ShapePath.DashLine
            dashPattern: [ 1, 2 ]
            // offset the end of the lines by the width of the graph axes
            startX: _indicator.x; startY: _origin.y - 5 //- Theme.geometry_droopGraph_axis_width/2
            PathLine { x: _indicator.x; y: _indicator.y }
            PathLine { x: _origin.x; y: _indicator.y }
        }
    }

    AxisLabel {
        id: xAxisLabel
        anchors {
            left: parent.left
            leftMargin: 27.5
            top: parent.top
        }

        text: root.xAxisLabel
    }
    QuantityLabel {
        id: xAxisZeroQuantity
        anchors.right: xAxisLabel.right
        y: _origin.y + (_yAxis.y - _origin.y)/2 - height/2
        value: 0
        unit: VenusOS.Units_Percentage
        unitColor: Theme.color_droop_graph_axis_line
        font.pixelSize: Theme.font_size_body1
        verticalAlignment: Text.AlignVCenter
    }
    QuantityLabel {
        id: xAxisQuantity
        anchors.right: xAxisLabel.right
        y: _indicator.y - height/2
        value: root.indicatorPercent
        unit: VenusOS.Units_Percentage
        unitColor: Theme.color_droop_graph_axis_line
        font.pixelSize: Theme.font_size_body1
        verticalAlignment: Text.AlignVCenter
    }

    AxisLabel {
        id: yAxisLabel
        anchors {
            right: parent.right
            bottom: parent.bottom
        }

        text: root.yAxisLabel
    }
    QuantityLabel {
        id: yAxisQuantity
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }
        value: 55
        valueColor: Theme.color_droop_graph_axis_line
        unit: VenusOS.Units_Hertz
        unitColor: Theme.color_droop_graph_axis_line
        font.pixelSize: Theme.font_size_body1
        verticalAlignment: Text.AlignVCenter
    }

    Indicator {
        id: indicator
        x: _indicator.x - width/2
        y: _indicator.y - height/2
    }
}

