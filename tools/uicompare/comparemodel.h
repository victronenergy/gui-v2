#ifndef COMPAREMODEL_H
#define COMPAREMODEL_H

#include <qqmlintegration.h>
#include <QAbstractListModel>
#include <QHash>

#include "imagecomparator.h"

class CompareModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(qreal errorTolerance READ errorTolerance WRITE setErrorTolerance NOTIFY errorToleranceChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)
    Q_PROPERTY(int passCount READ passCount NOTIFY passCountChanged)
    Q_PROPERTY(int failCount READ failCount NOTIFY failCountChanged)
    Q_PROPERTY(int missingBaselineCount READ missingBaselineCount NOTIFY missingBaselineCountChanged)
    Q_PROPERTY(int missingCandidateCount READ missingCandidateCount NOTIFY missingCandidateCountChanged)
    Q_PROPERTY(ImageComparator *comparator READ comparator CONSTANT)
    Q_PROPERTY(int filterMode READ filterMode WRITE setFilterMode NOTIFY filterModeChanged)

public:
    enum Role {
        FileNameRole = Qt::DisplayRole,
        StatusRole,
        PassedRole, // true if mse <= error threshold
        IdenticalRole, // true if passed and round(mse) = 0
        MeanSquaredErrorRole,
        ErrorMessageRole,
    };
    Q_ENUM(Role);

    enum ComparisonResult {
        ComparisonPending = ImageComparator::ComparisonPending,
        ComparisonReady = ImageComparator::ComparisonReady,
        NoBaselineImage = ImageComparator::NoBaselineImage,
        NoCandidateImage = ImageComparator::NoCandidateImage,
    };
    Q_ENUM(ComparisonResult);

    explicit CompareModel(QObject *parent = nullptr);

    int count() const;
    int totalCount() const { return m_allData.count(); }
    int passCount() const { return m_passCount; }
    int failCount() const { return m_failCount; }
    int missingBaselineCount() const { return m_missingBaselineCount; }
    int missingCandidateCount() const { return m_missingCandidateCount; }

    int filterMode() const { return m_filterMode; }
    ImageComparator *comparator() const;

    qreal errorTolerance() const { return m_errorTolerance; }
    void setErrorTolerance(qreal errorTolerance);

    Q_INVOKABLE void load();
    Q_INVOKABLE void setFilterMode(int mode);
    Q_INVOKABLE QVariantMap get(int index) const;

protected:
    // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

Q_SIGNALS:
    void errorToleranceChanged();
    void countChanged();
    void totalCountChanged();
    void passCountChanged();
    void failCountChanged();
    void missingBaselineCountChanged();
    void missingCandidateCountChanged();
    void filterModeChanged();
    void firstResultAvailable();

private:
    void onDiscoveryComplete(const QStringList &filenames);
    void onComparisonComplete(const QString &filename, const ImageComparator::ImageResult &result);
    void applyFilter();
    bool passesFilter(const QString &filename) const;
    bool resultPassed(const ImageComparator::ImageResult &result) const;
    bool resultIsIdentical(const ImageComparator::ImageResult &result) const;

    QHash<QString, ImageComparator::ImageResult> m_results;
    QList<QString> m_allData;
    QList<QString> m_data;
    qreal m_errorTolerance = 0;
    int m_filterMode = 0;  // 0=all, 1=pass, 2=fail, 3=missing baseline, 4=missing candidate
    int m_passCount = 0;
    int m_failCount = 0;
    int m_missingBaselineCount = 0;
    int m_missingCandidateCount = 0;
};

#endif // COMPAREMODEL_H
