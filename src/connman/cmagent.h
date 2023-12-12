#ifndef CMAGENT_H
#define CMAGENT_H

#include <QObject>
#include <QDBusConnection>
#include <qqmlintegration.h>
#include "cmagent_adaptor.h"

class CmAgent : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(QString path READ path WRITE path)
	Q_PROPERTY(QString passphrase READ passphrase WRITE passphrase)

public:
	CmAgent(QObject *parent = 0);
	CmAgent(const QString &objectPath, QObject *parent = 0);
	~CmAgent();

	const QString path() const { return mPath; }
	void path(const QString &path);
	const QString passphrase() const { return mPassPhrase; }
	void passphrase(const QString &phrase) { mPassPhrase = phrase; }

signals:

public slots:
	void release();
	void reportError(const QDBusObjectPath &path, const QString &error);
	void requestBrowser(const QDBusObjectPath &path, const QString &url);
	QVariantMap requestInput(const QDBusObjectPath &path, const QVariantMap &fields);
	void cancel();

private:
	QString mPath;
	QString mPassPhrase;
	CmAgentAdaptor mAgent;
};

#endif // CMAGENT_H
