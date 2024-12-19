/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	This component provides a way to find the startstop1 uid for a genset service.
	On D-Bus this is always "com.victronenergy.generator.startstop1", but on a MQTT backend this
	is less easily located.

	For some background context, there are two start/stop generator types:

	- startstop0
		The original start/stop generator. This turns the Cerbo's built-in relay on/off.
		On D-Bus, the uid is "com.victronenergy.generator.startstop0".
		On MQTT, the service uid is "mqtt/generator/0".

	- startstop1
		This works with an actual genset, by sending a command to it instead of closing the relay.
		That is, it controls any genset service with start-stop capabilities that can be remotely
		commanded. For example, FischerPanda, CompAp and DSE controllers.

		On D-Bus, the uid is "com.victronenergy.generator.startstop1".
		On MQTT, the service uid is found by locating the generator service with a /GensetService
			value that matches that of a genset or dcgenset service. It might turn out to be
			"mqtt/generator/1", but that is not guaranteed.

	So, unlike for many other service types, these services these do not refer to different generator
	instances; instead, they are used to distinguish between two different types of generators.
*/

QtObject {
	id: root

	property string gensetServiceUid

	// On D-Bus, the startstop1 generator is at com.victronenergy.generator.startstop1.
	// On MQTT, the startstop1 generator is the one with GensetService=com.victronenergy.genset.*
	// (or GensetService=com.victronenergy.dcgenset.* if this is a dcgenset)
	readonly property string startStop1Uid: BackendConnection.type === BackendConnection.MqttSource
			? _generatorWithGensetService
			: BackendConnection.uidPrefix() + "/com.victronenergy.generator.startstop1"

	property string _generatorWithGensetService

	readonly property Instantiator _generatorObjects: Instantiator {
		model: BackendConnection.type === BackendConnection.MqttSource ? Global.generators.model : null
		delegate: VeQuickItem {
			uid: model.device.serviceUid + "/GensetService"
			onValueChanged: {
				const serviceType = BackendConnection.serviceTypeFromUid(root.gensetServiceUid)
				if ( (isValid && serviceType === "dcgenset" && value.startsWith("com.victronenergy.dcgenset."))
						|| (isValid && serviceType !== "dcgenset" && value.startsWith("com.victronenergy.genset.")) ) {
						root._generatorWithGensetService = model.device.serviceUid
				}
			}
		}
	}
}
