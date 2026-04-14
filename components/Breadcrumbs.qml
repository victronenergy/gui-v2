import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

BaseListView {
	id: root

	required property PageStack pageStack
	property int focusEdgeHint: Qt.LeftEdge
	property color primaryBreadcrumbColor: Theme.color_settings_breadcrumb_background_top_page
	property color secondaryBreadcrumbColor: Theme.color_settings_breadcrumb_background

	function activate(index) {
		const isTopBreadcrumb = index === root.count - 1
		const isBottomBreadcrumb = index === 0

		if (isBottomBreadcrumb) { // the bottom breadcrumb is a special case, we inserted a dummy breadcrumb with the text "Settings" which doesn't relate to anything in the pageStack
			Global.pageManager.popAllPages()
			return
		}

		if (isTopBreadcrumb) { // ignore clicks on the top of the breadcrumb trail. We don't need to navigate there, we are already there...
			return
		}

		Global.pageManager.popPage(pageStack.get(index - 1)) // subtract 1, because we inserted a dummy "Settings" breadcrumb at the beginning
	}

	implicitHeight: Theme.geometry_settings_breadcrumb_height
	orientation: ListView.Horizontal
	currentIndex: count - 1
	clip: true
	model: root.pageStack.opened ? root.pageStack.depth + 1 : null // '+ 1' because we insert a dummy breadcrumb with the text "Settings"
	visible: count >= 2
	enabled: visible // don't receive focus when invisble
	focus: false // don't give status bar initial focus to the breadcrumbs

	delegate: ListItem {
		id: breadcrumb

		required property int index
		readonly property bool isTopBreadcrumb: index === root.count - 1
		readonly property bool isBottomBreadcrumb: index === 0
		readonly property color iconColor: isTopBreadcrumb ? primaryBreadcrumbColor : secondaryBreadcrumbColor

		implicitWidth: implicitContentWidth + leftPadding + rightPadding
		implicitHeight: Theme.geometry_settings_breadcrumb_height
		leftInset: leftEdgeIcon.width
		rightInset: rightEdgeIcon.width
		leftPadding: Theme.geometry_settings_breadcrumb_horizontalMargin + leftEdgeIcon.width
		rightPadding: Theme.geometry_settings_breadcrumb_horizontalMargin + rightEdgeIcon.width

		contentItem: Label {
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			height: parent.height
			color: breadcrumb.isTopBreadcrumb ? Theme.color_settings_breadcrumb_primaryText : Theme.color_settings_breadcrumb_secondaryText
			font.pixelSize: Theme.font_breadcrumbs_pixelSize
			text: breadcrumb.index === 0
					? Global.pageManager?.navBar?.currentTitle ?? "" // eg: "Settings"
					: root.pageStack.get(breadcrumb.index - 1).title // eg: "Device list"
		}
		background: Rectangle {
			color: breadcrumb.iconColor
		}

		Keys.onSpacePressed: root.activate(breadcrumb.index)

		CP.ColorImage {
			id: leftEdgeIcon
			color: breadcrumb.iconColor
			source: "qrc:/images/breadcrumb_lhs.svg"
		}

		CP.ColorImage {
			id: rightEdgeIcon
			anchors.right: parent.right
			color: breadcrumb.iconColor
			source: "qrc:/images/breadcrumb_rhs.svg"
		}

		PressArea {
			anchors.fill: parent
			onClicked: root.activate(breadcrumb.index)
		}
	}

	// Whenever a breadcrumb is added or removed, scroll to the end to make the last crumb visible.
	onCountChanged: positionViewAtEnd()

	onActiveFocusChanged: {
		if (activeFocus && focusEdgeHint >= 0) {
			// Focus the first (left-most) or last (right-most) breadcrumb, depending the side
			// that the key navigation is arriving from.
			currentIndex = focusEdgeHint === Qt.LeftEdge ? 0 : count - 1
			focusEdgeHint = -1
		}
	}

	Connections {
		target: root.pageStack
		enabled: root.pageStack.opened && Global.keyNavigationEnabled
		function onDepthChanged() {
			// When pages are pushed/popped, reset the focus to be on the last breadcrumb.
			root.currentIndex = root.count - 1
		}
	}

	Rectangle { // fade out the breadcrumbs LHS when overflowing
		width: parent.width
		height: Theme.geometry_settings_breadcrumb_height
		visible: !root.atXBeginning

		gradient: Gradient {
			orientation: Gradient.Horizontal

			GradientStop {
				position: 0
				color: Theme.color_viewGradient_color3
			}
			GradientStop {
				position: Theme.geometry_breadcrumbs_viewGradient_width / 2
				color: Theme.color_viewGradient_color2
			}
			GradientStop {
				position: Theme.geometry_breadcrumbs_viewGradient_width
				color: Theme.color_viewGradient_color1
			}
		}
	}
}
