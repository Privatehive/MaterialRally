include(GenerateExportHeader)
include(MaterialIcons)
include_directories(${CMAKE_CURRENT_BINARY_DIR})

find_package(Qt6 REQUIRED COMPONENTS Quick Gui Qml QuickControls2)

# Download Roboto Condensed fonts
file(DOWNLOAD https://fonts.google.com/download?family=Roboto%20Condensed ${CMAKE_CURRENT_SOURCE_DIR}/fonts/roboto_condensed.zip)
execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf roboto_condensed.zip WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/fonts)

qt_add_qml_module(MaterialRally
        URI MaterialRally
        VERSION 1.0
        OUTPUT_DIRECTORY MaterialRally
				NO_GENERATE_PLUGIN_SOURCE
				NO_PLUGIN_OPTIONAL
				#PLUGIN_TARGET MaterialRally

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
        controls/RallyRootPage.qml
        controls/RallyApplicationWindow.qml
        controls/BusyAction.qml
        controls/Button.qml
        controls/ComboBox.qml
        controls/GridLayout.qml
        controls/GroupBox.qml
        controls/Icon.qml
        controls/IconLabel.qml
        controls/InfoDialog.qml
        controls/InlineMessage.qml
        controls/Popup.qml
        controls/ScrollablePage.qml
        controls/TabBarFolding.qml
        controls/TabButtonFolding.qml
        controls/TextArea.qml
        controls/TextField.qml
        controls/ToolBar.qml
        controls/ToolButton.qml
        controls/helper.js
        controls/private/RefreshableScrollView.qml
        controls/private/ScrollablePageBase.qml
        controls/private/ScrollViewBase.qml

				RESOURCES
				fonts/RobotoCondensed-Bold.ttf
				fonts/RobotoCondensed-BoldItalic.ttf
				fonts/RobotoCondensed-Italic.ttf
				fonts/RobotoCondensed-Light.ttf
				fonts/RobotoCondensed-LightItalic.ttf
				fonts/RobotoCondensed-Regular.ttf
        )

set(QML_DIRS "")
list(APPEND QML_DIRS "${CMAKE_CURRENT_BINARY_DIR}")
set(QML_IMPORT_PATH "${QML_DIRS}" CACHE STRING "Qt Creator extra qml import paths")

target_sources(MaterialRallyplugin PUBLIC materialrallyplugin.cpp)
target_link_libraries(MaterialRallyplugin PRIVATE Qt6::Quick PRIVATE Qt6::Gui)

add_material_icon_theme_resource(MaterialRally THEME_NAME material_private ICONS
																 information-outline
																 alert-outline
																 playlist-remove
																 arrow-left
																 )

qt_add_resources(MaterialRally QtQuickControls2 FILES qtquickcontrols2.conf)

generate_export_header(MaterialRally EXPORT_FILE_NAME MaterialRallyExport.h)
set_target_properties(MaterialRally PROPERTIES PUBLIC_HEADER "${CMAKE_CURRENT_BINARY_DIR}/MaterialRallyExport.h")
target_link_libraries(MaterialRally PRIVATE Qt6::Quick PRIVATE Qt6::QuickControls2 PRIVATE Qt6::Gui PRIVATE Qt6::GuiPrivate)
target_include_directories(MaterialRally PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:include>)
target_include_directories(MaterialRally PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}> $<INSTALL_INTERFACE:include>)
target_compile_definitions(MaterialRally PRIVATE KIRIGAMI2_VERSION_STRING="1.0.0")

install_qml_module(MaterialRally)

add_subdirectory(gallery)
