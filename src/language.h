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
	Q_PROPERTY(int currentLanguage READ currentLanguage WRITE setCurrentLanguage NOTIFY currentLanguageChanged)
	Q_PROPERTY(int currentIndex READ currentIndex NOTIFY currentIndexChanged)
	Q_PROPERTY(QString currentDisplayText READ currentDisplayText NOTIFY currentDisplayTextChanged)
	Q_PROPERTY(int count READ rowCount CONSTANT)

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

	void addLanguage(const QString &name, const QString &code, const QLocale::Language &language);

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
	Q_PROPERTY(QLocale::Language current READ getCurrentLanguage WRITE setCurrentLanguage NOTIFY currentLanguageChanged FINAL)
	Q_PROPERTY(QUrl fontFileUrl READ fontFileUrl NOTIFY fontFileUrlChanged FINAL)
	Q_PROPERTY(QString fontFamily READ fontFamily NOTIFY fontFamilyChanged FINAL)

public:
	static Language* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);
	Language(const Victron::VenusOS::Language&) = delete;
	Language& operator=(const Victron::VenusOS::Language&) = delete;

	Q_ENUM(QLocale::Language)

	Q_INVOKABLE void retranslate(); // triggers world binding re-evaluation

	Q_INVOKABLE QString toString(QLocale::Language language) const;
	Q_INVOKABLE QString toCode(QLocale::Language language) const;
	Q_INVOKABLE void setCurrentLanguageCode(const QString &code);
	Q_INVOKABLE QLocale::Language fromCode(const QString &code);

	QLocale::Language getCurrentLanguage() const;
	void setCurrentLanguage(QLocale::Language language);

	QUrl fontFileUrl() const;
	QString fontFamily() const;

Q_SIGNALS:
	void currentLanguageChanged();
	void fontFileUrlChanged();
	void fontFamilyChanged();

private:
	explicit Language(QQmlEngine* engine);
	bool installTranslatorForLanguage(QLocale::Language language);

	QUrl m_fontFileUrl;
	QString m_fontFamily;
	QLocale::Language m_currentLanguage = QLocale::AnyLanguage;
	QHash<QLocale::Language, QTranslator*> m_loadedTranslators;
};

} /* VenusOS */

} /* Victron */

#endif // LANGUAGE_H
