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

void WidgetConnectorPathUpdater::update() const {

	if (!path) {
		qmlDebug(this) << "Cannot animate electrons without a specified path";
		return;
	}

	for (int i = 0; i < electrons.count(); i++) {
		QQuickItem *electron = electrons.at(i);
		// Can't use % operator, that gives remainder rather than a modulo that wraps.
		auto modulo = [](qreal dividend, qreal divisor)
		{
			return dividend - divisor * qFloor(dividend / divisor);
		};

		// Evenly space out the progress of each electron
		qreal _progress = modulo(progress - ((1.0 / electrons.count()) * i), 1.0);

		qreal angle = 0;
		const QPointF position = path->sequentialPointAt(_progress, &angle);

		electron->setX(position.x() - electron->width()/2);
		electron->setY(position.y() - electron->height()/2);

		const bool startToEnd = animationMode == Enums::WidgetConnector_AnimationMode::WidgetConnector_AnimationMode_StartToEnd;

		// The rotation expects clock-wise angle
		electron->setRotation(startToEnd ? 360.0 - angle : 180 - angle);

		qreal normalizedProgress = startToEnd ? _progress : (1.0 - _progress);

		// Set opacity using setProperty() to make sure the behavior animation plays
		electron->setProperty("opacity", normalizedProgress > fadeOutThreshold ? 0 : 1);
	}
}
