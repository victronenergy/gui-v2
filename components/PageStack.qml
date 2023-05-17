import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

C.StackView {
	id: pageStack

	// Slide new drill-down pages in from the right
	pushEnter: Transition {
		NumberAnimation {
			property: "x"
			from: width
			to: 0
			duration: Theme.animation.page.slide.duration
			easing.type: Easing.InOutQuad
		}
	}
	pushExit: Transition {
		NumberAnimation {
			property: "x"
			from: 0
			to: -width
			duration: Theme.animation.page.slide.duration
			easing.type: Easing.InOutQuad
		}
	}
	popEnter: Transition {
		NumberAnimation {
			property: "x"
			from: -width
			to: 0
			duration: Theme.animation.page.slide.duration
			easing.type: Easing.InOutQuad
		}
	}
	popExit: Transition {
		NumberAnimation {
			property: "x"
			from: 0
			to: width
			duration: Theme.animation.page.slide.duration
			easing.type: Easing.InOutQuad
		}
	}
	replaceEnter: Transition {
		enabled: Global.allPagesLoaded

		OpacityAnimator {
			from: 0.0
			to: 1.0
			duration: Theme.animation.page.slide.duration
			easing.type: Easing.InOutQuad
		}
	}
	replaceExit: Transition {
		enabled: Global.allPagesLoaded

		OpacityAnimator {
			from: 1.0
			to: 0.0
			duration: Theme.animation.page.slide.duration
			easing.type: Easing.InOutQuad
		}
	}
}
