/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

/*
 * These settings are regularly brought up to date with the settings from gui-v1.
 * Currently up to date with gui-v1 v5.6.6.
 */

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

SwipeViewPage {
	id: root

	//% "Settings"
	title: qsTrId("nav_settings")
	iconSource: "qrc:/images/settings.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/SettingsPage.qml"
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
	focusPolicy: Qt.TabFocus
	showTopGradient: Theme.screenSize === Theme.Portrait && !settingsListView.atYBeginning

	function goToConnectivityPage(pageId) {
		const properties = { title: Qt.binding(function() { return connectivityListItem.text }) }
		const page = Global.pageManager.pushPage(connectivityListItem.pageSource, properties, PageStack.Immediate)
		if (page) {
			page.goToPage(pageId)
		}
	}

	component SettingsListNavigation : ListNavigationBase {
		id: settingsNav

		property string pageIconSource
		property string pageSource

		topPadding: topInset + Theme.geometry_settingsListNavigation_verticalPadding
		bottomPadding: bottomInset + Theme.geometry_settingsListNavigation_verticalPadding
		onClicked: Global.pageManager.pushPage(pageSource, { title: Qt.binding(function() { return text }) })

		contentItem: Item {
			implicitWidth: Theme.geometry_listItem_width
			implicitHeight: labelLayout.implicitHeight

			CP.ColorImage {
				id: mainIcon

				anchors {
					verticalCenter: parent.verticalCenter
					left: parent.left
				}
				source: settingsNav.pageIconSource
				color: Theme.color_font_primary
			}

			ThreeLabelLayout {
				id: labelLayout

				anchors {
					verticalCenter: parent.verticalCenter
					left: settingsNav.pageIconSource.length > 0 ? mainIcon.right : parent.left
					leftMargin: settingsNav.pageIconSource.length > 0 ? settingsNav.horizontalContentPadding : 0
					right: arrowIcon.left
					rightMargin: settingsNav.spacing
				}
				primaryText: settingsNav.text
				primaryLabel.font: settingsNav.font
				primaryLabel.textFormat: settingsNav.textFormat
				secondaryText: settingsNav.secondaryText
				secondaryLabel.color: settingsNav.secondaryTextColor
				captionText: settingsNav.caption
				stretchSecondaryText: true
			}

			CP.ColorImage {
				id: arrowIcon

				anchors {
					right: parent.right
					verticalCenter: parent.verticalCenter
				}
				source: "qrc:/images/icon_chevron_right_32.svg"
				color: Theme.color_listItem_forwardIcon
				visible: settingsNav.interactive
			}
		}
	}

	GradientListView {
		id: settingsListView

		clip: true
		model: VisibleItemModel {
			SettingsListNavigation {
				text: CommonWords.devices
				//% "All connected devices"
				caption: qsTrId("settings_all_connected_devices")
				pageSource: "/pages/settings/devicelist/DeviceListPage.qml"
				pageIconSource: "qrc:/images/icon_devices_32.svg"
			}

			SettingsListNavigation {
				topInset: Theme.geometry_listItem_itemSeparator_height
				//% "General"
				text: qsTrId("settings_general")
				//% "Access control, Display, Firmware, Support"
				caption: qsTrId("settings_access_control_display_firmware")
				pageSource: "/pages/settings/PageSettingsGeneral.qml"
				pageIconSource: "qrc:/images/icon_general_32.svg"
			}

			SettingsListNavigation {
				id: connectivityListItem

				//% "Connectivity"
				text: qsTrId("settings_connectivity")
				//% "Ethernet, Wi-Fi, Bluetooth, VE.Can"
				caption: qsTrId("settings_ethernet_wifi_bluetooth_vecan")
				pageSource: "/pages/settings/PageSettingsConnectivity.qml"
				pageIconSource: "qrc:/images/icon_connectivity_32.svg"
			}

			SettingsListNavigation {
				//% "VRM"
				text: qsTrId("settings_vrm")
				//% "Remote monitoring portal"
				caption: qsTrId("settings_remote_monitoring_portal")
				pageSource: "/pages/settings/PageSettingsLogger.qml"
				pageIconSource: "qrc:/images/icon_vrm_32.svg"
			}

			SettingsListHeader {
				//% "Advanced"
				text: qsTrId("settings_advanced")
			}

			SettingsListNavigation {
				//% "Integrations"
				text: qsTrId("settings_integrations")
				//% "Relays, Sensors, PV Inverters, Modbus, Node-RED"
				caption: qsTrId("settings_relays_sensors_tanks")
				pageSource: "/pages/settings/PageSettingsIntegrations.qml"
				pageIconSource: "qrc:/images/icon_integration_32.svg"
			}

			SettingsListNavigation {
				//% "System Setup"
				text: qsTrId("settings_system_setup")
				//% "AC/DC system, ESS, DVCC, Battery..."
				caption: qsTrId("settings_acdcsystem_ess_dvcc_battery")
				pageSource: "/pages/settings/PageSettingsSystem.qml"
				pageIconSource: "qrc:/images/icon_system_32.svg"
			}

			SettingsListNavigation {
				//% "Debug & Develop"
				text: qsTrId("settings_debug_and_develop")
				//% "Profiling tools, debug statistics, app version..."
				caption: qsTrId("settings_profilingtools_debugstatistics_appversion")
				pageSource: "/pages/settings/debug/PageDebug.qml"
				pageIconSource: "qrc:/images/icon_debug_32.svg"
				showAccessLevel: VenusOS.User_AccessType_SuperUser
			}
		}
	}
}
