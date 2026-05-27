/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string settingsBindPrefix // must be non-empty
	required property string startStopBindPrefix // must be non-empty
	// the following property 'changesAllowed' is safety related. Do not change without discussing with Rein.
	readonly property bool changesAllowed: dcGensetAutoStartEnabled.value === 0 &&
										   (_state.value === VenusOS.Generators_State_Error || _state.value === VenusOS.Generators_State_Stopped)

	VeQuickItem {
		id: noGeneratorAtDcInAlarm
		uid: root.startStopBindPrefix + "/Alarms/NoGeneratorAtDcIn"
	}

	VeQuickItem {
		id: activeCondition
		readonly property bool isAutoStarted: valid && Global.generators.isAutoStarted(value)
		uid: root.startStopBindPrefix + "/RunningByConditionCode"
	}

	VeQuickItem {
		id: dcGensetAutoStartEnabled
		uid: root.startStopBindPrefix + "/AutoStartEnabled"
	}

	VeQuickItem {
		id: _state
		uid: root.startStopBindPrefix + "/State"
	}

	GradientListView {
		model: VisibleItemModel {
			ListNavigation {
				//% "Conditions"
				text: qsTrId("page_dc_gensets_settings_conditions")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageGeneratorConditions.qml", { title: text, bindPrefix: root.settingsBindPrefix, startStopBindPrefix: root.startStopBindPrefix })
			}

			ListRadioButtonGroup {
				id: mode

				function isGeneratorSelected(deviceId) {
					if (dataItem.value) {
						return dataItem.value
							.split(',')
							.map(s => parseInt(s, 10))
							.includes(deviceId)
					}
					return false
				}

				//% "Enabled DC Gensets"
				text: qsTrId("page_dc_gensets_settings_enabled_dc_gensets")
				dataItem.uid: "%1/MultipleGensets/GensetsEnabled".arg(root.startStopBindPrefix)
				updateDataOnClick: false
				popDestination: undefined
				defaultIndex: 2

				optionModel: [
					//% "Always control all available gensets"
					{ display: qsTrId("dc_gensets_all_gensets"), value: "all", interactive: root.changesAllowed },
					//% "Rotate over available gensets"
					{ display: qsTrId("dc_gensets_rotate"), value: "rotate", interactive: root.changesAllowed },
					//% "Custom selection"
					{ display: qsTrId("dc_gensets_custom_selection"), value: "", interactive: root.changesAllowed },
				]

				onOptionClicked: (index) => {
					 dataItem.setValue(optionModel[index].value)
				}

				optionHeader: root.changesAllowed ? null : settingsLockedComponent

				Component {
					id: settingsLockedComponent
					SettingsColumn {
						topPadding: spacing
						bottomPadding: spacing
						width: parent.width

						SettingsListHeader {
							width: parent.width
							text: activeCondition.value === VenusOS.Generators_RunningBy_Manual
									//% "These settings cannot currently be changed because the generator has been manually started."
								  ? qsTrId("dc_gensets_settings_these_settings_cannot_currently_be_changed_because_the_generator_has_been_manually_started")
									//% "These settings cannot currently be changed because auto-start is enabled."
								  : qsTrId("dc_gensets_settings_these_settings_cannot_currently_be_changed_because_auto_start_is_enabled")
						}
					}
				}

				optionFooter: SettingsColumn {
					anchors {
						left: parent.left
						right: parent.right
					}

					topPadding: spacing

					Repeater {
						id: switches

						function updateSelectedGenerators() {
							let deviceIds = ""
							for (let i = 0; i < switches.count; ++i) {
								let _switch = switches.itemAt(i)
								let generator = _switch ? _switch.device : null
								if (_switch?.checked && generator) {
									if (deviceIds.length > 0) {
										deviceIds += ","
									}
									deviceIds += generator.deviceInstance
								}
							}
							mode.dataItem.setValue(deviceIds)
						}

						function restoreCheckedBindings() {
							for (let i = 0; i < switches.count; ++i) {
								let _switch = switches.itemAt(i)
								if (_switch) {
									_switch.checked = Qt.binding(function() {
										return _switch.device ? mode.isGeneratorSelected(_switch.device.deviceInstance) : false
									})
								}
							}
						}

						model: mode.currentIndex == 2 ? Global.generators.dcModel : null
						delegate: ListSwitch {
							required property Device device

							checked: device ? mode.isGeneratorSelected(device.deviceInstance) : false
							checkable: root.changesAllowed
							interactive: defaultInteractive && checkable
							onClicked: {
								switches.updateSelectedGenerators()
								switches.restoreCheckedBindings()
							}
							text: device?.name || ""
						}
					}
				}
			}

			ListQuantityField {
				//% "Minimum run time"
				text: qsTrId("dc-gensets-minimum-runtime")
				dataItem.uid: root.settingsBindPrefix + "/MinimumRuntime"
				unit: VenusOS.Units_Time_Minute
			}

			ListSwitch {
				//% "Alarm if DC generator is not providing power"
				text: qsTrId("page_settings_generator_detect_generator_at_dc")
				//% "An alarm will be triggered when the DC genset does not reach at least 5A within the first 5 minutes after starting"
				caption: qsTrId("page_settings_generator_detect_at_dc_in_generator_set")
				dataItem.uid: settingsBindPrefix + "/Alarms/NoGeneratorAtDcIn"
				preferredVisible: noGeneratorAtDcInAlarm.valid
			}

			ListSwitch {
				//% "Alarm when generator is not in autostart mode"
				text: qsTrId("page_settings_generator_alarm_when_not_in_auto_start")
				//% "An alarm will be triggered when autostart function is left disabled for more than 10 minutes"
				caption: qsTrId("page_settings_generator_alarm_info")
				dataItem.uid: settingsBindPrefix + "/Alarms/AutoStartDisabled"
			}

			ListSwitch {
				id: quietHours

				text: CommonWords.quiet_hours
				dataItem.uid: settingsBindPrefix + "/QuietHours/Enabled"
				writeAccessLevel: VenusOS.User_AccessType_User
			}
		}
	}
}
