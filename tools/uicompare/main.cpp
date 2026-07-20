/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QCommandLineParser>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQuickWindow>
#include "applicationsettings.h"
#include "imagecomparator.h"
#include "imageprovider.h"

#include <iostream>

#define APP_INITIAL_X 20
#define APP_INITIAL_Y 20
#define APP_INITIAL_WIDTH 800
#define APP_INITIAL_HEIGHT 600

static int runHeadless(QCoreApplication *app, const QString &outputPath, qreal errorTolerance)
{
    QJsonArray results;
    ImageComparator *comparator = ImageComparator::instance();

    int passCount = 0;
    int failCount = 0;
    int missingBaselineCount = 0;
    int missingCandidateCount = 0;

    QObject::connect(comparator, &ImageComparator::comparisonComplete, app,
            [&](const QString &filename, const ImageComparator::ImageResult &result) {
        QString statusText;
        std::string debugText;
        switch (result.status) {
        case ImageComparator::ComparisonReady:
        {
            const bool pass = result.mse <= errorTolerance;
            statusText = pass ? QStringLiteral("passed") : QStringLiteral("failed");
            debugText = pass ? "." : "F";
            if (pass) {
                passCount++;
            } else {
                failCount++;
            }
            break;
        }
        case ImageComparator::NoBaselineImage:
            statusText = QStringLiteral("no_baseline");
            debugText = "(NB)";
            missingBaselineCount++;
            break;
        case ImageComparator::NoCandidateImage:
            statusText = QStringLiteral("no_candidate");
            debugText = "(NC)";
            missingCandidateCount++;
            break;
        default:
            statusText = QString();
            debugText = "?";
            break;
        }

        if (!outputPath.isEmpty()) {
            QJsonObject obj;
            obj[QStringLiteral("file_name")] = filename;
            obj[QStringLiteral("status")] = statusText;
            obj[QStringLiteral("mse")] = result.mse;
            if (!result.errorMessage.isEmpty()) {
                obj[QStringLiteral("error")] = result.errorMessage;
            }
            results.append(obj);
        }
        std::cout << debugText;
        if (results.count() == comparator->fileCount()) {
            std::cout << "\n";
        }
        std::cout.flush();
    });

    QObject::connect(comparator, &ImageComparator::allComparisonsComplete, app, [&]() {
        qDebug() << "\n*** Image comparison summary ***";
        qDebug() << "Total:" << results.count();
        qDebug() << "Passed:" << passCount;
        qDebug() << "Failed:" << failCount;
        qDebug() << "Missing baseline:" << missingBaselineCount;
        qDebug() << "Missing candidate:" << missingCandidateCount;

        if (!outputPath.isEmpty()) {
            QJsonObject jsonRoot;
            jsonRoot["error_tolerance"] = errorTolerance;
            jsonRoot["results"] = results;

            QJsonObject summary;
            summary["total"] = results.count();
            summary["passed"] = passCount;
            summary["failed"] = failCount;
            summary["no_baseline"] = missingBaselineCount;
            summary["no_candidate"] = missingCandidateCount;
            jsonRoot["summary"] = summary;

            QJsonDocument doc(jsonRoot);
            QFile file(outputPath);
            if (file.open(QIODevice::WriteOnly)) {
                file.write(doc.toJson(QJsonDocument::Indented));
                file.close();
                qDebug() << "Results written to" << QFileInfo(file).absoluteFilePath();
            } else {
                qWarning() << "Failed to write results to output file:" << QFileInfo(file).absoluteFilePath();
            }
        }
        qApp->quit();
    });

    ImageComparator::instance()->start();
    return app->exec();
}

static int runGui(QGuiApplication *app, qreal errorTolerance)
{
    QQmlApplicationEngine engine;
    ImageProvider *imageProvider = new ImageProvider;
    ApplicationSettings settings;

    QObject::connect(&engine, &QQmlApplicationEngine::destroyed,
                     app, []() { QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);

    QQmlComponent component(&engine, "uicompare", "Main");
    if (component.status() != QQmlComponent::Ready) {
        qWarning() << "Main.qml failed to load:";
        for (const QQmlError &error : component.errors()) {
            qWarning() << error.toString();
        }
        return -1;
    }

    imageProvider->setImageDirectories("image-captures-baseline/", "image-captures-candidate/");
    engine.addImageProvider(QLatin1String("difference"), imageProvider);

    QScopedPointer<QObject> object(component.beginCreate(engine.rootContext()));
    component.setInitialProperties(object.data(), { { "errorTolerance", errorTolerance } });
    const auto window = qobject_cast<QQuickWindow *>(object.data());
    window->setX(settings.value(ApplicationSettings::WindowX, APP_INITIAL_X).toInt());
    window->setY(settings.value(ApplicationSettings::WindowY, APP_INITIAL_Y).toInt());
    window->setWidth(settings.value(ApplicationSettings::WindowWidth, APP_INITIAL_WIDTH).toInt());
    window->setHeight(settings.value(ApplicationSettings::WindowHeight, APP_INITIAL_HEIGHT).toInt());

    component.completeCreate();
    window->show();
    QObject::connect(&engine, &QQmlApplicationEngine::quit, &QGuiApplication::quit);

    const int ret = app->exec();

    settings.setValue(ApplicationSettings::WindowX, window->x());
    settings.setValue(ApplicationSettings::WindowY, window->y());
    settings.setValue(ApplicationSettings::WindowWidth, window->width());
    settings.setValue(ApplicationSettings::WindowHeight, window->height());

    return ret;
}

static void initApplication(QCoreApplication *app, QCommandLineParser *parser)
{
    parser->addHelpOption();
    parser->addOption({"headless", "Run in headless mode (no UI)"});
    parser->addOption({{"error-tolerance", "e"}, "MSE error tolerance threshold", "value", "10.0"});
    parser->addOption({{"output", "o"}, "Output JSON file path (only in headless mode)", "path", QString()});
    parser->process(*app);
}

int main(int argc, char *argv[])
{
    bool headless = false;
    for (int i = 1; i < argc; ++i) {
        if (qstrcmp(argv[i], "--headless") == 0) {
            headless = true;
            break;
        }
    }

    if (headless) {
        QCoreApplication app(argc, argv);
        QCommandLineParser parser;
        initApplication(&app, &parser);
        return runHeadless(&app, parser.value("output"), parser.value("error-tolerance").toDouble());
    } else {
        qputenv("QT_QUICK_CONTROLS_STYLE", QByteArray("Basic"));
        QGuiApplication app(argc, argv);
        QCommandLineParser parser;
        initApplication(&app, &parser);
        return runGui(&app, parser.value("error-tolerance").toDouble());
    }
}
