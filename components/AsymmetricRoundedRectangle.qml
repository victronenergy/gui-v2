/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS

Item {
	id: root

	property bool flat: false // has outline/border by default
	property int roundedSide: VenusOS.AsymmetricRoundedRectangle_RoundedSide_Left
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
			leftMargin: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Left ? root.radius : 0
			rightMargin: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Right ? root.radius : 0
		}

		visible: root.roundedSide !== VenusOS.AsymmetricRoundedRectangle_RoundedSide_All

		color: roundedRect.border.color
	}

	Rectangle {
		id: bottomBorderRect
		anchors {
			fill: parent
			topMargin: root.height - root.border.width
			leftMargin: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Left ? root.radius : 0
			rightMargin: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Right ? root.radius : 0
		}

		visible: root.roundedSide !== VenusOS.AsymmetricRoundedRectangle_RoundedSide_All

		color: roundedRect.border.color
	}

	Rectangle {
		id: backgroundRect
		anchors {
			fill: parent
			topMargin: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Top ? root.radius : 0
			bottomMargin: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Bottom ? root.radius : 0
			leftMargin: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Left ? root.radius : 0
			rightMargin: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Right ? root.radius : 0
		}

		visible: root.roundedSide !== VenusOS.AsymmetricRoundedRectangle_RoundedSide_All

		color: roundedRect.color
	}

	Item {
		id: clipRect
		anchors {
			fill: parent
			leftMargin: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Right ? root.width - root.radius : 0
			rightMargin: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Left ? root.width - root.radius : 0
			topMargin: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Bottom ? root.height - root.radius : 0
			bottomMargin: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Top ? root.height - root.radius : 0
		}

		visible: root.roundedSide !== VenusOS.AsymmetricRoundedRectangle_RoundedSide_NoneHorizontal
		clip: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Left
			  || root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Right
			  || root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Top
			  || root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Bottom

		Rectangle {
			id: roundedRect
			x: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Right ? -(root.width - root.radius) : 0
			y: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Bottom ? -(root.height - root.radius) : 0
			width: root.width
			height: root.height
			color: Theme.color.darkOk
			radius: Theme.geometry.button.radius
			border.width: root.flat ? 0 : Theme.geometry.button.border.width
			border.color: Theme.color.ok
		}
	}
}
