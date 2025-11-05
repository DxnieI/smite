cmake_minimum_required(VERSION 3.29)
project(app LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Qt setup
set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_SCAN_FOR_MODULES OFF)

add_executable(app)

ecm_add_qml_module(app
        URI xyz.dxniel.smite
)

target_sources(app
        PRIVATE
        main.cxx
)

ecm_target_qml_sources(app
        SOURCES
        Main.qml
)

target_link_libraries(app
        PUBLIC
        core
        Qt6::Quick
        Qt6::Qml
        Qt6::Gui
        Qt6::QuickControls2
        Qt6::Widgets
        KF6::Kirigami
        KF6::I18n
        KF6::CoreAddons
        KF6::IconThemes
)

# Set output name
set_target_properties(app PROPERTIES WIN32_EXECUTABLE FALSE OUTPUT_NAME "smite")

if (WIN32)
    target_link_options(app PRIVATE
            "$<$<PLATFORM_ID:Windows>:-Xlinker;/DEFAULTLIB:swiftCore.lib>"
    )
endif()
