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
import "demo" as Demo

Window {
	id: root

	property Item battery: dataLoader.item.battery
	property Item tanks: dataLoader.item.tanks
	property Item generators: dataLoader.item.generators
	property Item solarChargers: dataLoader.item.solarChargers
	property Item systemAc: dataLoader.item.systemAc
	property Item systemDc: dataLoader.item.systemDc
	property alias systemTotals: systemTotals

	property alias dialogManager: dialogManager

	property Item dataLoader: dbusData.active ? dbusData : demoData

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
			property SolarChargers solarChargers: SolarChargers {}
			property SystemAc systemAc: SystemAc {}
			property SystemDc systemDc: SystemDc {}

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

	Loader {
		id: demoData

		active: !dbusConnected
		sourceComponent: Item {
			// TODO make demo versions
//            property Battery battery: Battery {}
			property Demo.Tanks tanks: Demo.Tanks {}
			property Demo.Generators generators: Demo.Generators {}
//            property Inverters inverters: Inverters {}
//            property Relays relays: Relays {}

			property Demo.SolarChargers solarChargers: Demo.SolarChargers {}
			property Demo.SystemAc systemAc: Demo.SystemAc {}
			property Demo.SystemDc systemDc: Demo.SystemDc {}
		}
	}

	QtObject {
		id: systemTotals

		// total load = AC + DC consumption
		property real loadPower: (systemAc ? systemAc.consumption.power : 0)
				+ (systemDc ? systemDc.power : 0)
		onLoadPowerChanged: Utils.updateMaximumValue("systemTotals.loadPower", loadPower)

		// total generator input = AC + DC input
		// TODO add DC generator input data.
		property real generatorPower: (systemAc ? systemAc.genset.power : 0)
		onGeneratorPowerChanged: Utils.updateMaximumValue("systemTotals.generatorPower", loadPower)
	}
}
