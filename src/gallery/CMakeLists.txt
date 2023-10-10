find_package(Qt6 REQUIRED COMPONENTS Core Gui Network Qml Quick QuickTemplates2 QuickControls2 Svg)
find_package(QtAppBase)

qt_add_executable(Gallery main.cpp fileloader.h fileloader.cpp)

qt_add_qml_module(Gallery
									URI Application
									VERSION 1.0

									QML_FILES
									main.qml
									ButtonsGallery.qml
									ListsGallery.qml
									)

target_link_libraries(Gallery
											PRIVATE Qt6::Core
											PRIVATE Qt6::Gui
											PRIVATE Qt6::Network
											PRIVATE Qt6::Qml
											PRIVATE Qt6::Quick
											PRIVATE Qt6::QuickTemplates2
											PRIVATE Qt6::QuickControls2
											PRIVATE Qt6::Svg
											PRIVATE QtAppBase
											PRIVATE MaterialRally
											)

add_dependencies(Gallery MaterialRallyplugin)

add_material_icon_theme_resource(MaterialRally THEME_NAME material ICONS
																 button-cursor
																 list-box
																 )

target_compile_definitions(Gallery PRIVATE QML_IMPORT_PATH="${CMAKE_BINARY_DIR}/src")
