# ============================================================================
#
# Helpers specific to MSVC compiler
# =================================
#
# This file contains support CMake script for Microsoft's MSVC compiler.
#
# Usage
# -----
#
# The file is included by pile_support.cmake if the compiler is
# the one targeted here, so all the user has to do to use it is to:
#
#    include(pile_support)
#
#
# CMake provides following variables:
#
#    MSVC60 True when using Microsoft Visual C 6.0
#    MSVC70 True when using Microsoft Visual C 7.0
#    MSVC71 True when using Microsoft Visual C 7.1
#    MSVC80 True when using Microsoft Visual C 8.0
#    MSVC90 True when using Microsoft Visual C 9.0
#    MSVC10 True when using Microsoft Visual C 10
#    MSVC11 True when using Microsoft Visual C 11
#    MSVC12 True when using Microsoft Visual C 12
#    MSVC14 True when using Microsoft Visual C 14
#    MSVC_IDE True when using the Microsoft Visual C IDE
#    MSVC True when using Microsoft Visual C
#    MSVC_VERSION The version of Microsoft Visual C/C++ being used if any
#        1200 = VS  6.0
#        1300 = VS  7.0
#        1310 = VS  7.1
#        1400 = VS  8.0
#        1500 = VS  9.0
#        1600 = VS 10.0
#        1700 = VS 11.0
#        1800 = VS 12.0
#        1900 = VS 14.0
#
#   CMAKE_CL_64 Using the 64 bit compiler from Microsoft
#
#
# The logic used in CMake for CMAKE_MSVC_ARCH is:
#
#      IF(CMAKE_CL_64)
#        IF(MSVC_VERSION GREATER 1599)
#          # VS 10 and later:
#          SET(CMAKE_MSVC_ARCH x64)
#        ELSE()
#          # VS 9 and earlier:
#          SET(CMAKE_MSVC_ARCH amd64)
#        ENDIF()
#      ELSE(CMAKE_CL_64)
#        SET(CMAKE_MSVC_ARCH x86)
#      ENDIF(CMAKE_CL_64)
#
# ============================================================================
