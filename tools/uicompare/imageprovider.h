#ifndef IMAGEPROVIDER_H
#define IMAGEPROVIDER_H

#include <QQuickImageProvider>

class ImageProvider : public QQuickImageProvider
{
public:
    ImageProvider();
//    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);

    void setImageDirectories(QString baselinedirectory, QString currentDirectory);

private:
    QString m_baselineDirectory = "";
    QString m_currentDirectory = "";
};

#endif // IMAGEPROVIDER_H
