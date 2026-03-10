/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
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
		target: Global.mainView?.statusBar ?? null
		enabled: root._canEditPoints && root.isCurrentPage

		function onRightButtonClicked() {
			Global.dialogLayer.open(editPointDialogComponent, {
					"sensorLevel": 1,
					"volume": 1,
					"modelIndex": -1
				})
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

		delegate: ListSetting {
			id: pointDelegate

			required property int index
			required property var modelData
			readonly property real sensorLevel: !!modelData ? modelData[0] : NaN
			readonly property real volume: !!modelData ? modelData[1] : NaN

			contentItem: RowLayout {
				spacing: pointDelegate.spacing

				Label {
					//: %1 = the point number
					//% "Point %1"
					text: qsTrId("devicelist_tankshape_point").arg(index + 1)
					font: pointDelegate.font
					Layout.fillWidth: true
				}

				QuantityRow {
					model: QuantityObjectModel {
						QuantityObject { object: pointDelegate; key: "sensorLevel"; unit: VenusOS.Units_Percentage }
						QuantityObject { object: pointDelegate; key: "volume"; unit: VenusOS.Units_Percentage }
					}
				}

				RemoveButton {
					visible: root._canEditPoints
					onClicked: {
						let pointList = pointsListView.model
						let pointsItem = points
						pointList.splice(pointDelegate.index, 1)
						pointsItem.savePoints(pointList)
					}
				}
			}

			background: ListSettingBackground {
				indicatorColor: pointDelegate.backgroundIndicatorColor

				ListPressArea {
					anchors.fill: parent
					enabled: pointDelegate.interactive
					onClicked: pointDelegate.editPoints()
				}
			}

			interactive: root._canEditPoints
			Keys.onSpacePressed: editPoints()

			function editPoints() {
				let sensorLevelMax = 0
				let sensorLevelMin = 0
				let volumeMax = 0
				let volumeMin = 0

				// need to set max allowed values when editing a point
				// if there is another point after it.
				const pointCount = pointsListView.model.length
				if (pointCount >= 2 && pointDelegate.index < (pointCount - 1)) {
					let nextPoint = pointsListView.model[pointDelegate.index + 1]
					sensorLevelMax = nextPoint[0]
					volumeMax = nextPoint[1]
				} else {
					sensorLevelMax = 99
					volumeMax = 99
				}

				// need to set min allowed values when editing a point
				// if there is another point before it.
				if (pointCount >= 2 && pointDelegate.index > 0) {
					let prevPoint = pointsListView.model[pointDelegate.index - 1]
					sensorLevelMin = prevPoint[0]
					volumeMin = prevPoint[1]
				} else {
					sensorLevelMin = 1
					volumeMin = 1
				}

				Global.dialogLayer.open(editPointDialogComponent, {
						"sensorLevel": pointDelegate.sensorLevel,
						"sensorLevelMax": sensorLevelMax,
						"sensorLevelMin": sensorLevelMin,
						"volume": pointDelegate.volume,
						"volumeMax": volumeMax,
						"volumeMin": volumeMin,
						"modelIndex": pointDelegate.index
					})
			}
		}
	}

	Component {
		id: editPointDialogComponent

		ModalDialog {
			id: root

			property alias sensorLevelMin: sensorLevelSpinBox.from
			property alias sensorLevelMax: sensorLevelSpinBox.to
			property alias sensorLevel: sensorLevelSpinBox.value
			property alias volumeMin: volumeSpinBox.from
			property alias volumeMax: volumeSpinBox.to
			property alias volume: volumeSpinBox.value
			property int modelIndex

			property var _pointArrayToSave

			title: modelIndex < 0
				  //% "Add point"
				? qsTrId("devicelist_tankshape_add_point")
				  //: %1 = which point is being edited, a number like "1" or "2"
				  //% "Edit point %1"
				: qsTrId("devicelist_tankshape_edit_point").arg(modelIndex+1)

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
				let pointList = []
				let point = []
				let i = 0
				for (i = 0; i < pointsListView.model.length; ++i) {
					point = pointsListView.model[i]
					pointList.push([ point[0], point[1] ])
				}
				const quantities = [ sensorLevelSpinBox.value, volumeSpinBox.value ]
				if (modelIndex < 0) {
					pointList.push(quantities)
				} else {
					pointList[modelIndex] = quantities
				}
				pointList.sort(function(a, b) { return a[0] - b[0] })

				for (i = 1; i < pointList.length; i++) {
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
