/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls as C

import "/components/Gauges.js" as Gauges

ListPage {
	id: root

	Flickable {
		x: Theme.geometry.page.content.horizontalMargin
		width: parent.width - 2*Theme.geometry.page.content.horizontalMargin
		height: parent.height
		topMargin: Theme.geometry.gradientList.topMargin
		bottomMargin: Theme.geometry.gradientList.bottomMargin

		Column {
			id: contentColumn

			width: parent.width

			Repeater {
				model: Global.systemSettings.briefView.gauges

				delegate: ListNavigationItem {
					//: Level number
					//% "Level %1"
					text: qsTrId("settings_briefview_level").arg(model.index + 1)
					secondaryText: Gauges.tankProperties(model.value).name || ""
					listPage: root
					listIndex: model.index
					onClicked: {
						listPage.navigateTo(briefLevelComponent, {
							tankType: Qt.binding(function() { return model.value }),
							levelIndex: model.index
						}, listIndex)
					}
				}
			}

			ListSwitch {
				//: Show percentage values in Brief view
				//% "Show %"
				text: qsTrId("settings_briefview_show_percentage")
				checked: Global.systemSettings.briefView.showPercentages.value
				onClicked: Global.systemSettings.briefView.showPercentages.setValue(checked)
			}
		}
	}

	Component {
		id: briefLevelComponent

		ListPage {
			property int tankType
			property int levelIndex

			listView: GradientListView {
				model: [
					VenusOS.Tank_Type_Battery,
					VenusOS.Tank_Type_Fuel,
					VenusOS.Tank_Type_FreshWater,
					VenusOS.Tank_Type_WasteWater,
					VenusOS.Tank_Type_LiveWell,
					VenusOS.Tank_Type_Oil,
					VenusOS.Tank_Type_BlackWater,
					VenusOS.Tank_Type_Gasoline
				]
				delegate: ListRadioButton {
					text: Gauges.tankProperties(modelData).name || ""
					checked: tankType === modelData
					C.ButtonGroup.group: radioButtonGroup

					onClicked: {
						Global.systemSettings.briefView.setGauge(levelIndex, modelData)
					}
				}

				C.ButtonGroup {
					id: radioButtonGroup
				}
			}
		}
	}
}
