find_package(Qt6 REQUIRED COMPONENTS Gui GuiPrivate Quick Qml QuickControls2)

qt_add_executable(RallyHarness main.cpp)
set_target_properties(RallyHarness PROPERTIES AUTOMOC ON)

# Lets the harness import MaterialRally straight from the build tree.
target_compile_definitions(RallyHarness PRIVATE RALLY_QML_IMPORT_DIR="${CMAKE_BINARY_DIR}/src")

target_link_libraries(RallyHarness
        PRIVATE Qt6::Gui
        PRIVATE Qt6::GuiPrivate
        PRIVATE Qt6::Quick
        PRIVATE Qt6::Qml
        PRIVATE MaterialRally
)

add_dependencies(RallyHarness MaterialRallyplugin)
