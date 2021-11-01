#ifndef LANGUAGE_H
#define LANGUAGE_H

#include <QqmlEngine>
#include <QObject>
#include <QString>

namespace Victron {

namespace VenusOS {

class Language : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString current READ getCurrentLanguage WRITE setCurrentLanguage NOTIFY currentLanguageChanged FINAL)
public:
	explicit Language(QQmlEngine *engine, QObject *parent = nullptr);

	QString getCurrentLanguage() const;
	void setCurrentLanguage(const QString &language);

signals:

	void currentLanguageChanged();

private:
	QQmlEngine *m_engine = nullptr;
	QString m_currentLanguage;
};

} /* VenusOS */

} /* Victron */

#endif // LANGUAGE_H
