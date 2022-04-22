import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

C.StackView {
	id: pageStack

	property PageManager pageManager
	Component.onCompleted: {
		if (Global.pageManager == null) {
			Global.pageManager = pageManager
		}
		pageStack.push("qrc:/pages/MainPage.qml")
	}

	// Slide new drill-down pages in from the right
	pushEnter: Transition {
		NumberAnimation {
			onRunningChanged: console.log("PageStack pushEnter animation: running:", running)
			property: "x"
			from: width
			to: 0
			duration: Theme.animation.page.slide.duration
			easing.type: Easing.InOutQuad
		}
	}
	pushExit: Transition {
		NumberAnimation {
			onRunningChanged: console.log("PageStack pushExit animation: running:", running)
			property: "x"
			from: 0
			to: -width
			duration: Theme.animation.page.slide.duration
			easing.type: Easing.InOutQuad
		}
	}
	popEnter: Transition {
		NumberAnimation {
			onRunningChanged: console.log("PageStack popEnter animation: running:", running)
			property: "x"
			from: -width
			to: 0
			duration: Theme.animation.page.slide.duration
			easing.type: Easing.InOutQuad
		}
	}
	popExit: Transition {
		NumberAnimation {
			onRunningChanged: console.log("PageStack popExit animation: running:", running)
			property: "x"
			from: 0
			to: width
			duration: Theme.animation.page.slide.duration
			easing.type: Easing.InOutQuad
		}
	}
}
