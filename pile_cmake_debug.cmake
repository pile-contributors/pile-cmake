# ============================================================================
#
# Introduction
# ------------
#
# This file contains support CMake script for piles as described
# at http://pile-contributors.github.io
#
# ============================================================================

# ============================================================================

# Show a debug message on behalf of the  pile
#
# For the message to be actually printed PILE_SUPPORT_DEBUG
# must be set to ON and <PILE>_DEBUG_MSG
macro    (pileDebugMessage
          pile_debug_message__name
          pile_debug_message__message)

    # general switch
    if (PILE_SUPPORT_DEBUG)
        # pile-level switch
        string (TOUPPER ${pile_debug_message__name} pile_debug_message__name_u)
        if    (${pile_debug_message__name_u}_DEBUG_MSG)
            # ok, go ahead
            message (STATUS "${pile_debug_message__name_u}: ${pile_debug_message__message}")
        endif (${pile_debug_message__name_u}_DEBUG_MSG)
    endif (PILE_SUPPORT_DEBUG)

endmacro ()

# ============================================================================


# Print all variables in CMake
#
# For the variables to be actually printed PILE_SUPPORT_DEBUG
# must be ON.
#
# Arguments
#     - pattern (optional): the variables are only printed if they match this pattern
#
macro    (pilePrintVars)
    set (pile_print_vars__argn ${ARGN})

    # load optional name pattern
    set(pile_print_vars__pattern )
    if (pile_print_vars__argn)
        list(GET pile_print_vars__argn 0 pile_print_vars__pattern)
    endif()

    get_cmake_property(pile_print_vars__all_vars VARIABLES)
    if ("${pile_print_vars__pattern}" STREQUAL "")
        message(STATUS "List of all variables:")
        foreach (pile_print_vars__var_name ${pile_print_vars__all_vars})
            message(STATUS "    ${pile_print_vars__var_name}=${${pile_print_vars__var_name}}")
        endforeach()
    else ()
        cmake_policy(PUSH)
        cmake_policy(SET CMP0054 OLD)
        message(STATUS "List of variables matching ${pile_print_vars__pattern}")
        foreach (pile_print_vars__var_name ${pile_print_vars__all_vars})
            if ("${pile_print_vars__var_name}" MATCHES "${pile_print_vars__pattern}")
                message(STATUS "    ${pile_print_vars__var_name}=${${pile_print_vars__var_name}}")
            endif ()
        endforeach()
        cmake_policy(POP)
    endif ()

endmacro ()

# ============================================================================

