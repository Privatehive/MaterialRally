#include "materialrallyplugin.h"
#include "settings.h"
#include "wheelhandler.h"
#include "units.h"
#include <QJSEngine>
#include <QQmlEngine>


void MaterialRallyPlugin::registerTypes(const char *uri) {

    Q_ASSERT(QLatin1String(uri) == QLatin1String("MaterialRally"));

    qmlRegisterSingletonType<Settings>(uri, 1, 0, "Settings", [](QQmlEngine *e, QJSEngine *) -> QObject * {
        Settings *settings = Settings::self();
        // singleton managed internally, qml should never delete it
        e->setObjectOwnership(settings, QQmlEngine::CppOwnership);
        return settings;
    });

    qmlRegisterSingletonType<Kirigami::Units>(uri, 1, 0, "Units", [] (QQmlEngine *engine, QJSEngine *) {
        // Fall back to the default units implementation
        return new Kirigami::Units(engine);
    });

    qmlRegisterType<WheelHandler>(uri, 1, 0, "WheelHandler");
    qmlRegisterUncreatableType<KirigamiWheelEvent>(uri, 1, 0, "WheelEvent", QStringLiteral("Cannot create objects of type WheelEvent."));

    qmlProtectModule(uri, 1);
}
