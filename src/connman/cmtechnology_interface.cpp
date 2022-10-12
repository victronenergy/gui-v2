#include "cmtechnology_interface.h"

CmTechnologyInterface::CmTechnologyInterface(const QString &service, const QString &path, const QDBusConnection &connection, QObject *parent) :
	QDBusAbstractInterface(service, path, staticInterfaceName(), connection, parent)
{
}
