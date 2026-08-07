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
		// Start faded out, so that the electron is not visible in its default
		// position until update() first places it on the path.
		electron->setOpacity(FadedOutOpacity);
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

qreal WidgetConnectorPathUpdater::opacityAt(qreal normalizedProgress) const
{
	// The electron fades out once it passes fadeOutThreshold, and fades back in
	// after it wraps around to the start of the path. Both fades take fadeDuration,
	// which as a fraction of the progress of a whole lap is fadeDuration/duration.
	//
	// The fade is calculated here, rather than by stepping the opacity between two
	// values and letting a QML Behavior animate between them, because that Behavior
	// used an OpacityAnimator. An OpacityAnimator advances on the render thread on
	// every single frame, so it dirtied the scene graph on the frames in between
	// the animation ticks as well. On a GX device, where the ticks are throttled to
	// 20fps, that alone accounted for a quarter of all frames.
	const qreal fadeSpan = duration > 0 ? qBound(0.0, fadeDuration / duration, 1.0) : 0.0;
	if (fadeSpan <= 0) {
		return normalizedProgress > fadeOutThreshold ? FadedOutOpacity : FadedInOpacity;
	}

	qreal fadedIn = 1.0;
	if (normalizedProgress > fadeOutThreshold) {
		fadedIn = 1.0 - ((normalizedProgress - fadeOutThreshold) / fadeSpan);
	} else if (normalizedProgress < fadeSpan) {
		fadedIn = normalizedProgress / fadeSpan;
	}
	fadedIn = qBound(0.0, fadedIn, 1.0);

	return FadedOutOpacity + (fadedIn * (FadedInOpacity - FadedOutOpacity));
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

	const int count = electrons.count();
	if (count == 0) {
		return;
	}

	// Can't use % operator, that gives remainder rather than a modulo that wraps.
	const auto modulo = [](qreal dividend, qreal divisor)
	{
		return dividend - divisor * qFloor(dividend / divisor);
	};

	const bool startToEnd = animationMode == Enums::WidgetConnector_AnimationMode::WidgetConnector_AnimationMode_StartToEnd;
	const qreal spacing = 1.0 / count;
	const qreal baseProgress = qIsNaN(progress) ? 0.0 : progress;

	for (int i = 0; i < count; i++) {
		QQuickItem *electron = electrons.at(i);

		// Evenly space out the progress of each electron
		const qreal _progress = modulo(baseProgress - (spacing * i), 1.0);

		const PathPoint pp = sampleLut(_progress);

		// Use setPosition() rather than setX() and setY(), so that the item emits a
		// single geometry change instead of two.
		electron->setPosition(QPointF(pp.position.x() - electron->width()/2,
									  pp.position.y() - electron->height()/2));

		// The rotation expects clock-wise angle
		electron->setRotation(startToEnd ? 360.0 - pp.angle : 180 - pp.angle);

		electron->setOpacity(opacityAt(startToEnd ? _progress : (1.0 - _progress)));
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
