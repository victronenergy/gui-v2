/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	property var _editPointDialog
	readonly property bool _canEditPoints: Global.systemSettings.canAccess(VenusOS.User_AccessType_Installer)

	topRightButton: _canEditPoints && pointsListView.count < 10
			? VenusOS.StatusBar_RightButton_Add
			: VenusOS.StatusBar_RightButton_None

	Connections {
		target: !!Global.pageManager ? Global.pageManager.statusBar : null
		enabled: root._canEditPoints && root.isCurrentPage

		function onRightButtonClicked() {
			if (!root._editPointDialog) {
				root._editPointDialog = editPointDialogComponent.createObject(root)
			}
			root._editPointDialog.sensorLevel = 1
			root._editPointDialog.volume = 1
			root._editPointDialog.modelIndex = -1
			root._editPointDialog.open()
		}
	}

	VeQuickItem {
		id: points

		property bool _saving

		function savePoints(pointList) {
			const formattedPoints = pointList.map(function(v) { return v.join(":") }).join(",")
			_saving = true
			setValue(formattedPoints)
			_saving = false
		}

		uid: root.bindPrefix + "/Shape"
		onValueChanged: {
			if (_saving) {
				return
			}
			if (!value) {
				pointsListView.model = []
			} else if (value.length > 0) {
				// Value is a comma-separated list of "<sensor-level>:<volume>" pairs.
				// E.g. "2:5,64:13,89:32"
				pointsListView.model = value.split(",").map(function(v) {
					const pair = v.split(":")
					try {
						return [ parseInt(pair[0]), parseInt(pair[1]) ]
					} catch (e) {
						console.warn("Bad shape data:", value, "exception:", e)
						return [ 0,0 ]
					}
				})
			}
		}
	}

	GradientListView {
		id: pointsListView

		header: PrimaryListLabel {
			//% "No custom shape defined. You may define one with up to ten points. Note that 0% and 100% are implied."
			text: qsTrId("devicelist_tankshape_empty")
			preferredVisible: pointsListView.count === 0
		}

		delegate: ListItem {
			id: pointDelegate

			required property int index
			required property var modelData
			readonly property real sensorLevel: modelData[0]
			readonly property real volume: modelData[1]

			//: %1 = the point number
			//% "Point %1"
			text: qsTrId("devicelist_tankshape_point").arg(index + 1)
			content.children: [
				QuantityRow {
					model: QuantityObjectModel {
						QuantityObject { object: pointDelegate; key: "sensorLevel"; unit: VenusOS.Units_Percentage }
						QuantityObject { object: pointDelegate; key: "volume"; unit: VenusOS.Units_Percentage }
					}
				},

				CP.ColorImage {
					anchors.verticalCenter: parent.verticalCenter
					source: "qrc:/images/icon_minus.svg"
					color: Theme.color_ok
					visible: root._canEditPoints

					MouseArea {
						anchors.fill: parent
						onClicked: {
							let pointList = pointsListView.model
							pointList.splice(pointDelegate.index, 1)
							points.savePoints(pointList)
							pointsListView.model = pointList
						}
					}
				}
			]
		}
	}

	Component {
		id: editPointDialogComponent

		ModalDialog {
			id: root

			property alias sensorLevel: sensorLevelSpinBox.value
			property alias volume: volumeSpinBox.value
			property int modelIndex

			property var _pointArrayToSave

			//% "Add point"
			title: qsTrId("devicelist_tankshape_add_point")

			contentItem: ModalDialog.FocusableContentItem {
				Row {
					id: spinBoxRow

					anchors {
						centerIn: parent
						verticalCenterOffset: -Theme.geometry_modalDialog_content_margins
					}
					spacing: Theme.geometry_modalDialog_content_spacing

					Column {
						width: sensorLevelSpinBox.width
						spacing: Theme.geometry_modalDialog_content_margins

						Label {
							width: parent.width
							wrapMode: Text.Wrap
							horizontalAlignment: Text.AlignHCenter
							color: Theme.color_font_secondary
							//: The sensor level (as a percentage) for this tank shape point
							//% "Sensor level"
							text: qsTrId("devicelist_tankshape_sensor_level")
						}

						SpinBox {
							id: sensorLevelSpinBox
							width: Theme.geometry_tankShapeSelector_spinBox_width
							height: Theme.geometry_tankShapeSelector_spinBox_height
							spacing: Theme.geometry_spinBox_wide_spacing
							from: 1
							to: 99
							textFromValue: function(value, locale) { return value + "%" }
							onValueModified: errorLabel.text = ""

							// Use BeforeItem priority to override the default key Spinbox event handling, else
							// up/down keys will modify the number even when SpinBox is not in "edit" mode.
							focus: true
							KeyNavigation.priority: KeyNavigation.BeforeItem
							KeyNavigation.up: sensorLevelSpinBox
							KeyNavigation.down: root.footer
							KeyNavigation.right: volumeSpinBox
						}
					}

					Column {
						width: volumeSpinBox.width
						spacing: Theme.geometry_modalDialog_content_margins

						Label {
							width: parent.width
							wrapMode: Text.Wrap
							horizontalAlignment: Text.AlignHCenter
							color: Theme.color_font_secondary
							//: The volume (as a percentage) for this tank shape point
							//% "Volume"
							text: qsTrId("devicelist_tankshape_volume")
						}

						SpinBox {
							id: volumeSpinBox

							width: Theme.geometry_tankShapeSelector_spinBox_width
							height: Theme.geometry_tankShapeSelector_spinBox_height
							spacing: Theme.geometry_spinBox_wide_spacing
							from: 1
							to: 99
							textFromValue: function(value, locale) { return value + "%" }
							onValueModified: errorLabel.text = ""

							KeyNavigation.priority: KeyNavigation.BeforeItem
							KeyNavigation.up: volumeSpinBox
							KeyNavigation.down: root.footer
							KeyNavigation.left: sensorLevelSpinBox
						}
					}
				}

				Row {
					anchors {
						top: spinBoxRow.bottom
						topMargin: Theme.geometry_modalDialog_content_margins
						horizontalCenter: parent.horizontalCenter
					}
					spacing: Theme.geometry_listItem_content_spacing
					visible: errorLabel.text.length > 0

					CP.ColorImage {
						id: alarmIcon

						source: "qrc:/images/icon_warning_24.svg"
						color: Theme.color_red
					}

					Label {
						id: errorLabel

						width: Math.min(implicitWidth, spinBoxRow.width - alarmIcon.width - parent.spacing)
						wrapMode: Text.Wrap
						color: Theme.color_font_secondary
					}
				}
			}

			onAboutToShow: {
				errorLabel.text = ""
			}

			tryAccept: function() {
				_pointArrayToSave = ""
				let pointList = pointsListView.model
				const quantities = [ sensorLevelSpinBox.value, volumeSpinBox.value ]
				if (modelIndex < 0) {
					pointList.push(quantities)
				} else {
					pointList[modelIndex] = quantities
				}
				pointList.sort(function(a, b) { return a[0] - b[0] });

				for (let i = 1; i < pointList.length; i++) {
					if (pointList[i][0] <= pointList[i - 1][0]) {
						//% "Duplicate sensor level values are not allowed."
						errorLabel.text = qsTrId("devicelist_tankshape_duplicate_sensor_level")
						return false
					}

					if (pointList[i][1] <= pointList[i - 1][1]) {
						//% "Volume values must be increasing."
						errorLabel.text = qsTrId("devicelist_tankshape_volume_not_increasing")
						return false
					}
				}
				_pointArrayToSave = pointList
				return true
			}

			onAccepted: {
				points.savePoints(_pointArrayToSave)
				pointsListView.model = _pointArrayToSave
			}
		}
	}
}
