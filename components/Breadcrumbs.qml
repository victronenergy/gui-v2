import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

BaseListView {
	id: root

	property color primaryBreadcrumbColor: Theme.color_settings_breadcrumb_background_top_page
	property color secondaryBreadcrumbColor: Theme.color_settings_breadcrumb_background

	signal clicked(index : int)

	property var getText // override with function

	orientation: ListView.Horizontal
	currentIndex: count - 1
	clip: true

	delegate: ListItemControl {
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
			text: getText(breadcrumb.index)
		}
		background: Rectangle {
			color: breadcrumb.iconColor
		}

		Keys.onSpacePressed: root.clicked(breadcrumb.index)

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
			onClicked: root.clicked(breadcrumb.index)
		}
	}

	// Whenever a breadcrumb is added or removed, scroll to the end to make the last crumb visible.
	onCountChanged: positionViewAtEnd()

	Rectangle { // fade out the breadcrumbs LHS when overflowing
		anchors.fill: parent
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

	Rectangle { // fade out the breadcrumbs RHS when overflowing
		anchors.fill: parent
		visible: !root.atXEnd

		gradient: Gradient {
			orientation: Gradient.Horizontal

			GradientStop {
				position: 1 - Theme.geometry_breadcrumbs_viewGradient_width
				color: Theme.color_viewGradient_color1
			}
			GradientStop {
				position: 1 - Theme.geometry_breadcrumbs_viewGradient_width / 2
				color: Theme.color_viewGradient_color2
			}
			GradientStop {
				position: 1
				color: Theme.color_viewGradient_color3
			}
		}
	}
}
