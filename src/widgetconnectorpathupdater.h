/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_WIDGETCONNECTORPATHUPDATER_H
#define VICTRON_VENUSOS_GUI_V2_WIDGETCONNECTORPATHUPDATER_H

#include <QQuickItem>
#include <QVector>

#include "enums.h"

#include <QtQuick/private/qquickpath_p.h>

namespace Victron {
namespace VenusOS {

class WidgetConnectorPathUpdater : public QObject
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(qreal progress MEMBER progress NOTIFY progressChanged FINAL)
	Q_PROPERTY(QQuickPath *path READ getPath WRITE setPath NOTIFY pathChanged FINAL)
	Q_PROPERTY(qreal fadeOutThreshold MEMBER fadeOutThreshold FINAL)
	Q_PROPERTY(Victron::VenusOS::Enums::WidgetConnector_AnimationMode animationMode MEMBER animationMode FINAL)

public:
	explicit WidgetConnectorPathUpdater(QObject *parent = nullptr);
	~WidgetConnectorPathUpdater() override;

	QQuickPath *getPath() const;
	void setPath(QQuickPath *newPath);

	Q_INVOKABLE void add(QQuickItem *electron);
	Q_INVOKABLE void remove(QQuickItem *electron);

	Q_INVOKABLE void update();
	Q_INVOKABLE qreal angleForArrow(qreal progress, bool startToEnd);
	Q_INVOKABLE void invalidateLut();

signals:
	void progressChanged();
	void pathChanged();

private:
	struct PathPoint {
		QPointF position;
		qreal angle = 0;
	};

	static constexpr int LUT_SIZE = 512;

	void rebuildLut();
	PathPoint sampleLut(qreal progress) const;

	qreal progress = 0;
	QPointer<QQuickPath> path;
	qreal fadeOutThreshold = 1.0;
	Victron::VenusOS::Enums::WidgetConnector_AnimationMode animationMode =
		Victron::VenusOS::Enums::WidgetConnector_AnimationMode_NotAnimated;
	QList<QPointer<QQuickItem>> electrons;

	QVector<PathPoint> m_lut;
	bool m_lutValid = false;
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_WIDGETCONNECTORPATHUPDATER_H
