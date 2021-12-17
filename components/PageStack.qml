import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

C.StackView {
	id: pageStack
	initialItem: "qrc:/pages/MainPage.qml"

	// Slide new drill-down pages in from the right
	pushEnter: Transition {
		NumberAnimation {
			property: "x"
			from: width
			to: 0
			duration: 250
		}
	}
	pushExit: Transition {
		NumberAnimation {
			property: "x"
			from: 0
			to: -width
			duration: 250
		}
	}
	popEnter: Transition {
		NumberAnimation {
			property: "x"
			from: -width
			to: 0
			duration: 250
		}
	}
	popExit: Transition {
		NumberAnimation {
			property: "x"
			from: 0
			to: width
			duration: 250
		}
	}
}
