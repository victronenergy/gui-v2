/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "imagecomparator.h"

#include <QCoreApplication>
#include <QDir>
#include <QImage>
#include <QPointer>
#include <QRunnable>
#include <QThread>

class ImageDiscoveryWorker : public QRunnable
{
public:
    ImageDiscoveryWorker(ImageComparator *comparator)
        : m_comparator(comparator)
    {
        setAutoDelete(true);
    }

    void run() override
    {
        QStringList allFiles;

        // Scan baseline directory
        QDir baselineDir("image-captures-baseline");
        if (baselineDir.exists() && !baselineDir.isEmpty() && baselineDir.isReadable()) {
            allFiles = baselineDir.entryList(QStringList() << "*.*", QDir::Files, QDir::Name);
        } else {
            qDebug() << "Cannot find images in baseline directory:" << baselineDir.absolutePath();
        }

        // Scan candidate directory
        QDir candidateDir("image-captures-candidate");
        if (candidateDir.exists() && !candidateDir.isEmpty() && candidateDir.isReadable()) {
            const QStringList candidateFiles = candidateDir.entryList(QStringList() << "*.*", QDir::Files, QDir::Name);
            if (candidateFiles != allFiles) {
                // Add the candidate files into allFiles and sort the result.
                QSet allFilesSet(allFiles.constBegin(), allFiles.constEnd());
                allFilesSet.unite(QSet(candidateFiles.constBegin(), candidateFiles.constEnd()));
                allFiles = QList<QString>(allFilesSet.constBegin(), allFilesSet.constEnd());
                allFiles.sort();
            }
        } else {
            qDebug() << "Cannot find images in candidate directory:" << candidateDir.absolutePath();
        }

        // Send results back to the comparator's thread
        QPointer<ImageComparator> ptr(m_comparator);
        QMetaObject::invokeMethod(qApp, [ptr, allFiles]() {
            if (ptr) {
                ptr->onDiscoveryComplete(allFiles);
            }
        }, Qt::QueuedConnection);
    }

private:
    QPointer<ImageComparator> m_comparator;
};

class ImageComparisonWorker : public QRunnable
{
public:
    ImageComparisonWorker(ImageComparator *comparator, const QString &fileName)
        : m_comparator(comparator), m_fileName(fileName)
    {
        setAutoDelete(true);
    }

    void run() override
    {
        auto result = compare(m_fileName);

        QPointer<ImageComparator> ptr(m_comparator);
        QMetaObject::invokeMethod(qApp, [ptr, fileName = m_fileName, result]() {
            if (ptr) {
                ptr->onComparisonComplete(fileName, result);
            }
        }, Qt::QueuedConnection);
    }

    int squaredDifference(const QRgb &rgb1, const QRgb &rgb2) const
    {
        const int aDiff = qAlpha(rgb1) - qAlpha(rgb2);
        const int rDiff = qRed(rgb1) - qRed(rgb2);
        const int gDiff = qGreen(rgb1) - qGreen(rgb2);
        const int bDiff = qBlue(rgb1) - qBlue(rgb2);
        return (aDiff * aDiff) + (rDiff * rDiff) + (gDiff * gDiff) + (bDiff * bDiff);
    }

    ImageComparator::ImageResult compare(const QString &fileName) const
    {
        const QString baselinePath = "image-captures-baseline/" + fileName;
        const QString candidatePath = "image-captures-candidate/" + fileName;

        // Load images for comparison
        QImage a(baselinePath);
        QImage b(candidatePath);
        if (a.format() != QImage::Format_ARGB32) {
            a = a.convertToFormat(QImage::Format_ARGB32);
        }
        if (b.format() != QImage::Format_ARGB32) {
            b = b.convertToFormat(QImage::Format_ARGB32);
        }

        ImageComparator::ImageResult result;

        if (a.isNull() || b.isNull() || a.size() != b.size()) {
            if (a.isNull() && !b.isNull()) {
                result.status = ImageComparator::NoBaselineImage;
                result.errorMessage = "Baseline image missing";
            } else if (!a.isNull() && b.isNull()) {
                result.status = ImageComparator::NoCandidateImage;
                result.errorMessage = "Candidate image missing";
            } else if (a.isNull() && b.isNull()) {
                result.status = ImageComparator::ComparisonReady;
                result.errorMessage = "Both images missing";
            } else {
                result.status = ImageComparator::ComparisonReady;
                result.errorMessage = QString("Size mismatch: %1x%2 vs %3x%4")
                                         .arg(a.width()).arg(a.height())
                                         .arg(b.width()).arg(b.height());
            }
            return result;
        }

        const int width = a.width();
        const int height = a.height();
        quint64 totalDiff = 0;

        for (int y = 0; y < height; ++y) {
            const uchar *scanLineA = a.constScanLine(y);
            const uchar *scanLineB = b.constScanLine(y);
            const QRgb *pixelA = reinterpret_cast<const QRgb*>(scanLineA);
            const QRgb *pixelB = reinterpret_cast<const QRgb*>(scanLineB);

            for (int x = 0; x < width; ++x) {
                const QRgb &rgb1 = pixelA[x];
                const QRgb &rgb2 = pixelB[x];
                totalDiff += squaredDifference(rgb1, rgb2);
            }
        }

        // Mean squared error = total difference / (image size * number of channels)
        result.mse = static_cast<double>(totalDiff) / (width * height * 4);
        result.status = ImageComparator::ComparisonReady;
        return result;
    }

private:
    QPointer<ImageComparator> m_comparator;
    QString m_fileName;
};


ImageComparator::ImageComparator(QObject *parent)
    : QObject(parent)
{
    qRegisterMetaType<ImageComparator::ImageResult>("ImageComparator::ImageResult");
}

ImageComparator::~ImageComparator()
{
    // Cancel all pending tasks and wait for active ones to complete
    if (m_threadPool) {
        m_threadPool->clear();  // Remove queued tasks
        m_threadPool->waitForDone(5000);    // Wait up to 5 seconds for active tasks
    }
}

void ImageComparator::start()
{
    if (m_threadPool) {
        qWarning() << "Comparator already started!";
        return;
    }

    m_threadPool = new QThreadPool(this);
    m_threadPool->setMaxThreadCount(qMax(2, QThread::idealThreadCount() / 2));

    qDebug() << "Looking for baseline and candidate images...";
    m_threadPool->start(new ImageDiscoveryWorker(this));
}

void ImageComparator::onDiscoveryComplete(const QStringList &filenames)
{
    qDebug() << "Image discovery complete. Found" << filenames.count() << "images";

    m_fileCount = filenames.count();
    emit discoveryComplete(filenames);

    m_comparisonTimer.start();
    for (const QString &fileName : filenames) {
        ImageComparisonWorker *worker = new ImageComparisonWorker(this, fileName);
        m_threadPool->start(worker);
    }
}

void ImageComparator::onComparisonComplete(const QString &filename, const ImageComparator::ImageResult &result)
{
    m_comparedCount++;
    emit comparisonComplete(filename, result);

    if (m_comparedCount == m_fileCount) {
        qDebug() << "Image comparisons completed in" << m_comparisonTimer.elapsed() << "ms";
        emit allComparisonsComplete();
    }
}

ImageComparator *ImageComparator::instance()
{
    static ImageComparator *comparator = new ImageComparator;
    return comparator;
}
