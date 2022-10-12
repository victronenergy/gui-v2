#include "connmandbustypes.h"

// Marshall the ConnmanObject data into a D-Bus argument
QDBusArgument &operator<<(QDBusArgument &argument, const ConnmanObject &obj)
{
	argument.beginStructure();
	argument << obj.path << obj.properties;
	argument.endStructure();
	return argument;
}

// Retrieve the ConnmanObject data from the D-Bus argument
const QDBusArgument &operator>>(const QDBusArgument &argument, ConnmanObject &obj)
{
	argument.beginStructure();
	argument >> obj.path >> obj.properties;
	argument.endStructure();
	return argument;
}
