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



# when things get tough turn this on
if (NOT DEFINED PILEPROJ_DEBUG_MSG)
    set (PILEPROJ_DEBUG_MSG OFF)
endif()
macro(pileProjectMessage pile_project_message__content)
    if (PILEPROJ_DEBUG_MSG)
        message(STATUS "PILE PROJECT> ${pile_project_message__content}")
    endif()
endmacro()



# ============================================================================

# Prepares a target for being constructed
#
# Arguments
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
#
#		TARGET_COMPILER_MSVC: The compiler to be used is Microsoft compiler?
#		TARGET_SYSTEM_WIN32: target system is Windows?
#		TARGET_SYSTEM_UNIX: are we targeting unix?
#		<PROJECT_UPPER>_DEBUG: is this a debug build or a release build?
#
# The module search path is ammended to include a cmake directory at
# the top level of the hierarchy.
#
macro    (pileProject
          pile_project__settings_version)


    # common name for the project
    pileProjectMessage("PROJECT_NAME = ${PROJECT_NAME}")

    # must be a string without spaces and special characters
    string(REGEX REPLACE "[ \t]" "_" PROJECT_NAME_UNIX "${PROJECT_NAME}")
    string(TOUPPER "${PROJECT_NAME_UNIX}" PROJECT_NAME_UPPER)
    string(TOLOWER "${PROJECT_NAME_UNIX}" PROJECT_NAME_UNIX)
    pileProjectMessage("PROJECT_NAME_UPPER = ${PROJECT_NAME_UPPER}")
    pileProjectMessage("PROJECT_NAME_UNIX = ${PROJECT_NAME_UNIX}")

    # the versions
    # set(${PROJECT_NAME_UPPER}_VERSION_LIST ${pile_project__version})
    set(${PROJECT_NAME_UPPER}_MAJOR_VERSION ${PROJECT_VERSION_MAJOR})
    set(${PROJECT_NAME_UPPER}_MINOR_VERSION ${PROJECT_VERSION_MINOR})
    set(${PROJECT_NAME_UPPER}_PATCH_VERSION ${PROJECT_VERSION_PATCH})
    set(${PROJECT_NAME_UPPER}_VERSION "${PROJECT_VERSION}")

    # when the settings change increment this number
    set(${PROJECT_NAME_UPPER}_SETTINGS_VERSION "${pile_project__settings_version}")

    pileProjectMessage("${PROJECT_NAME_UPPER}_MAJOR_VERSION = ${${PROJECT_NAME_UPPER}_MAJOR_VERSION}")
    pileProjectMessage("${PROJECT_NAME_UPPER}_MINOR_VERSION = ${${PROJECT_NAME_UPPER}_MINOR_VERSION}")
    pileProjectMessage("${PROJECT_NAME_UPPER}_PATCH_VERSION = ${${PROJECT_NAME_UPPER}_PATCH_VERSION}")
    pileProjectMessage("${PROJECT_NAME_UPPER}_SETTINGS_VERSION = ${${PROJECT_NAME_UPPER}_SETTINGS_VERSION}")

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

    if (CMAKE_BUILD_TYPE MATCHES "Debug")
      set (${PROJECT_NAME_UPPER}_DEBUG ON)
    else ()
      set (${PROJECT_NAME_UPPER}_DEBUG OFF)
    endif ()

endmacro ()

# ============================================================================

# Common project initialization related to debug/release variants.
#
# The macro sets the postfix for targets to "_debug" in
# Debug builds and adds a number of definitions for all targets 
# of this project:
# - QT_DEBUG or QT_NO_DEBUG
# - <PROJECT_NAME_UPPER>_DEBUG or <PROJECT_NAME_UPPER>_NO_DEBUG
# - _DEBUG or _NDEBUG
#
#
macro    (pileProjectCommonDebug)
    set( CMAKE_DEBUG_POSTFIX  "_debug")
    if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
        add_definitions( -DQT_DEBUG=1 -D${PROJECT_NAME_UPPER}_DEBUG=1 -D_DEBUG=1 )
    else()
        add_definitions( -DQT_NO_DEBUG=1 -D${PROJECT_NAME_UPPER}_NO_DEBUG=1 -D_NDEBUG=1 )
    endif()
endmacro ()

# ============================================================================

# Common project initialization related to module paths.
#
# Top level cmake directory and the list of directories in
# CMAKE_MODULE_PATH environment variable are added to
# internal CMAKE_MODULE_PATH variable. The list is fixed
# for Windows systems and duplicates are removed.
#
macro    (pileProjectCommonModPaths)
    # find cmake modules in `cmake` directory
    # also use CMAKE_MODULE_PATH environment variable
    list (APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/")
    list (APPEND CMAKE_MODULE_PATH "$ENV{CMAKE_MODULE_PATH}")
    IF(WIN32)
        string(REPLACE "\\" "/" CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}")
    ENDIF()
    list(REMOVE_DUPLICATES CMAKE_MODULE_PATH)
endmacro ()

# ============================================================================

# Common project initialization related to user options.
#
# Following general purpose options are created:
# - <PROJECT_NAME_UPPER>_BUILD_TESTS: enable tests
# - <PROJECT_NAME_UPPER>_BUILD_DOCUMENTATION: enable documentation
# - <PROJECT_NAME_UPPER>_FORCE_DEBUG: debug features in release builds
# Position independent code is also enabled.
#
macro    (pileProjectCommonOptions)

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
endmacro ()

# ============================================================================

# Common project initialization related to build directory.
#
# A build directory will be assumed inside top level binary directory
# and will have three subdirectories: bin, lib and include.
# These folders are created and following variables are set:
# - EXECUTABLE_OUTPUT_PATH, CMAKE_RUNTIME_OUTPUT_DIRECTORY
# - LIBRARY_OUTPUT_PATH, LIBRARY_OUTPUT_DIRECTORY
# - INCLUDE_OUTPUT_PATH
#
macro    (pileProjectCommonBuildDir)
    # assume a build directory
    set( CMAKE_RUNTIME_OUTPUT_DIRECTORY
        "${PROJECT_BINARY_DIR}/build/bin" )
    set( EXECUTABLE_OUTPUT_PATH
        "${PROJECT_BINARY_DIR}/build/bin" )
    file(MAKE_DIRECTORY ${EXECUTABLE_OUTPUT_PATH})
    set( LIBRARY_OUTPUT_PATH
        "${PROJECT_BINARY_DIR}/build/lib" )
    set( ARCHIVE_OUTPUT_DIRECTORY
        "${PROJECT_BINARY_DIR}/build/lib" )
    set( LIBRARY_OUTPUT_DIRECTORY
        "${PROJECT_BINARY_DIR}/build/lib" )
    file(MAKE_DIRECTORY ${LIBRARY_OUTPUT_PATH})
    set( INCLUDE_OUTPUT_PATH
        "${PROJECT_BINARY_DIR}/build/include/${PROJECT_NAME_UNIX}" )
    file(MAKE_DIRECTORY ${INCLUDE_OUTPUT_PATH})
endmacro ()

# ============================================================================

# Common project initialization related to include directories.
#
# Include paths are altered to include source and destination
# for header files. Current directory is also included by default.
#
macro    (pileProjectCommonIncludeDir)
    include_directories(
      "${PROJECT_SOURCE_DIR}"
      "${PROJECT_BINARY_DIR}/build/include")

    # Find includes in corresponding build directories
    set( CMAKE_INCLUDE_CURRENT_DIR ON)
endmacro ()

# ============================================================================

# Common project initialization related to number of bits in an integer.
#
# Variables TARGET_32BITS and TARGET_64BITS are boolean while
# TARGET_BITS is set to either 64 or 32.
#
macro    (pileProjectCommonBits)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set (TARGET_32BITS OFF)
        set (TARGET_64BITS ON)
        set (TARGET_BITS 64)
    else (CMAKE_SIZEOF_VOID_P EQUAL 4)
        set (TARGET_32BITS ON)
        set (TARGET_64BITS OFF)
        set (TARGET_BITS 32)
    else()
        message (FATAL_ERROR "Architecture is not supported (size of void* is ${CMAKE_SIZEOF_VOID_P})")
    endif()
    pileProjectMessage("TARGET_BITS = ${TARGET_BITS}")
endmacro ()

# ============================================================================

# Common project initialization related to Qt package.
#
# Qt5 package is silently searched and core and widgets components
# are requested. We also enable automatic link to qtmain
# on Windows and automatic moc.
#
macro    (pileProjectCommonQt)
    # see if we can find Qt
    find_package(Qt5 QUIET COMPONENTS Core Widgets)
	
    # Automatically link Qt executables to qtmain target on Windows
    cmake_policy(SET CMP0020 OLD)

    # Instruct CMake to run moc automatically when needed.
    set (CMAKE_AUTOMOC ON)
endmacro ()

# ============================================================================

# Common project initialization
macro    (pileProjectCommon)
	pileProjectCommonDebug ()
	pileProjectCommonModPaths ()
	pileProjectCommonOptions ()
	pileProjectCommonBuildDir ()
	pileProjectCommonIncludeDir ()
	pileProjectCommonBits ()
	pileProjectCommonQt ()
endmacro ()

# ============================================================================

# Final touches for a pile project
#
# Configures default file if it exists and creates a target for
# documentation.
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
                pileProjectMessage("Documentation requested but Doxygen was not found")
            endif(DOXYGEN_FOUND)
        endif(EXISTS "${PROJECT_SOURCE_DIR}/Doxyfile.in")
    endif(${PROJECT_NAME_UPPER}_BUILD_DOCUMENTATION)

endmacro ()

# ============================================================================

