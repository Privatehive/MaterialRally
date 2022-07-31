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

#options

find_package(Qt${QT_MAJOR_VERSION} REQUIRED COMPONENTS Qml Quick QuickControls2)

#include(KDEGitCommitHooks)

#include(ECMGenerateExportHeader)

#include(ECMAddTests)
#include(ECMSetupVersion)
#include(ECMQtDeclareLoggingCategory)

set(ENV{QML2_IMPORT_PATH} "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
set(QML_IMPORT_PATH "" CACHE STRING "" FORCE)
add_definitions(-DQML_IMPORT_PATHS="${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
#add_definitions(-DQML_PLUGIN_PATHS="${Kirigami2_INSTALL_PREFIX}/lib/qml/org/kde/kirigami.2,${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")

add_subdirectory(src)
#add_subdirectory(gallery)

ecm_setup_version(
		PROJECT
		VARIABLE_PREFIX KF5QuickCharts
		VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/quickcharts_version.h"
		PACKAGE_VERSION_FILE "${CMAKE_CURRENT_BINARY_DIR}/KF5QuickChartsConfigVersion.cmake"
		SOVERSION 1
)


#SET(QML_IMPORT_PATH "${QML_IMPORT_PATHS}" CACHE STRING "Qt Creator qml modules search paths" FORCE)
feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
