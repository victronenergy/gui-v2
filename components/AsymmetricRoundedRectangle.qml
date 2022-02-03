/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS

Item {
	id: root

	enum RoundedSide {
		All,			// allow all sides to be rounded, show all borders
		Left,			// round left, hide right border
		Right,			// round right, hide left border
		Top,			// round top, hide bottom border
		Bottom,			// round bottom, hide top border
		NoneHorizontal	// no rounding, show top/bottom borders only
	}

	property bool flat: false // has outline/border by default
	property int roundedSide: AsymmetricRoundedRectangle.RoundedSide.Left
	property alias backgroundColor: backgroundRect.color // must be opaque and match the surface the control is placed on
	property alias color: roundedRect.color
	property alias radius: roundedRect.radius
	property alias border: roundedRect.border

	// we have to draw each element separately as any of the colors may have transparency...

	Rectangle {
		id: topBorderRect
		anchors {
			fill: parent
			bottomMargin: root.height - root.border.width
			leftMargin: root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Left ? root.radius : 0
			rightMargin: root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Right ? root.radius : 0
		}

		visible: root.roundedSide !== AsymmetricRoundedRectangle.RoundedSide.All

		color: roundedRect.border.color
	}

	Rectangle {
		id: bottomBorderRect
		anchors {
			fill: parent
			topMargin: root.height - root.border.width
			leftMargin: root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Left ? root.radius : 0
			rightMargin: root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Right ? root.radius : 0
		}

		visible: root.roundedSide !== AsymmetricRoundedRectangle.RoundedSide.All

		color: roundedRect.border.color
	}

	Rectangle {
		id: backgroundRect
		anchors {
			fill: parent
			topMargin: root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Top ? root.radius : 0
			bottomMargin: root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Bottom ? root.radius : 0
			leftMargin: root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Left ? root.radius : 0
			rightMargin: root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Right ? root.radius : 0
		}

		visible: root.roundedSide !== AsymmetricRoundedRectangle.RoundedSide.All

		color: roundedRect.color
	}

	Item {
		id: clipRect
		anchors {
			fill: parent
			leftMargin: root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Right ? root.width - root.radius : 0
			rightMargin: root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Left ? root.width - root.radius : 0
			topMargin: root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Bottom ? root.height - root.radius : 0
			bottomMargin: root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Top ? root.height - root.radius : 0
		}

		visible: root.roundedSide !== AsymmetricRoundedRectangle.RoundedSide.NoneHorizontal
		clip: root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Left
			  || root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Right
			  || root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Top
			  || root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Bottom

		Rectangle {
			id: roundedRect
			x: root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Right ? -(root.width - root.radius) : 0
			y: root.roundedSide === AsymmetricRoundedRectangle.RoundedSide.Bottom ? -(root.height - root.radius) : 0
			width: root.width
			height: root.height
			color: Theme.color.button.outline.background
			radius: Theme.geometry.button.radius
			border.width: root.flat ? 0 : Theme.geometry.button.border.width
			border.color: Theme.color.button.outline.border
		}
	}
}
