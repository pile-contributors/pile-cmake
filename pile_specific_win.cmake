# ============================================================================
#
# Helpers specific to Windows
# ===========================
#
# This file contains support CMake script for Windows.
#
# Usage
# -----
#
# The file is included by pile_support.cmake if the target system is
# the one targeted here, so all the user has to do to use it is to:
#
#    include(pile_support)
#
# ============================================================================

set (TARGET_SYSTEM_WIN32 ON)

# ============================================================================

# Sets the variable to a version number.

macro(pileMsVcVersion pile_msvc_version )
    # ${CMAKE_MSVC_ARCH} = x86 / x64
    if    ("${MSVC70}" STREQUAL "1")
        set (${pile_msvc_version} "7")
    elseif("${MSVC80}" STREQUAL "1")
        set (${pile_msvc_version} "8")
    elseif("${MSVC90}" STREQUAL "1")
        set (${pile_msvc_version} "9")
    elseif("${MSVC10}" STREQUAL "1")
        set (${pile_msvc_version} "10")
    elseif("${MSVC11}" STREQUAL "1")
        set (${pile_msvc_version} "11")
    elseif("${MSVC12}" STREQUAL "1")
        set (${pile_msvc_version} "12")
    elseif("${MSVC13}" STREQUAL "1")
        set (${pile_msvc_version} "13")
    elseif("${MSVC14}" STREQUAL "1")
        set (${pile_msvc_version} "14")
    elseif("${MSVC15}" STREQUAL "1")
        set (${pile_msvc_version} "15")
    else  ("${MSVC70}" STREQUAL "1")
        set (${pile_msvc_version} )
    endif ()
endmacro(pileMsVcVersion pile_msvc_version )

# ============================================================================


# Remove warnings about deprecations.

macro(pileMsVcNoDeprecation)
    if (TARGET_COMPILER_MSVC)
        add_definitions(
            -D_CRT_SECURE_NO_DEPRECATE
            -D_CRT_NONSTDC_NO_DEPRECATE)
    endif (TARGET_COMPILER_MSVC)
endmacro(pileMsVcNoDeprecation)

# ============================================================================

if ("${CMAKE_SIZEOF_VOID_P}" STREQUAL "4")
    set(SIGNTOOL_PROGRAM_SUF "x86")
    set(SIGNTOOL_PROGRAM_HINT
        "$ENV{ProgramFiles}/Windows Kits/10"
        "$ENV{ProgramFiles}/Windows Kits/8.1")
else()
    set(SIGNTOOL_PROGRAM_SUF "x64")
    set(SIGNTOOL_PROGRAM_HINT
        "$ENV{ProgramW6432}/Windows Kits/10"
        "$ENV{ProgramW6432}/Windows Kits/8.1"
        "$ENV{ProgramFiles}/Windows Kits/10"
        "$ENV{ProgramFiles}/Windows Kits/8.1")
endif()

find_program(SIGNTOOL_PROGRAM signtool
    HINTS ${SIGNTOOL_PROGRAM_HINT} ENV SIGNTOOL_PROGRAM_PATH
    PATH_SUFFIXES "bin/${SIGNTOOL_PROGRAM_SUF}"
    DOC "Tool used for signing the binaries")

set(SIGNTOOL_CERTIFICATE "$ENV{SIGNTOOL_CERTIFICATE}"
    CACHE PATH "The path towards the certificate used for signing the binaries")

set(SIGNTOOL_CERT_PASS "$ENV{SIGNTOOL_CERT_PASS}"
    CACHE STRING "The password for the certificate used for signing the binaries")

set(SIGNTOOL_ENABLED ON
    CACHE BOOL "Are we going to sign binaries or not?")

if (NOT SIGNTOOL_PROGRAM)
    if (NOT "${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
        message(STATUS "Binaries will not be signed because signtool was not found")
    endif()
    set(SIGNTOOL_ENABLED OFF
        CACHE BOOL "Are we going to sign binaries or not?" FORCE)
elseif (NOT SIGNTOOL_CERT_PASS)
    if (NOT "${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
        message(STATUS "Binaries will not be signed because a certificate was not provided")
    endif()
    set(SIGNTOOL_ENABLED OFF
        CACHE BOOL "Are we going to sign binaries or not?" FORCE)
elseif (NOT SIGNTOOL_CERT_PASS)
    if (NOT "${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
        message(STATUS "Binaries will not be signed because a password was not provided")
    endif()
    set(SIGNTOOL_ENABLED OFF
        CACHE BOOL "Are we going to sign binaries or not?" FORCE)
endif()

if (SIGNTOOL_ENABLED)
    message(STATUS "Binaries will be signed using ${SIGNTOOL_CERTIFICATE}")
endif()


macro (pileSignBinary pile_sign_binary__target)
    if (SIGNTOOL_ENABLED)
        add_custom_command(TARGET ${pile_sign_binary__target}
                           POST_BUILD
                           COMMAND
                              "${SIGNTOOL_PROGRAM}" sign
                                /t http://timestamp.digicert.com
                                /f "${SIGNTOOL_CERTIFICATE}"
                                /p ${SIGNTOOL_CERT_PASS}
                                $<TARGET_FILE:${pile_sign_binary__target}>
                           COMMENT "Target ${pile_sign_binary__target} is being signed")
    endif()
endmacro()
