/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

/*
** If there are too many gauges to fit on the screen, gauges of the same type (eg. Fuel) will be merged into a single gauge, containing several tanks.
** The user may click on a merged gauge, which will give an expanded view containing separate gauges, each containing a single tank.
** If tanks are removed, merged tanks will be split back into individual tanks if there is enough space to display them.
*/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Gauges

LevelsTab {
	id: root

	model: AggregateTankModel {
		mergeThreshold: Theme.geometry_levelsPage_tankMergeThreshold
		tankModels: Global.tanks.allTankModels
	}

	delegate: TankGaugePanel {
		width: root.orientation === ListView.Vertical
			   ? ListView.view.width
			   : Gauges.width(root.count, Theme.geometry_levelsPage_max_tank_count, root.width)
		height: root.orientation === ListView.Vertical
			   ? implicitHeight
			   : Gauges.height(Global.pageManager?.expandLayout ?? false)
		animationEnabled: root.animationEnabled
		focusPolicy: Qt.TabFocus

		Behavior on height {
			enabled: root.animationEnabled && Global.pageManager?.animatingIdleResize
			NumberAnimation {
				duration: Theme.animation_page_idleResize_duration
				easing.type: Easing.InOutQuad
			}
		}

		KeyNavigationHighlight.active: activeFocus
		KeyNavigationHighlight.leftMargin: leftInset
		KeyNavigationHighlight.rightMargin: rightInset
		Keys.enabled: Global.keyNavigationEnabled
		Keys.onSpacePressed: (event) => {
			if (pressArea.enabled) {
				pressArea.clicked(null)
			} else {
				event.accepted = false
			}
		}

		PressArea {
			id: pressArea
			anchors.fill: parent
			radius: Theme.geometry_levelsPage_panel_radius
			enabled: parent.isGroup
			onClicked: {
				Global.dialogLayer.open(expandedTanksComponent, { tankModel: tankModel })
			}
		}
	}

	// If you have multiple tanks merged into a single gauge, you can click on the gauge.
	// This popup appears, containing an exploded view with each of the tanks in its own gauge.
	Component {
		id: expandedTanksComponent

		ModalDialog {
			id: expandedDialog

			property TankModel tankModel

			header: null
			footer: null
			backgroundColor: "transparent"
			leftMargin: 0
			rightMargin: 0
			topPadding: Theme.geometry_tankGaugeDialog_topPadding
			bottomPadding: Theme.geometry_tankGaugeDialog_bottomPadding

			background: DialogShadow {
				implicitWidth: Theme.geometry_screen_width
				implicitHeight: Theme.geometry_screen_height

				MouseArea {
					anchors.fill: parent
					onClicked: expandedDialog.accept()
				}
			}

			contentItem: Item {
				focus: true

				Keys.onPressed: expandedDialog.accept()
				Keys.enabled: Global.keyNavigationEnabled

				CP.ColorImage {
					id: closeIcon

					anchors {
						bottom: expandedTanksView.top
						bottomMargin: Theme.geometry_tankGaugeDialog_closeButton_leftMargin
						right: parent.right
						rightMargin: Theme.geometry_tankGaugeDialog_closeButton_rightMargin
					}
					color: Theme.color_ok
					source: "qrc:/images/icon_close_32.svg"
				}

				ExpandedTanksView {
					id: expandedTanksView

					anchors.centerIn: parent
					width: Theme.geometry_screen_width
					height: Theme.screenSize === Theme.Portrait
							? Math.min(contentHeight, Theme.geometry_screen_height)
							: parent.height

					leftMargin: Theme.screenSize === Theme.Portrait ? 0
							: contentWidth > width
								? Theme.geometry_levelsPage_gaugesView_horizontalMargin
								: parent.width/2 - contentWidth / 2
					rightMargin: Theme.screenSize === Theme.Portrait ? 0
							: contentWidth > width
								 ? Theme.geometry_levelsPage_gaugesView_horizontalMargin
								 : 0
					model: expandedDialog.tankModel
					animationEnabled: root.animationEnabled

					MouseArea {
						anchors.fill: parent
						onClicked: expandedDialog.accept()
					}
				}
			}
		}
	}
}
