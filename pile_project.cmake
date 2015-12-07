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

set (PILEPROJ_DEBUG_MSG ON)

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
#        PROJECT_NAME: the name of the project (CamelCased, with spaces)
#        PROJECT_NAME_UNIX: the name of the project (low case, no spaces)
#        PROJECT_NAME_UPPER: the name of the project (high case, no spaces)
#        <PROJECT>_MAJOR_VERSION: major version
#        <PROJECT>_MINOR_VERSION: minor version
#        <PROJECT>_PATCH_VERSION: pathc/build number
#        <PROJECT>_SETTINGS_VERSION: the version for settings
#        <PROJECT>_VERSION: a string in the form "1.2.3"
#
#        TARGET_COMPILER_MSVC: The compiler to be used is Microsoft compiler?
#        TARGET_SYSTEM_WIN32: target system is Windows?
#        TARGET_SYSTEM_UNIX: are we targeting unix?
#        <PROJECT_UPPER>_DEBUG: is this a debug build or a release build?
#
# The module search path is amended to include a cmake directory at
# in top source directory.
#
# For Windows builds a variable - PILE_PROJECT_DEP_LIBS - is initialized to
# contain the name of the binary libraries that should be included in a package
# produced by CPACK. The list is used by pileProjectEnd to find absolute
# paths and install them in binary directory (use PILE_PROJECT_DEP_LIB_DIRS
# list if you want to custom paths to be searched).
#
# Qt plug-ins may also be installed by using PILE_PROJECT_QT_PLUGINS list.
# Each entry should have category/name format without .dll suffix. The special
# value category/all can be used to include all plug-ins in a category. The directory
# to use will be auto-magically derived if Qt Core is found.
#
macro    (pileProject
          pile_project__settings_version)

    set (pile_project__argn ${ARGN})
    set(PROJECT_NEEDS_GUI OFF
        CACHE INTERNAL "Project needs GUI support")
    if (pile_project__argn)
        list(GET pile_project__argn 0 pile_project__gui)
        if (pile_project__gui)
        set(PROJECT_NEEDS_GUI ON
            CACHE INTERNAL "Project needs GUI support")
        endif()
    endif()
    unset (pile_project__argn)

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
    set(${PROJECT_NAME_UPPER}_MAJOR_VERSION ${PROJECT_VERSION_MAJOR}
        CACHE STRING "Major version")
    set(${PROJECT_NAME_UPPER}_MINOR_VERSION ${PROJECT_VERSION_MINOR}
        CACHE STRING "Minor version")
    set(${PROJECT_NAME_UPPER}_PATCH_VERSION ${PROJECT_VERSION_PATCH}
        CACHE STRING "Patch version")
    set(${PROJECT_NAME_UPPER}_VERSION "${PROJECT_VERSION}"
        CACHE STRING "Project version")

    # when the settings change increment this number
    set(${PROJECT_NAME_UPPER}_SETTINGS_VERSION "${pile_project__settings_version}"
        CACHE STRING "Settings version")

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

    if (APPLE)
      set (TARGET_SYSTEM_APPLE ON)
    else ()
      set (TARGET_SYSTEM_APPLE OFF)
    endif ()

    if (CMAKE_BUILD_TYPE MATCHES "Debug")
      set (${PROJECT_NAME_UPPER}_DEBUG ON)
    else ()
      set (${PROJECT_NAME_UPPER}_DEBUG OFF)
    endif ()

    set (PILE_PROJECT_DEP_LIBS
         CACHE INTERNAL "The list of dlls to install and package" FORCE)
    set (PILE_PROJECT_DEP_LIB_DIRS
        CACHE INTERNAL "The list of directories to search for dlls" FORCE)
    set (PILE_PROJECT_QT_PLUGINS
         CACHE INTERNAL "The list of Qt plug-ins to install and package" FORCE)

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
# If Qt Core is found PILE_QT_ROOT is defined as the directory that contains
# bin, lib, ... and it is appended to PILE_PROJECT_DEP_LIB_DIRS.
#
macro    (pileProjectCommonQt)
    # see if we can find Qt
    set (qt_default_comp "Core")
    if (PROJECT_NEEDS_GUI)
        list(APPEND qt_default_comp Widgets Gui)
    endif()
    find_package(Qt5 QUIET COMPONENTS ${qt_default_comp})
    unset(qt_default_comp)

    # Automatically link Qt executables to qtmain target on Windows
    cmake_policy(SET CMP0020 OLD)

    # Instruct CMake to run moc automatically when needed.
    set (CMAKE_AUTOMOC ON)

    if (Qt5Core_DIR)
        # Qt5Core_DIR is like C:/pf/Qt/5.5/msvc2013_64/lib/cmake/Qt5Core
        get_filename_component(PILE_QT_ROOT "${Qt5Core_DIR}/../../.." ABSOLUTE CACHE)
        list(APPEND PILE_PROJECT_DEP_LIB_DIRS "${PILE_QT_ROOT}")

        list(APPEND PILE_PROJECT_QT_PLUGINS "platforms/minimal")
        list(APPEND PILE_PROJECT_QT_PLUGINS "platforms/offscreen")
        if (TARGET_SYSTEM_WIN32)
            list(APPEND PILE_PROJECT_QT_PLUGINS "platforms/windows")
        endif()
        set (PILE_PROJECT_QT_PLUGINS ${PILE_PROJECT_QT_PLUGINS}
             CACHE INTERNAL "The list of Qt plug-ins to install and package" FORCE)
    endif()
endmacro ()

# ============================================================================

# Common project initialization related to generating packages.
#
# A configuration file template may be provided in packaging sub-directory
# and it will be generated in binary directory using standard CMake
# config mechanism.
#
# CPACK version variables are set based on project values and
# a default generator is set if one is not provided. A name for
# generated file consisting of project name and version will
# be set.
#
macro    (pileProjectCommonPackage)
    # "standard" path for config file template
    if (NOT CPACK_PROJECT_CONFIG_FILE)
        set (CPACK_PROJECT_CONFIG_FILE
             "${PROJECT_BINARY_DIR}/CPackConfigurations.cmake")
    endif()
    # "standard" path for config file
    if (NOT CPACK_PROJECT_CONFIG_TEMPLATE)
        set (CPACK_PROJECT_CONFIG_TEMPLATE
             "${PROJECT_SOURCE_DIR}/packaging/CPackConfigurations.cmake.in")
    endif()

    # version
    set(CPACK_PACKAGE_VERSION
        "${${PROJECT_NAME_UPPER}_VERSION}")
    set(CPACK_PACKAGE_VERSION_MAJOR
        "${${PROJECT_NAME_UPPER}_MAJOR_VERSION}")
    set(CPACK_PACKAGE_VERSION_MINOR
        "${${PROJECT_NAME_UPPER}_MINOR_VERSION}")
    set(CPACK_PACKAGE_VERSION_PATCH
        "${${PROJECT_NAME_UPPER}_PATCH_VERSION}")

    # default generator
    if (NOT CPACK_GENERATOR)
        if(APPLE)
            set (CPACK_GENERATOR "DragNDrop")
        elseif(WIN32 AND NOT UNIX)
            set (CPACK_GENERATOR NSIS)
        elseif(UNIX)
            set (CPACK_GENERATOR DEB )
        else()
            set (CPACK_GENERATOR "DEB;RPM")
        endif()
    endif(NOT CPACK_GENERATOR)

    # default name of generated package
    if (NOT CPACK_PACKAGE_FILE_NAME)
        set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${PROJECT_VERSION}")
    endif(NOT CPACK_PACKAGE_FILE_NAME)

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
    pileProjectCommonPackage ()


    #if (NOT CMAKE_INSTALL_PREFIX)
        if (${PROJECT_NAME_UPPER}_DEBUG)
            if ("${CMAKE_INSTALL_PREFIX}" MATCHES "[A-Za-z]:[\\\\/]Program Files.+")
                set (CMAKE_INSTALL_PREFIX
                    "${PROJECT_SOURCE_DIR}/../install-${CMAKE_BUILD_TYPE}-${TARGET_BITS}"
                    CACHE PATH "install prefix for debug should not go to Program Files" FORCE)
            endif()
        endif()
    #endif()
endmacro ()

# ============================================================================

macro (pileProjectAddDocument document_to_search)
    unset (local_document_found)
    find_file(local_document_found "${document_to_search}"
              HINTS "${PROJECT_SOURCE_DIR}/documents"
              NO_DEFAULT_PATHS)
    if (local_document_found)
        list (APPEND PROJECT_INSTALLED_DOCUMENTS ${local_document_found})
    endif()
    unset (local_document_found)
endmacro ()


macro (pileProjectAddVcRedist redist_name)
    unset (redist_variable)
    unset (redist_name_base)
    string(TOUPPER "${redist_name}" redist_variable)
    string(REPLACE " " "_" redist_variable "${redist_variable}")

    find_program(${redist_variable}
                 NAMES "${redist_name}"
                 HINTS
                    "${VCREDIST_INSTALLER_PATH}"
                    "$ENV{QTDIR}/../../vcredist"
                 PATH_SUFFIXES BIN
                 DOC "Visual C Redistributable package ${redist_name}")
    get_filename_component(redist_name_base "${redist_variable}" NAME)
    unset(quiet_args)
    if (redist_variable MATCHES "(2012|2013)")
        set (quiet_args "/quiet /norestart")
    else()
        set (quiet_args "/q")
    endif()

    install(
        FILES ${VCREDIST_INSTALLER}
        DESTINATION "tmp"
        COMPONENT applications)
    list(APPEND CPACK_NSIS_EXTRA_INSTALL_COMMANDS "
           ExecWait '$INSTDIR\\\\tmp\\\\${redist_name_base} ${quiet_args}'
           ")
    list(REMOVE_DUPLICATES CPACK_NSIS_EXTRA_INSTALL_COMMANDS)

    unset (redist_variable)
    unset (redist_name_base)
    unset (quiet_args)
endmacro ()

# Install and package project and dependencies.
#
# PILE_PROJECT_DEP_LIBS variable is expected to contain a list of names that
# will be searched and, if found, will be included in the list of binary files
# (installed in bin directory). PILE_PROJECT_DEP_LIB_DIRS can be used to add
# to the list of paths searched for these libraries.
#
macro    (pileProjectInstall)

    # dynamic libraries to install
    list(REMOVE_DUPLICATES PILE_PROJECT_DEP_LIBS)
    foreach(dep_lib ${PILE_PROJECT_DEP_LIBS})
        if (${PROJECT_NAME_UPPER}_DEBUG)
            set (dep_lib_names "${dep_lib}d" "${dep_lib}d.dll"
                               "${dep_lib}_debug" "${dep_lib}_debug.dll"
                               "Qt${dep_lib}d.dll" "Qt5${dep_lib}d.dll"
                               "${dep_lib}.dll"
                               "${dep_lib}"
                               "Qt${dep_lib}.dll" "Qt5${dep_lib}.dll")
        else()
            set (dep_lib_names "${dep_lib}" "${dep_lib}.dll"
                               "Qt${dep_lib}" "Qt${dep_lib}.dll"
                               "Qt5${dep_lib}" "Qt5${dep_lib}.dll")
        endif()
        find_file (dep_lib_found
              NAMES ${dep_lib_names}
              PATHS ${PILE_PROJECT_DEP_LIB_DIRS}
              PATH_SUFFIXES bin
              NO_DEFAULT_PATH)
        if (dep_lib_found)
            list(APPEND PILE_PROJECT_DEP_LIBS_EXPANDED ${dep_lib_found})
            pileProjectMessage("Found ${dep_lib} at ${dep_lib_found}")
        else()
            message(AUTHOR_WARNING "Library ${dep_lib} was not found and will not be installed and packaged")
            pileProjectMessage("  - names: ${dep_lib_names}")
            pileProjectMessage("  - paths: ${PILE_PROJECT_DEP_LIB_DIRS}")
        endif()
        unset(dep_lib_names)
        unset(dep_lib_found CACHE)
    endforeach()

    # install this list of files in bin directory
    if (PILE_PROJECT_DEP_LIBS_EXPANDED)
        list(REMOVE_DUPLICATES PILE_PROJECT_DEP_LIBS_EXPANDED)
        install(
            FILES ${PILE_PROJECT_DEP_LIBS_EXPANDED}
            DESTINATION bin
            COMPONENT applications)
    endif()

    # the list of Qt plug-ins to install
    list(REMOVE_DUPLICATES PILE_PROJECT_QT_PLUGINS)
    foreach(dep_lib ${PILE_PROJECT_QT_PLUGINS})
        string(REPLACE "/" ";" dep_comp_name ${dep_lib})
        list (GET dep_comp_name 0 dep_category)
        list (GET dep_comp_name 1 dep_name)

        if (dep_name STREQUAL "all")
            if (${PROJECT_NAME_UPPER}_DEBUG)
                set (dep_lib_names "${PILE_QT_ROOT}/plugins/${dep_category}/q*d.dll")
            else()
                set (dep_lib_names "${PILE_QT_ROOT}/plugins/${dep_category}/q*.dll")
            endif()
            file(GLOB dep_lib_all "${dep_lib_names}")
            if (dep_lib_all)
                pileProjectMessage("Found ${dep_category} Qt plug-ins")
            else()
                if (${PROJECT_NAME_UPPER}_DEBUG)
                    set (dep_lib_names "${PILE_QT_ROOT}/plugins/${dep_category}/*d.dll")
                else()
                    set (dep_lib_names "${PILE_QT_ROOT}/plugins/${dep_category}/*.dll")
                endif()
                file(GLOB dep_lib_all "${dep_lib_names}")
                if (dep_lib_all)
                    pileProjectMessage("Found ${dep_category} Qt plug-ins")
                else()
                    message(AUTHOR_WARNING "No Qt plug-ins in ${dep_category} category")
                    pileProjectMessage("  - names: ${dep_lib_names}")
                endif()
            endif()
            list(APPEND PILE_PROJECT_DEP_QT_PLUGINS_EXPANDED ${dep_lib_all})
        else()
            if (${PROJECT_NAME_UPPER}_DEBUG)
                set (dep_lib_names "${dep_name}d" "${dep_name}d.dll"
                                   "qt${dep_name}d.dll" "q${dep_name}d.dll"
                                   "${dep_name}" "${dep_name}.dll"
                                   "qt${dep_name}.dll" "q${dep_name}.dll")
            else()
                set (dep_lib_names "${dep_name}" "${dep_name}.dll"
                                   "q${dep_name}" "q${dep_name}.dll"
                                   "qt${dep_name}" "qt${dep_name}.dll")
            endif()

            unset(dep_lib_found)
            find_file (dep_lib_found
                  NAMES ${dep_lib_names}
                  HINTS "${PILE_QT_ROOT}/plugins/${dep_category}"
                  NO_DEFAULT_PATH)
            if (dep_lib_found)
                list(APPEND PILE_PROJECT_DEP_QT_PLUGINS_EXPANDED ${dep_lib_found})
                pileProjectMessage("Found ${dep_lib_found} Qt plug-in")
                set(dep_lib_all ${dep_lib_found})
            else()
                message(AUTHOR_WARNING "Qt plug-in ${dep_lib} was not found and will not be installed and packaged")
                pileProjectMessage("  - names: ${dep_lib_names}")
                pileProjectMessage("  - path: ${PILE_QT_ROOT}/plugins/${dep_category}")
            endif()
        endif()

        if (dep_lib_all)
            install(
                FILES ${dep_lib_all}
                DESTINATION "bin/plugins/${dep_category}"
                COMPONENT applications)
        endif()

        if (WIN32)
            if (TARGET_COMPILER_MSVC)
                # TODO: should be imported from some system variable
                # set (VCREDIST_INSTALLER_PATH "C:/...")

                # set (VCREDIST_INSTALLER_NAME "vcredist_msvc2013_x86.exe")

                pileProjectAddVcRedist("vcredist_msvc2013_x86")
                if (TARGET_64BITS)
                    pileProjectAddVcRedist("vcredist_msvc2013_x64")
                endif(TARGET_64BITS)
            endif(TARGET_COMPILER_MSVC)

        endif(WIN32)

        unset(dep_comp_name)
        unset(dep_category)
        unset(dep_name)
        unset(dep_lib_names)
        unset(dep_lib_all)
        unset(dep_lib_found CACHE)
    endforeach()

    # install this list of files in bin directory
    if (PILE_PROJECT_DEP_QT_PLUGINS_EXPANDED)
        list(REMOVE_DUPLICATES PILE_PROJECT_DEP_QT_PLUGINS_EXPANDED)
        ##install(
        ##    FILES ${PILE_PROJECT_DEP_QT_PLUGINS_EXPANDED}
        ##    DESTINATION "bin/plugins"
        ##    COMPONENT applications)

        file(WRITE "${PROJECT_BINARY_DIR}/qt.conf"
                   "[Paths]\nPlugins=./plugins\n")
        install(
            FILES "${PROJECT_BINARY_DIR}/qt.conf"
            DESTINATION bin
            COMPONENT applications)
    endif()

    # documents
    pileProjectAddDocument ("Warranty Disclaimer.rtf")
    pileProjectAddDocument ("Privacy Policy.rtf")
    pileProjectAddDocument ("FatCow License.txt")
    pileProjectAddDocument ("OpenSSL License.txt")
    pileProjectAddDocument ("Qt License.txt")
    pileProjectAddDocument ("Qt Third Party Software Listing.txt")
    list(REMOVE_DUPLICATES PROJECT_INSTALLED_DOCUMENTS)
    if (PROJECT_INSTALLED_DOCUMENTS)
        install(
            FILES ${PROJECT_INSTALLED_DOCUMENTS}
            DESTINATION documents
            COMPONENT documents)
    endif ()

    if(EXISTS "${CPACK_PROJECT_CONFIG_TEMPLATE}")
        configure_file (
            "${CPACK_PROJECT_CONFIG_TEMPLATE}"
            "${CPACK_PROJECT_CONFIG_FILE}"
            @ONLY)
    endif()

    # all library files listed in the variable
    # CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS will be installed
    INCLUDE(InstallRequiredSystemLibraries)
    INCLUDE(CPack)
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

    # packaging
    pileProjectInstall ()

endmacro ()

# ============================================================================

