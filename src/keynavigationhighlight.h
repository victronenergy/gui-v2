#ifndef KEYNAVIGATIONHIGHLIGHT_H
#define KEYNAVIGATIONHIGHLIGHT_H

#include <QQuickItem>
#include <QtQmlIntegration/qqmlintegration.h>

class KeyNavigationHighlight : public QObject
{
	Q_OBJECT
	QML_ELEMENT

	QML_ATTACHED(KeyNavigationHighlight)
	QML_UNCREATABLE("KeyNavigationHighlight is an attached object and is not creatable")

	Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged FINAL)
	Q_PROPERTY(QQuickItem* fill READ fill WRITE setFill NOTIFY fillChanged FINAL)
	Q_PROPERTY(int leftMargin READ leftMargin WRITE setLeftMargin RESET resetLeftMargin NOTIFY leftMarginChanged FINAL)
	Q_PROPERTY(int rightMargin READ rightMargin WRITE setRightMargin RESET resetRightMargin NOTIFY rightMarginChanged FINAL)
	Q_PROPERTY(int topMargin READ topMargin WRITE setTopMargin RESET resetTopMargin NOTIFY topMarginChanged FINAL)
	Q_PROPERTY(int bottomMargin READ bottomMargin WRITE setBottomMargin RESET resetBottomMargin NOTIFY bottomMarginChanged FINAL)
	Q_PROPERTY(int margins READ margins WRITE setMargins NOTIFY marginsChanged FINAL)

public:
	explicit KeyNavigationHighlight(QObject *parent = nullptr);

	static KeyNavigationHighlight *qmlAttachedProperties(QObject *object);

	bool active() const;
	void setActive(bool active);

	QQuickItem *fill() const;
	void setFill(QQuickItem *fill);

	int leftMargin() const;
	void setLeftMargin(int leftMargin);
	void resetLeftMargin();

	int rightMargin() const;
	void setRightMargin(int rightMargin);
	void resetRightMargin();

	int topMargin() const;
	void setTopMargin(int topMargin);
	void resetTopMargin();

	int bottomMargin() const;
	void setBottomMargin(int bottomMargin);
	void resetBottomMargin();

	int margins() const;
	void setMargins(int margins);

public slots:

signals:
	void activeChanged();
	void fillChanged();
	void leftMarginChanged();
	void rightMarginChanged();
	void topMarginChanged();
	void bottomMarginChanged();
	void marginsChanged();    

private:
	bool m_active { false };
	QQuickItem *m_fill { nullptr };
	int m_leftMargin { 0 };
	int m_rightMargin { 0 };
	int m_topMargin { 0 };
	int m_bottomMargin { 0 };
	int m_margins { 0 };

	bool m_hasLeftMargin { false };
	bool m_hasRightMargin { false };
	bool m_hasTopMargin { false };
	bool m_hasBottomMargin { false };
};

#endif // KEYNAVIGATIONHIGHLIGHT_H
