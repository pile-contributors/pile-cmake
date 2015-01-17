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

# Prepares XP support (creates required precursor files)
macro (supportXpInit)

    IF    (MSVC)
        find_program (
              EDIT_BIN_PROG
              editbin
              #[HINTS path1 [path2 ... ENV var]]
              #[PATHS path1 [path2 ... ENV var]]
              #[PATH_SUFFIXES suffix1 [suffix2 ...]]
              DOC "editbin Executable"
             )

        set (EDIT_BIN_COMMAND "${PROJECT_BINARY_DIR}/run_edit_bin.bat")
        file(WRITE "${EDIT_BIN_COMMAND}"
"
@echo off
call set EDIT_BIN_EXE=${EDIT_BIN_PROG}
call set EXE_FILE=%1
call set EDIT_BIN_EXE=%%EDIT_BIN_EXE:/=\\%%
call set EXE_FILE=%%EXE_FILE:/=\\%%
%EDIT_BIN_EXE% %EXE_FILE% /SUBSYSTEM:WINDOWS,5.01 /OSVERSION:5.1
@echo on
")
    ENDIF (MSVC)
endmacro()

# ============================================================================

# Prepares XP support (creates required precursor files)
#
# Arguments
#     - target_name: name of the target for executable to patch
#
macro (fixForXP
       fix_for_xp__target_name)

    #if (${OS_VARIANT} MATCHES ".*XP.*")
        message (STATUS "pixForXP patches ${fix_for_xp__target_name}   $<TARGET_FILE:${fix_for_xp__target_name}>")
        if (NOT EDIT_BIN_PROG)
            message (WARNING "editbin was not found; ${fix_for_xp__target_name} cannot be patched")
        elseif (MSVC)
            add_custom_command(TARGET ${fix_for_xp__target_name}
                       POST_BUILD
                       COMMAND "${EDIT_BIN_COMMAND}" "$<TARGET_FILE:${fix_for_xp__target_name}>"
                       COMMENT "${fix_for_xp__target_name} being patched for Windows XP")

        endif ()
    #endif ()

endmacro()
