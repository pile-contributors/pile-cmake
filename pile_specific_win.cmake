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


