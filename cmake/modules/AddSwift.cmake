# This source file is part of the Swift open source project
#
# Copyright (c) 2023 Apple Inc. and the Swift project authors.
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information


# Generate the bridging header from Swift to C++
#
# target: the name of the target to generate headers for.
#         This target must build swift source files.
# header: the name of the header file to generate.
#
# NOTE: This logic will eventually be unstreamed into CMake.
function(_swift_generate_cxx_header target header)
  if(NOT TARGET ${target})
    message(FATAL_ERROR "Target ${target} not defined.")
  endif()

  if(NOT DEFINED CMAKE_Swift_COMPILER)
    message(WARNING "Swift not enabled in project. Cannot generate headers for Swift files.")
    return()
  endif()

  cmake_parse_arguments(ARG "" "" "SEARCH_PATHS;MODULE_NAME" ${ARGN})

  if(NOT ARG_MODULE_NAME)
    set(target_module_name $<TARGET_PROPERTY:${target},Swift_MODULE_NAME>)
    set(ARG_MODULE_NAME $<IF:$<BOOL:${target_module_name}>,${target_module_name},${target}>)
  endif()

  # Automatically collect module search paths from dependencies
  get_target_property(_link_libs ${target} LINK_LIBRARIES)
  if(_link_libs)
    foreach(_lib ${_link_libs})
      if(TARGET ${_lib})
        # Get the binary directory for Swift modules
        get_target_property(_lib_binary_dir ${_lib} BINARY_DIR)
        if(_lib_binary_dir)
          list(APPEND ARG_SEARCH_PATHS "${_lib_binary_dir}")
        endif()

        # Get include directories for C/C++ module maps
        get_target_property(_lib_include_dirs ${_lib} INTERFACE_INCLUDE_DIRECTORIES)
        if(_lib_include_dirs)
          list(APPEND ARG_SEARCH_PATHS ${_lib_include_dirs})
        endif()

        # Recursively get transitive dependencies' paths
        get_target_property(_transitive_libs ${_lib} LINK_LIBRARIES)
        if(_transitive_libs)
          foreach(_trans_lib ${_transitive_libs})
            if(TARGET ${_trans_lib})
              get_target_property(_trans_binary_dir ${_trans_lib} BINARY_DIR)
              if(_trans_binary_dir)
                list(APPEND ARG_SEARCH_PATHS "${_trans_binary_dir}")
              endif()
              get_target_property(_trans_include_dirs ${_trans_lib} INTERFACE_INCLUDE_DIRECTORIES)
              if(_trans_include_dirs)
                list(APPEND ARG_SEARCH_PATHS ${_trans_include_dirs})
              endif()
            endif()
          endforeach()
        endif()
      endif()
    endforeach()

    # Remove duplicates
    if(ARG_SEARCH_PATHS)
      list(REMOVE_DUPLICATES ARG_SEARCH_PATHS)
    endif()
  endif()

  if(ARG_SEARCH_PATHS)
    list(TRANSFORM ARG_SEARCH_PATHS PREPEND "-I")
  endif()

  if(APPLE AND CMAKE_OSX_SYSROOT)
    set(SDK_FLAGS "-sdk" "${CMAKE_OSX_SYSROOT}")
  elseif(WIN32)
    set(SDK_FLAGS "-sdk" "$ENV{SDKROOT}")
  elseif(CMAKE_SYSROOT)
    set(SDK_FLAGS "-sdk" "${CMAKE_SYSROOT}")
  endif()

  cmake_path(APPEND CMAKE_CURRENT_BINARY_DIR include
    OUTPUT_VARIABLE base_path)

  cmake_path(APPEND base_path ${header}
    OUTPUT_VARIABLE header_path)

  cmake_path(APPEND CMAKE_CURRENT_BINARY_DIR "${ARG_MODULE_NAME}.emit-module.d" OUTPUT_VARIABLE depfile_path)

  set(_AllSources $<PATH:ABSOLUTE_PATH,$<TARGET_PROPERTY:${target},SOURCES>,${CMAKE_CURRENT_SOURCE_DIR}>)
  set(_SwiftSources $<FILTER:${_AllSources},INCLUDE,\\.swift$>)

  add_custom_command(OUTPUT ${header_path}
    DEPENDS ${_SwiftSources}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND
      ${CMAKE_Swift_COMPILER} -typecheck
      ${ARG_SEARCH_PATHS}
      ${_SwiftSources}
      ${SDK_FLAGS}
      -module-name "${ARG_MODULE_NAME}"
      -cxx-interoperability-mode=default
      -emit-clang-header-path ${header_path}
      -emit-dependencies
    DEPFILE "${depfile_path}"
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT
      "Generating '${header_path}'"
    COMMAND_EXPAND_LISTS)

  # Added to public interface for dependees to find.
  target_include_directories(${target} PUBLIC ${base_path})
  # Added to the target to ensure target rebuilds if header changes and is used
  # by sources in the target.
  target_sources(${target} PRIVATE ${header_path})
endfunction()