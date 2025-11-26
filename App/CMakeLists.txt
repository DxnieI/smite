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

qt_add_resources(RESOURCE_FILES
    src/resources.qrc
)

target_sources(app
        PRIVATE
        src/main.cxx
        src/ViewModels/UserViewModel.cxx
        include/viewmodels/UserViewModel.h
        ${RESOURCE_FILES}
)

ecm_target_qml_sources(app
        SOURCES
        Views/Main.qml
        Views/UserView.qml
        Views/LibraryView.qml
)

target_include_directories(app PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_BINARY_DIR}/Core/include
)

find_package(Qt6 REQUIRED COMPONENTS Quick Qml WebEngineQuick Svg Concurrent)

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
        Qt6::WebEngineQuick
        Qt6::Svg
        Qt6::Concurrent
)

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    # macOS: Install inside the .app bundle
    set(LEGENDARY_DEST_DIR "$<TARGET_BUNDLE_CONTENT_DIR:app>/Resources/bin")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    # Windows: Install next to the executable
    set(LEGENDARY_DEST_DIR "$<TARGET_FILE_DIR:app>/bin")
else()
    # Linux: Install in a bin subdirectory
    set(LEGENDARY_DEST_DIR "$<TARGET_FILE_DIR:app>/bin")
endif()

add_custom_command(TARGET app PRE_BUILD
    COMMAND ${Python3_EXECUTABLE} ${CMAKE_SOURCE_DIR}/fetch_legendary.py "${LEGENDARY_DEST_DIR}"
    COMMENT "Downloading legendary binary for current platform"
    VERBATIM
)

# Set output name
set_target_properties(app PROPERTIES WIN32_EXECUTABLE FALSE OUTPUT_NAME "smite")

if (WIN32)
    target_link_options(app PRIVATE
            "$<$<PLATFORM_ID:Windows>:-Xlinker;/DEFAULTLIB:swiftCore.lib>"
    )
endif()
