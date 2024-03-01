/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_WIDGETCONNECTORPATHUPDATER_H
#define VICTRON_VENUSOS_GUI_V2_WIDGETCONNECTORPATHUPDATER_H

#include <QQuickItem>

#include "enums.h"

#include <QtQuick/private/qquickpath_p.h>

namespace Victron {
namespace VenusOS {

class WidgetConnectorPathUpdater : public QObject
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(qreal progress MEMBER progress NOTIFY progressChanged)
	Q_PROPERTY(QQuickPath *path MEMBER path)
	Q_PROPERTY(qreal fadeOutThreshold MEMBER fadeOutThreshold)
	Q_PROPERTY(Victron::VenusOS::Enums::WidgetConnector_AnimationMode animationMode MEMBER animationMode)

public:
	explicit WidgetConnectorPathUpdater(QObject *parent = nullptr);
	~WidgetConnectorPathUpdater() override;

	Q_INVOKABLE void add(QQuickItem *electron);
	Q_INVOKABLE void remove(QQuickItem *electron);

protected slots:
	Q_INVOKABLE void update() const;

signals:
	void progressChanged();
private:
	qreal progress;
	QPointer<QQuickPath> path;
	qreal fadeOutThreshold;
	Victron::VenusOS::Enums::WidgetConnector_AnimationMode animationMode;
	QList<QPointer<QQuickItem>>electrons;
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_WIDGETCONNECTORPATHUPDATER_H
