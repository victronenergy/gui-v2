/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef CAMPERDATAPROVIDER_H
#define CAMPERDATAPROVIDER_H

#include <QObject>
#include <QVariantMap>

class QTimer;

class CamperDataProvider : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QVariantMap data READ data NOTIFY dataChanged FINAL)
	Q_PROPERTY(QString sourceName READ sourceName NOTIFY sourceNameChanged FINAL)
	Q_PROPERTY(bool hostDataAvailable READ hostDataAvailable NOTIFY hostDataAvailableChanged FINAL)

public:
	explicit CamperDataProvider(QObject *parent = nullptr);

	QVariantMap data() const;
	QString sourceName() const;
	bool hostDataAvailable() const;

	Q_INVOKABLE void refresh();

Q_SIGNALS:
	void dataChanged();
	void sourceNameChanged();
	void hostDataAvailableChanged();

private:
	QVariantMap buildMockData();
	bool tryReadHostData(QVariantMap *data) const;
	void applyData(const QVariantMap &data, const QString &sourceName, bool hostDataAvailable);

	QTimer *m_refreshTimer = nullptr;
	QVariantMap m_data;
	QString m_sourceName;
	bool m_hostDataAvailable = false;
	double m_mockPhase = 0.0;
};

#endif // CAMPERDATAPROVIDER_H
