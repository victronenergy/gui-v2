#include "imageprovider.h"

ImageProvider::ImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
}

void ImageProvider::setImageDirectories(const QString &baselineDirectory, const QString &candidateDirectory)
{
    if (m_baselineDirectory != baselineDirectory) {
        m_baselineDirectory = baselineDirectory;
    }
    if (m_candidateDirectory != candidateDirectory) {
        m_candidateDirectory = candidateDirectory;
    }
}


QImage ImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    if (id.isEmpty()) {
        return QImage();
    }

    QImage img1(m_baselineDirectory + id);
    QImage img2(m_candidateDirectory + id);

    if (img1.isNull() && img2.isNull()) {
        return QImage();
    }
    if (img1.isNull() && !img2.isNull()) {
        return img2;
    }
    if (!img1.isNull() && img2.isNull()) {
        return img1;
    }
    
    if (img1.size() != img2.size()) {
        // Return an empty image for size mismatches
        if (size) {
            *size = QSize(0, 0);
        }
        return QImage();
    }

    QImage diffImage(img1.width(), img1.height(), QImage::Format_ARGB32);
    if (size) {
        *size = diffImage.size();
    }

    quint64 totalDiff = 0;
    for (int y = 0; y < img1.height(); ++y) {
        for (int x = 0; x < img1.width(); ++x) {
            const QRgb rgb1 = img1.pixel(x, y);
            const QRgb rgb2 = img2.pixel(x, y);
            totalDiff += qAbs(qRed(rgb1) - qRed(rgb2))
                         + qAbs(qGreen(rgb1) - qGreen(rgb2))
                         + qAbs(qBlue(rgb1) - qBlue(rgb2))
                         + qAbs(qAlpha(rgb1) - qAlpha(rgb2));

            if (rgb1 == rgb2) {
                diffImage.setPixel(x, y, rgb1);
            } else {
                // Use full red to emphasize difference. Show green from new image, blue from old image.
                // TODO improve the generated image??
                diffImage.setPixel(x, y, qRgba(255, qGreen(rgb2), qBlue(rgb1), 255));
            }
        }
    }
    
    if (requestedSize.isValid() && !requestedSize.isEmpty()) {
        return diffImage.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    }
    return diffImage;
}
