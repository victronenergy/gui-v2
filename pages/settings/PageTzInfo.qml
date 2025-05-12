/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property var _timeZoneModels: [ tzAfrica, tzAmerica, tzAntarctica, tzArctic, tzAsia, tzAtlantic, tzAustralia, tzEurope, tzIndian, tzPacific, tzEtc ]

	function _findTimeZoneName(region, city) {
		if (city === "UTC") {
			return city
		}
		for (let i = 0; i < _timeZoneModels.length; ++i) {
			const tzModel = _timeZoneModels[i]
			if (tzModel.region !== region) {
				continue
			}
			for (let j = 0; j < tzModel.count; ++j) {
				const tz = tzModel.get(j)
				if (tz.city === city) {
					return tz.display
				}
			}
		}
		return ""
	}

	function _openDateSelector() {
		Global.dialogLayer.open(dateSelectorComponent, {year: ClockTime.year, month: ClockTime.month, day: ClockTime.day})
	}

	function _openTimeSelector() {
		Global.dialogLayer.open(timeSelectorComponent, {hour: ClockTime.hour, minute: ClockTime.minute})
	}

	Component {
		id: dateSelectorComponent

		DateSelectorDialog {
			onAccepted: {
				Global.systemSettings.time.setValue(
					ClockTime.otherClockTime(
						year,
						month,
						day,
						ClockTime.hour,
						ClockTime.minute))
			}
		}
	}

	Component {
		id: timeSelectorComponent

		TimeSelectorDialog {
			onAccepted: {
				Global.systemSettings.time.setValue(
					ClockTime.otherClockTime(
						ClockTime.year,
						ClockTime.month,
						ClockTime.day,
						hour,
						minute))
			}
		}
	}

	// Ensure time is up-to-date while this page is open.
	Timer {
		interval: 10000
		repeat: true
		triggeredOnStart: true
		running: BackendConnection.applicationVisible
		onTriggered: Global.systemSettings.time.getValue(true)
	}

	GradientListView {
		model: VisibleItemModel {

			ListText {
				//% "Date/Time UTC"
				text: qsTrId("settings_tz_date_time_utc")
				secondaryText: ClockTime.currentDateTimeUtc
			}

			ListItem {
				id: timeZoneButton
				// Qt for WebAssembly doesn't support timezones,
				// so we can't display the device-local date/time,
				// as we don't know what it is.  Just hide the setting.
				preferredVisible: Qt.platform.os != "wasm"

				//% "Date/Time local"
				text: qsTrId("settings_tz_date_time_local")
				writeAccessLevel: VenusOS.User_AccessType_User
				interactive: Global.systemSettings.time.valid

				content.children: Row {
					spacing: Theme.geometry_listItem_content_spacing
					ListItemButton {
						id: localDateButton
						text: ClockTime.currentDate
						enabled: timeZoneButton.clickable
						focus: enabled
						KeyNavigation.right: localTimeButton
						onClicked: root._openDateSelector()
					}
					ListItemButton {
						id: localTimeButton
						text: ClockTime.currentTime
						enabled: timeZoneButton.clickable
						focus: enabled
						onClicked: root._openTimeSelector()
					}
				}
			}

			ListNavigation {
				//% "Time zone"
				text: qsTrId("settings_tz_time_zone")
				secondaryText: root._findTimeZoneName(tzData.region, tzData.city)
				writeAccessLevel: VenusOS.User_AccessType_User

				onClicked: Global.pageManager.pushPage(pageTzMenuComponent, { title: text })

				VeQuickItem {
					id: tzData

					property string city
					property string region

					function saveTimeZone(region, city) {
						tzData.city = city
						tzData.region = region
						setValue(region + "/" + city)
					}

					uid: Global.systemSettings.serviceUid + "/Settings/System/TimeZone"
					onValueChanged: {
						if (value !== undefined) {
							const slash = value.indexOf('/')
							if (slash >= 0) {
								region = value.substring(0, slash)
								city = value.substring(slash + 1)
							}
						}
					}
				}

				Component {
					id: pageTzMenuComponent

					Page {
						GradientListView {
							id: tzListView

							header: SettingsColumn {
								width: parent.width
								bottomPadding: Theme.geometry_gradientList_spacing

								ListSwitch {
									text: "UTC"
									writeAccessLevel: VenusOS.User_AccessType_User
									checked: tzData.city === text
									onClicked: {
										if (!checked) {
											tzData.saveTimeZone("", text)
											popTimer.start()
										}
									}

								}
								Timer {
									id: popTimer

									interval: Theme.animation_settings_radioButtonPage_autoClose_duration
									onTriggered: if (!!Global.pageManager) Global.pageManager.popPage(root)
								}
							}

							model: root._timeZoneModels

							delegate: ListRadioButtonGroup {
								text: modelData.name
								optionModel: modelData
								secondaryText: ""
								writeAccessLevel: VenusOS.User_AccessType_User
								updateDataOnClick: false
								popDestination: root
								currentIndex: {
									if (tzData.region === modelData.region) {
										for (let i = 0; i < modelData.count; ++i) {
											if (modelData.get(i).city === tzData.city) {
												return i
											}
										}
									}
									return -1
								}

								onOptionClicked: function(index) {
									tzData.saveTimeZone(modelData.region, modelData.get(index).city)
								}
							}
						}
					}
				}
			}
		}
	}

	TzAfricaData {
		id: tzAfrica
		//% "Africa"
		readonly property string name: qsTrId("settings_tz_africa")
		readonly property string region: "Africa"
	}
	TzAmericaData {
		id: tzAmerica
		//% "America"
		readonly property string name: qsTrId("settings_tz_america")
		readonly property string region: "America"
	}
	TzAntarcticaData {
		id: tzAntarctica
		//% "Antarctica"
		readonly property string name: qsTrId("settings_tz_antarctica")
		readonly property string region: "Antarctica"
	}
	TzArcticData {
		id: tzArctic
		//% "Arctic"
		readonly property string name: qsTrId("settings_tz_arctic")
		readonly property string region: "Arctic"
	}
	TzAsiaData {
		id: tzAsia
		//% "Asia"
		readonly property string name: qsTrId("settings_tz_asia")
		readonly property string region: "Asia"
	}
	TzAtlanticData {
		id: tzAtlantic
		//% "Atlantic"
		readonly property string name: qsTrId("settings_tz_atlantic")
		readonly property string region: "Atlantic"
	}
	TzAustraliaData {
		id: tzAustralia
		//% "Australia"
		readonly property string name: qsTrId("settings_tz_ustralia")
		readonly property string region: "Australia"
	}
	TzEuropeData {
		id: tzEurope
		//% "Europe"
		readonly property string name: qsTrId("settings_tz_europe")
		readonly property string region: "Europe"
	}
	TzIndianData {
		id: tzIndian
		//% "Indian"
		readonly property string name: qsTrId("settings_tz_indian")
		readonly property string region: "Indian"
	}
	TzPacificData {
		id: tzPacific
		//% "Pacific"
		readonly property string name: qsTrId("settings_tz_pacific")
		readonly property string region: "Pacific"
	}
	TzEtcData {
		id: tzEtc
		//% "Other"
		readonly property string name: qsTrId("settings_tz_etc")
		readonly property string region: "Etc"
	}
}
