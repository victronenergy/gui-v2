#ifndef KEYNAVIGATIONHIGHLIGHTHELPER_H
#define KEYNAVIGATIONHIGHLIGHTHELPER_H

#include <QQuickItem>
#include <QtQmlIntegration/qqmlintegration.h>
#include "keynavigationhighlight.h"

class KeyNavigationHighlightHelper : public QObject
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(QQuickItem *activeFocusItem READ activeFocusItem WRITE setActiveFocusItem NOTIFY activeFocusItemChanged FINAL)
	Q_PROPERTY(bool active READ active NOTIFY activeChanged FINAL)
	Q_PROPERTY(QQuickItem *fill READ fill NOTIFY fillChanged FINAL)
	Q_PROPERTY(qint32 margins READ margins NOTIFY marginsChanged FINAL)
	Q_PROPERTY(qint32 leftMargin READ leftMargin NOTIFY leftMarginChanged FINAL)
	Q_PROPERTY(qint32 rightMargin READ rightMargin NOTIFY rightMarginChanged FINAL)
	Q_PROPERTY(qint32 topMargin READ topMargin NOTIFY topMarginChanged FINAL)
	Q_PROPERTY(qint32 bottomMargin READ bottomMargin NOTIFY bottomMarginChanged FINAL)
	Q_PROPERTY(qint32 verticalBorders READ verticalBorders WRITE setVerticalBorders NOTIFY verticalBordersChanged FINAL)
	Q_PROPERTY(qint32 horizontalBorders READ horizontalBorders WRITE setHorizontalBorders NOTIFY horizontalBordersChanged FINAL)

public:
	explicit KeyNavigationHighlightHelper(QObject *parent = nullptr);

	QQuickItem *activeFocusItem() const;
	void setActiveFocusItem(QQuickItem *activeFocusItem);

	bool active() const;
	QQuickItem *fill() const;
	qint32 margins() const;
	qint32 leftMargin() const;
	qint32 rightMargin() const;
	qint32 topMargin() const;
	qint32 bottomMargin() const;
	qint32 verticalBorders() const;
	void setVerticalBorders(qint32 verticalBorders);
	qint32 horizontalBorders() const;
	void setHorizontalBorders(qint32 horizontalBorders);

public slots:

signals:
	void activeFocusItemChanged();
	void activeChanged();
	void fillChanged();
	void marginsChanged();
	void leftMarginChanged();
	void rightMarginChanged();
	void topMarginChanged();
	void bottomMarginChanged();
	void verticalBordersChanged();
	void horizontalBordersChanged();

private:
	void updateActive();
	void updateFill();
	void updateMargins();
	void updateLeftMargin();
	void updateRightMargin();
	void updateTopMargin();
	void updateBottomMargin();

	KeyNavigationHighlight * m_attached { nullptr };
	QQuickItem *m_activeFocusItem { nullptr };
	bool m_active { false };
	QQuickItem *m_fill { nullptr };
	qint32 m_margins { 0 };
	qint32 m_leftMargin { 0 };
	qint32 m_rightMargin { 0 };
	qint32 m_topMargin { 0 };
	qint32 m_bottomMargin { 0 };
	qint32 m_verticalBorders { 0 };
	qint32 m_horizontalBorders { 0 };
};

#endif // KEYNAVIGATIONHIGHLIGHTHELPER_H
