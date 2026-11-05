/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef CAMPERDATAPROVIDER_H
#define CAMPERDATAPROVIDER_H

#include <QObject>
#include <QVariantMap>

class QTimer;

/*
	Provides the values to be displayed in the illustration.

	In a WebAssembly build they are read from window.camperViewData, which is set by the hosting
	page. If the host has not provided any values, the data is empty and the illustration shows
	no values: it never shows made-up values that could be mistaken for real ones.

	In a desktop build, which is only for development, there is no host, so sample data is used.
*/
class CamperDataProvider : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QVariantMap data READ data NOTIFY dataChanged FINAL)

public:
	explicit CamperDataProvider(QObject *parent = nullptr);

	QVariantMap data() const;

Q_SIGNALS:
	void dataChanged();

private:
	void refresh();
	QVariantMap readData();

	QTimer *m_refreshTimer = nullptr;
	QVariantMap m_data;
	int m_sampleIndex = 0;
};

#endif // CAMPERDATAPROVIDER_H
