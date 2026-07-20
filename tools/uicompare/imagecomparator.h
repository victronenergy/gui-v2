/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef IMAGECOMPARATOR_H
#define IMAGECOMPARATOR_H

#include <qqmlintegration.h>
#include <QObject>
#include <QElapsedTimer>
#include <QThreadPool>

class ImageComparator : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Created in C++")

public:
    enum ComparisonStatus {
        ComparisonPending,
        ComparisonReady,
        NoBaselineImage,
        NoCandidateImage,
    };

    struct ImageResult
    {
        QString errorMessage;
        qreal mse = 0;
        int status = ComparisonPending;
    };

    ~ImageComparator();
    int fileCount() const { return m_fileCount; }

    Q_INVOKABLE void start();

    // internal
    void onDiscoveryComplete(const QStringList &filenames);
    void onComparisonComplete(const QString &filename, const ImageComparator::ImageResult &result);

    static ImageComparator *instance();

Q_SIGNALS:
    void discoveryComplete(const QStringList &filenames);
    void comparisonComplete(const QString &filename, const ImageComparator::ImageResult &result);
    void allComparisonsComplete();

private:
    explicit ImageComparator(QObject *parent = nullptr);

    QElapsedTimer m_comparisonTimer;
    QThreadPool *m_threadPool = nullptr;
    int m_comparedCount = 0;
    int m_fileCount = 0;
};

#endif // IMAGECOMPARATOR_H
