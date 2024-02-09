/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

C.StackView {
	id: pageStack

	onDepthChanged: if (depth === 1) pageStack.navbarX = 0

	// the x position that the navbar should follow.
	property real navbarX

	// Slide new drill-down pages in from the right
	pushEnter: Transition {
		XAnimator {
			from: width
			to: 0
			duration: Theme.animation_page_slide_duration
			easing.type: Easing.InOutQuad
		}
	}

	pushExit: Transition {
		ScriptAction { script: if (pageStack.depth === 2) pageStack.navbarX = -width }
		XAnimator {
			from: 0
			to: -width
			duration: Theme.animation_page_slide_duration
			easing.type: Easing.InOutQuad
		}
	}
	popEnter: Transition {
		XAnimator {
			from: -width
			to: 0
			duration: Theme.animation_page_slide_duration
			easing.type: Easing.InOutQuad
		}
	}

	popExit: Transition {
		XAnimator {
			from: 0
			to: width
			duration: Theme.animation_page_slide_duration
			easing.type: Easing.InOutQuad
		}
	}

	replaceEnter: Transition {
		enabled: Global.allPagesLoaded

		OpacityAnimator {
			from: 0.0
			to: 1.0
			duration: Theme.animation_page_slide_duration
			easing.type: Easing.InOutQuad
		}
	}

	replaceExit: Transition {
		enabled: Global.allPagesLoaded

		OpacityAnimator {
			from: 1.0
			to: 0.0
			duration: Theme.animation_page_slide_duration
			easing.type: Easing.InOutQuad
		}
	}
}
