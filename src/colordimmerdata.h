/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_COLORDIMMERDATA_H
#define VICTRON_GUIV2_COLORDIMMERDATA_H

#include <QAbstractListModel>
#include <QPointer>
#include <QColor>
#include <QQmlParserStatus>
#include <qqmlintegration.h>

#include <veutil/qt/ve_qitem.hpp>

namespace Victron {
namespace VenusOS {

class ColorDimmerData : public QObject, public QQmlParserStatus
{
	Q_OBJECT
	QML_ELEMENT
	Q_INTERFACES(QQmlParserStatus)
	Q_PROPERTY(QString dataUid READ dataUid WRITE setDataUid NOTIFY dataUidChanged REQUIRED FINAL)
	Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged FINAL)
	Q_PROPERTY(qreal white READ white WRITE setWhite NOTIFY whiteChanged FINAL)
	Q_PROPERTY(qreal colorTemperature READ colorTemperature WRITE setColorTemperature NOTIFY colorTemperatureChanged FINAL)

public:
	explicit ColorDimmerData(QObject *parent = nullptr);

	QString dataUid() const;
	void setDataUid(const QString &dataUid);

	QColor color() const;
	void setColor(const QColor &color);

	qreal white() const;
	void setWhite(qreal white);

	qreal colorTemperature() const;
	void setColorTemperature(qreal colorTemperature);

	void classBegin() override;
	void componentComplete() override;

	Q_INVOKABLE void loadFromPreset(const QVariantMap &values);
	Q_INVOKABLE void save();

Q_SIGNALS:
	void dataUidChanged();
	void colorChanged();
	void whiteChanged();
	void colorTemperatureChanged();

private Q_SLOTS:
	void colorDataChanged(QVariant var);

private:
	void reload();

	QPointer<VeQItem> m_colorDataItem;
	QColor m_color;
	qreal m_white = 0;
	qreal m_colorTemperature = 1.0;
	bool m_completed = false;
};

/*
	A model of color presets.

	Set the settingUid property to add color data from the JSON array at that path.
*/
class ColorPresetModel : public QAbstractListModel, public QQmlParserStatus
{
	Q_OBJECT
	QML_ELEMENT
	Q_INTERFACES(QQmlParserStatus)
	Q_PROPERTY(int count READ count NOTIFY countChanged)
	Q_PROPERTY(QString settingUid READ settingUid WRITE setSettingUid NOTIFY settingUidChanged REQUIRED FINAL)

public:
	enum Role {
		ColorRole = Qt::UserRole
	};
	Q_ENUM(Role)

	explicit ColorPresetModel(QObject *parent = nullptr);

	QString settingUid() const;
	void setSettingUid(const QString &settingUid);

	int count() const;

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	void classBegin() override;
	void componentComplete() override;

	Q_INVOKABLE QVariantMap get(int index) const;

	// Note: the model is saved to the settingUid when changes are made.
	Q_INVOKABLE void setPreset(int index, const QColor &color, qreal white, qreal colorTemperature);
	Q_INVOKABLE void clearPreset(int index);

Q_SIGNALS:
	void countChanged();
	void settingUidChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	struct ColorInfo {
		QColor color;
		qreal white = 0;
		qreal colorTemperature = 0;
	};
	void save();
	void reload();

	QList<ColorInfo> m_colors;
	QPointer<VeQItem> m_settingItem;
	bool m_completed = false;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_COLORDIMMERDATA_H
