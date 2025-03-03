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

	delegate: BaseListItem {
		id: breadcrumb

		readonly property bool isTopBreadcrumb: index === root.count - 1
		readonly property bool isBottomBreadcrumb: index === 0
		readonly property color iconColor: isTopBreadcrumb ? primaryBreadcrumbColor : secondaryBreadcrumbColor

		height: root.height
		width: contentRow.width
		background.visible: false

		Keys.onSpacePressed: root.clicked(index)
		Keys.enabled: Global.keyNavigationEnabled

		Row {
			id: contentRow
			height: parent.height

			CP.ColorImage {
				color: breadcrumb.iconColor
				source: "qrc:/images/breadcrumb_lhs.svg"
			}

			Label {
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				height: parent.height
				width: implicitWidth + Theme.geometry_settings_breadcrumb_horizontalMargin * 2
				color: breadcrumb.isTopBreadcrumb ? Theme.color_settings_breadcrumb_primaryText : Theme.color_settings_breadcrumb_secondaryText
				background: Rectangle {
					color: breadcrumb.iconColor
					height: parent.height
				}
				text: getText(index)
			}

			CP.ColorImage {
				color: breadcrumb.iconColor
				source: "qrc:/images/breadcrumb_rhs.svg"
			}
		}

		PressArea {
			anchors.fill: parent
			onClicked: root.clicked(index)
		}
	}

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
