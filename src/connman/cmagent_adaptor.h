#ifndef CMAGENT_INTERFACE_H
#define CMAGENT_INTERFACE_H

#include <QDBusAbstractAdaptor>
#include <QDBusObjectPath>

class CmAgentAdaptor : public QDBusAbstractAdaptor
{
	Q_OBJECT
	Q_CLASSINFO("D-Bus Interface", "net.connman.Agent")

public:
	CmAgentAdaptor(QObject *parent = 0);

public slots:
	void Release();
	void ReportError(const QDBusObjectPath &path, const QString &error);
	void RequestBrowser(const QDBusObjectPath &path, const QString &url);
	QVariantMap  RequestInput(const QDBusObjectPath &path, const QVariantMap &fields);
	void Cancel();
};

#endif // CMAGENT_INTERFACE_H
