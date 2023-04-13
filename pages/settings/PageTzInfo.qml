/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "tz"

Page {
	id: root

	property var _timeZoneModels: [ tzAfrica, tzAmerica, tzAntartica, tzArtic, tzAsia, tzAtlantic, tzAustralia, tzEurope, tzIndian, tzPacific, tzEtc ]
	property var _timeSelector

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

	function _openTimeSelector() {
		if (!_timeSelector) {
			_timeSelector = timeSelectorComponent.createObject(Global.dialogLayer)
		}
		const dt = ClockTime.currentDateTime
		_timeSelector.hour = dt.getHours()
		_timeSelector.minute = dt.getMinutes()
		_timeSelector.open()
	}

	Component {
		id: timeSelectorComponent

		TimeSelectorDialog {
			onAccepted: {
				let dt = ClockTime.currentDateTime
				dt.setHours(hour)
				dt.setMinutes(minute)
				// TODO set system date time to 'dt' using venus-platform or such
				Global.showToastNotification(VenusOS.Notification_Info, "TODO not yet implemented")
			}
		}
	}

	GradientListView {
		model: ObjectModel {

			ListTextItem {
				//% "Date/Time UTC"
				text: qsTrId("settings_tz_date_time_utc")
				secondaryText: Qt.formatDateTime(ClockTime.currentDateTimeUtc, "yyyy-MM-dd hh:mm")
			}

			ListButton {
				//% "Date/Time local"
				text: qsTrId("settings_tz_date_time_local")
				button.text: ClockTime.currentTimeText
				writeAccessLevel: VenusOS.User_AccessType_User

				onClicked: {
					root._openTimeSelector()
				}
			}

			ListNavigationItem {
				//% "Time zone"
				text: qsTrId("settings_tz_time_zone")
				secondaryText: root._findTimeZoneName(tzData.region, tzData.city)
				writeAccessLevel: VenusOS.User_AccessType_User

				onClicked: Global.pageManager.pushPage(pageTzMenuComponent, { title: text })

				DataPoint {
					id: tzData

					property string city
					property string region

					function saveTimeZone(region, city) {
						tzData.city = city
						tzData.region = region
						setValue(region + "/" + city)
					}

					source: "com.victronenergy.settings/Settings/System/TimeZone"
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

							header: ListSwitch {
								text: "UTC"
								writeAccessLevel: VenusOS.User_AccessType_User
								checked: tzData.city === text
								updateOnClick: false
								onClicked: {
									if (!checked) {
										tzData.saveTimeZone("", text)
										popTimer.start()
									}
								}

								Timer {
									id: popTimer

									interval: Theme.animation.settings.radioButtonPage.autoClose.duration
									onTriggered: Global.pageManager.popPage(root)
								}
							}
							model: root._timeZoneModels

							delegate: ListRadioButtonGroup {
								text: modelData.name
								optionModel: modelData
								secondaryText: ""
								writeAccessLevel: VenusOS.User_AccessType_User
								updateOnClick: false
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

	TimezoneModel {
		id: tzAfrica
		prefix: "Africa"
		//% "Africa"
		readonly property string name: qsTrId("settings_tz_africa")
		readonly property string region: "Africa"
	}
	TimezoneModel {
		id: tzAmerica
		prefix: "America"
		//% "America"
		readonly property string name: qsTrId("settings_tz_america")
		readonly property string region: "America"
	}
	TimezoneModel {
		id: tzAntartica
		prefix: "Antarctica"
		//% "Antartica"
		readonly property string name: qsTrId("settings_tz_antartica")
		readonly property string region: "Antartica"
	}
	TimezoneModel {
		id: tzArtic
		prefix: "Arctic"
		//% "Artic"
		readonly property string name: qsTrId("settings_tz_artic")
		readonly property string region: "Artic"
	}
	TimezoneModel {
		id: tzAsia
		prefix: "Asia"
		//% "Asia"
		readonly property string name: qsTrId("settings_tz_asia")
		readonly property string region: "Asia"
	}
	TimezoneModel {
		id: tzAtlantic
		prefix: "Atlantic"
		//% "Atlantic"
		readonly property string name: qsTrId("settings_tz_atlantic")
		readonly property string region: "Atlantic"
	}
	TimezoneModel {
		id: tzAustralia
		prefix: "Australia"
		//% "Australia"
		readonly property string name: qsTrId("settings_tz_ustralia")
		readonly property string region: "Australia"
	}
	TimezoneModel {
		id: tzEurope
		prefix: "Europe"
		//% "Europe"
		readonly property string name: qsTrId("settings_tz_europe")
		readonly property string region: "Europe"
	}
	TimezoneModel {
		id: tzIndian
		prefix: "Indian"
		//% "Indian"
		readonly property string name: qsTrId("settings_tz_indian")
		readonly property string region: "Indian"
	}
	TimezoneModel {
		id: tzPacific
		prefix: "Pacific"
		//% "Pacific"
		readonly property string name: qsTrId("settings_tz_pacific")
		readonly property string region: "Pacific"
	}
	TimezoneModel {
		id: tzEtc
		prefix: "Etc"
		//% "Etc"
		readonly property string name: qsTrId("settings_tz_etc")
		readonly property string region: "Etc"
	}
}
