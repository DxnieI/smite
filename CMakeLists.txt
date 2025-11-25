cmake_minimum_required(VERSION 3.29)
project(smite LANGUAGES CXX Swift)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add ECM and Swift CMake modules
find_package(ECM 6.0.0 REQUIRED NO_MODULE)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules" ${ECM_MODULE_PATH})
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMFindQmlModule)
include(ECMQmlModule)
include(InitializeSwift)
include(AddSwift)

# Find Qt6 packages
find_package(Qt6 REQUIRED COMPONENTS
        Core
        Quick
        Gui
        QuickControls2
        Widgets
        WebEngineQuick
)

# Find KDE Frameworks 6
find_package(KF6 REQUIRED COMPONENTS
        Kirigami
        I18n
        CoreAddons
        IconThemes
)

ecm_find_qmlmodule(org.kde.kirigami REQUIRED)

# Find Python3
find_package(Python3 COMPONENTS Interpreter REQUIRED)

# Add subdirectories
add_subdirectory(Core)
add_subdirectory(App)
