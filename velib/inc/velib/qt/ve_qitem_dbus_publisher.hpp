#ifndef VEDBUSITEMPROVIDER_H
#define VEDBUSITEMPROVIDER_H

#include <QDBusConnection>

class VeQItem;
class VeQItemDbusVirtualObject;

/// Publishes an existing VeQItem tree on the D-Bus.
/// Some notes:
/// * The child item of the root item will be represented by a D-Bus service. All items below that
///   level will be D-Bus objects. The paths to the objects will be the relative path from the
///   service item to the object item.
///	* Items with status Offline and Idle will not be published. In case of a service level item,
///	  no D-Bus service will be created. This means you have to set the state of service level items
///   explicitly to get them published.
///   This behavior was introduced for 2 reasons: at time of publication of a D-Bus service, all
///   objects should be available and have the correct value. So with this class you can create
///   all necessary items and provide values before setting the state of the service level item.
///   What's more, deleting VeQItems often creates problems (eg. when connected to qml items). If
///   you want a D-Bus service / object to disappear from the D-Bus, you can change the state of
///   the root to Offline.
/// * This class does not create `VeQItem`s. You will need a `VeQItemProducer` or one of its child
///   classes to do that. Most likely you need VeQItemProducer itself, because it does not
///   connect to another data source to retrieve item values.
class VeQItemDbusPublisher : public QObject
{
	Q_OBJECT
public:
	VeQItemDbusPublisher(VeQItem *root, QObject *parent = 0);

	bool open(const QString &address = "session");

private slots:
	void onChildAdded(VeQItem *item);

	void onChildRemoved(VeQItem *item);

	void onRootStateChanged(VeQItem *item);

private:
	void addServices();

	void addChild(VeQItem *item);

	void removeChild(VeQItem *item);

	static QDBusConnection getConnection(const QString &address, const QString &qtDbusName);

	QString mDbusAddress;
	QList<VeQItemDbusVirtualObject *> mServices;
	VeQItem *mRoot;
};

#endif // VEDBUSITEMPROVIDER_H
