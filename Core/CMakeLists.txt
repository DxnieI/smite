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

add_library(core STATIC
        src/Commands/AuthCommand.swift
        src/Commands/BaseTypes.swift
        src/Commands/ImportCommand.swift
        src/Commands/LegendaryCommand.swift
        src/Commands/ListCommand.swift
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

target_link_libraries(core PUBLIC glaze::glaze)

# Generate C++ header from Swift sources
_swift_generate_cxx_header(core
        core/commands.h
        SEARCH_PATHS "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
