/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	function _timeoutOptions() {
		//% "Never"
		let options = [ { display: qsTrId("settings_startpage_timeout_never"), value: 0 } ]
		const timeouts = [ 1, 5, 10, 30, 60 ]
		for (let i = 0; i < timeouts.length; ++i) {
			const minutes = timeouts[i]
			//% "After %n minute(s)"
			options.push({
				display: qsTrId("settings_startpage_timeout_minutes", minutes),
				value: minutes * 60
			})
		}
		return options
	}

	VeQuickItem {
		id: startPageName
		uid: Global.systemSettings.serviceUid + "/Settings/Gui2/StartPageName"
	}

	GradientListView {
		model: VisibleItemModel {
			ListNavigation {
				id: startPageNavigation
				//% "Start page"
				text: qsTrId("settings_startpage_name")
				secondaryText: {
					const options = Global.systemSettings.startPageConfiguration.options
					let optionText = ""
					for (let i = 0; i < options.length; ++i) {
						if (options[i].value === startPageName.value) {
							optionText = options[i].display
							break
						}
					}
					if (optionText.length) {
						return optionText
					} else if (Global.systemSettings.startPageConfiguration.autoSelect) {
						return CommonWords.auto
					} else {
						//% "None"
						return qsTrId("settings_startpage_none")
					}
				}
				bottomContentChildren: [
					PrimaryListLabel {
						width: Math.min(implicitWidth, startPageNavigation.width)
						topPadding: 0
						bottomPadding: 0
						color: Theme.color_font_secondary
						//% "Go to this page when the application starts."
						text: qsTrId("settings_startpage_description")
					}
				]
				onClicked: {
					Global.pageManager.pushPage(startPageOptionsComponent, { title: text })
				}
			}

			ListRadioButtonGroup {
				id: startPageTimeout
				//% "Timeout"
				text: qsTrId("settings_startpage_timeout")
				optionModel: root._timeoutOptions()
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui2/StartPageTimeout"
				bottomContentChildren: [
					PrimaryListLabel {
						width: Math.min(implicitWidth, startPageTimeout.width)
						topPadding: 0
						bottomPadding: 0
						color: Theme.color_font_secondary
						//% "Revert to the start page when the application is inactive."
						text: qsTrId("settings_startpage_timeout_description")
					}
				]
			}
		}
	}

	Timer {
		id: popTimer
		interval: Theme.animation_settings_radioButtonPage_autoClose_duration
		onTriggered: Global.pageManager.popPage()
	}

	Component {
		id: startPageOptionsComponent

		Page {
			GradientListView {
				model: VisibleItemModel {
					ListSwitch {
						id: startPageMode
						text: CommonWords.auto
						dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui2/StartPage"
						invertSourceValue: true
						bottomContentChildren: [
							PrimaryListLabel {
								width: Math.min(implicitWidth, startPageMode.width)
								topPadding: 0
								bottomPadding: 0
								color: Theme.color_font_secondary
								//% "After one minute of inactivity, select the current page as the start page, if it is in this list."
								text: qsTrId("settings_startpage_auto_description")
							}
						]
						onClicked: {
							popTimer.stop()
							if (checked) {
								// Clear the selected start page to indicate that it should now be
								// auto-selected instead.
								startPageName.setValue("")
							}
						}
					}

					Column {
						width: parent ? parent.width : 0

						Repeater {
							model: Global.systemSettings.startPageConfiguration.options
							delegate: ListRadioButton {
								checked: modelData.value === startPageName.value
								text: modelData.display
								onClicked: {
									popTimer.stop()
									startPageName.setValue(modelData.value)
									startPageMode.dataItem.setValue(VenusOS.StartPage_Mode_UserSelect)  // disable auto-select switch
									popTimer.start()
								}
							}
						}
					}
				}
			}
		}
	}
}
