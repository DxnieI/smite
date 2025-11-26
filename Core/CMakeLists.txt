cmake_minimum_required(VERSION 3.29)
project(core LANGUAGES CXX Swift)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (WIN32)
    # Remove /utf-8 flag that gets inherited from parent
    get_directory_property(COMPILE_OPTIONS COMPILE_OPTIONS)
    list(REMOVE_ITEM COMPILE_OPTIONS "/utf-8")
    set_directory_properties(PROPERTIES COMPILE_OPTIONS "${COMPILE_OPTIONS}")
endif()

set(LEGENDARY_COMMANDS_SOURCES
    src/legendary/Commands/AuthCommand.swift
    src/legendary/Commands/BaseTypes.swift
    src/legendary/Commands/ImportCommand.swift
    src/legendary/Commands/LegendaryCommand.swift
    src/legendary/Commands/ListCommand.swift
    src/legendary/Paths.swift
    src/legendary/Models+Legendary.swift
    src/legendary/User.swift
    src/legendary/Library.swift
)

set(LEGENDARY_RUNNER_SOURCES
    src/legendary/Runner/LegendaryRunner.swift
)

add_library(core STATIC
    ${LEGENDARY_COMMANDS_SOURCES}
    ${LEGENDARY_RUNNER_SOURCES}
    src/common/Models.swift
)

set_target_properties(core PROPERTIES
        Swift_MODULE_NAME "Core"
)

# Enable C++ interoperability for Swift
target_compile_options(core PUBLIC
        "$<$<COMPILE_LANGUAGE:Swift>:-cxx-interoperability-mode=default>"
        "$<$<COMPILE_LANGUAGE:Swift>:-wmo>"
)

target_include_directories(core PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

_swift_generate_cxx_header(core
        core/legendary/user.h
        SOURCES src/legendary/User.swift
        SEARCH_PATHS "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
