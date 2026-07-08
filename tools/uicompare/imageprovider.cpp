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

    // Source image formats should be ARGB32, but check just in case.
    if (img1.format() != QImage::Format_ARGB32) {
        img1 = img1.convertToFormat(QImage::Format_ARGB32);
    }
    if (img2.format() != QImage::Format_ARGB32) {
        img2 = img2.convertToFormat(QImage::Format_ARGB32);
    }

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

    const int width = img1.width();
    const int height = img1.height();
    QImage diffImage(width, height, QImage::Format_ARGB32);
    if (size) {
        *size = diffImage.size();
    }

    uchar* diffImageData = diffImage.bits();
    int diffBytesPerLine = diffImage.bytesPerLine();

    for (int y = 0; y < height; ++y) {
        const uchar *scanLineA = img1.constScanLine(y);
        const uchar *scanLineB = img2.constScanLine(y);
        const QRgb *pixelA = reinterpret_cast<const QRgb*>(scanLineA);
        const QRgb *pixelB = reinterpret_cast<const QRgb*>(scanLineB);
        QRgb* diffRowData = reinterpret_cast<QRgb*>(diffImageData + y * diffBytesPerLine);

        for (int x = 0; x < width; ++x) {
            const QRgb &rgb1 = pixelA[x];
            const QRgb &rgb2 = pixelB[x];
            QRgb &pixelValue = diffRowData[x];

            if (rgb1 == rgb2) {
                // Pixel is same in both images, so copy it into the diff image.
                pixelValue = rgb1;
            } else {
                // Use full red to emphasize difference. Show green from new image, blue from old image.
                // TODO improve the generated image??
                pixelValue = qRgba(255, qGreen(rgb2), qBlue(rgb1), 255);
            }
        }
    }

    if (requestedSize.isValid() && !requestedSize.isEmpty()) {
        const QImage scaledDiffImage = diffImage.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
        if (size) {
            *size = scaledDiffImage.size();
        }
        return scaledDiffImage;
    }
    return diffImage;
}
