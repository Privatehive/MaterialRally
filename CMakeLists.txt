cmake_minimum_required(VERSION 3.16)

project(MaterialRally VERSION "1.0.0")

# Check if we use conan
if(EXISTS "${PROJECT_BINARY_DIR}/conanbuildinfo.cmake")
	include("${PROJECT_BINARY_DIR}/conanbuildinfo.cmake")
	set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
	set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
	set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)
	conan_basic_setup(KEEP_RPATHS)
elseif(EXISTS "${PROJECT_SOURCE_DIR}/conanbuildinfo.cmake")
	include("${PROJECT_SOURCE_DIR}/conanbuildinfo.cmake")
	set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
	set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
	set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)
	conan_basic_setup(KEEP_RPATHS)
endif()

include(FeatureSummary)
find_package(ECM 5.95.0 NO_MODULE)
set_package_properties(ECM PROPERTIES TYPE REQUIRED DESCRIPTION "Extra CMake Modules." URL "https://commits.kde.org/extra-cmake-modules")
feature_summary(WHAT REQUIRED_PACKAGES_NOT_FOUND FATAL_ON_MISSING_REQUIRED_PACKAGES)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/CMake ${ECM_MODULE_PATH})

include(KDEInstallDirs)
if(NOT EMSCRIPTEN)
	include(KDECompilerSettings NO_POLICY_SCOPE)
endif()

set(KDE_SKIP_TEST_SETTINGS TRUE)
include(KDECMakeSettings NO_POLICY_SCOPE)
include(ECMSetupVersion)
include(ECMQmlModule)
include(ECMFindQmlModule)

file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/MaterialRallyConfig.cmake.in"
"@PACKAGE_INIT@

set(QML2_IMPORT_PATH_IN_CONFIG \"@PACKAGE_KDE_INSTALL_QMLDIR@\")

include(CMakeFindDependencyMacro)
find_dependency(Qt@QT_MAJOR_VERSION@Core)

find_dependency(ECM @ECM_VERSION@)
include(\${ECM_MODULE_DIR}/ECMFindQmlModule.cmake)

set(MaterialRally_QML_DIR \"\${QML2_IMPORT_PATH_IN_CONFIG}\")
set(ENV{QML2_IMPORT_PATH} \"\${QML2_IMPORT_PATH_IN_CONFIG}\")
ecm_find_qmlmodule(MaterialRally 1.0)
check_required_components(MaterialRally-QMLModule)"
)

ecm_setup_version(
	PROJECT
    VARIABLE_PREFIX MaterialRally
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/MaterialRally_version.h"
    PACKAGE_VERSION_FILE "${CMAKE_CURRENT_BINARY_DIR}/MaterialRallyConfigVersion.cmake"
    SOVERSION 1
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/MaterialRallyConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/MaterialRallyConfig.cmake"
    INSTALL_DESTINATION  "${KDE_INSTALL_CMAKEPACKAGEDIR}/MaterialRally"
	PATH_VARS KDE_INSTALL_QMLDIR
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/MaterialRallyConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/MaterialRallyConfigVersion.cmake"
    DESTINATION "${KDE_INSTALL_CMAKEPACKAGEDIR}/MaterialRally"
    COMPONENT Devel
)

find_package(Qt${QT_MAJOR_VERSION} REQUIRED COMPONENTS Qml Quick QuickControls2)

add_subdirectory(src)
#add_subdirectory(gallery)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
