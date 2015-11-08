
# ============================================================================
set(PILE_CALL_BY_NAME_COUNTER 0 CACHE STRING "unique names for pileCallByName files")

# Allows one to call a macro using a dynamically generated name
macro    (pileCallByName
          pile_includecall__macro_name)
    set (pile_include__argn ${ARGN})
    string (TIMESTAMP pile_include__tstamp "%Y%m%d-%H%M%S" UTC)
    unset(pile_include__file)
    file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/macro_helpers")
    set(pile_include__file "${CMAKE_BINARY_DIR}/macro_helpers/${pile_includecall__macro_name}_${pile_include__tstamp}-${PILE_CALL_BY_NAME_COUNTER}.cmake")
    MATH(EXPR PILE_CALL_BY_NAME_COUNTER "${PILE_CALL_BY_NAME_COUNTER}+1")
    set(PILE_CALL_BY_NAME_COUNTER "${PILE_CALL_BY_NAME_COUNTER}" CACHE STRING "unique names for pileCallByName files" FORCE)
    unset(pile_include__tstamp)
    file(WRITE "${pile_include__file}" "${pile_includecall__macro_name}(${pile_include__argn})")
    include("${pile_include__file}")
    unset(pile_include__file)
    unset(pile_include__argn)
endmacro ()

# ============================================================================
