#ifndef KEYNAVIGATIONHIGHLIGHT_H
#define KEYNAVIGATIONHIGHLIGHT_H

#include <QQuickItem>
#include <QtQmlIntegration/qqmlintegration.h>

/* This class is an attached object "KeyNavigationHighlight" which the GlobalKeyNavigationHighlight
   accesses for the current activeFocusItem. It contains properties that help to customise the appearance
   of the GlobalKeynavigationHighlight.

   Only items which specify a KeyNavigationHighlight attached object will attract the GlobalKeyNavigationHighlight.
   The GlobalKeyNavigationHighlight will not reparent or show itself when it is not required.
   The GlobalKeyNavigationHighlight observes Global.keyNavigationEnabled && !Global.pageManager?.expandLayout.

   Example usage as follows:

   MySpecialItem {
	   id: mySpecialItem

	   // The attachee - "MySpecialItem" will get the GlobalKeyNavigationHighlight when active is true
	   // You can provide additional binding logic to active for more complex active states.
	   // active is false by default - so you must request it to be active
	   KeyNavigationHighlight.active: mySpecialItem.activeFocus

	   // The following attached properties follow the same naming/purpose as anchors:

	   // if you want to provide extra margins for the GlobalKeyNavigationHighlight
	   // margins defaults to 0.
	   KeyNavigationHighlight.margins: -4 // makes it bigger all round by 4

	   // You can also set individual left/right/top/bottomMargin (default 0) which follow the margins value if not explicitly set
	   KeyNavigationHighlight.leftMargin: 10
	   KeyNavigationHighlight.rightMargin: 10
	   KeyNavigationHighlight.topMargin: 5
	   KeyNavigationHighlight.bottomMargin: 5

	   // you may provide an alternative parent to place the GlobalKeyNavigationHighlight on by specifying
	   // an alternative item to fill. Note: this does not have to be a parent or sibling and any margins will be applied
	   // with respect to the fill item. If not specified, the GlobalKeyNavigationHighlight will fill the attachee item.
	   // SpinBox.qml contains one such example.
	   KeyNavigationHighlight.fill: alternativeItem

	   // this is useful when you want to track the activeFocus of one item but need to show the GlobalKeyNavigationHighlight
	   // on a different contextually related item. In this case, alternativeItem never gets activeFocus,
	   // but gets the GlobalKeyNavigationHighlight.

	   ChildItem {
		  id: alternativeItem

		  anchors.centerIn: parent
		  width: parent.width / 2
		  height: parent.height / 2
	   }
	}
*/

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
