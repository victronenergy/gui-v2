/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIPLUGINS_PLUGINDATAPATHMODEL_H
#define VICTRON_GUIPLUGINS_PLUGINDATAPATHMODEL_H

#include <QAbstractListModel>
#include <QHash>
#include <QPointer>
#include <QString>
#include <QStringList>
#include <QTimer>
#include <QVariant>
#include <qqmlintegration.h>

class VeQItem;

namespace Victron {
namespace GuiPlugins {

class DeviceWatcher;

/*
	The child paths of a uid, for plugins, such as the top-level paths of a device.

	Set uid, such as a device's service uid, or set serviceType and path, and deviceInstance for a
	device, as on a PluginDataItem. Each child path has a name, such as "Dc", and a uid. When
	serviceType and path are set, it also has a path on the service, such as "/Pv/0", for a
	PluginDataItem with the same serviceType and deviceInstance. Only the paths that the system
	has are listed.
*/
class PluginDataPathModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(QString uid READ uid WRITE setUid NOTIFY uidChanged FINAL)
	Q_PROPERTY(QString serviceType READ serviceType WRITE setServiceType NOTIFY serviceTypeChanged FINAL)
	Q_PROPERTY(int deviceInstance READ deviceInstance WRITE setDeviceInstance NOTIFY deviceInstanceChanged FINAL)
	Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged FINAL)
	Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)

public:
	explicit PluginDataPathModel(QObject *parent = nullptr);

	QString uid() const;
	void setUid(const QString &uid);

	QString serviceType() const;
	void setServiceType(const QString &serviceType);

	int deviceInstance() const;
	void setDeviceInstance(int deviceInstance);

	QString path() const;
	void setPath(const QString &path);

	int count() const;

	Q_INVOKABLE QString childNameAt(int index) const;
	Q_INVOKABLE QString childPathAt(int index) const;
	Q_INVOKABLE QString childUidAt(int index) const;

	int rowCount(const QModelIndex &parent = QModelIndex()) const override;
	QVariant data(const QModelIndex &index, int role) const override;
	QHash<int, QByteArray> roleNames() const override;

Q_SIGNALS:
	void uidChanged();
	void serviceTypeChanged();
	void deviceInstanceChanged();
	void pathChanged();
	void countChanged();

private:
	enum Role {
		ChildNameRole = Qt::UserRole,
		ChildPathRole,
		ChildUidRole
	};

	void updateResolvedUid();
	void applyResolvedUid();
	void findRoot();
	void watchItem(VeQItem *item);
	void unwatchItem(VeQItem *item);
	void childAdded(VeQItem *child);
	void scheduleUpdate();
	void rootDestroyed();
	void findDeletedRoot();
	QStringList listedNames() const;
	void update();

	QPointer<VeQItem> m_root;
	DeviceWatcher *m_watcher = nullptr;
	QString m_uid;
	QString m_rootUid;
	QString m_serviceType;
	QString m_path;
	QStringList m_names;
	QTimer m_updateTimer;
	int m_deviceInstance = -1;
};

} // namespace GuiPlugins
} // namespace Victron

#endif // VICTRON_GUIPLUGINS_PLUGINDATAPATHMODEL_H
