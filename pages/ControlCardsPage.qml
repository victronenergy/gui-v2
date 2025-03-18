/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS

Page {
	id: root

	property int cardWidth: cardsView.count > 2
			? Theme.geometry_controlCard_minimumWidth
			: Theme.geometry_controlCard_maximumWidth

	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsActive
	width: parent.width
	anchors {
		top: parent.top
		bottom: parent.bottom
		bottomMargin: Theme.geometry_controlCardsPage_bottomMargin
	}

	// The cards list view is made up of:
	// - Header - ESS card
	// - Per-device Control Cards for EVCS, Generators, Inverter/chargers
	// - Footer - Manual relays
	ListView {
		id: cardsView

		anchors {
			fill: parent
			leftMargin: Theme.geometry_controlCardsPage_horizontalMargin
			rightMargin: Theme.geometry_controlCardsPage_horizontalMargin
		}
		spacing: Theme.geometry_controlCardsPage_spacing
		orientation: ListView.Horizontal
		boundsBehavior: Flickable.StopAtBounds
		maximumFlickVelocity: Theme.geometry_flickable_maximumFlickVelocity
		flickDeceleration: Theme.geometry_flickable_flickDeceleration

		header: Loader {
			active: systemType.value === "ESS" || systemType.value === "Hub-4"
			sourceComponent: Item {
				width: root.cardWidth + cardsView.spacing
				height: cardsView.height

				ESSCard {
					width: root.cardWidth
					height: cardsView.height
				}
			}

			VeQuickItem {
				id: systemType
				uid: Global.system.serviceUid + "/SystemType"
			}
		}

		footer: Loader {
			active: manualRelays.count > 0
			sourceComponent: Item {
				width: root.cardWidth + cardsView.spacing
				height: cardsView.height

				SwitchesCard {
					x: cardsView.spacing
					width: root.cardWidth
					height: cardsView.height
					model: manualRelays
				}
			}

			ManualRelayModel { id: manualRelays }
		}

		model: controlCardModel
		delegate: Loader {
			id: deviceDelegate

			required property Device device

			width: root.cardWidth
			height: cardsView.height
			sourceComponent: {
				const serviceType = BackendConnection.serviceTypeFromUid(device.serviceUid)
				if (serviceType === "evcharger") {
					return evcsComponent
				} else if (serviceType === "generator") {
					return generatorComponent
				}
				return inverterChargerComponent
			}

			Component {
				id: evcsComponent

				EVCSCard {
					width: root.cardWidth
					serviceUid: deviceDelegate.device.serviceUid
				}
			}

			Component {
				id: generatorComponent

				GeneratorCard {
					width: root.cardWidth
					generator: deviceDelegate.device
				}
			}

			Component {
				id: inverterChargerComponent

				InverterChargerCard {
					width: root.cardWidth
					serviceUid: deviceDelegate.device.serviceUid
					name: deviceDelegate.device.name
				}
			}
		}
	}

	AggregateDeviceModel {
		id: controlCardModel

		sortBy: AggregateDeviceModel.SortBySourceModel | AggregateDeviceModel.SortByDeviceName
		sourceModels: [
			evChargerModel,
			Global.generators.model,
			Global.inverterChargers.veBusDevices,
			Global.inverterChargers.acSystemDevices,
			Global.inverterChargers.inverterDevices
		]
	}

	// A model of evcharger services that represent controllable EV chargers, i.e. those with a
	// valid /Mode value. Global.evChargers.model cannot be used in the control cards, as it
	// includes services without a /Mode, such as Energy Meters configured as EV chargers.
	ServiceDeviceModel {
		id: evChargerModel

		serviceType: "evcharger"
		modelId: "evcharger"
		deviceDelegate: Device {
			id: device

			required property string uid
			readonly property bool isRealCharger: valid && _chargerMode.valid

			readonly property VeQuickItem _chargerMode: VeQuickItem {
				uid: device.serviceUid + "/Mode"
			}

			serviceUid: uid
			onIsRealChargerChanged: {
				if (isRealCharger) {
					evChargerModel.addDevice(device)
				} else {
					evChargerModel.removeDevice(device.serviceUid)
				}
			}
		}
	}
}
