#ifndef APPLICATIONSETTINGS_H
#define APPLICATIONSETTINGS_H

#include <QObject>
#include <QQmlEngine>
#include <QSettings>
#include <QMetaEnum>

class ApplicationSettings : public QSettings
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    enum SettingKey {
        WindowX,
        WindowY,
        WindowWidth,
        WindowHeight,
    };
    Q_ENUM(SettingKey);

    explicit ApplicationSettings(QObject *parent = 0);
    Q_DISABLE_COPY(ApplicationSettings);

    Q_INVOKABLE void setValue(const SettingKey &key, const QVariant &value);
    Q_INVOKABLE QVariant value(const SettingKey &key, const QVariant &defaultValue) const;
};

#endif // APPLICATIONSETTINGS_H
