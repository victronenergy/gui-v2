/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QDir>
#include <QFile>
#include <QQmlInfo>
#include <QRegularExpression>

#include "screenblanker.h"

#include <QtDebug>

using namespace Victron::VenusOS;

ScreenBlanker::ScreenBlanker(QObject *parent) : QObject(parent)
{
	qInfo() << "ScreenBlanker: determining support";
	m_blankDevice = getFeature("blank_display_device");
	m_blanked = supported() ? readFromFile(m_blankDevice) == 1 : false;

	if (supported()) {
		qInfo() << "ScreenBlanker: supported.  Currently, blanked = " << m_blanked;
		m_enabled = true;
		connect(&m_blankingTimer, &QTimer::timeout, this, &ScreenBlanker::setDisplayOff);
	} else {
		qWarning() << "ScreenBlanker: not supported.";
	}
}

bool ScreenBlanker::enabled() const
{
	return m_enabled;
}

void ScreenBlanker::setEnabled(bool enabled)
{
	if (!supported()) {
		return;
	}

	if (m_enabled != enabled) {
		m_enabled = enabled;
		if (m_enabled) {
			setDisplayOn();
		} else {
			stopDisplayOffTimer();
		}
		emit enabledChanged();
	}
}

void ScreenBlanker::restartDisplayOffTimer()
{
	if (!m_blanked && m_blankingTimer.interval() > 0) {
		m_blankingTimer.start();
	}
}


void ScreenBlanker::stopDisplayOffTimer()
{
	m_blankingTimer.stop();
	setBlanked(false);
}

bool ScreenBlanker::supported() const
{
#if defined(VENUS_DESKTOP_BUILD)
	return true; // For unit testing
#else
	return m_blankDevice.length() > 0;
#endif
}

bool ScreenBlanker::blanked() const
{
	return m_blanked;
}

int ScreenBlanker::displayOffTime() const
{
	return m_blankingTimer.interval();
}

void ScreenBlanker::setDisplayOffTime(int time)
{
	if (time >= 0 && time != m_blankingTimer.interval()) {
		m_blankingTimer.setInterval(time);
		if (m_enabled) {
			if (m_blankingTimer.interval() > 0) {
				restartDisplayOffTimer();
			} else {
				stopDisplayOffTimer();
			}
		}
		emit displayOffTimeChanged();
	}
}

QQuickWindow* ScreenBlanker::window() const
{
	return m_window;
}

void ScreenBlanker::setWindow(QQuickWindow* window) {
	if (window != m_window) {
		m_window = window;
		if (m_window) {
			m_window->installEventFilter(this);
		} else {
			qmlWarning(this) << "ScreenBlanker: Access to the window required for implementing the screen blanking timeout";
		}
		emit windowChanged();
	}
}

bool ScreenBlanker::eventFilter(QObject *obj, QEvent *event)
{
	if (obj == m_window) {
		switch (event->type()) {
		case QEvent::KeyPress:
		case QEvent::MouseButtonPress:
		case QEvent::Scroll:
		case QEvent::TouchBegin: {
			bool wasBlanked = m_blanked;
			setDisplayOn();
			if (wasBlanked) {
				return true;
			}
			break;
		}
		default:
			// fall-through
			break;
		}
	}
	return false;
}

void ScreenBlanker::setDisplayOn()
{
	setBlanked(false);
	if (m_enabled) {
		restartDisplayOffTimer();
	}
}

void ScreenBlanker::setDisplayOff()
{
	if (m_enabled) {
		m_blankingTimer.stop();
		setBlanked(true);
	}
}

void ScreenBlanker::setBlanked(bool blanked)
{
	if (supported() && blanked != m_blanked) {
		m_blanked = blanked;
		writeToFile(m_blankDevice, blanked ? 1 : 0);
		emit blankedChanged();
	}
}

// From gui/platform/ve_platform.cpp
bool ScreenBlanker::writeToFile(QString filename, int value) const
{
	if (filename.isEmpty())
		return false;

	QFile file(filename);
	if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
		return false;

	QTextStream out(&file);
	out << QString::number(value);
	file.close();

	return true;
}

int ScreenBlanker::readFromFile(QString filename) const
{
	if (filename.isEmpty())
		return 0;

	QFile file(filename);
	if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
		return 0;

	int value = 0;
	if (!file.atEnd()) {
		const QString data = QString::fromUtf8(file.readAll());
		bool ok = true;
		value = data.toInt(&ok);
		if (!ok) {
			qWarning() << "ScreenBlanker: unable to read status from file; assuming not blanked";
			value = 0;
		}
	} else {
		qWarning() << "ScreenBlanker: no data to read from file; assuming not blanked";
	}
	file.close();

	return value;
}

// From gui/platform/ve_platform_venus.cpp
QString ScreenBlanker::getFeature(QString const &name) const
{
#if !defined(VENUS_WEBASSEMBLY_BUILD) && !defined(VENUS_DESKTOP_BUILD)
	QDir machineRuntimeDir = QDir("/etc/venus");
	if (!machineRuntimeDir.exists()) {
		qmlWarning(this) << "could not find the machine feature directory " + machineRuntimeDir.absolutePath();
		return QString();
	}

	QStringList ret;
	QFile file(machineRuntimeDir.filePath(name));

	if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
		return QString();

	QString line;
	while (!file.atEnd()) {
		line = file.readLine();
		ret.append(line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts));
	}

	return ret.count() >= 1 ? ret[0] : QString();
#else
	return QString();
#endif
}
