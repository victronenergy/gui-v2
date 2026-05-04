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

		header: SettingsColumn {
			width: parent?.width ?? 0
			bottomPadding: addPoint.effectiveVisible || placeholderLabel.effectiveVisible ? Theme.geometry_listItem_itemSeparator_height : 0

			ListNavigation {
				id: addPoint

				//% "Add shape point"
				text: qsTrId("devicelist_tankshape_add_shape_point")
				iconSource: "qrc:/images/icon_plus_32.svg"
				iconColor: Theme.color_ok
				showAccessLevel: VenusOS.User_AccessType_Installer
				preferredVisible: _canEditPoints && pointsListView.count < 10
				hasSubMenu: false
				onClicked: {
					Global.dialogLayer.open(editPointDialogComponent, {
						"sensorLevel": 1,
						"volume": 1,
						"modelIndex": -1
					})
				}
			}

			PrimaryListLabel {
				id: placeholderLabel

				//% "No custom shape defined. You may define one with up to ten points. Note that 0% and 100% are implied."
				text: qsTrId("devicelist_tankshape_empty")
				preferredVisible: pointsListView.count === 0
			}
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
					source: "qrc:/images/icon_minus_32.svg"
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
				implicitHeight: spinBoxLayout.implicitHeight

				GridLayout {
					id: spinBoxLayout

					anchors {
						left: parent.left
						leftMargin: Theme.geometry_page_content_horizontalMargin
						right: parent.right
						rightMargin: Theme.geometry_page_content_horizontalMargin
						verticalCenter: parent.verticalCenter
						verticalCenterOffset: -(Theme.geometry_modalDialog_content_spacing / 2)
					}
					columnSpacing: Theme.geometry_modalDialog_content_spacing
					rowSpacing: 0
					columns: Theme.screenSize === Theme.Portrait ? 1 : 2

					ColumnLayout {
						spacing: Theme.geometry_modalDialog_content_spacing

						Layout.preferredWidth: sensorLevelSpinBox.width
						Layout.alignment: Qt.AlignHCenter
						Layout.bottomMargin: Theme.screenSize === Theme.Portrait ? Theme.geometry_modalDialog_content_spacing : 0

						Label {
							elide: Text.ElideRight
							horizontalAlignment: Text.AlignHCenter
							color: Theme.color_font_secondary
							//: The sensor level (as a percentage) for this tank shape point
							//% "Sensor level"
							text: qsTrId("devicelist_tankshape_sensor_level")

							Layout.fillWidth: true
						}

						SpinBox {
							id: sensorLevelSpinBox
							width: Theme.geometry_tankShapeSelector_spinBox_width
							height: Theme.geometry_tankShapeSelector_spinBox_height
							spacing: Theme.geometry_spinBox_wide_spacing
							from: 1
							to: 99
							suffix: Units.defaultUnitString(VenusOS.Units_Percentage)
							onValueModified: errorLabel.text = ""

							// Use BeforeItem priority to override the default key Spinbox event handling, else
							// up/down keys will modify the number even when SpinBox is not in "edit" mode.
							focus: true
							KeyNavigation.priority: KeyNavigation.BeforeItem
							KeyNavigation.up: sensorLevelSpinBox
							KeyNavigation.down: root.footer
							KeyNavigation.right: volumeSpinBox

							Layout.alignment: Qt.AlignHCenter
						}
					}

					ColumnLayout {
						spacing: Theme.geometry_modalDialog_content_spacing

						Layout.preferredWidth: volumeSpinBox.width
						Layout.alignment: Qt.AlignHCenter

						Label {
							elide: Text.ElideRight
							horizontalAlignment: Text.AlignHCenter
							color: Theme.color_font_secondary
							//: The volume (as a percentage) for this tank shape point
							//% "Volume"
							text: qsTrId("devicelist_tankshape_volume")

							Layout.fillWidth: true
						}

						SpinBox {
							id: volumeSpinBox

							width: Theme.geometry_tankShapeSelector_spinBox_width
							height: Theme.geometry_tankShapeSelector_spinBox_height
							spacing: Theme.geometry_spinBox_wide_spacing
							from: 1
							to: 99
							suffix: Units.defaultUnitString(VenusOS.Units_Percentage)
							onValueModified: errorLabel.text = ""

							KeyNavigation.priority: KeyNavigation.BeforeItem
							KeyNavigation.up: volumeSpinBox
							KeyNavigation.down: root.footer
							KeyNavigation.left: sensorLevelSpinBox

							Layout.alignment: Qt.AlignHCenter
						}
					}

					RowLayout {
						spacing: Theme.geometry_listItem_content_spacing
						opacity: errorLabel.text.length > 0 ? 1 : 0

						Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
						Layout.maximumWidth: spinBoxLayout.parent.width
						Layout.minimumHeight: Theme.geometry_spinBox_indicator_height // minimize resizing when error text is set
						Layout.columnSpan: Theme.screenSize === Theme.Portrait ? 1 : 2

						CP.ColorImage {
							source: "qrc:/images/icon_warning_24.svg"
							color: Theme.color_red
						}

						Label {
							id: errorLabel

							wrapMode: Text.Wrap
							color: Theme.color_font_secondary
							font.pixelSize: Theme.font_dialog_body_secondary_size

							Layout.fillWidth: true
						}
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
