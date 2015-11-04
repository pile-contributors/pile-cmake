# ============================================================================
#
# Git Helpers
# ===========
#
# This file contains support CMake script for working with Windows Xp.
#
# Usage
# -----
#
# The file is included by pile_support.cmake, so all the
# user has to do to use it is to:
#
#    include(pile_support)
#
# At initialization time the script creates a file (run_edit_bin.bat)
# that can be used to edit a binary. It Takes a single argument (the path
# towards the file to edit).
# ============================================================================

IF    (MSVC)
    find_program (
              EDIT_BIN_PROG
              editbin
              #[HINTS path1 [path2 ... ENV var]]
              #[PATHS path1 [path2 ... ENV var]]
              #[PATH_SUFFIXES suffix1 [suffix2 ...]]
              DOC "editbin executable"
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

# ============================================================================

# Edit a binary file to make it compatible with Windows XP.
#
# Arguments
#     - target_name: name of the target that produces the binary.
#

macro (FixForXP
       FIX_FOR_XP__TARGET_NAME)

    cuttilesLog( "FixForXP patches ${FIX_FOR_XP__TARGET_NAME}   $<TARGET_FILE:${FIX_FOR_XP__TARGET_NAME}>")
    if (NOT EDIT_BIN_PROG)
        message (FATAL_ERROR "editbin was not found; ${FIX_FOR_XP__TARGET_NAME} cannot be patched")
    elseif (MSVC)
        add_custom_command(TARGET ${FIX_FOR_XP__TARGET_NAME}
                   POST_BUILD
                   COMMAND "${EDIT_BIN_COMMAND}" "$<TARGET_FILE:${FIX_FOR_XP__TARGET_NAME}>"
                   COMMENT "${FIX_FOR_XP__TARGET_NAME} being patched for Windows XP")
    endif ()

endmacro(FixForXP)

# ============================================================================

