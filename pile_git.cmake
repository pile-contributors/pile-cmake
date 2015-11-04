# ============================================================================
#
# Git Helpers
# ===========
#
# This file contains support CMake script for working with git.
#
# Usage
# -----
#
# The file is included by pile_support.cmake, so all the
# user has to do to use it is to:
#
#    include(pile_support)
#
# ============================================================================
find_package(Git)

# ============================================================================

# Get git commit and branch.
#
# Arguments
#     - path: full path to the file to generate
#     - commit (output variable): resulted commit
#     - branch (output variable): resulted branch
#
# An error is generated if the path is not part of a git repository.
#
macro    (pileGitStamp
          pile_git_stamp__path
          pile_git_stamp__commit
          pile_git_stamp__branch)

    set(pile_git_stamp__describe_build )
    set(pile_git_stamp__err )
    if(GIT_FOUND)

        execute_process(
                COMMAND ${GIT_EXECUTABLE} log -1 --pretty=%H
                WORKING_DIRECTORY ${pile_git_stamp__path}
                OUTPUT_VARIABLE   ${pile_git_stamp__commit}
                ERROR_VARIABLE pile_git_stamp__err
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        if (pile_git_stamp__err)
            message(WARNING "Error extracting git commit from ${pile_git_stamp__path}: ${pile_git_stamp__err}")
            set(${pile_git_stamp__commit} "error")
        endif()

        execute_process(
                COMMAND ${GIT_EXECUTABLE} symbolic-ref --short HEAD
                WORKING_DIRECTORY ${pile_git_stamp__path}
                OUTPUT_VARIABLE   ${pile_git_stamp__branch}
                ERROR_VARIABLE pile_git_stamp__err
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        if (pile_git_stamp__err)
            message(WARNING "Error extracting git branch: ${pile_git_stamp__err}")
            set(${pile_git_stamp__branch} "error")
        endif()

    else()
        set(${pile_git_stamp__commit} "git not found")
        set(${pile_git_stamp__branch} "git not found")
    endif()

endmacro ()

# ============================================================================

# Generates a C header file containing git commit and branch as defines.
#
# Arguments
#     - path: full path to the git repository
#     - out: full path to the file to generate
#     - header (optional): text to add before the definition
#     - footer (optional): text to add after the definition
#
macro    (pileGitStampHeader
          pile_git_stamp_header__path
          pile_git_stamp_header__out
          pile_git_stamp_header__header
          pile_git_stamp_header__footer)

    # get the info from git
    set (pile_git_stamp_header__branch )
    set (pile_git_stamp_header__commit )
    pileGitStamp(${pile_git_stamp_header__path}
        pile_git_stamp_header__branch
        pile_git_stamp_header__commit)

    file(WRITE "${pile_git_stamp_header__out}"
"${pile_git_stamp_header__header}

#ifndef SOURCE_CODE_GIT_HASH
#   define SOURCE_CODE_GIT_HASH ${pile_git_stamp_header__commit}
#endif // SOURCE_CODE_GIT_HASH

#ifndef SOURCE_CODE_GIT_BRANCH
#   define SOURCE_CODE_GIT_BRANCH ${pile_git_stamp_header__branch}
#endif // SOURCE_CODE_GIT_BRANCH

${pile_git_stamp_header__footer}
")

endmacro ()

# ============================================================================

# Generates a C header file containing git commit and branch as defines.
#
# Arguments
#     - path: full path to the git repository
#     - out: full path to the file to generate
#     - header (optional): text to add before the definition
#     - footer (optional): text to add after the definition
#
# If the file already exists, its content is inspected to see if an update is
# required.
macro    (pileGitStampHeaderCheck
          pile_git_stamp_header_check__path
          pile_git_stamp_header_check__out
          pile_git_stamp_header_check__header
          pile_git_stamp_header_check__footer)

    set (pile_git_stamp_header_check__branch )
    set (pile_git_stamp_header_check__commit )
    pileGitStamp(${pile_git_stamp_header_check__path}
        pile_git_stamp_header_check__branch
        pile_git_stamp_header_check__commit)

    set (pile_git_stamp_header_check__intermed
        "${CMAKE_CURRENT_BINARY_DIR}/git_info.h.in")
    if(NOT EXISTS ${pile_git_stamp_header_check__intermed})
        file(WRITE "${pile_git_stamp_header_check__intermed}"
"${pile_git_stamp_header_check__header}

#ifndef SOURCE_CODE_GIT_HASH
#   define SOURCE_CODE_GIT_HASH @SOURCE_CODE_GIT_HASH@
#endif // SOURCE_CODE_GIT_HASH

#ifndef SOURCE_CODE_GIT_BRANCH
#   define SOURCE_CODE_GIT_BRANCH @SOURCE_CODE_GIT_BRANCH@
#endif // SOURCE_CODE_GIT_BRANCH

${pile_git_stamp_header_check__footer}
")
    endif()

    configure_file(
        "${pile_git_stamp_header_check__intermed}"
        "${pile_git_stamp_header_check__out}"
       @ONLY)

endmacro ()

# ============================================================================


