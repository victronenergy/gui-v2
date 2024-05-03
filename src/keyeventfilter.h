/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef KEYEVENTFILTER_H
#define KEYEVENTFILTER_H

#include <QQmlEngine>
#include <QQuickWindow>

namespace Victron {
namespace VenusOS {

class KeyEventFilter : public QObject
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(bool consumeKeyEvents MEMBER m_consumeKeyEvents)
	Q_PROPERTY(QQuickWindow* window READ window WRITE setWindow NOTIFY windowChanged)

public:
	explicit KeyEventFilter(QObject *parent = nullptr);

	QQuickWindow* window() const;
	void setWindow(QQuickWindow* window);

protected:
	bool eventFilter(QObject *obj, QEvent *event) override;

Q_SIGNALS:
	void pressed();
	void windowChanged();
private:
	QQuickWindow *m_window;
	bool m_consumeKeyEvents = false;
	bool m_waitForRelease;
};

}
}

#endif // KEYEVENTFILTER_H
