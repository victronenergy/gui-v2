/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

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

	// Ensure time is up-to-date while this page is open.
	Timer {
		interval: 10000
		repeat: true
		triggeredOnStart: true
		running: BackendConnection.applicationVisible
		onTriggered: Global.systemSettings.time.getValue(true)
	}

	Component {
		id: timeSelectorComponent

		TimeSelectorDialog {
			onAccepted: {
				let dt = ClockTime.currentDateTime
				dt.setHours(hour)
				dt.setMinutes(minute)
				Global.systemSettings.time.setValue(dt.getTime() / 1000)
			}
		}
	}

	GradientListView {
		model: ObjectModel {

			ListTextItem {
				//% "Date/Time UTC"
				text: qsTrId("settings_tz_date_time_utc")
				secondaryText: ClockTime.currentTimeUtcText
			}

			ListButton {
				//% "Date/Time local"
				text: qsTrId("settings_tz_date_time_local")
				button.text: ClockTime.currentTimeText
				writeAccessLevel: VenusOS.User_AccessType_User
				enabled: Global.systemSettings.time.isValid

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
		id: tzAntartica
		//% "Antartica"
		readonly property string name: qsTrId("settings_tz_antartica")
		readonly property string region: "Antartica"
	}
	TzArcticData {
		id: tzArtic
		//% "Artic"
		readonly property string name: qsTrId("settings_tz_artic")
		readonly property string region: "Artic"
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
		//% "Etc"
		readonly property string name: qsTrId("settings_tz_etc")
		readonly property string region: "Etc"
	}
}
