#include <velib/qt/v_busitems.h>

QDBusConnection::BusType VBusItems::mBusType = QDBusConnection::SessionBus;
QString VBusItems::mDBusAddress = "";

VBusItems::VBusItems(QObject* parent) :
	QObject(parent)
{
}

void VBusItems::setConnectionType(QDBusConnection::BusType type)
{
	mBusType = type;
	mDBusAddress = "";
}

/**
 * Set the address of the dbus.
 * @note overwrites setConnectionType
 * @example
 *   tcp:host=<ip-address>,port=<tcp-port>
 *   unix:abstract=/tmp/dbus-UFmYHA8NiO
 *   session
 *   system
 */
void VBusItems::setDBusAddress(const QString &address)
{
	if (address == "session") {
		setConnectionType(QDBusConnection::SessionBus);
	} else if (address == "system") {
		setConnectionType(QDBusConnection::SystemBus);
	} else {
		mDBusAddress = address;
	}
}

const QString VBusItems::getDBusAddress()
{
	if (!mDBusAddress.isEmpty())
		return mDBusAddress;

	switch (mBusType)
	{
	case QDBusConnection::SystemBus:
		return QString::fromLatin1("system");
	case QDBusConnection::SessionBus:
		return QString::fromLatin1("session");
	default:
		return "";
	}
}

QDBusConnection &VBusItems::getConnection()
{
	static bool isValid;
	static QDBusConnection mDBusConnection("not connected");

	if (isValid)
		return mDBusConnection;

	mDBusConnection = getConnection("qt-refuses-to-connect-without-a-name");
	isValid = true;

	return mDBusConnection;
}

QDBusConnection VBusItems::getConnection(const QString &name)
{
	if (mDBusAddress.isEmpty())
		return QDBusConnection::connectToBus(mBusType, name);

	return QDBusConnection::connectToBus(mDBusAddress, name);
}
