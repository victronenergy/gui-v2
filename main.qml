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

	property Item acInputs: dataLoader.item.acInputs
	property Item dcInputs: dataLoader.item.dcInputs
	property Item battery: dataLoader.item.battery
	property Item environmentLevels: dataLoader.item.environmentLevels
	property Item ess: dataLoader.item.ess
	property Item tanks: dataLoader.item.tanks
	property Item inverters: dataLoader.item.inverters
	property Item generators: dataLoader.item.generators
	property var generator0: generators ? generators.generator0 : null
	property Item relays: dataLoader.item.relays
	property Item solarChargers: dataLoader.item.solarChargers
	property Item system: dataLoader.item.system

	property alias dialogManager: dialogManager

	property Item dataLoader: dbusData.active ? dbusData : demoData

	width: [800, 1024][Theme.screenSize]
	height: [480, 600][Theme.screenSize]
	color: {
		if (Theme.colorScheme === Theme.Light
				&& PageManager.statusBar
				&& PageManager.statusBar.controlsActive) {
			return Theme.color.overviewPage.backgroundColor
		}
		switch (PageManager.navBar.currentUrl) {
		case "qrc:/pages/OverviewPage.qml":
		case "qrc:/pages/LevelsPage.qml":
			return Theme.color.overviewPage.backgroundColor
			break
		default: return Theme.color.background.primary
		}
	}

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

	MouseArea {
		id: idleModeMouseArea

		anchors.fill: parent
		enabled: PageManager.interactivity === Enums.PageManager_InteractionMode_Idle
		onClicked: PageManager.interactivity = Enums.PageManager_InteractionMode_EndFullScreen
	}

	MouseArea {
		anchors.fill: parent
		onPressed: function(mouse) {
			mouse.accepted = false
			PageManager.idleModeTimer.restart()
		}
	}

	DialogManager {
		id: dialogManager
	}

	Loader {
		id: dbusData

		active: dbusConnected
		sourceComponent: Item {
			property AcInputs acInputs: AcInputs {}
			property DcInputs dcInputs: DcInputs {}
			property Battery battery: Battery {}
			property EnvironmentLevels environmentLevels: EnvironmentLevels {}
			property Ess ess: Ess {}
			property Tanks tanks: Tanks {}
			property Generators generators: Generators {}
			property Inverters inverters: Inverters {}
			property Relays relays: Relays {}
			property SolarChargers solarChargers: SolarChargers {}
			property System system: System {}

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
		focus: active

		sourceComponent: Item {
			property Demo.AcInputs acInputs: Demo.AcInputs {}
			property Demo.DcInputs dcInputs: Demo.DcInputs {}
			property Demo.Battery battery: Demo.Battery {}
			property Demo.EnvironmentLevels environmentLevels: Demo.EnvironmentLevels {}
			property Demo.Ess ess: Demo.Ess {}
			property Demo.Tanks tanks: Demo.Tanks {}
			property Demo.Inverters inverters: Demo.Inverters {}
			property Demo.Generators generators: Demo.Generators {}
			property Demo.Relays relays: Demo.Relays {}
			property Demo.SolarChargers solarChargers: Demo.SolarChargers {}
			property Demo.System system: Demo.System {}

			Demo.DemoConfig {}
		}
	}
}
