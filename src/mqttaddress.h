/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_MQTTADDRESS_H
#define VICTRON_GUIV2_MQTTADDRESS_H

#include <QString>

namespace Victron {
namespace VenusOS {

// The VRM MQTT broker address for a shard or a portal id. The gui-v2 app and the standalone RV
// app (tools/camperview) both use these, so they connect to the same broker.
QString calculateMqttAddressFromShard(const QString &shard);
QString calculateMqttAddressFromPortalId(const QString &portalId);

}
}

#endif // VICTRON_GUIV2_MQTTADDRESS_H
