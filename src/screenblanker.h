/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef SCREENBLANKER_H
#define SCREENBLANKER_H

#include <QQmlEngine>
#include <QQuickWindow>
#include <QTimer>

class VeQItem;

namespace Victron {
namespace VenusOS {

class ScreenBlanker : public QObject
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(bool blanked READ blanked NOTIFY blankedChanged)
	Q_PROPERTY(bool supported READ supported CONSTANT)
	Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
	Q_PROPERTY(int displayOffTime READ displayOffTime WRITE setDisplayOffTime NOTIFY displayOffTimeChanged)
	Q_PROPERTY(QQuickWindow* window READ window WRITE setWindow NOTIFY windowChanged)

public:
	explicit ScreenBlanker(QObject *parent = nullptr);

	bool supported() const;

	bool blanked() const;

	bool enabled() const;
	void setEnabled(bool enabled);

	Q_INVOKABLE void setDisplayOn();
	Q_INVOKABLE void setDisplayOff();

	int displayOffTime() const;
	void setDisplayOffTime(int time);

	QQuickWindow* window() const;
	void setWindow(QQuickWindow* window);

Q_SIGNALS:
	void enabledChanged();
	void blankedChanged();
	void displayOffTimeChanged();
	void windowChanged();
protected:
	bool eventFilter(QObject *obj, QEvent *event) override;
private:
	void restartDisplayOffTimer();
	void stopDisplayOffTimer();

	void setBlanked(bool blanked);

	int readFromFile(QString filename) const;
	bool writeToFile(QString filename, int value) const;
	QString getFeature(QString const &name) const;

private:
	bool m_blanked = false;
	bool m_enabled = false;

	QQuickWindow *m_window;
	QTimer m_blankingTimer;
	QString m_blankDevice;
};

}
}

#endif // SCREENBLANKER_H
