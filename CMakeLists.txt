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
)

# Find KDE Frameworks 6
find_package(KF6 REQUIRED COMPONENTS
        Kirigami
        I18n
        CoreAddons
        IconThemes
)

ecm_find_qmlmodule(org.kde.kirigami REQUIRED)

# Fetch glaze for JSON serialization
include(FetchContent)
FetchContent_Declare(
        glaze
        GIT_REPOSITORY https://github.com/stephenberry/glaze.git
        GIT_TAG v5.7.2
)
FetchContent_MakeAvailable(glaze)

# Wrap glaze's compile options to only apply to C++, not Swift
# This prevents -Wno-missing-braces from being passed to swiftc
# There's probably a smarter way
get_target_property(_glaze_aliased glaze::glaze ALIASED_TARGET)
if(_glaze_aliased)
    get_target_property(_glaze_opts ${_glaze_aliased} INTERFACE_COMPILE_OPTIONS)
    if(_glaze_opts)
        set_target_properties(${_glaze_aliased} PROPERTIES
                INTERFACE_COMPILE_OPTIONS "$<$<COMPILE_LANGUAGE:CXX>:${_glaze_opts}>"
        )
    endif()
endif()

# Find Python3
find_package(Python3 COMPONENTS Interpreter REQUIRED)

# Add subdirectories
add_subdirectory(Core)
add_subdirectory(App)
