/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_SYSTEMSERVICELISTENER_H
#define VICTRON_VENUSOS_GUI_V2_SYSTEMSERVICELISTENER_H

#include <veutil/qt/ve_qitem.hpp>

#include <QQmlEngine>
#include <QAbstractListModel>
#include <QObject>
#include <QPointer>

namespace Victron {
namespace VenusOS {

class AllServicesModel;
class SystemServiceListener : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON

	Q_PROPERTY(bool settingsOnline READ settingsOnline NOTIFY settingsOnlineChanged FINAL)
	Q_PROPERTY(bool platformOnline READ platformOnline NOTIFY platformOnlineChanged FINAL)

public:
	static SystemServiceListener* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);
	explicit SystemServiceListener(QObject *parent);

	bool settingsOnline() const { return m_settingsOnline; }
	bool platformOnline() const { return m_platformOnline; }

Q_SIGNALS:
	void settingsOnlineChanged();
	void platformOnlineChanged();

private:
	void handleServiceAdded(VeQItem *serviceItem);
	void handleServiceAboutToBeRemoved(VeQItem *serviceItem);
	void listenToSettingsItem(VeQItem *serviceItem);
	void listenToPlatformItem(VeQItem *serviceItem);
	QPointer<AllServicesModel> m_allServicesModel;
	QPointer<VeQItem> m_settingsItem;
	QPointer<VeQItem> m_platformItem;
	bool m_settingsOnline = true;
	bool m_platformOnline = true;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_VENUSOS_GUI_V2_SYSTEMSERVICELISTENER_H
