#include <QDBusMetaType>
#include <QDebug>
#include <QtDBus>
#ifdef QT_XML_LIB
#include <QtXml>
#endif

#include <velib/velib_config.h>
#include <velib/qt/ve_qitems_dbus.hpp>

Q_DECLARE_METATYPE(StringMap)

VeQItemDbus::VeQItemDbus(VeQItemDbusProducer *producer) :
	VeQItem(producer),
	mDbusService(0),
	mRequestValueWhenOnline(false),
	mRequestTextWhenOnline(false),
	mRequestDefaultWhenOnline(false),
	mRequestMaxWhenOnline(false),
	mRequestMinWhenOnline(false)
{
}

VeQItemDbusProducer *VeQItemDbus::producer()
{
	return static_cast<VeQItemDbusProducer *>(mProducer);
}

/*
 * qtDbus creates a variant of QDBusArgument for all none basic types
 * encountered in case of a QDBusVariant. These can be be casted / demarshalled to
 * an explicit type. However qml will not perform such casts and complains it can't
 * deal with a QDBusArgument. In order to make this work, the casts are performed
 * here. This is in no way complete. QVariantMap and arrays of basic types are supported.
 *
 * NOTE: The remote c side has no onChange support at the moment (june 2014)
 */
void VeQItemDbus::demarshallVariantForQml(QVariant &variant, QString &signature)
{
	QString dummy;

	if (variant.canConvert<QDBusVariant>()) {
		QDBusVariant dbusVar = qvariant_cast<QDBusVariant>(variant);
		variant = dbusVar.variant();
		demarshallVariantForQml(variant, dummy);
	} else if (variant.canConvert<QDBusArgument>()) {
		const QDBusArgument &dbusArgument = qvariant_cast<QDBusArgument>(variant);
		signature = dbusArgument.currentSignature();
		switch (dbusArgument.currentType())
		{
		case QDBusArgument::MapType:
			/* QVariantMap support */
			if (dbusArgument.currentSignature() == "a{sv}")
			{
				QVariantMap map = qdbus_cast<QVariantMap>(dbusArgument);
				for (QVariantMap::iterator i = map.begin(); i != map.end(); i++)
					demarshallVariantForQml(i.value(), dummy);
				variant = QVariant::fromValue(map);
			} else {
				qDebug() << "unsupported MapType, your likely toasted...";
			}
			break;

		case QDBusArgument::ArrayType:
		{
			// An empty array represents an invalid value for busitems,
			// simply because there is no simple method to invalidate
			// a value on the dbus at the moment.
			dbusArgument.beginArray();
			if (dbusArgument.atEnd()) {
				dbusArgument.endArray();
				variant = QVariant();
				signature = "";
				break;
			}

			// Upcast everything to a QVariantList as qml understands that
			// by default..
			QVariantList list;
			while (!dbusArgument.atEnd())
				list.append(dbusArgument.asVariant());
			dbusArgument.endArray();

			for (QVariantList::iterator i = list.begin(); i != list.end(); i++)
				demarshallVariantForQml(*i, dummy);

			variant = QVariant::fromValue(list);
			break;
		}

		default:
			qDebug() << "unsupported QDBusArgument, your likely toasted...";
		}
	} else {
		signature = QDBusMetaType::typeToSignature(QMetaType(variant.typeId()));
	}
}

void VeQItemDbus::onPropertiesChanged(const QVariantMap &changes)
{
	QMapIterator<QString, QVariant> i(changes);
	QString dummy;

	while (i.hasNext()) {
		i.next();
		if (i.key() == "Value") {
			QVariant value(i.value());
			demarshallVariantForQml(value, mSignature);
			produceValue(value);
		} else if (i.key() == "Text") {
			QString value(i.value().toString());
			produceText(value);
		} else if (i.key() == "Max") {
			QVariant value(i.value());
			demarshallVariantForQml(value, dummy);
			itemProduceProperty("max", value);
		} else if (i.key() == "Min") {
			QVariant value(i.value());
			demarshallVariantForQml(value, dummy);
			itemProduceProperty("min", value);
		} else if (i.key() == "Default") {
			QVariant value(i.value());
			demarshallVariantForQml(value, dummy);
			itemProduceProperty("defaultValue", value);
		}
	}
}

void VeQItemDbus::serviceRegistrationChanged(bool registered)
{
	if (registered) {
		if (mIsLeaf) {
			/*
			 * Since the ccgx gui does not look at state changes at the moment, a state
			 * transition goes unnoticed. When a service invalidates an item, disconnects
			 * and returns without sending a change event itself, there won't be a pending
			 * action, since there was no value change in the first place (so getValue won't
			 * get called, since it didn't change, and hence didn't get marked as pending).
			 * For now just sync both text and value if there is a consumer of this item.
			 */
			if (mWatched) {
				mRequestValueWhenOnline = true;
				mRequestTextWhenOnline = true;
			}

			if (mRequestValueWhenOnline) {
				mRequestValueWhenOnline = false;
				getValue(true);
			}
			if (mRequestTextWhenOnline) {
				mRequestTextWhenOnline = false;
				getText(true);
			}
			if (mRequestDefaultWhenOnline) {
				mRequestDefaultWhenOnline = false;
				itemProperty("defaultValue", true);
			}
			if (mRequestMaxWhenOnline) {
				mRequestMaxWhenOnline = false;
				itemProperty("max", true);
			}
			if (mRequestMinWhenOnline) {
				mRequestMinWhenOnline = false;
				itemProperty("min", true);
			}
		}

		// If there was no pending action at all mark as Idle
		if (dbusPath() != "/") {
			if (mState == Offline)
				setState(Idle);
			if (mTextState == Offline)
				setTextState(Idle);
		} else {
			// mark the service item itself as synchronized again
			setState(Synchronized);
		}

	} else {
#if CFG_DBUS_INVALIDATE_OFFLINE
		/*
		 * Ideally the values are kept but only the state is changed, so the user interface
		 * has a choice how to cope with it. Since the ccgx gui doesn't do that at the moment,
		 * invalidate it so the display gets updated accordingly.
		 */
		produceValue(QVariant(), Offline);
		produceText("", Offline);
#else
		setState(Offline);
		setTextState(Offline);
#endif
	}
}

void VeQItemDbus::bulkInitValueDone()
{
	if (mRequestValueWhenOnline) {
		mRequestValueWhenOnline = false;
		getValue(true);
	}
}

void VeQItemDbus::bulkInitTextDone()
{
	if (mRequestTextWhenOnline) {
		mRequestTextWhenOnline = false;
		getText(true);
	}
}

void VeQItemDbus::produceValue(QVariant variant, State state, bool forceChanged)
{
	VeQItem::produceValue(variant, state, forceChanged);
	if (mRequestValueWhenOnline && state == VeQItem::Synchronized)
		mRequestValueWhenOnline = false;
}

void VeQItemDbus::produceText(QString text, State state)
{
	VeQItem::produceText(text, state);
	if (mRequestTextWhenOnline && state == VeQItem::Synchronized)
		mRequestTextWhenOnline = false;
}

#ifdef QT_XML_LIB
void VeQItemDbus::introspectObtained(QDBusPendingCallWatcher *call)
{
	QDBusPendingReply<QString> reply = *call;
	QDomDocument doc;

	if (!reply.isValid()) {
		qDebug() << "Cannot introspect object" <<  reply.error();
	} else {
		doc.setContent(reply.value());
		QDomElement child = doc.firstChildElement().firstChildElement();
		while (!child.isNull()) {
			if (child.tagName() == "node") {
				QString name = child.attribute("name");
				itemGetOrCreate(name);
			}

			child = child.nextSiblingElement();
		}
	}

	call->deleteLater();
}

class FreeDesktopIntrospect : public QDBusAbstractInterface
{
public:
	FreeDesktopIntrospect(const QString &service, const QString &path,
						   const QDBusConnection &connection, QObject *parent = 0) :
		QDBusAbstractInterface(service, path, "org.freedesktop.DBus.Introspectable", connection, parent)
	{
	}
};

bool VeQItemDbus::introspect()
{
	FreeDesktopIntrospect iface(dbusServiceName(), dbusPath(), dbusConnection());

	if (!iface.isValid()) {
		qDebug() << "Cannot introspect object" << dbusPath();
		return false;
	}

	QList<QVariant> argumentList;
	QDBusPendingReply<QString> call = iface.asyncCallWithArgumentList("Introspect", argumentList);
	QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(call, this);
	this->connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher*)), SLOT(introspectObtained(QDBusPendingCallWatcher*)));

	return true;
}
#endif

QDBusPendingCallWatcher *VeQItemDbus::asyncCall(const QString &method, const char *returnMethod)
{
	QDBusMessage msg = QDBusMessage::createMethodCall(mDbusService->owner(), dbusPath(), "com.victronenergy.BusItem", method);
	QDBusPendingCall async = dbusConnection().asyncCall(msg);
	QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(async, this);
	connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher*)), returnMethod);

	return watcher;
}

void VeQItemDbus::valueObtained(QDBusPendingCallWatcher *call)
{
	QDBusPendingReply<QDBusVariant> reply = *call;
	QVariant value;
	State state(Synchronized);

	if (reply.isError()) {
		QDBusError error(reply.error());

		// bulk init failed
		if (dbusPath() == "/" && mDbusService->isBulkInitValueActive()) {
			qDebug() << dbusServiceName() << "bulkInitValue not supported";
			mDbusService->bulkInitValueDone(false);
			state = (dbusIsServiceRegistered() ? Synchronized : Offline);
		// tolerate paths not yet being present and failing GetValues on the root
		} else {
			state = Offline;
			if (error.type() != QDBusError::UnknownObject)
				qDebug() << "Error value:" << reply.error() << dbusServiceName() << dbusPath();
		}
	} else {
		value = reply.value().variant();
		demarshallVariantForQml(value, mSignature);

		if (!isLeaf()) {
			// when support, which is apperently is, having a valid responds on a non-leaf
			// item returns all the values of the leaves in one go. So iterate and update them
			// all as well.
			QVariantMap map(value.toMap());
			bool create = producer()->getAutoCreateItems();

			for (QVariantMap::const_iterator i = map.constBegin(); i != map.constEnd(); i++) {
				VeQItem *item = create ? itemGetOrCreate(i.key()) : itemGet(i.key());
				if (item)
					item->produceValue(i.value());
			}

			// Note: only the leaves receive change events, so clear the actual value
			// to prevent users from using the non-leaves
			value = QVariant();

			// bulk init succeeded
			if (dbusPath() == "/" && mDbusService->isBulkInitValueActive())
				mDbusService->bulkInitValueDone(true);
		}
	}

	produceValue(value, state);
	call->deleteLater();
}

QVariant VeQItemDbus::getValue(bool force)
{
	if (mState == Idle || force) {
		// If the service is not online, postpone the request till it is ...
		if (!dbusIsServiceRegistered()) {
			mRequestValueWhenOnline = true;
			setState(Offline);
			return QVariant();
		}

		if (mDbusService->isBulkInitValueActive()) {
			// reusing the flag here for the case that bulk get is not supported
			mRequestValueWhenOnline = true;
			return QVariant();
		}

		setState(Requested);
		asyncCall("GetValue", SLOT(valueObtained(QDBusPendingCallWatcher*)));
	}

	return mValue;
}

void VeQItemDbus::textObtained(QDBusPendingCallWatcher *call)
{
	QString value;
	State state(Synchronized);

	if (!isLeaf()) {
		QDBusPendingReply< QVariant > reply = *call;
		if (reply.isError()) {
			QDBusError error(reply.error());

			// bulk init failed
			if (dbusPath() == "/" && mDbusService->isBulkInitTextActive()) {
				qDebug() << dbusServiceName() << "bulkInitText not supported";
				mDbusService->bulkInitTextDone(false);
				state = (dbusIsServiceRegistered() ? Synchronized : Offline);
			// tolerate paths not yet being present
			} else {
				state = Offline;
				if (error.type() != QDBusError::UnknownObject)
					qDebug() << "Error value:" << reply.error() << dbusServiceName() << dbusPath();
			}
		} else {
			QVariant variant = reply.value();
			const QDBusArgument &dbusArgument = qvariant_cast<QDBusArgument>(variant);
			StringMap map = qdbus_cast<StringMap>(dbusArgument);
			bool create = producer()->getAutoCreateItems();

			for (StringMap::const_iterator i = map.constBegin(); i != map.constEnd(); i++) {
				VeQItem *item = create ? itemGetOrCreate(i.key()) : itemGet(i.key());
				if (item)
					item->produceText(i.value());
			}

			// bulk init succeeded
			if (dbusPath() == "/" && mDbusService->isBulkInitTextActive())
				mDbusService->bulkInitTextDone(true);

			produceText("");
		}
	} else {
		QDBusPendingReply<QString> reply = *call;

		if (reply.isError()) {
			QDBusError error(reply.error());
			state = Offline;

			// tolerate paths not yet being present
			if (error.type() != QDBusError::UnknownObject)
				qDebug() << "Error value:" << reply.error() << dbusServiceName() << dbusPath();
		} else {
			value = reply.value();
		}

		produceText(value, state);
	}

	call->deleteLater();
}

QString VeQItemDbus::getText(bool force)
{
	if (mTextState == Idle || force) {
		// If the service is not online, postpone the request till it is ...
		if (!dbusIsServiceRegistered()) {
			mRequestTextWhenOnline = 1;
			setTextState(Offline);
			return QString();
		}

		if (mDbusService->isBulkInitValueActive()) {
			// reusing the flag here for the case that bulk get is not supported
			mRequestTextWhenOnline = true;
			return QString();
		}

		setTextState(Requested);
		asyncCall("GetText", SLOT(textObtained(QDBusPendingCallWatcher*)));
	}

	return mText;
}

void VeQItemDbus::propertyObtained(const char *name, QDBusPendingCallWatcher *call)
{
	QDBusPendingReply<QDBusVariant> reply = *call;
	QVariant value;
	State state(Synchronized);

	if (reply.isError()) {
		QDBusError error(reply.error());
		state = Offline;
		// tolerate paths not yet being present
		if (error.type() != QDBusError::UnknownObject)
			qDebug() << "Error value:" << reply.error() << dbusServiceName() << dbusPath();
	} else {
		value = reply.value().variant();
		QString dummy;
		demarshallVariantForQml(value, dummy);
	}

	itemProduceProperty(name, value, state);
	call->deleteLater();
}

void VeQItemDbus::defaultObtained(QDBusPendingCallWatcher *call)
{
	propertyObtained("defaultValue", call);
}

void VeQItemDbus::maxObtained(QDBusPendingCallWatcher *call)
{
	propertyObtained("max", call);
}

void VeQItemDbus::minObtained(QDBusPendingCallWatcher *call)
{
	propertyObtained("min", call);
}

QVariant VeQItemDbus::itemProperty(const char *name, bool force)
{
	if (mPropertyState[name] == Idle || force) {
		QString method;
		bool *pending;
		const char *slot;

		if (QLatin1String(name) == "min") {
			method = "GetMin";
			pending = &mRequestMinWhenOnline;
			slot = SLOT(minObtained(QDBusPendingCallWatcher*));
		} else if (QLatin1String(name) == "max") {
			method = "GetMax";
			pending = &mRequestMaxWhenOnline;
			slot = SLOT(maxObtained(QDBusPendingCallWatcher*));
		} else if (QLatin1String(name) == "defaultValue") {
			method = "GetDefault";
			pending = &mRequestDefaultWhenOnline;
			slot = SLOT(defaultObtained(QDBusPendingCallWatcher*));
		} else {
			return property(name);
		}

		// If the service is not online, postpone the request till it is ...
		if (!dbusIsServiceRegistered()) {
			*pending = true;
			mPropertyState[name] = Offline;
			return QVariant();
		}

		mPropertyState[name] = Requested;
		asyncCall(method, slot);
	}

	return property(name);
}

void VeQItemDbus::setValueDone(QDBusPendingCallWatcher *call)
{
	call->deleteLater();
}

int VeQItemDbus::setValue(const QVariant &value)
{
	if (!dbusIsServiceRegistered() || mState == Offline) {
		qDebug() << "ignoring request for" << uniqueId() << "to set value" << value << "(not online)";
		return -1;
	}

	// no need to set values to the same again
	if (mState == Storing && mPendingSetValue == value)
		return 0;

	mPendingSetValue = value;
	setState(Storing);

	QDBusMessage msg = QDBusMessage::createMethodCall(mDbusService->owner(), dbusPath(), "com.victronenergy.BusItem", "SetValue");
	if (value.isValid()) {
		msg << QVariant::fromValue(QDBusVariant(value));
	} else {
		QDBusArgument invalid;
		invalid.beginArray(qMetaTypeId<int>());
		invalid.endArray();
		msg << QVariant::fromValue(invalid);
	}
	QDBusPendingCall set = dbusConnection().asyncCall(msg);
	QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(set, this);
	this->connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher*)), SLOT(setValueDone(QDBusPendingCallWatcher*)));

	return 0;
}

// hook just before the item is added
void VeQItemDbus::setParent(QObject *parent)
{
	VeQItem::setParent(parent);

	// If this is a dbus service check if it is known
	if (parent == producer()->services()) {
		mDbusService = producer()->dbusServiceGetOrCreate(id());
		mDbusService->attachRootItem(this);
	} else {
		mDbusService = static_cast<VeQItemDbus *>(parent)->mDbusService;
	}
}

QString VeQItemDbus::dbusPath()
{
	return mDbusService->dbusPath(this);
}

QString VeQItemDbus::dbusServiceName()
{
	return mDbusService->serviceName();
}

bool VeQItemDbus::dbusIsServiceRegistered()
{
	return mDbusService->isRegistered();
}

QDBusConnection &VeQItemDbus::dbusConnection()
{
	return producer()->dbusConnection();
}

/*
 * Qt its default QDBusAbstractInterface is a bit heavy to instaniate when there
 * are many items. In the order of tens of ms on a beaglebone increasing with the
 * number of items, so with 6000 items it takes more then a minute to create them
 * all. This is likely caused by the fact that every Item subscribes to name owner
 * changes itself. Since the name owner changes are already monitored here and all
 * items are already notified about such an event, see VeQItemDbus::serviceRegistrationChanged
 * it is unneeded for use that the QDBusAbstractInterface does this, but it does
 * goes trouble when connection many services with many Items, which we would like
 * to support now (2017). So this class talks to the dbus connection directly instead
 * of the having an intermediate QDBusAbstractInterface.
 */

VeDbusServicePrivate::VeDbusServicePrivate(QString owner, QObject *parent) :
	QObject(parent),
	mOwner(owner),
	mServiceRoot(0),
	mBulkInitValueActive(false),
	mBulkInitTextActive(false)
{
	// NOTE: don t do anything here, since the object is not attached to an item
	// yet, all members are bound to fail. Use attachItem instead.
}

VeDbusServicePrivate::~VeDbusServicePrivate()
{
	if (!mServiceRoot)
		return;

	// guess it is https://bugreports.qt.io/browse/QTBUG-29498
	dbusConnection().disconnect(serviceName(), "", "com.victronenergy.BusItem" ,"PropertiesChanged",
								this, SLOT(onPropertiesChanged(const QVariantMap &)));

	dbusConnection().disconnect(serviceName(), "/", "com.victronenergy.BusItem" ,"ItemsChanged",
								this, SLOT(onItemsChanged(ItemMap)));

	if (!producer()->getFindVictronServices())
		dbusConnection().disconnect("org.freedesktop.DBus", "", "org.freedesktop.DBus",
								 "NameOwnerChanged", QStringList() << serviceName(), "sss",
								 producer(), SLOT(onServiceOwnerChanged(QString,QString,QString)));
}


void VeDbusServicePrivate::attachRootItem(VeQItemDbus *serviceRoot)
{
	mServiceRoot = serviceRoot;

	dbusConnection().connect(serviceName(), "", "com.victronenergy.BusItem" ,"PropertiesChanged",
							 this, SLOT(onPropertiesChanged(QVariantMap)));

	dbusConnection().connect(serviceName(), "/", "com.victronenergy.BusItem", "ItemsChanged",
							this, SLOT(onItemsChanged(ItemMap)));

	if (!producer()->getFindVictronServices())
		dbusConnection().connect("org.freedesktop.DBus", "", "org.freedesktop.DBus",
								 "NameOwnerChanged", QStringList() << serviceName(), "sss",
								 producer(), SLOT(onServiceOwnerChanged(QString,QString,QString)));

	/*
	 * When added from the consuming side / found by registeredServiceNames,
	 * the name owner might needs to be requested. It is already known when
	 * found by a NameOwnerChange. This blocks, not sure it that matters...
	 */
	if (mOwner.isNull()) {
		QDBusReply<QString> reply = dbusConnection().interface()->serviceOwner(serviceName());
		if (reply.isValid()) {
			mOwner = reply.value();
			if (!producer()->getBulkInit())
				serviceRoot->setState(VeQItem::Synchronized);
		} else {
			serviceRoot->setState(VeQItem::Offline);
		}
	}

	/*
	 * The service might not be available on the dbus at this time, but that
	 * seldomly occurs. In that case bulk init is simply skipped for now, since
	 * the call to getValue will be refused for offline items, they would be
	 * stuck forever in the waitingForBulkReply.
	 */
	if (serviceRoot->dbusIsServiceRegistered() && producer()->getBulkInit()) {
		mServiceRoot->getValue();
		mServiceRoot->getText();
		// mind it: order matters here, since above root getValue should succeed!
		mBulkInitValueActive = true;
		mBulkInitTextActive = true;
	}
}

void VeDbusServicePrivate::bulkInitValueDone(bool success)
{
	Q_UNUSED(success);

	mBulkInitValueActive = false;

	// Note: always do this, since there is a time window between sending
	// and receiving, there is a chance that even when the bulk get was
	// succesfull, there are still items which need to be obtained individually
	// if it was created in the meantime.
	foreach (VeQItemDbus *child, mServiceRoot->findChildren<VeQItemDbus *>())
		child->bulkInitValueDone();
}

void VeDbusServicePrivate::bulkInitTextDone(bool success)
{
	Q_UNUSED(success);

	mBulkInitTextActive = false;
	foreach (VeQItemDbus *child, mServiceRoot->findChildren<VeQItemDbus *>())
		child->bulkInitTextDone();
}

QString VeDbusServicePrivate::dbusPath(VeQItemDbus *item)
{
	return item->getRelId(mServiceRoot);
}

void VeDbusServicePrivate::handleItemProperties(const QString &path, const QVariantMap &changes)
{
	VeQItem *item;

	if (producer()->getAutoCreateItems()) {
		item = mServiceRoot->itemGetOrCreate(path);
	} else {
		item = mServiceRoot->itemGet(path);
		if (!item)
			return;
	}

	static_cast<VeQItemDbus *>(item)->onPropertiesChanged(changes);
}

void VeDbusServicePrivate::onItemsChanged(ItemMap const &items)
{
	for (auto it = items.begin(); it != items.end(); ++it)
		handleItemProperties(it.key(), it.value());
}

void VeDbusServicePrivate::serviceRegistrationChanged(bool registered)
{
	mServiceRoot->serviceRegistrationChanged(registered);
	foreach (VeQItemDbus *child, mServiceRoot->findChildren<VeQItemDbus *>())
		child->serviceRegistrationChanged(registered);
}

void VeDbusServicePrivate::ownerChanged(const QString &oldOwner, const QString &newOwner)
{
	mOwner = newOwner;
	if (!mServiceRoot)
		return;

	if (oldOwner != "") // disconnect event
		serviceRegistrationChanged(false);

	if (newOwner != "") // connect event
		serviceRegistrationChanged(true);
}

/**
 * @brief VeQItemDbusProducer::VeQItemDbusProducer
 * @param root
 * @param id
 * @param findVictronServices
 *          There are two modus operandi. Well known services can be added and monitored for
 *          presence. com.victronenergy services typically have "something" unique added
 *          to the dbus service name to allow multiple service of the same kind (e.g. multiple
 *          battery banks, motors etc). Setting this flag will auto add all services starting
 *          with com.victronengy. (It will cause a warning to be displayed about connecting to
 *          a depecrated signal to monitor all services, which is exactly the intended, the warning
 *          is the BUG)
 * @param bulkInitOfNewService
 *          Some services (c based at the moment) allow the get all values at once
 *          by calling GetValue on its root item. This can be enabled to initialize,
 *          but will complain when querying services which don't support it. When
 *          debugging you typically want to turn this off.
 * @param parent
 */
VeQItemDbusProducer::VeQItemDbusProducer(VeQItem *root, QString id,
										 bool findVictronServices, bool bulkInitOfNewService,
										 QObject *parent)
	: VeQItemProducer(root, id, parent),
	  mDbus(QDBusConnection("")),
	  mFindVictronServices(findVictronServices),
	  mBulkInitOfNewService(bulkInitOfNewService),
	  mAutoCreateItems(true)
{
	qDBusRegisterMetaType<StringMap>();
	qDBusRegisterMetaType<ItemMap>();
}

bool VeQItemDbusProducer::open(const QString &address, const QString &qtDbusName)
{
	// FIXME: find non blocking version, all signals / slots are stalled for
	// 30 secs or so if this fails when connection by tcp/ip...
	if (address == "session")
		return open(QDBusConnection::connectToBus(QDBusConnection::SessionBus, qtDbusName));
	if (address == "system")
		return open(QDBusConnection::connectToBus(QDBusConnection::SystemBus, qtDbusName));

	return open(QDBusConnection::connectToBus(address, qtDbusName));
}

bool VeQItemDbusProducer::open(const QDBusConnection &dbusConnection)
{
	mDbus = dbusConnection;

	if (!mDbus.isConnected())
		return false;

	if (mFindVictronServices) {
		QDBusConnectionInterface *interface = mDbus.interface();
		connect(interface, SIGNAL(serviceOwnerChanged(QString,QString,QString)), this, SLOT(onServiceOwnerChanged(QString,QString,QString)));

		QStringList registerServices = interface->registeredServiceNames();
		foreach (QString name, registerServices) {
			if (name.startsWith("com.victronenergy."))
				services()->itemGetOrCreate(name, false);
		}
	}

	return true;
}

VeQItem *VeQItemDbusProducer::createItem()
{
	return new VeQItemDbus(this);
}

/**
 * Setting this option to false will improve memory usage if you are interested in a few D-Bus items
 * per service.
 */
void VeQItemDbusProducer::setAutoCreateItems(bool v)
{
	if (mDbus.isConnected()) {
		qDebug() << "cannot change 'autoCreateItems' flag when the producer has already been opened";
		return;
	}
	mAutoCreateItems = v;
}

// Finds not "well known services"
void VeQItemDbusProducer::onServiceOwnerChanged(const QString &serviceName, const QString &oldOwner, const QString &newOwner)
{
	Q_UNUSED(oldOwner);

	if (!serviceName.startsWith("com.victronenergy."))
		return;

	// make sure there is a service object
	VeDbusServicePrivate *service = dbusServiceGetOrCreate(serviceName, newOwner);
	// and a corresponding spot in in the tree
	if (newOwner != "")
		mProducerRoot->itemGetOrCreate(serviceName, false);
	// now handle the owner change
	service->ownerChanged(oldOwner, newOwner);
}

VeDbusServicePrivate *VeQItemDbusProducer::dbusServiceGetOrCreate(QString const serviceName, QString owner)
{
	VeDbusServicePrivate *ret = mServiceWatchers.value(serviceName);
	if (ret == 0) {
		ret = new VeDbusServicePrivate(owner, this);
		mServiceWatchers[serviceName] = ret;
	}
	return ret;
}

/** Settings */
VeQItemDbusSettings::VeQItemDbusSettings(VeQItem *parent, QString id) :
	VeQItemSettings(parent, id),
	mConn(static_cast<VeQItemDbus *>(mRoot)->dbusConnection())
{
	qDBusRegisterMetaType<QVariantMapList>();
}

QDBusMessage VeQItemDbusSettings::sendAddSettings(VeQItemSettingsInfo const &settingsInfo)
{
	QDBusMessage message = QDBusMessage::createMethodCall("com.victronenergy.settings",
														  "/Settings",
														  "com.victronenergy.Settings",
														  "AddSettings");

	QVariantMapList settings;

	for (VeQItemSettingInfo const &settingInfo: settingsInfo.info()) {
		QMap<QString, QVariant> setting;
		setting.insert("path", settingInfo.mPath);
		setting.insert("default", settingInfo.mDefaultValue);
		if (settingInfo.mMin.isValid())
			setting.insert("min", settingInfo.mMin);
		if (settingInfo.mMax.isValid())
			setting.insert("max", settingInfo.mMax);
		if (settingInfo.mSilent)
			setting.insert("silent", 1);
		settings.append(setting);
	}

	QList<QVariant> arguments;
	arguments.append(QVariant::fromValue(settings));
	message.setArguments(arguments);
	QDBusMessage reply = mConn.call(message);

	return reply;
}

bool VeQItemDbusSettings::handleAddSettingsReply(QDBusMessage &reply)
{
	bool ret = true;

	QList<QVariant> retArgs = reply.arguments();
	if (retArgs.length() != 1)
		return false;

	QVariantMapList results;
	qvariant_cast<QDBusArgument>(retArgs[0]) >> results;
	for(QVariantMap result: results) {
		int error = result["error"].toInt(&ret);
		if (!ret || error) {
			ret = false;
			continue;
		}

		QString path = result["path"].toString();
		if (path.isEmpty()) {
			ret = false;
			continue;
		}

		QVariant value = result["value"];
		root()->itemGetOrCreateAndProduce("Settings/" + path, value);
	}

	return ret;
}

bool VeQItemDbusSettings::addSettings(VeQItemSettingsInfo const &info)
{
	QDBusMessage reply = sendAddSettings(info);

	if (reply.type() != QDBusMessage::ReplyMessage)
		return false;

	return handleAddSettingsReply(reply);
}
