/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Victron.Velib
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "data"

Window {
	id: root

	property Item battery: dbusData.item.battery
	property Item tanks: dbusData.item.tanks
	property Item generators: dbusData.item.generators

	property alias dialogManager: dialogManager

	width: [800, 1024][Theme.screenSize]
	height: [480, 600][Theme.screenSize]
	color: PageManager.navBar.currentUrl === "qrc:/pages/OverviewPage.qml" ? Theme.color.overviewPage.backgroundColor : Theme.color.background.primary

	//: Application title
	//% "Venus OS GUI"
	//~ Context only shown on desktop systems
	title: qsTrId("venus_os_gui")

	SplashView {
		id: splashView
		anchors.fill: parent
		visible: opacity > 0.0
		opacity: 1.0

		Behavior on opacity {
			NumberAnimation {
				duration: Theme.animation.page.fade.duration
				easing.type: Easing.InOutQuad
			}
		}

		onHideSplash: {
			splashView.opacity = 0.0
			mainView.opacity = 1.0
		}
	}

	MainView {
		id: mainView
		anchors.fill: parent
		opacity: 0.0

		Behavior on opacity {
			NumberAnimation {
				duration: Theme.animation.page.fade.duration
				easing.type: Easing.InOutQuad
			}
		}
	}

	DialogManager {
		id: dialogManager
	}

	Loader {
		id: dbusData

		active: dbusConnected
		sourceComponent: Item {
			property Battery battery: Battery {}
			property Tanks tanks: Tanks {}
			property Generators generators: Generators {}
			property Inverters inverters: Inverters {}
			property Relays relays: Relays {}

			VeQuickItem {
				id: veDBus
				uid: "dbus"
			}
			VeQuickItem {
				id: veSystem
				uid: "dbus/com.victronenergy.system"
			}
			VeQuickItem {
				id: veSettings
				uid: "dbus/com.victronenergy.settings"
			}
		}
	}
}
