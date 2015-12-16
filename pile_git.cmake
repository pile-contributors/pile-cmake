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
        unset(pile_git_stamp__err)
        unset(pile_git_stamp__temp)
        execute_process(
                COMMAND ${GIT_EXECUTABLE} log -1 --pretty=%H
                WORKING_DIRECTORY ${pile_git_stamp__path}
                OUTPUT_VARIABLE   pile_git_stamp__temp
                ERROR_VARIABLE    pile_git_stamp__err
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        if (pile_git_stamp__err)
            message(WARNING "Error extracting git commit from ${pile_git_stamp__path}: ${pile_git_stamp__err}")
            set(${pile_git_stamp__commit} "error")
        else()
            STRING(REGEX REPLACE "\n" ";" pile_git_stamp__temp "${pile_git_stamp__temp}")
            STRING(REGEX REPLACE "\r" ";" pile_git_stamp__temp "${pile_git_stamp__temp}")
            list(GET pile_git_stamp__temp -1 pile_git_stamp__temp)
            string(STRIP "${pile_git_stamp__temp}" ${pile_git_stamp__commit})
        endif()

        unset(pile_git_stamp__temp)
        execute_process(
                COMMAND ${GIT_EXECUTABLE} symbolic-ref --short HEAD
                WORKING_DIRECTORY ${pile_git_stamp__path}
                OUTPUT_VARIABLE   pile_git_stamp__temp
                ERROR_VARIABLE    pile_git_stamp__err
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        if (pile_git_stamp__err)
            message(WARNING "Error extracting git branch: ${pile_git_stamp__err}")
            set(${pile_git_stamp__branch} "error")
        else()
            STRING(REGEX REPLACE "\n" ";" pile_git_stamp__temp "${pile_git_stamp__temp}")
            STRING(REGEX REPLACE "\r" ";" pile_git_stamp__temp "${pile_git_stamp__temp}")
            list(GET pile_git_stamp__temp -1 pile_git_stamp__temp)
            string(STRIP "${pile_git_stamp__temp}" ${pile_git_stamp__branch})
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
    unset (pile_git_stamp_header__branch )
    unset (pile_git_stamp_header__commit )
    pileGitStamp(${pile_git_stamp_header__path}
        pile_git_stamp_header__commit
        pile_git_stamp_header__branch)

    file(WRITE "${pile_git_stamp_header__out}"
"${pile_git_stamp_header__header}

#ifndef SOURCE_CODE_GIT_HASH
#   define SOURCE_CODE_GIT_HASH \"${pile_git_stamp_header__commit}\"
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
          pile_git_stamp_header_check__footer
          pile_git_stamp_header_check__prefix)

    unset (pile_git_stamp_header_check__branch )
    unset (pile_git_stamp_header_check__commit )
    pileGitStamp(${pile_git_stamp_header_check__path}
        pile_git_stamp_header_check__commit
        pile_git_stamp_header_check__branch)


    set (pile_git_stamp_header_check__intermed
        "${CMAKE_CURRENT_BINARY_DIR}/git_info.h.in")
    if(NOT EXISTS ${pile_git_stamp_header_check__intermed})
        file(WRITE "${pile_git_stamp_header_check__intermed}"
"${pile_git_stamp_header_check__header}

#ifndef ${pile_git_stamp_header_check__prefix}_SOURCE_CODE_GIT_HASH
#   define ${pile_git_stamp_header_check__prefix}_SOURCE_CODE_GIT_HASH \"@${pile_git_stamp_header_check__prefix}_SOURCE_CODE_GIT_HASH@\"
#endif // ${pile_git_stamp_header_check__prefix}_SOURCE_CODE_GIT_HASH

#ifndef ${pile_git_stamp_header_check__prefix}_SOURCE_CODE_GIT_BRANCH
#   define ${pile_git_stamp_header_check__prefix}_SOURCE_CODE_GIT_BRANCH @${pile_git_stamp_header_check__prefix}_SOURCE_CODE_GIT_BRANCH@
#endif // ${pile_git_stamp_header_check__prefix}_SOURCE_CODE_GIT_BRANCH

${pile_git_stamp_header_check__footer}
")
    endif()

    set (${pile_git_stamp_header_check__prefix}_SOURCE_CODE_GIT_HASH "${pile_git_stamp_header_check__commit}"
         CACHE STRING "Git hash of source code for ${pile_git_stamp_header_check__prefix}" FORCE)
    set (${pile_git_stamp_header_check__prefix}_SOURCE_CODE_GIT_BRANCH "${pile_git_stamp_header_check__branch}"
         CACHE STRING "Git branch of source code for ${pile_git_stamp_header_check__prefix}" FORCE)

    unset(pile_git_stamp_header_check__commit)
    unset(pile_git_stamp_header_check__branch)

    configure_file(
        "${pile_git_stamp_header_check__intermed}"
        "${pile_git_stamp_header_check__out}"
       @ONLY)

endmacro ()

# ============================================================================


