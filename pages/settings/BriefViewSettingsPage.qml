/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls
import Victron.VenusOS

Page {
	id: root

	Flickable {
		x: Theme.geometry.page.content.horizontalMargin
		width: parent.width - 2*Theme.geometry.page.content.horizontalMargin
		height: parent.height
		topMargin: Theme.geometry.settingsPage.settingsList.topMargin
		bottomMargin: Theme.geometry.settingsPage.settingsList.bottomMargin

		Column {
			id: contentColumn

			width: parent.width

			Repeater {
				model: systemSettings.briefView.gauges

				delegate: SettingsListNavigationItem {
					//: Level number
					//% "Level %1"
					text: qsTrId("settings_briefview_level").arg(model.index + 1)
					secondaryText: Gauges.tankProperties(model.value).name || ""

					onClicked: {
						Global.pageManager.pushPage(briefLevelComponent, {
							tankType: Qt.binding(function() { return model.value }),
							levelIndex: model.index
						})
					}
				}
			}

			SettingsListSwitch {
				//: Show percentage values in Brief view
				//% "Show %"
				text: qsTrId("settings_briefview_show_percentage")
				checked: systemSettings.briefView.showPercentages
				onClicked: systemSettings.briefView.setShowPercentages(checked)
			}
		}
	}

	Component {
		id: briefLevelComponent

		Page {
			property int tankType
			property int levelIndex

			SettingsListView {
				model: Gauges.gaugeTypes
				delegate: SettingsListRadioButton {
					text: Gauges.tankProperties(modelData).name || ""
					checked: tankType === modelData
					buttonGroup: radioButtonGroup

					onClicked: {
						systemSettings.briefView.setGauge(levelIndex, modelData)
					}
				}

				ButtonGroup {
					id: radioButtonGroup
				}
			}
		}
	}
}
