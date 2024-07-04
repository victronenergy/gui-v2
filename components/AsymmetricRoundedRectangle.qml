/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
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

	// ensure that the entire texture is faded equally during animations
	// otherwise the clip messes with this on WASM platform.
	layer.enabled: true

	// we have to draw each element separately as any of the colors may have transparency...
	// the order of declaration matters, because any of the colors may be fully opaque...

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
			leftMargin: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Right ? root.width - root.radius - 1 : 0
			rightMargin: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Left ? root.width - root.radius - 1 : 0
			topMargin: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Bottom ? root.height - root.radius - 1 : 0
			bottomMargin: root.roundedSide === VenusOS.AsymmetricRoundedRectangle_RoundedSide_Top ? root.height - root.radius - 1 : 0
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
			color: Theme.color_darkOk
			radius: Theme.geometry_button_radius
			border.width: root.flat ? 0 : Theme.geometry_button_border_width
			border.color: Theme.color_ok
		}
	}

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
}
