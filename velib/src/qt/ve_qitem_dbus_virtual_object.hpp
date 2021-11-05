#ifndef _VELIB_QT_VE_QITEMS_DBUS_VIRTUAL_OBJECT_HPP_
#define _VELIB_QT_VE_QITEMS_DBUS_VIRTUAL_OBJECT_HPP_

#include <QDBusConnection>
#include <QDBusVirtualObject>
#include <QList>
#include <QVariantMap>

#include <velib/qt/ve_qitem.hpp>
#include <velib/qt/ve_qitems_dbus.hpp> // contains StringMap typedef

/// Represents a single D-Bus service and handles all method calls.
/// This is used by VeQItemDbusPublisher to publish VeQItem tree on the D-Bus.
class VeQItemDbusVirtualObject : public QDBusVirtualObject
{
	Q_OBJECT
public:
	VeQItemDbusVirtualObject(const QDBusConnection &connection, VeQItem *root, QObject *parent = 0);

	QString serviceName() const;
	VeQItem *root();
	bool registerService();
	bool unregisterService();
	virtual QString introspect(const QString &path) const;
	virtual bool handleMessage(const QDBusMessage &message, const QDBusConnection &connection);

private slots:
	void onChildAdded(VeQItem *item);
	void onChildRemoved(VeQItem *item);
	void onValueChanged(VeQItem *item);
	void onTextChanged(VeQItem *item);

private:
	bool handleGetValue(const QDBusMessage &message, const QDBusConnection &connection,
						VeQItem *item);
	bool handleGetText(const QDBusMessage &message, const QDBusConnection &connection,
						VeQItem *item);
	bool handleSetValue(const QDBusMessage &message, const QDBusConnection &connection,
						VeQItem *producer);
	bool handleGetItems(const QDBusMessage &message, const QDBusConnection &connection);

	void addPending(VeQItem *item);
	Q_INVOKABLE void processPending();

	void sendPropertiesChanged(VeQItem *item);

	void connectItem(VeQItem *item);
	void disconnectItem(VeQItem *item);

	/// This will create a map for GetValue on a node if map is of type QVariantMap.
	/// If it is a StringMap the map for GetText will be created.
	template<typename Map>
	void buildTree(VeQItem *root, VeQItem *item, Map &map)
	{
		for (VeQItem *child: item->itemChildren()) {
			if (child->isLeaf()) {
				QString path = child->getRelId(root);
				if (path.startsWith('/'))
					path.remove(0, 1);
				addTreeValue(path, child, map);
			} else {
				buildTree(root, child, map);
			}
		}
	}

	void addTreeValue(const QString &path, VeQItem *item, QVariantMap &map)
	{
		map[path] = denormalizeVariant(item->getValue());
	}

	void addTreeValue(const QString &path, VeQItem *item, StringMap &map)
	{
		map[path] = item->getText();
	}

	static void normalizeVariant(QVariant &v);
	static void normalizeMap(QVariantMap &map);
	static void normalizeList(QVariantList &list);
	static QVariant &denormalizeVariant(QVariant &v);
	static QVariant denormalizeVariant(const QVariant &v);

	QDBusConnection mConnection;
	VeQItem *mRoot;
	QList<VeQItem *> mPendingChanges;
};

#endif
