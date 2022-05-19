#include "progressarc.h"

namespace Victron {
namespace VenusOS {

ProgressArc::ProgressArc(QQuickItem *parent)
	: QQuickItem(parent)
{
	setFlag(ItemHasContents, true);

	// brace initializers for bitfields was only added in C++20,
	// so initialize it here, instead...
	m_paintNodeChanges.directionChanged = 1;
	m_paintNodeChanges.vertexCountChanged = 1;
	m_paintNodeChanges.xCenterChanged = 1;
	m_paintNodeChanges.yCenterChanged = 1;
	m_paintNodeChanges.valueChanged = 1;
	m_paintNodeChanges.radiusChanged = 1;
	m_paintNodeChanges.strokeWidthChanged = 1;
	m_paintNodeChanges.startAngleChanged = 1;
	m_paintNodeChanges.endAngleChanged = 1;
	m_paintNodeChanges.transitionAngleChanged = 1;
	m_paintNodeChanges.progressColorChanged = 1;
	m_paintNodeChanges.remainderColorChanged = 1;
	m_paintNodeChanges.fillColorChanged = 1;

	connect(this, &QQuickItem::widthChanged, [this] {
		m_data.xCenter = width()/2.0;
		m_paintNodeChanges.xCenterChanged = 1;
	});

	connect(this, &QQuickItem::heightChanged, [this] {
		m_data.yCenter = height()/2.0;
		m_paintNodeChanges.yCenterChanged = 1;
	});
}

ProgressArc::~ProgressArc()
{
}

bool ProgressArc::animationEnabled() const
{
	return m_animationEnabled;
}

void ProgressArc::setAnimationEnabled(bool e)
{
	if (m_animationEnabled != e) {
		m_animationEnabled = e;
		emit animationEnabledChanged();
	}
}

int ProgressArc::direction() const
{
	return m_data.direction;
}

void ProgressArc::setDirection(int d)
{
	if (m_data.direction != d) {
		m_data.direction = d;
		m_paintNodeChanges.directionChanged = 1;
		emit directionChanged();
		update();
	}
}

int ProgressArc::vertexCount() const
{
	return m_data.vertexCount;
}

void ProgressArc::setVertexCount(int c)
{
	// must be even, and must be greater than 16.
	c = qMax(c, 16);
	if ((c % 2) != 0) c += 1;
	if (m_data.vertexCount != c) {
		m_data.vertexCount = c;
		m_paintNodeChanges.vertexCountChanged = 1;
		emit vertexCountChanged();
		update();
	}
}

qreal ProgressArc::value() const
{
	return m_data.value;
}

void ProgressArc::setValue(qreal v)
{
	if (m_data.value != v) {
		m_data.value = v;
		m_paintNodeChanges.vertexCountChanged = 1;
		emit valueChanged();
		update();
	}
}

qreal ProgressArc::radius() const
{
	return m_data.radius;
}

void ProgressArc::setRadius(qreal r)
{
	if (m_data.radius != r) {
		m_data.radius = r;
		m_paintNodeChanges.radiusChanged = 1;
		emit radiusChanged();
		update();
	}
}

qreal ProgressArc::strokeWidth() const
{
	return m_data.strokeWidth;
}

void ProgressArc::setStrokeWidth(qreal r)
{
	if (m_data.strokeWidth != r) {
		m_data.strokeWidth = r;
		m_paintNodeChanges.strokeWidthChanged = 1;
		emit strokeWidthChanged();
		update();
	}
}

qreal ProgressArc::startAngle() const
{
	return m_data.startAngle;
}

void ProgressArc::setStartAngle(qreal r)
{
	if (m_data.startAngle != r) {
		m_data.startAngle = r;
		m_paintNodeChanges.startAngleChanged = 1;
		emit startAngleChanged();
		update();
	}
}

qreal ProgressArc::endAngle() const
{
	return m_data.endAngle;
}

void ProgressArc::setEndAngle(qreal r)
{
	if (m_data.endAngle != r) {
		m_data.endAngle = r;
		m_paintNodeChanges.endAngleChanged = 1;
		emit endAngleChanged();
		update();
	}
}

qreal ProgressArc::transitionAngle() const
{
	return m_data.transitionAngle;
}

void ProgressArc::setTransitionAngle(qreal r)
{
	if (m_data.transitionAngle != r) {
		m_data.transitionAngle = r;
		m_paintNodeChanges.transitionAngleChanged = 1;
		emit transitionAngleChanged();
		update();
	}
}

QColor ProgressArc::progressColor() const
{
	return m_data.progressColor;
}

void ProgressArc::setProgressColor(const QColor &c)
{
	if (m_data.progressColor != c) {
		m_data.progressColor = c;
		m_paintNodeChanges.progressColorChanged = 1;
		emit progressColorChanged();
		update();
	}
}

QColor ProgressArc::remainderColor() const
{
	return m_data.remainderColor;
}

void ProgressArc::setRemainderColor(const QColor &c)
{
	if (m_data.remainderColor != c) {
		m_data.remainderColor = c;
		m_paintNodeChanges.remainderColorChanged = 1;
		emit remainderColorChanged();
		update();
	}
}

QColor ProgressArc::fillColor() const
{
	return m_data.fillColor;
}

void ProgressArc::setFillColor(const QColor &c)
{
	if (m_data.fillColor != c) {
		m_data.fillColor = c;
		m_paintNodeChanges.fillColorChanged = 1;
		emit fillColorChanged();
		update();
	}
}

QSGNode* ProgressArc::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *)
{
	// Update or construct the scene graph node.
	Node *node = oldNode ? static_cast<Node*>(oldNode) : new Node;

	if (m_paintNodeChanges.directionChanged) {
		node->setDirection(direction());
		m_paintNodeChanges.directionChanged = 0;
	}

	if (m_paintNodeChanges.vertexCountChanged) {
		node->setVertexCount(vertexCount());
		m_paintNodeChanges.vertexCountChanged = 0;
	}

	if (m_paintNodeChanges.xCenterChanged
			|| m_paintNodeChanges.yCenterChanged) {
		node->setCenter(m_data.xCenter, m_data.yCenter);
		m_paintNodeChanges.xCenterChanged = 0;
		m_paintNodeChanges.yCenterChanged = 0;
	}

	if (m_paintNodeChanges.valueChanged) {
		node->setValue(value());
		m_paintNodeChanges.valueChanged = 0;
	}

	if (m_paintNodeChanges.radiusChanged) {
		node->setRadius(radius());
		m_paintNodeChanges.radiusChanged = 0;
	}

	if (m_paintNodeChanges.strokeWidthChanged) {
		node->setStrokeWidth(strokeWidth());
		m_paintNodeChanges.strokeWidthChanged = 0;
	}

	if (m_paintNodeChanges.startAngleChanged) {
		node->setStartAngle(startAngle());
		m_paintNodeChanges.startAngleChanged = 0;
	}

	if (m_paintNodeChanges.endAngleChanged) {
		node->setEndAngle(endAngle());
		m_paintNodeChanges.endAngleChanged = 0;
	}

	if (m_paintNodeChanges.transitionAngleChanged) {
		node->setTransitionAngle(transitionAngle());
		m_paintNodeChanges.transitionAngleChanged = 0;
	}

	if (m_paintNodeChanges.progressColorChanged) {
		node->setProgressColor(progressColor());
		m_paintNodeChanges.progressColorChanged = 0;
	}

	if (m_paintNodeChanges.remainderColorChanged) {
		node->setRemainderColor(remainderColor());
		m_paintNodeChanges.remainderColorChanged = 0;
	}

	if (m_paintNodeChanges.fillColorChanged) {
		node->setFillColor(fillColor());
		m_paintNodeChanges.fillColorChanged = 0;
	}

	return node;
}

Node::Node()
{
	QSGMaterial *m = new Material;
	setMaterial(m);
	setFlag(OwnsMaterial, true);

	QSGGeometry *g = new QSGGeometry(QSGGeometry::defaultAttributes_TexturedPoint2D(), 24, 72); // 16, 48 ?
	g->setIndexDataPattern(QSGGeometry::StaticPattern);
	g->setDrawingMode(QSGGeometry::DrawTriangles);
	setGeometry(g);
	setFlag(OwnsGeometry, true);
}

void Node::setDirection(int i)
{
	Material *m = static_cast<Material*>(material());
	m->uniforms.direction = i;
	m->uniforms.dirty = true;
	markDirty(DirtyMaterial);
}

void Node::setVertexCount(int i)
{
	Material *m = static_cast<Material*>(material());
	m->uniforms.vertexCount = i;
	m->uniforms.dirty = true;
	markDirty(DirtyMaterial);

	updateGeometry();
}

void Node::setCenter(qreal x, qreal y)
{
	Material *m = static_cast<Material*>(material());
	m->uniforms.xCenter = x;
	m->uniforms.yCenter = y;
	m->uniforms.dirty = true;
	markDirty(DirtyMaterial);

	updateGeometry();
}

void Node::setValue(qreal r)
{
	Material *m = static_cast<Material*>(material());
	m->uniforms.value = r;
	m->uniforms.dirty = true;
	markDirty(DirtyMaterial);
}

void Node::setRadius(qreal r)
{
	Material *m = static_cast<Material*>(material());
	m->uniforms.radius = r;
	m->uniforms.dirty = true;
	markDirty(DirtyMaterial);

	updateGeometry();
}

void Node::setStrokeWidth(qreal r)
{
	Material *m = static_cast<Material*>(material());
	m->uniforms.strokeWidth = r;
	m->uniforms.dirty = true;
	markDirty(DirtyMaterial);

	updateGeometry();
}

void Node::setStartAngle(qreal r)
{
	Material *m = static_cast<Material*>(material());
	m->uniforms.startAngle = r;
	m->uniforms.dirty = true;
	markDirty(DirtyMaterial);
}

void Node::setEndAngle(qreal r)
{
	Material *m = static_cast<Material*>(material());
	m->uniforms.endAngle = r;
	m->uniforms.dirty = true;
	markDirty(DirtyMaterial);
}

void Node::setTransitionAngle(qreal r)
{
	Material *m = static_cast<Material*>(material());
	m->uniforms.transitionAngle = r;
	m->uniforms.dirty = true;
	markDirty(DirtyMaterial);
}

void Node::setProgressColor(const QColor &c)
{
	Material *m = static_cast<Material*>(material());
	m->uniforms.progressColor = c;
	m->uniforms.dirty = true;
	markDirty(DirtyMaterial);
}

void Node::setRemainderColor(const QColor &c)
{
	Material *m = static_cast<Material*>(material());
	m->uniforms.remainderColor = c;
	m->uniforms.dirty = true;
	markDirty(DirtyMaterial);
}

void Node::setFillColor(const QColor &c)
{
	Material *m = static_cast<Material*>(material());
	m->uniforms.fillColor = c;
	m->uniforms.dirty = true;
	markDirty(DirtyMaterial);
}

void Node::updateGeometry()
{
	QSGGeometry *g = geometry();

	// Imagine an arc which makes a full circle, with a given stroke-width.
	// It is defined by an (inner) radius and an outer radius, where outer radius = radius+strokeWidth.
	// Now we want to construct quads (trapezoids) which will enclose the entire arc.
	// These trapezoids are defined by INTERNAL vertices (i.e. points which are on the innerRadius)
	// and EXTERNAL vertices (i.e. points which have the same angle as the internal vertices,
	// but whose radius is LARGER than the outerRadius, such that a line drawn between any two
	// adjacent external vertices will be tangent to the outerRadius circle).
	// We will call this larger radius the extruded radius.
	// We will have as many quads as we have internal vertices.
	// We will have two triangles per quad.
	// Thus, if we have 16 total vertices, we will have 8 internal vertices, and 16 total triangles.
	// So, triangleCount will be identical to vertexCount.

	const Material *m = static_cast<Material*>(material());
	const int triangleCount = m->uniforms.vertexCount;
	const int indexCount = triangleCount * 3; // 3 vertices per triangle.
	const int internalVertexCount = triangleCount/2;
	const double theta = qDegreesToRadians(360.0 / internalVertexCount);
	const qreal radius = m->uniforms.radius;
	const qreal strokeWidth = m->uniforms.strokeWidth;
	const qreal externalRadius = radius + strokeWidth;
	const qreal extrudedRadius = externalRadius/cos(theta/2);
	const qreal xCenter = m->uniforms.xCenter;
	const qreal yCenter = m->uniforms.yCenter;

	// Update the geometry vertex and index buffers.
	g->allocate(triangleCount, indexCount);

	// Fill out the vertex data.
	// Aside from the cartesian coordinates of each vertex, we also pass
	// in "polar normalized coordinates" (i.e. without x/y offset applied).
	// We use these polar normalized coordinates to calculate per-pixel-position
	// in the vertex shader, which allows us to convert back to polar form
	// (angle + radius) per-pixel in the fragment shader.
	// TODO: instead of assuming a start angle of 0, use m->uniforms.startAngle
	// TODO: instead of assuming an end angle of 360, use m->uniforms.endAngle
	QSGGeometry::TexturedPoint2D *points = g->vertexDataAsTexturedPoint2D();
	for (int i = 0; i < internalVertexCount; ++i) {
		// set the internal vertex data.  internal vertices will have even array indices.
		points[i*2].set(xCenter + radius*cos(i*theta), yCenter + radius*sin(i*theta),
				radius*cos(i*theta), radius*sin(i*theta));
		// set the external vertex data.  external vertices will have odd array indices.
		points[(i*2)+1].set(xCenter + extrudedRadius*cos(i*theta), yCenter + extrudedRadius*sin(i*theta),
				extrudedRadius*cos(i*theta), extrudedRadius*sin(i*theta));
	}

	// Fill out the index data (i.e. for each triangle).
	quint16* indices = g->indexDataAsUShort();
	for (int i = 0; i < triangleCount; ++i) {
		const int trianglePointIndex = i*3;
		// modulo to avoid using non-existent vertices,
		// since the last triangle will use either (or both of) vertex 0 or 1.
		indices[trianglePointIndex]   = i % triangleCount;
		indices[trianglePointIndex+1] = (i+1) % triangleCount;
		indices[trianglePointIndex+2] = (i+2) % triangleCount;
	}

	g->markVertexDataDirty();
	g->markIndexDataDirty();

	markDirty(DirtyGeometry);
}

Material::Material()
{
}

QSGMaterialType *Material::type() const
{
	static QSGMaterialType type;
	return &type;
}

int Material::compare(const QSGMaterial *o) const
{
	// TODO: actually compare uniforms / state.
	const auto *other = static_cast<const Material *>(o);
	return other == this ? 0 : 1;
}

QSGMaterialShader *Material::createShader(QSGRendererInterface::RenderMode) const
{
	return new Shader;
}

Shader::Shader()
{
	Shader::setShaderFileName(VertexStage, QLatin1String(":/shaders/progressarc.vert.qsb"));
	Shader::setShaderFileName(FragmentStage, QLatin1String(":/shaders/progressarc.frag.qsb"));
}

namespace {
	void writeColorToUniformData(QByteArray *buf, int offset, const QColor &c)
	{
		float a = c.alphaF();
		float r = a * c.redF();
		float g = a * c.greenF();
		float b = a * c.blueF();
		memcpy(buf->data() + offset,      &r, 4);
		memcpy(buf->data() + offset + 4,  &g, 4);
		memcpy(buf->data() + offset + 8,  &b, 4);
		memcpy(buf->data() + offset + 12, &a, 4);
	}
}

bool Shader::updateUniformData(RenderState &state, QSGMaterial *newMaterial, QSGMaterial *oldMaterial)
{
	bool changed = false;
	QByteArray *buf = state.uniformData();
	Q_ASSERT(buf->size() >= 156);

	if (state.isMatrixDirty()) {
		const QMatrix4x4 m = state.combinedMatrix();
		memcpy(buf->data(), m.constData(), 64);
		changed = true;
	}

	if (state.isOpacityDirty()) {
		const float opacity = state.opacity();
		memcpy(buf->data() + 64, &opacity, 4);
		changed = true;
	}

	// Update all of the uniforms, ensuring the layout matches the shader requirements...
	Material *material = static_cast<Material *>(newMaterial);
	if (oldMaterial != newMaterial || material->uniforms.dirty) {
		memcpy(buf->data() + 68,  &material->uniforms.direction, 4);
		memcpy(buf->data() + 72,  &material->uniforms.vertexCount, 4);
		memcpy(buf->data() + 76,  &material->uniforms.xCenter, 4);
		memcpy(buf->data() + 80,  &material->uniforms.yCenter, 4);
		memcpy(buf->data() + 84,  &material->uniforms.value, 4);
		memcpy(buf->data() + 88,  &material->uniforms.radius, 4);
		memcpy(buf->data() + 92,  &material->uniforms.strokeWidth, 4);
		memcpy(buf->data() + 96,  &material->uniforms.startAngle, 4);
		memcpy(buf->data() + 100, &material->uniforms.endAngle, 4);
		memcpy(buf->data() + 104, &material->uniforms.transitionAngle, 4);
		writeColorToUniformData(buf, 108, material->uniforms.progressColor);
		writeColorToUniformData(buf, 124, material->uniforms.remainderColor);
		writeColorToUniformData(buf, 140, material->uniforms.fillColor);
		material->uniforms.dirty = false;
		changed = true;
	}

	return changed;
}

}
}
