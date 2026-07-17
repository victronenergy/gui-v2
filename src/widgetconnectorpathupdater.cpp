/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "widgetconnectorpathupdater.h"
#include <QQmlInfo>

using namespace Victron::VenusOS;

WidgetConnectorPathUpdater::WidgetConnectorPathUpdater(QObject *parent)
	: QObject(parent)
{
	connect(this, &WidgetConnectorPathUpdater::progressChanged, this, &WidgetConnectorPathUpdater::update);
}

WidgetConnectorPathUpdater::~WidgetConnectorPathUpdater()
{
}

QQuickPath *WidgetConnectorPathUpdater::getPath() const
{
	return path;
}

void WidgetConnectorPathUpdater::setPath(QQuickPath *newPath)
{
	if (path != newPath) {
		path = newPath;
		invalidateLut();
		emit pathChanged();
	}
}

void WidgetConnectorPathUpdater::add(QQuickItem *electron)
{
	if (!electrons.contains(electron)) {
		electrons.append(electron);
	} else {
		qmlWarning(this) << "Trying to add an electron item that was already added";
	}
}

void WidgetConnectorPathUpdater::remove(QQuickItem *electron)
{
	if (electrons.contains(electron)) {
		electrons.removeAll(electron);
	} else {
		qmlWarning(this) << "Trying to remove an electron item that hasn't been added";
	}
}

void WidgetConnectorPathUpdater::invalidateLut()
{
	m_lutValid = false;
}

void WidgetConnectorPathUpdater::rebuildLut()
{
	if (!path) {
		m_lutValid = false;
		return;
	}

	m_lut.resize(LUT_SIZE + 1);
	for (int i = 0; i <= LUT_SIZE; ++i) {
		const qreal p = static_cast<qreal>(i) / LUT_SIZE;
		qreal angle = 0;
		const QPointF pos = path->sequentialPointAt(p, &angle);
		m_lut[i] = { pos, angle };
	}
	m_lutValid = true;
}

WidgetConnectorPathUpdater::PathPoint WidgetConnectorPathUpdater::sampleLut(qreal p) const
{
	const qreal scaledProgress = qBound(0.0, p, 1.0) * LUT_SIZE;
	const int idx = static_cast<int>(scaledProgress);
	const qreal frac = scaledProgress - idx;

	if (idx >= LUT_SIZE) {
		return m_lut[LUT_SIZE];
	}

	if (frac < 1e-6) {
		return m_lut[idx];
	}

	const PathPoint &a = m_lut[idx];
	const PathPoint &b = m_lut[idx + 1];
	const qreal oneMinusFrac = 1.0 - frac;

	// Use shortest-arc interpolation for angles to handle the 360/0 wrap correctly
	qreal angleDiff = b.angle - a.angle;
	if (angleDiff > 180.0) angleDiff -= 360.0;
	else if (angleDiff < -180.0) angleDiff += 360.0;

	return {
		QPointF(a.position.x() * oneMinusFrac + b.position.x() * frac,
				a.position.y() * oneMinusFrac + b.position.y() * frac),
		a.angle + frac * angleDiff
	};
}

void WidgetConnectorPathUpdater::update()
{
	if (!path) {
		qmlDebug(this) << "Cannot animate electrons without a specified path";
		return;
	}

	if (!m_lutValid) {
		rebuildLut();
		if (!m_lutValid) {
			return;
		}
	}

	electrons.removeIf([](const QPointer<QQuickItem> &e) { return e.isNull(); });

	for (int i = 0; i < electrons.count(); i++) {
		QQuickItem *electron = electrons.at(i);
		// Can't use % operator, that gives remainder rather than a modulo that wraps.
		auto modulo = [](qreal dividend, qreal divisor)
		{
			return dividend - divisor * qFloor(dividend / divisor);
		};

		// Evenly space out the progress of each electron
		const qreal _progress = modulo((qIsNaN(progress) ? 0.0 : progress) - ((1.0 / electrons.count()) * i), 1.0);

		const PathPoint pp = sampleLut(_progress);

		electron->setX(pp.position.x() - electron->width()/2);
		electron->setY(pp.position.y() - electron->height()/2);

		const bool startToEnd = animationMode == Enums::WidgetConnector_AnimationMode::WidgetConnector_AnimationMode_StartToEnd;

		// The rotation expects clock-wise angle
		electron->setRotation(startToEnd ? 360.0 - pp.angle : 180 - pp.angle);

		const qreal normalizedProgress = startToEnd ? _progress : (1.0 - _progress);

		// Set opacity using setProperty() to make sure the behavior animation plays
		electron->setProperty("opacity", normalizedProgress > fadeOutThreshold ? 0 : 1);
	}
}

qreal WidgetConnectorPathUpdater::angleForArrow(qreal progress, bool startToEnd)
{
	if (!path) {
		qmlDebug(this) << "Cannot animate electrons without a specified path";
		return qQNaN();
	}

	if (!m_lutValid) {
		rebuildLut();
		if (!m_lutValid) {
			return qQNaN();
		}
	}

	const PathPoint pp = sampleLut(progress);
	return startToEnd ? 360.0 - pp.angle : 180 - pp.angle;
}
