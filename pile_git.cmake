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

    # TODO
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
          pile_git_stamp_header__path)

    # TODO

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
          pile_git_stamp_header_check__path)

    # TODO

endmacro ()

# ============================================================================


