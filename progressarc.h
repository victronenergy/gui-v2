/*
** Copyright (C) 2022 Victron Energy B.V.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_PROGRESSARC_H
#define VICTRON_VENUSOS_GUI_V2_PROGRESSARC_H

#include <QtQuick/QQuickItem>

#include <QtQuick/QSGNode>
#include <QtQuick/QSGGeometry>
#include <QtQuick/QSGGeometryNode>
#include <QtQuick/QSGMaterialShader>
#include <QtQuick/QSGMaterial>

namespace Victron {
namespace VenusOS {

struct ProgressArcValues
{
	int direction = 1;
	int vertexCount = 24; // 16
	qreal xCenter = 0.0;
	qreal yCenter = 0.0;
	qreal value = 0.0;
	qreal radius = 0.0;
	qreal strokeWidth = 0.0;
	qreal startAngle = 0.0;
	qreal endAngle = 0.0;
	qreal transitionAngle = 0.0;
	QColor progressColor = Qt::transparent;
	QColor remainderColor = Qt::transparent;
	QColor fillColor = Qt::transparent;

	bool dirty = false;
};

class ProgressArc : public QQuickItem
{
	Q_OBJECT
	Q_PROPERTY(bool animationEnabled READ animationEnabled WRITE setAnimationEnabled NOTIFY animationEnabledChanged)
	Q_PROPERTY(int direction READ direction WRITE setDirection NOTIFY directionChanged)
	Q_PROPERTY(int vertexCount READ vertexCount WRITE setVertexCount NOTIFY vertexCountChanged)
	Q_PROPERTY(qreal value READ value WRITE setValue NOTIFY valueChanged)
	Q_PROPERTY(qreal radius READ radius WRITE setRadius NOTIFY radiusChanged)
	Q_PROPERTY(qreal strokeWidth READ strokeWidth WRITE setStrokeWidth NOTIFY strokeWidthChanged)
	Q_PROPERTY(qreal startAngle READ startAngle WRITE setStartAngle NOTIFY startAngleChanged)
	Q_PROPERTY(qreal endAngle READ endAngle WRITE setEndAngle NOTIFY endAngleChanged)
	Q_PROPERTY(qreal transitionAngle READ transitionAngle WRITE setTransitionAngle NOTIFY transitionAngleChanged)
	Q_PROPERTY(QColor progressColor READ progressColor WRITE setProgressColor NOTIFY progressColorChanged)
	Q_PROPERTY(QColor remainderColor READ remainderColor WRITE setRemainderColor NOTIFY remainderColorChanged)
	Q_PROPERTY(QColor fillColor READ fillColor WRITE setFillColor NOTIFY fillColorChanged)

public:
	ProgressArc(QQuickItem *parent = nullptr);
	~ProgressArc() override;

	bool animationEnabled() const;
	void setAnimationEnabled(bool e);

	int direction() const;
	void setDirection(int d);

	int vertexCount() const;
	void setVertexCount(int c);

	qreal value() const;
	void setValue(qreal v);

	qreal radius() const;
	void setRadius(qreal r);

	qreal strokeWidth() const;
	void setStrokeWidth(qreal r);

	qreal startAngle() const;
	void setStartAngle(qreal r);

	qreal endAngle() const;
	void setEndAngle(qreal r);

	qreal transitionAngle() const;
	void setTransitionAngle(qreal r);

	QColor progressColor() const;
	void setProgressColor(const QColor &c);

	QColor remainderColor() const;
	void setRemainderColor(const QColor &c);

	QColor fillColor() const;
	void setFillColor(const QColor &c);

Q_SIGNALS:
	void animationEnabledChanged();
	void directionChanged();
	void vertexCountChanged();
	void valueChanged();
	void radiusChanged();
	void strokeWidthChanged();
	void startAngleChanged();
	void endAngleChanged();
	void transitionAngleChanged();
	void progressColorChanged();
	void remainderColorChanged();
	void fillColorChanged();

protected:
	QSGNode *updatePaintNode(QSGNode *, UpdatePaintNodeData *) override;

private:
	bool m_animationEnabled = true;
	ProgressArcValues m_data;
	struct PaintNodeChanges {
		unsigned int directionChanged       : 1;
		unsigned int vertexCountChanged     : 1;
		unsigned int xCenterChanged         : 1;
		unsigned int yCenterChanged         : 1;
		unsigned int valueChanged           : 1;
		unsigned int radiusChanged          : 1;
		unsigned int strokeWidthChanged     : 1;
		unsigned int startAngleChanged      : 1;
		unsigned int endAngleChanged        : 1;
		unsigned int transitionAngleChanged : 1;
		unsigned int progressColorChanged   : 1;
		unsigned int remainderColorChanged  : 1;
		unsigned int fillColorChanged       : 1;
	} m_paintNodeChanges;
};

class Node : public QSGGeometryNode
{
public:
	Node();

	void setDirection(int i);
	void setVertexCount(int i);
	void setCenter(qreal x, qreal y);
	void setValue(qreal r);
	void setRadius(qreal r);
	void setStrokeWidth(qreal r);
	void setStartAngle(qreal r);
	void setEndAngle(qreal r);
	void setTransitionAngle(qreal r);
	void setProgressColor(const QColor &c);
	void setRemainderColor(const QColor &c);
	void setFillColor(const QColor &c);

private:
	void updateGeometry();
};

class Material : public QSGMaterial
{
public:
	Material();

	QSGMaterialType *type() const override;
	int compare(const QSGMaterial *other) const override;
	QSGMaterialShader *createShader(QSGRendererInterface::RenderMode) const override;

	ProgressArcValues uniforms;
};

class Shader : public QSGMaterialShader
{
public:
	Shader();

	bool updateUniformData(
		RenderState &state,
		QSGMaterial *newMaterial,
		QSGMaterial *oldMaterial) override;
};

} // Victron
} // VenusOS

#endif // VICTRON_VENUSOS_GUI_V2_PROGRESSARC_H
