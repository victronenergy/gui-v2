/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	VeQItemSortTableModel {
		id: dbusGpsModel

		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterOffline
		filterRole: VeQItemTableModel.IdRole
		filterRegExp: "^com\.victronenergy\.gps"
		model: BackendConnection.type === BackendConnection.DBusSource ? Global.dataServiceModel : null
	}

	VeQItemTableModel {
		id: mqttGpsModel

		uids: BackendConnection.type === BackendConnection.MqttSource ? ["mqtt/gps"] : []
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
	}

	Component {
		id: mockGpsModelComponent

		ListModel {
			ListElement { uid: "com.victronenergy.gps" }
		}
	}

	GradientListView {
		model: BackendConnection.type === BackendConnection.DBusSource
			   ? dbusGpsModel
			   : BackendConnection.type === BackendConnection.MqttSource
				 ? mqttGpsModel
				 : mockGpsModelComponent.createObject(root)

		delegate: ListNavigationItem {
			Component {
				id: pageGps

				PageGps { }
			}

			text: (productName.valid && vrmInstance.valid)
				  ? "%1 [2]".arg(productName.value).arg(vrmInstance.value)
				  : "--"

			onClicked: {
				Global.pageManager.pushPage(pageGps,
						{"title": text, bindPrefix: model.uid })
			}

			DataPoint {
				id: productName
				source: model.uid + "/ProductName"
			}

			DataPoint {
				id: vrmInstance
				source: model.uid + "/DeviceInstance"
			}
		}

		footer: ListNavigationItem {
			//% "GPS Settings"
			text: qsTrId("settings_gps_settings")
			onClicked: {
				Global.pageManager.pushPage(gpsFormatSettingsComponent, {"title": text})
			}

			Component {
				id: gpsFormatSettingsComponent

				Page {
					GradientListView {
						model: ObjectModel {
							ListRadioButtonGroup {
								//: Format of reported GPS data
								//% "Format"
								text: qsTrId("settings_gps_format")
								dataSource: "com.victronenergy.settings/Settings/Gps/Format"
								optionModel: [
									//: Example of GPS data in the 'Degrees, Minutes, Seconds' format
									//% "52° 20' 41.6\" N, 5° 13' 12.3\" E"
									{ display: qsTrId("settings_gps_format_dms_example"), value: VenusOS.GpsData_Format_DegreesMinutesSeconds },
									//: Example of GPS data in the 'Decimal Degrees' format
									//% "52.34489, 5.22008"
									{ display: qsTrId("settings_gps_format_dd_example"), value: VenusOS.GpsData_Format_DecimalDegrees },
									//: Example of GPS data in the 'Degrees Minutes' format
									//% "52° 20.693 N, 5° 13.205 E"
									{ display: qsTrId("settings_gps_format_dm_example"), value: VenusOS.GpsData_Format_DegreesMinutes },
								]
							}

							ListRadioButtonGroup {
								//: Speed unit for reported GPS data
								//% "Speed Unit"
								text: qsTrId("settings_gps_speed_unit")
								dataSource: "com.victronenergy.settings/Settings/Gps/SpeedUnit"
								optionModel: [
									//% "Kilometers per hour"
									{ display: qsTrId("settings_gps_format_kmh"), value: "km/h" },
									//% "Meters per second"
									{ display: qsTrId("settings_gps_format_ms"), value: "m/s" },
									//% "Miles per hour"
									{ display: qsTrId("settings_gps_format_mph"), value: "mph" },
									//% "Knots"
									{ display: qsTrId("settings_gps_format_kt"), value: "kt" },
								]
							}
						}
					}
				}
			}
		}
	}
}
