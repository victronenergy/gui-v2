/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_KEYEVENTFILTER_H
#define VICTRON_GUIV2_KEYEVENTFILTER_H

#include <QQuickWindow>
#include <qqmlintegration.h>

namespace Victron {
namespace VenusOS {

class KeyEventFilter : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(QQuickWindow* window READ window WRITE setWindow NOTIFY windowChanged)
	Q_PROPERTY(bool consumeKeyEvents READ consumeKeyEvents WRITE setConsumeKeyEvents NOTIFY consumeKeyEventsChanged)

public:
	explicit KeyEventFilter(QObject *parent = nullptr);

	QQuickWindow* window() const;
	void setWindow(QQuickWindow* window);

	bool consumeKeyEvents() const;
	void setConsumeKeyEvents(bool consumeKeyEvents);

Q_SIGNALS:
	void keyPressed(int key, int modifiers);
	void windowChanged();
	void consumeKeyEventsChanged();

protected:
	bool eventFilter(QObject *obj, QEvent *event) override;

private:
	QQuickWindow *m_window = nullptr;
	bool m_consumeKeyEvents = false;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_KEYEVENTFILTER_H
