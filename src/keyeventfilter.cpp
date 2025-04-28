/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "keyeventfilter.h"

#include <QKeyEvent>

using namespace Victron::VenusOS;

KeyEventFilter::KeyEventFilter(QObject *parent)
	: QObject(parent)
{
}


QQuickWindow* KeyEventFilter::window() const
{
	return m_window;
}

void KeyEventFilter::setWindow(QQuickWindow* window)
{
	if (m_window != window) {
		if (m_window) {
			m_window->removeEventFilter(this);
		}
		m_window = window;
		if (m_window) {
			window->installEventFilter(this);
		}
		emit windowChanged();
	}
}

bool KeyEventFilter::consumeKeyEvents() const
{
	return m_consumeKeyEvents;
}

void KeyEventFilter::setConsumeKeyEvents(bool consumeKeyEvents)
{
	if (m_consumeKeyEvents != consumeKeyEvents) {
		m_consumeKeyEvents = consumeKeyEvents;
		emit consumeKeyEventsChanged();
	}
}

bool KeyEventFilter::eventFilter(QObject *obj, QEvent *event)
{
	if (m_window && obj == m_window) {
		if (event->type() == QEvent::KeyPress) {
			QKeyEvent *keyEvent = static_cast<QKeyEvent *>(event);
			emit keyPressed(keyEvent->key(), keyEvent->modifiers());
			return m_consumeKeyEvents;
		}
	}
	return false;
}

