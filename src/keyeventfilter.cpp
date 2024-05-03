/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "keyeventfilter.h"

using namespace Victron::VenusOS;

KeyEventFilter::KeyEventFilter(QObject *parent) : QObject(parent)
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
            window->removeEventFilter(this);
        }
        m_window = window;
        if (m_window) {
            window->installEventFilter(this);
        }
    }
}

bool KeyEventFilter::eventFilter(QObject *obj, QEvent *event)
{
    if (obj && obj == m_window) {
        if (event->type() == QEvent::KeyPress) {
            m_waitForRelease = m_consumeKeyEvents;
            emit pressed();
        }
        if (event->type() == QEvent::KeyPress || event->type() == QEvent::KeyRelease) {
            return m_consumeKeyEvents || m_waitForRelease;
            m_waitForRelease = false;
        }
    }
    return false;
}
