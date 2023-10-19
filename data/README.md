# Bridging service data from D-Bus, MQTT and mock backends

Components in the /data directory are used to map data from D-Bus and MQTT services (and optionally a dummy "mock" backend for testing) into objects and properties that can be easily read from QML.

To add support for a new service, e.g. com.victronenergy.charger, the main files to add are:

- data/Chargers.qml - provides a model of all charger devices on the system, and assigns an instance of itself to a `Global.chargers` property
- data/common/Charger.qml - defines the properties of an charger device
- data/dbus/ChargersImpl.qml - creates `Charger` objects using a D-Bus model
- data/mqtt/ChargersImpl.qml - creates `Charger` objects using a MQTT model
- data/mock/ChargersImpl.qml - creates `Charger` objects using a mock backend (optional)

Then, the following files must be modified:
- Global.qml - provide an `chargers` property that can be assigned to from data/Chargers.qml
- data/DataManager.qml - create an instance of data/Chargers.qml, e.g by declaring `Chargers {}`
- dbus/DBusDataManager.qml, dbus/MqttDataManager.qml and mock/MockDataManager.qml - instantiate the `*Impl.qml` components, e.g. as `property var chargers: ChargersImpl { }`

Once this is done, the UI can access charger objects through `Global.chargers.model`. For example, this should show the names of all available charger devices:

    Repeater {
        model: Global.chargers.model
        delegate: Label { text: model.device.name }
    }

You may also need to update pages/settings/devicelist/DeviceListPage.qml to show charger devices in the Device List.

