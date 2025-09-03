#ifndef BASEAUTOTOGGLESWITCH_H
#define BASEAUTOTOGGLESWITCH_H

#include <QObject>
#include <QQmlEngine>
#include <QtQuickTemplates2/private/qquickcontrol_p.h>

class BaseAutoToggleSwitch : public QQuickControl
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(bool onChecked READ onChecked WRITE setOnChecked NOTIFY onCheckedChanged FINAL)
	Q_PROPERTY(bool autoChecked READ autoChecked WRITE setAutoChecked NOTIFY autoCheckedChanged FINAL)
	Q_PROPERTY(int buttonCount READ buttonCount CONSTANT FINAL)

public:
	BaseAutoToggleSwitch(QQuickItem *parent = nullptr);

	bool onChecked() const;
	void setOnChecked(bool checked);

	bool autoChecked() const;
	void setAutoChecked(bool checked);

	int buttonCount() const;

signals:
	void onCheckedChanged();
	void autoCheckedChanged();

	void onClicked();
	void offClicked();
	void autoClicked();

private:
	bool m_onChecked = false;
	bool m_autoChecked = false;
};

#endif // BASEAUTOTOGGLESWITCH_H
