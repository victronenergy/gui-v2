#include "applicationsettings.h"

ApplicationSettings::ApplicationSettings(QObject *parent)
    : QSettings("Victron", "uicompare", parent)
{
}

void ApplicationSettings::setValue(const SettingKey &key, const QVariant &value)
{
    auto metaEnum = QMetaEnum::fromType<ApplicationSettings::SettingKey>();
    QSettings::setValue(metaEnum.valueToKey(key), value);
}

QVariant ApplicationSettings::value(const SettingKey &key, const QVariant &defaultValue = QVariant()) const
{
    auto metaEnum = QMetaEnum::fromType<ApplicationSettings::SettingKey>();
    return QSettings::value(metaEnum.valueToKey(key), defaultValue);
}
