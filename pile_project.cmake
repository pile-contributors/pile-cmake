# ============================================================================
#
# Project Helpers
# ===============
#
# This file contains support CMake script for projects.
#
# Usage
# -----
#
# The file is included by pile_support.cmake, so all the
# user has to do to use it is to:
#
#    include(pile_support)
#
# The purpose is to abstract away complex but repetitive statements from
# project's main CMakeLists.txt file.
#
# By calling
#
#   project("NAME_UPPER" VERSION "X.T.K" LANGUAGES C CXX)
#
# following variables are defined by CMake >= 3.0.0):
#
#        PROJECT_VERSION
#        PROJECT_VERSION_MAJOR
#        PROJECT_VERSION_MINOR
#        PROJECT_VERSION_PATCH
#        PROJECT_VERSION_TWEAK
#        PROJECT_BINARY_DIR
#        PROJECT_NAME
#
#        <PROJECT-NAME>_BINARY_DIR
#        <PROJECT-NAME>_SOURCE_DIR
#        <PROJECT-NAME>_VERSION
#        <PROJECT-NAME>_VERSION_MAJOR
#        <PROJECT-NAME>_VERSION_MINOR
#        <PROJECT-NAME>_VERSION_PATCH
#        <PROJECT-NAME>_VERSION_TWEAK
#
# ============================================================================






# ============================================================================

# Prepares a target for being constructed
#
# Arguments
#     - name: the user name (CamelCased, with spaces) for the project
#     - settings_version: version for the settings
#
# The macro defines or changes
#		PROJECT_NAME: the name of the project (CamelCased, with spaces)
#		PROJECT_NAME_UNIX: the name of the project (low case, no spaces)
#		PROJECT_NAME_UPPER: the name of the project (high case, no spaces)
#		<PROJECT>_MAJOR_VERSION: major version
#		<PROJECT>_MINOR_VERSION: minor version
#		<PROJECT>_PATCH_VERSION: pathc/build number
#		<PROJECT>_SETTINGS_VERSION: the version for settings
#		<PROJECT>_VERSION: a string in the form "1.2.3"
macro    (pileProject
          pile_project__settings_version)


    # common name for the project
    message (STATUS "PROJECT_NAME = ${PROJECT_NAME}")

    # must be a string without spaces and special characters
    string(REGEX REPLACE "[ \t]" "_" PROJECT_NAME_UNIX "${PROJECT_NAME}")
    string(TOUPPER "${PROJECT_NAME_UNIX}" PROJECT_NAME_UPPER)
    string(TOLOWER "${PROJECT_NAME_UNIX}" PROJECT_NAME_UNIX)
    message (STATUS "PROJECT_NAME_UPPER = ${PROJECT_NAME_UPPER}")
    message (STATUS "PROJECT_NAME_UNIX = ${PROJECT_NAME_UNIX}")

    # the versions
    set(${PROJECT_NAME_UPPER}_VERSION_LIST ${pile_project__version})
    set(${PROJECT_NAME_UPPER}_MAJOR_VERSION ${PROJECT_VERSION_MAJOR})
    set(${PROJECT_NAME_UPPER}_MINOR_VERSION ${PROJECT_VERSION_MINOR})
    set(${PROJECT_NAME_UPPER}_PATCH_VERSION ${PROJECT_VERSION_PATCH})
    set(${PROJECT_NAME_UPPER}_VERSION "${PROJECT_VERSION}")

    # when the settings change increment this number
    set(${PROJECT_NAME_UPPER}_SETTINGS_VERSION "${pile_project__settings_version}")

    message (STATUS "${PROJECT_NAME_UPPER}_MAJOR_VERSION = ${${PROJECT_NAME_UPPER}_MAJOR_VERSION}")
    message (STATUS "${PROJECT_NAME_UPPER}_MINOR_VERSION = ${${PROJECT_NAME_UPPER}_MINOR_VERSION}")
    message (STATUS "${PROJECT_NAME_UPPER}_PATCH_VERSION = ${${PROJECT_NAME_UPPER}_PATCH_VERSION}")
    message (STATUS "${PROJECT_NAME_UPPER}_SETTINGS_VERSION = ${${PROJECT_NAME_UPPER}_SETTINGS_VERSION}")

    string(TIMESTAMP
        ${PROJECT_NAME_UPPER}_BUILD_TIME
        UTC)

    # http://www.cmake.org/cmake/help/v3.1/command/project.html#command:project
    # The top-level CMakeLists.txt file for a project must contain a literal,
    # direct call to the project() command; loading one through the include()
    # command is not sufficient. If no such call exists CMake will implicitly add
    # one to the top that enables the default languages (C and CXX).
    if(POLICY CMP0043)
        cmake_policy(SET CMP0043 NEW)
    endif(POLICY CMP0043)

    # if the project has a cmake directory, allow finding modules there
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

    # Prepare proper system variables for config files
    if (MSVC)
        set (TARGET_COMPILER_MSVC ON)
    else (MSVC)
        set (TARGET_COMPILER_MSVC OFF)
    endif (MSVC)

    if (WIN32)
      set (TARGET_SYSTEM_WIN32 ON)
    else (WIN32)
      set (TARGET_SYSTEM_WIN32 OFF)
    endif (WIN32)

    if (UNIX)
      set (TARGET_SYSTEM_UNIX ON)
    else ()
      set (TARGET_SYSTEM_UNIX OFF)
    endif ()

    if (CMAKE_BUILD_TYPE MATCHES DEBUG)
      set (${PROJECT_NAME_UPPER}_DEBUG ON)
    else ()
      set (${PROJECT_NAME_UPPER}_DEBUG OFF)
    endif ()

endmacro ()

# ============================================================================

# Prepares a target for being constructed
macro    (pileProjectCommon)

    set( CMAKE_DEBUG_POSTFIX  "_debug")
    if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
        add_definitions( -DQT_DEBUG=1 -D${PROJECT_NAME_UPPER}_DEBUG=1 -D_DEBUG=1 )
    else()
        add_definitions( -DQT_NO_DEBUG=1 -D${PROJECT_NAME_UPPER}_NO_DEBUG=1 -D_NDEBUG=1 )
    endif()

    # find cmake modules in `cmake` directory
    # also use CMAKE_MODULE_PATH environment variable
    list (APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/")
    list (APPEND CMAKE_MODULE_PATH "$ENV{CMAKE_MODULE_PATH}")
    IF(WIN32)
        string(REPLACE "\\" "/" CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}")
    ENDIF()
    list(REMOVE_DUPLICATES CMAKE_MODULE_PATH)

    # default to position independent code
    set( CMAKE_POSITION_INDEPENDENT_CODE ON)

    # common options
    option( ${PROJECT_NAME_UPPER}_BUILD_TESTS
            "Activate or deactivate building of internal tests"
            OFF)
    option( ${PROJECT_NAME_UPPER}_BUILD_DOCUMENTATION
            "Activate or deactivate building of documentation"
            OFF)
    option( ${PROJECT_NAME_UPPER}_FORCE_DEBUG
            "Activate internal debug features in a release build"
            OFF)

    # see if we can find Qt
    find_package(Qt5 COMPONENTS Core Widgets)

    # assume a build directory
    set( CMAKE_RUNTIME_OUTPUT_DIRECTORY
        "${PROJECT_BINARY_DIR}/build/bin" )
    set( EXECUTABLE_OUTPUT_PATH
        "${PROJECT_BINARY_DIR}/build/bin" )
    file(MAKE_DIRECTORY ${EXECUTABLE_OUTPUT_PATH})
    set( LIBRARY_OUTPUT_PATH
        "${PROJECT_BINARY_DIR}/build/lib" )
    file(MAKE_DIRECTORY ${LIBRARY_OUTPUT_PATH})
    set( INCLUDE_OUTPUT_PATH
        "${PROJECT_BINARY_DIR}/build/include/${PROJECT_NAME_UNIX}" )
    file(MAKE_DIRECTORY ${INCLUDE_OUTPUT_PATH})

    include_directories(
      "${PROJECT_SOURCE_DIR}"
      "${PROJECT_BINARY_DIR}/build/include")

    # Find includes in corresponding build directories
    set( CMAKE_INCLUDE_CURRENT_DIR ON)

    # number of bits
    if ("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86")
        set (TARGET_32BITS ON)
        set (TARGET_64BITS OFF)
    elseif ("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "arm")
        message (FATAL_ERROR "Architecture is not supported")
    else ("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86")
        set (TARGET_32BITS OFF)
        set (TARGET_64BITS ON)
    endif ("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86")

    # Automatically link Qt executables to qtmain target on Windows
    cmake_policy(SET CMP0020 OLD)

    # Instruct CMake to run moc automatically when needed.
    set ( CMAKE_AUTOMOC ON)

#    if(EXISTS "${PROJECT_SOURCE_DIR}/config.h.in")
#        configure_file (
#            "${PROJECT_SOURCE_DIR}/config.h.in"
#            "${INCLUDE_OUTPUT_PATH}/config.h"
#            @ONLY
#        )
#    endif(EXISTS "${PROJECT_SOURCE_DIR}/config.h.in")


endmacro ()

# ============================================================================

# Prepares a target for being constructed
macro    (pileProjectEnd)

    if(EXISTS "${PROJECT_SOURCE_DIR}/config.h.in")
        configure_file (
            "${PROJECT_SOURCE_DIR}/config.h.in"
            "${INCLUDE_OUTPUT_PATH}/config.h"
            @ONLY
        )
    endif(EXISTS "${PROJECT_SOURCE_DIR}/config.h.in")

    # documentaion
    if(${PROJECT_NAME_UPPER}_BUILD_DOCUMENTATION)
        if(EXISTS "${PROJECT_SOURCE_DIR}/Doxyfile.in")

            find_package(Doxygen)

            configure_file (
                "${PROJECT_SOURCE_DIR}/Doxyfile.in"
                "${PROJECT_BINARY_DIR}/Doxyfile"
                @ONLY
            )

            if(DOXYGEN_FOUND)
                add_custom_target(doc
                    ${DOXYGEN_EXECUTABLE} ${PROJECT_BINARY_DIR}/Doxyfile
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                    COMMENT "Generating API documentation with Doxygen" VERBATIM
                )
            else(DOXYGEN_FOUND)
                message(STATUS "Documentation requested but Doxygen was not found")
            endif(DOXYGEN_FOUND)
        endif(EXISTS "${PROJECT_SOURCE_DIR}/Doxyfile.in")
    endif(${PROJECT_NAME_UPPER}_BUILD_DOCUMENTATION)

endmacro ()

# ============================================================================

