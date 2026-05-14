#ifndef IMAGEPROVIDER_H
#define IMAGEPROVIDER_H

#include <QQuickImageProvider>

class ImageProvider : public QQuickImageProvider
{
public:
    ImageProvider();
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);

    void setImageDirectories(const QString &baselineDirectory, const QString &candidateDirectory);

private:
    QString m_baselineDirectory = "";
    QString m_candidateDirectory = "";
};

#endif // IMAGEPROVIDER_H
