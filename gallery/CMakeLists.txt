file(DOWNLOAD https://fonts.google.com/download?family=Roboto%20Condensed "${CMAKE_CURRENT_BINARY_DIR}/RobotoCondensed.zip")
file(DOWNLOAD https://fonts.google.com/download?family=Roboto%20Mono "${CMAKE_CURRENT_BINARY_DIR}/RobotoMono.zip")
execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf RobotoCondensed.zip WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf RobotoMono.zip WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/fonts.qrc" "
<RCC>
    <qresource prefix=\"/fonts\">
        <file alias=\"RobotoCondensed-Regular.ttf\">RobotoCondensed-Regular.ttf</file>
        <file alias=\"RobotoCondensed-Light.ttf\">RobotoCondensed-Light.ttf</file>
        <file alias=\"RobotoCondensed-Bold.ttf\">RobotoCondensed-Bold.ttf</file>
        <file alias=\"RobotoMono-Regular.ttf\">static/RobotoMono-Regular.ttf</file>
    </qresource>
</RCC>")

#if(ANDROID)
#	find_package(Qt5 REQUIRED COMPONENTS AndroidExtras)
#endif()
add_definitions("-DQT_STATICPLUGIN")
find_package(Qt5 REQUIRED COMPONENTS Core Widgets Svg Quick QuickControls2 QuickTemplates2 OPTIONAL_COMPONENTS QuickCompiler)

if(NOT ${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
    find_package(Qt5 QUIET COMPONENTS QmlWorkerScript)
endif()

#find_path(Qt5_plugin_DIR NAMES platforms/qminimald.dll platforms/libqminimald.so platforms/qminimal.dll platforms/libqminimal.so PATH_SUFFIXES "plugins")
#find_path(Qt5_qml_DIR NAMES QtQml/qmldir PATH_SUFFIXES "lib" "lib/qml" "qml")

#find_package(KF5Kirigami2 REQUIRED COMPONENTS Kirigami2)
#find_path(KF5_qml_DIR NAMES org/kde/kirigami.2/qmldir PATH_SUFFIXES "lib" "lib/qml" "qml")

include(ECMFindQmlModule)
ecm_find_qmlmodule(org.kde.kirigami 2.0)
ecm_find_qmlmodule(MaterialRally 1.0)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

qt_add_resources(RESOURCES resources.qrc "${CMAKE_CURRENT_BINARY_DIR}/fonts.qrc")

add_executable(MaterialRallyGallery ${RESOURCES} main.cpp fileloader.cpp fileloader.h)
target_link_libraries(MaterialRallyGallery PRIVATE Qt5::Core Qt5::Widgets Qt5::Gui Qt5::Qml Qt5::Quick Qt5::QuickControls2 MaterialRallyPlugin)
add_dependencies(MaterialRallyGallery MaterialRallyPlugin)

get_target_property(QT_TARGET_TYPE Qt5::Core TYPE)
if(${QT_TARGET_TYPE} STREQUAL "STATIC_LIBRARY")
    include(QtStaticCMake)

    qt_generate_plugin_import(MaterialRallyGallery VERBOSE)

    # EXTRA_PLUGIN are the one required by plugin loaded by qt_generate_plugin_import
    # It's not automatic yet :( All this workflow might change in future version of qt
    # with better and better cmake support
    qt_generate_qml_plugin_import(MaterialRallyGallery
            QML_SRC ${CMAKE_CURRENT_SOURCE_DIR}
            QML_DIR "${QML_IMPORT_PATH}"
            VERBOSE
            )

    target_compile_definitions(MaterialRallyGallery PUBLIC -DKIRIGAMI_BUILD_TYPE_STATIC)
endif()

if(TARGET Qt5::QmlWorkerScript AND NOT ${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
    target_link_libraries(MaterialRallyGallery PRIVATE Qt5::QmlWorkerScript)
endif()

if(${CMAKE_SYSTEM_NAME} STREQUAL "iOS")
    include(FetchQtIosCMake)
    add_qt_ios_app(MaterialRallyGallery VERBOSE)
endif()

if(${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
    include(QtWasmCMake)
    add_qt_wasm_app(MaterialRallyGallery)
endif()

install(TARGETS MaterialRallyGallery ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})
