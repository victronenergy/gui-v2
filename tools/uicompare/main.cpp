#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQuickWindow>
#include "applicationsettings.h"
#include "imageprovider.h"

#define APP_INITIAL_X 20
#define APP_INITIAL_Y 20
#define APP_INITIAL_WIDTH 800
#define APP_INITIAL_HEIGHT 600

int main(int argc, char *argv[])
{
    qputenv("QT_QUICK_CONTROLS_STYLE", QByteArray("Basic"));

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    ImageProvider *imageProvider = new ImageProvider;
    ApplicationSettings settings;
    QObject::connect(&engine, &QQmlApplicationEngine::destroyed,
                     &app, []() { QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);

    QQmlComponent component(&engine, "uicompare", "Main");
    if (component.status() != QQmlComponent::Ready) {
        qWarning() << "Main.qml failed to load:";
        for (const QQmlError &error : component.errors()) {
            qWarning() << error.toString();
        }
        return -1;
    }

    imageProvider->setImageDirectories("image-captures-baseline/", "image-captures/");
    engine.addImageProvider(QLatin1String("difference"), imageProvider);

    QScopedPointer<QObject> object(component.beginCreate(engine.rootContext()));
    const auto window = qobject_cast<QQuickWindow *>(object.data());
    window->setX(settings.value(ApplicationSettings::WindowX, APP_INITIAL_X).toInt());
    window->setY(settings.value(ApplicationSettings::WindowY, APP_INITIAL_Y).toInt());
    window->setWidth(settings.value(ApplicationSettings::WindowWidth, APP_INITIAL_WIDTH).toInt());
    window->setHeight(settings.value(ApplicationSettings::WindowHeight, APP_INITIAL_HEIGHT).toInt());

    component.completeCreate();
    window->show();
    QObject::connect(&engine, &QQmlApplicationEngine::quit, &QGuiApplication::quit);

    int ret = app.exec();

    settings.setValue(ApplicationSettings::WindowX, window->x());
    settings.setValue(ApplicationSettings::WindowY, window->y());
    settings.setValue(ApplicationSettings::WindowWidth, window->width());
    settings.setValue(ApplicationSettings::WindowHeight, window->height());

    return ret;

}
