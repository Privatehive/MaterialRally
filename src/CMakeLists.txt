ecm_add_qml_module(MaterialRallyPlugin URI "MaterialRally" VERSION 1.0 CLASSNAME MaterialRallyPlugin)

ecm_add_qml_module_dependencies(MaterialRallyPlugin DEPENDS
        "QtQuick.Controls 2.15"
        "QtQuick.Controls.Material 2.15"
        "QtGraphicalEffects 1.0")

target_sources(MaterialRallyPlugin PRIVATE
        materialrallyplugin.cpp
        materialrallyplugin.h
        settings.cpp
        settings.h
        wheelhandler.cpp
        wheelhandler.h
        units.cpp
        units.h
)

ecm_target_qml_sources(MaterialRallyPlugin SOURCES
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
        )

ecm_target_qml_sources(MaterialRallyPlugin PRIVATE PATH private SOURCES
        controls/private/RefreshableScrollView.qml
        controls/private/ScrollablePageBase.qml
        controls/private/ScrollViewBase.qml
        )

target_compile_definitions(MaterialRallyPlugin PRIVATE -DKIRIGAMI2_VERSION_STRING="1.0.0")

target_link_libraries(MaterialRallyPlugin
        PUBLIC Qt${QT_MAJOR_VERSION}::Core
        PRIVATE
        Qt${QT_MAJOR_VERSION}::GuiPrivate
        Qt${QT_MAJOR_VERSION}::Qml
        Qt${QT_MAJOR_VERSION}::Quick
        Qt${QT_MAJOR_VERSION}::QuickControls2
        )

if(NOT BUILD_SHARED_LIBS)
    target_compile_definitions(MaterialRallyPlugin PUBLIC QT_STATICPLUGIN)
    target_compile_definitions(MaterialRallyPlugin PUBLIC QT_PLUGIN)
endif()

ecm_finalize_qml_module(MaterialRallyPlugin DESTINATION ${KDE_INSTALL_QMLDIR})
