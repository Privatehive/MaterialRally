include(GenerateExportHeader)
include(MaterialIcons)
include_directories(${CMAKE_CURRENT_BINARY_DIR})

set(FEATURE_GALLERY_APP OFF CACHE BOOL "Build the gallery app")

find_package(Qt6 REQUIRED COMPONENTS Gui Quick Qml QuickControls2)

# Download Roboto Condensed fonts
if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/fonts/RobotoCondensed.ttf)
    file(DOWNLOAD "https://raw.githubusercontent.com/google/fonts/main/ofl/robotocondensed/RobotoCondensed%5Bwght%5D.ttf" ${CMAKE_CURRENT_SOURCE_DIR}/fonts/RobotoCondensed.ttf)
endif ()

if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/fonts/RobotoMono.ttf)
    file(DOWNLOAD "https://raw.githubusercontent.com/google/fonts/main/apache/robotomono/RobotoMono%5Bwght%5D.ttf" ${CMAKE_CURRENT_SOURCE_DIR}/fonts/RobotoMono.ttf)
endif ()

set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

set_source_files_properties(MaterialRally/Helper.qml PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(MaterialRally
        URI MaterialRally
        CLASS_NAME materialrallyplugin

        NO_PLUGIN_OPTIONAL

        IMPORTS
        QtQuick
        Qt5Compat.GraphicalEffects

        SOURCES
        rootitemattachedtype.h
        rootitemattachedtype.cpp
        settings.h
        settings.cpp
        wheelhandler.h
        wheelhandler.cpp
        units.h
        units.cpp

        QML_FILES
        MaterialRally/ListView.qml
        MaterialRally/ItemDelegate.qml
        MaterialRally/ScrollView.qml
        MaterialRally/PasswordTextField.qml
        MaterialRally/Divider.qml
        MaterialRally/FormLayout.qml
        MaterialRally/RallyRootPage.qml
        MaterialRally/RallyApplicationWindow.qml
        MaterialRally/BusyAction.qml
        MaterialRally/Button.qml
        MaterialRally/ComboBox.qml
        MaterialRally/GridLayout.qml
        MaterialRally/GroupBox.qml
        MaterialRally/Icon.qml
        MaterialRally/IconLabel.qml
        MaterialRally/InfoDialog.qml
        MaterialRally/InlineMessage.qml
        MaterialRally/Dialog.qml
        MaterialRally/ScrollablePage.qml
        MaterialRally/TabBarFolding.qml
        MaterialRally/TabButtonFolding.qml
        MaterialRally/TextArea.qml
        MaterialRally/TextField.qml
        MaterialRally/ToolBar.qml
        MaterialRally/ToolButton.qml
        MaterialRally/helper.js # Don't export (done by renaming to upper case) - Qt bug in importing Project??? qqmlinport.cpp - setQmldirContent() - is ambiguous error
        MaterialRally/Helper.qml
        MaterialRally/private/RefreshableScrollView.qml
        MaterialRally/private/ScrollablePageBase.qml
        MaterialRally/private/ScrollViewBase.qml

        RESOURCES
        fonts/RobotoMono.ttf
        fonts/RobotoCondensed.ttf
)

set(QML_DIRS "")
list(APPEND QML_DIRS "${CMAKE_CURRENT_BINARY_DIR}")
set(QML_IMPORT_PATH "${QML_DIRS}" CACHE STRING "Qt Creator extra qml import paths")

target_sources(MaterialRallyplugin PRIVATE materialrallyplugin.h materialrallyplugin.cpp)
#target_link_libraries(MaterialRallyplugin PRIVATE Qt6::Gui PRIVATE Qt6::Quick)

add_material_icon_theme_resource(MaterialRally THEME_NAME material_private ICONS
        information-outline
        alert-outline
        playlist-remove
        arrow-left
        eye
        eye-off
        chevron-right
)

qt_add_resources(MaterialRally QtQuickControls2 FILES qtquickcontrols2.conf)

generate_export_header(MaterialRally EXPORT_FILE_NAME MaterialRallyExport.h)
target_mark_public_header(MaterialRally
        settings.h
        units.h
        ${CMAKE_CURRENT_BINARY_DIR}/MaterialRallyExport.h
)
target_link_libraries(MaterialRally PUBLIC Qt6::Gui PUBLIC Qt6::Quick PUBLIC Qt6::Qml PUBLIC Qt6::QuickControls2 PRIVATE Qt6::GuiPrivate)
target_include_directories(MaterialRally PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:include>)
target_include_directories(MaterialRally PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}> $<INSTALL_INTERFACE:include>)
target_compile_definitions(MaterialRally PRIVATE KIRIGAMI2_VERSION_STRING="1.0.0")

# Gallery
if (FEATURE_GALLERY_APP)
    find_package(QtAppBase REQUIRED)

    qt_add_executable(RallyGallery main.cpp)

    qt_add_qml_module(RallyGallery
            URI Gallery

            QML_FILES
            Gallery/main.qml
            Gallery/ButtonsGallery.qml
            Gallery/ListsGallery.qml
            Gallery/TestDialog.qml
    )

    target_link_libraries(RallyGallery
            PRIVATE Qt6::Core
            PRIVATE Qt6::Gui
            PRIVATE Qt6::Network
            PRIVATE Qt6::Qml
            PRIVATE Qt6::Quick
            PRIVATE Qt6::QuickTemplates2
            PRIVATE Qt6::QuickControls2
            PRIVATE QtAppBase
            PRIVATE MaterialRally
    )

    add_dependencies(RallyGallery MaterialRallyplugin)

    add_material_icon_theme_resource(MaterialRally THEME_NAME material ICONS
            button-cursor
            list-box
    )
endif ()

install_qml_module(MaterialRally)
