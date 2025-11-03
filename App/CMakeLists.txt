cmake_minimum_required(VERSION 3.29)
project(app LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Qt setup
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(CMAKE_CXX_SCAN_FOR_MODULES OFF)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)

add_executable(app
    main.cpp
    resources.qrc
)

# Link to Qt and Core library
target_link_libraries(app PRIVATE
    core
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)

# Set output name
set_target_properties(app PROPERTIES OUTPUT_NAME "smite")
