/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef LANGUAGE_H
#define LANGUAGE_H

#include <QUrl>
#include <QLocale>
#include <QObject>
#include <QString>
#include <QHash>
#include <QAbstractListModel>
#include <qqmlintegration.h>

class QTranslator;
class QJSEngine;
class QQmlEngine;

namespace Victron {

namespace VenusOS {

class LanguageModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int currentLanguage READ currentLanguage WRITE setCurrentLanguage NOTIFY currentLanguageChanged FINAL)
	Q_PROPERTY(int currentIndex READ currentIndex NOTIFY currentIndexChanged FINAL)
	Q_PROPERTY(QString currentDisplayText READ currentDisplayText NOTIFY currentDisplayTextChanged FINAL)
	Q_PROPERTY(int count READ rowCount CONSTANT FINAL)

public:
	enum Role {
		FontFileUrlRole = Qt::UserRole,
		FontFamilyRole
	};

	explicit LanguageModel(QObject *parent = nullptr);
	~LanguageModel() override;

	int currentLanguage() const;
	void setCurrentLanguage(int language);

	int currentIndex() const;
	QString currentDisplayText() const;

	Q_INVOKABLE int languageAt(int index) const;
	Q_INVOKABLE void setFontFamily(const QUrl &fontUrl, const QString &fontFamily);

	int rowCount(const QModelIndex &parent = QModelIndex()) const override;
	QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

signals:
	void currentLanguageChanged();
	void currentIndexChanged();
	void currentDisplayTextChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	struct LanguageData {
		QString name;
		QString code;
		QUrl fontFileUrl;
		QString fontFamily;
		QLocale::Language language;
	};

	void addLanguage(const QString &name, const QString &code, QLocale::Language language);
	QString languageDisplayName(QLocale::Language language, const QString &name) const;

	QHash<int, QByteArray> m_roleNames;
	QList<LanguageData> m_languages;
	int m_currentIndex = -1;
	QLocale::Language m_currentLanguage = QLocale::AnyLanguage;
};

class Language : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON
	Q_PROPERTY(QLocale::Language current READ getCurrentLanguage NOTIFY currentLanguageChanged FINAL)
	Q_PROPERTY(QString currentLocaleName READ getCurrentLocaleName NOTIFY currentLanguageChanged FINAL)
	Q_PROPERTY(QUrl fontFileUrl READ fontFileUrl NOTIFY fontFileUrlChanged FINAL)
	Q_PROPERTY(QString fontUrlPrefix READ fontUrlPrefix WRITE setFontUrlPrefix NOTIFY fontUrlPrefixChanged FINAL)

public:
	static Language* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);
	Language(const Victron::VenusOS::Language&) = delete;
	Language& operator=(const Victron::VenusOS::Language&) = delete;

	Q_ENUM(QLocale::Language)

	void init();

	Q_INVOKABLE QString toString(QLocale::Language language) const;
	Q_INVOKABLE QString toCode(QLocale::Language language) const;
	Q_INVOKABLE bool setCurrentLanguageCode(const QString &code);
	Q_INVOKABLE QLocale::Language fromCode(const QString &code);

	QLocale::Language getCurrentLanguage() const;
	Q_INVOKABLE bool setCurrentLanguage(QLocale::Language language);

	QString getCurrentLocaleName() const;

	QUrl fontFileUrl() const;
	QString fontUrlPrefix() const;
	void setFontUrlPrefix(const QString &prefix);

Q_SIGNALS:
	void languageChangeFailed();
	void currentLanguageChanged();
	void fontFileUrlChanged();
	void fontUrlPrefixChanged();

private:
	explicit Language(QQmlEngine* engine);
	bool installTranslatorForLanguage(QLocale::Language language);

	QLocale::Language m_currentLanguage = QLocale::AnyLanguage;
	QHash<QLocale::Language, QTranslator*> m_loadedTranslators;
	QUrl m_fontFileUrl;
	QString m_fontUrlPrefix;
};

} /* VenusOS */

} /* Victron */

#endif // LANGUAGE_H
