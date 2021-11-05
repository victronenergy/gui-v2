#include <QDBusArgument>
#include <QDBusMessage>
#include <QDBusVariant>
#include <QDebug>
#include <velib/qt/ve_qitem.hpp>
#include "ve_qitem_dbus_virtual_object.hpp"

Q_DECLARE_METATYPE(QList<int>)
Q_DECLARE_METATYPE(StringMap)

VeQItemDbusVirtualObject::VeQItemDbusVirtualObject(const QDBusConnection &connection, VeQItem *root,
												   QObject *parent):
	QDBusVirtualObject(parent),
	mConnection(connection),
	mRoot(root)
{
	Q_ASSERT(root != 0);
	connectItem(root);
}

VeQItem *VeQItemDbusVirtualObject::root()
{
	return mRoot;
}

QString VeQItemDbusVirtualObject::serviceName() const
{
	return mConnection.name();
}

bool VeQItemDbusVirtualObject::registerService()
{
	if (!mConnection.registerVirtualObject("/", this, QDBusConnection::SubPath)) {
		qDebug() << "[VeQItemDbusVirtualObject] Could not register virtual object";
		return false;
	}

	if (!mConnection.registerService(serviceName())) {
		qDebug() << "[VeQItemDbusVirtualObject] Could not register service" << serviceName();
		return false;
	}

	return true;
}

bool VeQItemDbusVirtualObject::unregisterService()
{
	if (!mConnection.unregisterService(serviceName())) {
		qDebug() << "[VeQItemDbusVirtualObject] Could not unregister service" << serviceName();
		return false;
	}

	return true;
}

QString VeQItemDbusVirtualObject::introspect(const QString &path) const
{
	VeQItem *item = mRoot->itemGet(path);
	if (item == 0)
		return QString();

	QString result = QString(
				"  <interface name=\"com.victronenergy.BusItem\">\n"
				"    <method name=\"GetValue\">\n"
				"      <arg direction=\"out\" type=\"v\" name=\"value\"/>\n"
				"    </method>\n"
				"    <method name=\"GetText\">\n"
				"      <arg direction=\"out\" type=\"s\" name=\"value\"/>\n"
				"    </method>\n"
				"%1"
				"%2"
				"  </interface>\n")
			.arg(item->isLeaf()
				 ? "    <method name=\"SetValue\">\n"
				   "      <arg direction=\"in\" type=\"v\" name=\"value\"/>\n"
				   "      <arg direction=\"out\" type=\"i\" name=\"retval\"/>\n"
				   "    </method>\n"
				   "    <method name=\"GetMin\">\n"
				   "      <arg direction=\"out\" type=\"v\" name=\"value\"/>\n"
				   "    </method>\n"
				   "    <method name=\"GetMax\">\n"
				   "      <arg direction=\"out\" type=\"v\" name=\"value\"/>\n"
				   "    </method>\n"
				   "    <method name=\"GetDefault\">\n"
				   "      <arg direction=\"out\" type=\"v\" name=\"value\"/>\n"
				   "    </method>\n"
				   "    <method name=\"GetDescription\">\n"
				   "      <arg direction=\"in\" type=\"s\" name=\"language\"/>\n"
				   "      <arg direction=\"in\" type=\"i\" name=\"length\"/>\n"
				   "      <arg direction=\"out\" type=\"s\" name=\"descr\"/>\n"
				   "    </method>\n"
				   "    <signal name=\"PropertiesChanged\">\n"
				   "      <arg direction=\"out\" type=\"a{sv}\" name=\"changes\"/>\n"
				   "      <annotation value=\"QVariantMap\" name=\"com.trolltech.QtDBus.QtTypeName.In0\"/>\n"
				   "    </signal>\n"
				 : "",
			path == "/"
				 ? "    <method name=\"GetItems\">\n"
				   "      <arg direction=\"out\" type=\"a{sa{sv}}\" name=\"items\"/>\n"
				   "    </method>\n"
				 : "")
			;

	for (VeQItem *child: item->itemChildren())
		result.append(QString("  <node name=\"%1\"/>\n").arg(child->id()));

	return result;
}

bool VeQItemDbusVirtualObject::handleMessage(const QDBusMessage &message,
											 const QDBusConnection &connection)
{
	switch (message.type()) {
	case QDBusMessage::MethodCallMessage:
	{
		QString member = message.member();
		VeQItem *item = mRoot->itemGet(message.path());
		if (item == 0)
			return false;

		if (member == "GetValue")
			return handleGetValue(message, connection, item);
		if (member == "GetText")
			return handleGetText(message, connection, item);
		if (member == "GetItems" && message.path() == "/")
			return handleGetItems(message, connection);

		if (!item->isLeaf())
			return false;

		if (member == "SetValue")
			return handleSetValue(message, connection, item);
		break;
	}
	default:
		qDebug() << "[VeQItemDbusVirtualObject] unhandled message type:" << message.type();
		break;
	}
	return false;
}

bool VeQItemDbusVirtualObject::handleGetValue(const QDBusMessage &message,
											  const QDBusConnection &connection, VeQItem *item)
{
	if (item->isLeaf()) {
		QDBusMessage reply = message.createReply(QVariant::fromValue(QDBusVariant(denormalizeVariant(item->getValue()))));
		return connection.send(reply);
	} else {
		QVariantMap map;
		buildTree(item, item, map);
		QDBusMessage reply = message.createReply(QVariant::fromValue(QDBusVariant(map)));
		return connection.send(reply);
	}
}

bool VeQItemDbusVirtualObject::handleGetText(const QDBusMessage &message,
											 const QDBusConnection &connection, VeQItem *item)
{
	if (item->isLeaf()) {
		QDBusMessage reply = message.createReply(QVariant::fromValue(item->getText()));
		return connection.send(reply);
	} else {
		StringMap map;
		buildTree(item, item, map);
		QDBusMessage reply = message.createReply(
			QVariant::fromValue(QDBusVariant(QVariant::fromValue(map))));
		return connection.send(reply);
	}
}

bool VeQItemDbusVirtualObject::handleSetValue(const QDBusMessage &message,
											  const QDBusConnection &connection, VeQItem *producer)
{
	QList<QVariant> args = message.arguments();
	if (args.size() != 1) {
		QDBusMessage reply = message.createErrorReply(QDBusError::InvalidArgs,
													  "Expected 1 argument");
		return connection.send(reply);
	}
	QVariant v = args.first();
	normalizeVariant(v);
	int r = producer->setValue(v);
	QDBusMessage reply = message.createReply(r);
	return connection.send(reply);
}

void VeQItemDbusVirtualObject::addPending(VeQItem *item)
{
	if (!mPendingChanges.contains(item)) {
		if (mPendingChanges.isEmpty())
			QMetaObject::invokeMethod(this, "processPending", Qt::QueuedConnection);
		mPendingChanges.append(item);
	}
}

bool VeQItemDbusVirtualObject::handleGetItems(const QDBusMessage &message,
											  const QDBusConnection &connection)
{
	ItemMap items;

	mRoot->foreachParentFirst([&items,this](VeQItem *item){
		if (item->isLeaf()) {
			QMap<QString, QVariant> m;
			m.insert("Value", denormalizeVariant(item->getLocalValue()));
			m.insert("Text", item->getText());

			QVariant v;
			v = item->property("min");
			if (v.isValid())
				m.insert("Min", v); // No need to denormalize as v is valid
			v = item->property("max");
			if (v.isValid())
				m.insert("Max", v);
			v = item->property("default");
			if (v.isValid())
				m.insert("Default", v);
			items.insert(item->getRelId(mRoot), m);
		}
	});

	QDBusMessage reply = message.createReply(QVariant::fromValue(items));

	return connection.send(reply);
}

void VeQItemDbusVirtualObject::processPending()
{
	QList<VeQItem *> pending = mPendingChanges;
	mPendingChanges.clear();
	foreach (VeQItem *p, pending)
		sendPropertiesChanged(p);
}

void VeQItemDbusVirtualObject::sendPropertiesChanged(VeQItem *item)
{
	QString dbusPath = item->getRelId(mRoot);
	QDBusMessage message = QDBusMessage::createSignal(dbusPath, "com.victronenergy.BusItem",
													  "PropertiesChanged");
	QVariantMap map;
	QVariant v = item->getLocalValue();
	denormalizeVariant(v);
	map.insert("Value", v);
	map.insert("Text", item->getText());
	message << map;
	if (!mConnection.send(message))
		qDebug() << "[VeQItemDbusVirtualObject] Could not send PropertiesChanged signal on path"
				 << dbusPath;
}

void VeQItemDbusVirtualObject::connectItem(VeQItem *item)
{
	if (item->isLeaf()) {
		connect(item, SIGNAL(valueChanged(VeQItem*,QVariant)),
				this, SLOT(onValueChanged(VeQItem*)));
		connect(item, SIGNAL(textChanged(VeQItem*,QString)),
				this, SLOT(onTextChanged(VeQItem*)));
	} else {
		connect(item, SIGNAL(childAdded(VeQItem*)), this, SLOT(onChildAdded(VeQItem*)));
		connect(item, SIGNAL(childRemoved(VeQItem*)), this, SLOT(onChildRemoved(VeQItem*)));

		for (VeQItem *child: item->itemChildren())
			connectItem(child);
	}
}

void VeQItemDbusVirtualObject::disconnectItem(VeQItem *item)
{
	item->disconnect(this);

	for (VeQItem *child: item->itemChildren())
		disconnectItem(child);
}

void VeQItemDbusVirtualObject::onChildAdded(VeQItem *item)
{
	connectItem(item);
}

void VeQItemDbusVirtualObject::onChildRemoved(VeQItem *item)
{
	disconnectItem(item);
}

void VeQItemDbusVirtualObject::onValueChanged(VeQItem *item)
{
	addPending(item);
}

void VeQItemDbusVirtualObject::onTextChanged(VeQItem *item)
{
	addPending(item);
}

void VeQItemDbusVirtualObject::normalizeVariant(QVariant &v)
{
	if (v.userType() == QVariant::Map) {
		QVariantMap m = v.toMap();
		normalizeMap(m);
	} else if (v.userType() == qMetaTypeId<QDBusVariant>()) {
		v = qvariant_cast<QDBusVariant>(v).variant();
		normalizeVariant(v);
	} else if (v.userType() == qMetaTypeId<QDBusArgument>()) {
		QDBusArgument arg = qvariant_cast<QDBusArgument>(v);
		if (arg.currentSignature() == "a{sv}") {
			QVariantMap m = qdbus_cast<QVariantMap>(arg);
			normalizeMap(m);
			v = m;
		} else  if (arg.currentSignature() == "av") {
			QVariantList vl = qdbus_cast<QVariantList>(arg);
			normalizeList(vl);
			v = vl;
		} else  if (arg.currentSignature() == "ai") {
			// An empty list of integers is used by victron to encode an invalid
			// value, because D-Bus itself does not define an invalid (or null)
			// value.
			QList<int> vl = qdbus_cast<QList<int> >(arg);
			if (vl.size() == 0)
				v = QVariant();
		} else {
			qDebug() <<	"Cannot handle signature:" << arg.currentSignature();
		}
	}
}

void VeQItemDbusVirtualObject::normalizeMap(QVariantMap &map)
{
	for (QVariantMap::iterator it = map.begin(); it != map.end(); ++it)
		normalizeVariant(it.value());
}

void VeQItemDbusVirtualObject::normalizeList(QVariantList &list)
{
	for (QVariantList::iterator it = list.begin(); it != list.end(); ++it)
		normalizeVariant(*it);
}

QVariant & VeQItemDbusVirtualObject::denormalizeVariant(QVariant &v)
{
	if (!v.isValid())
		v = QVariant::fromValue(QList<int>());

	return v;
}

QVariant VeQItemDbusVirtualObject::denormalizeVariant(const QVariant &v)
{
	if (!v.isValid())
		return QVariant::fromValue(QList<int>());

	return v;
}
