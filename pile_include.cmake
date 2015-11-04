
include (pile_cmake_style_path)

# ============================================================================

# Includes a pile .cmake file but does not initialize the pile
# 
# Path can be provided as optional arguments after the name.
# If path is provided it can be absolute or relative to CMAKE_SOURCE_DIR.
# If path is not provided then "${CMAKE_SOURCE_DIR}/name" and
# "${CMAKE_SOURCE_DIR}/name-src" are tried.
#
# Defines following variables:
#     <PILE>_NAME: the name with all-lower-case letters
#     <PILE>_NAME_U: the name with all-UPPER-case letters
#     <PILE>_NAME_C: the name as provided (should be CamelCase)
#     <PILE>_SOURCE_DIR: the path where this pile is stored (not including /cmake)
#     <PILE>_BINARY_DIR: the path where this pile generates output
#
# By using this function the top level cmake file does not have to
# alter CMAKE_MODULE_PATH itself.
macro    (pileInclude
          pile_include__name_camel_case)
    set (pile_include__argn ${ARGN})

    # load optional path argument
    set(pile_include__path )
    if (pile_include__argn)
        list(GET pile_include__argn 0 pile_include__path)
    endif()

    # compute upper and lover case variants
    string (TOUPPER ${pile_include__name_camel_case} pile_include__name_u)
    string (TOLOWER ${pile_include__name_camel_case} pile_include__name_l)
    
    # define some variables related to the name
    set (${pile_include__name_u}_NAME "${pile_include__name_l}" CACHE STRING "name with all-lower-case letters")
    set (${pile_include__name_u}_NAME_U "${pile_include__name_u}" CACHE STRING "name with all-UPPER-case letters")
    set (${pile_include__name_u}_NAME_C "${pile_include__name_camel_case}" CACHE STRING "the name as provided (should be CamelCase)")
    
    # locate the path
    find_path ( ${pile_include__name_u}_SOURCE_DIR
		NAME
			"${pile_include__name_l}.cmake"
			"${pile_include__name_camel_case}.cmake"
        PATHS
            ${pile_include__path}
            "${CMAKE_CURRENT_SOURCE_DIR}/${pile_include__path}"
            "${CMAKE_CURRENT_SOURCE_DIR}/${pile_include__name_l}"
            "${CMAKE_CURRENT_SOURCE_DIR}/${pile_include__name_l}-src"
            "${CMAKE_SOURCE_DIR}/${pile_include__path}"
            "${CMAKE_SOURCE_DIR}/${pile_include__name_l}"
            "${CMAKE_SOURCE_DIR}/${pile_include__name_l}-src"
        PATH_SUFFIXES "cmake"
        DOC "Path to ${pile_include__name_camel_case} pile"
        NO_DEFAULT_PATH)
	
	# be verbose about it
    if (NOT ${pile_include__name_u}_SOURCE_DIR)
        message (FATAL_ERROR "Pile ${pile_include__name_camel_case} could not be found")
    else ()
		pileDebugMessage (
			"${pile_include__name_camel_case} "
			"path for pile ${pile_include__name_camel_case}: ${${pile_include__name_u}_PATH}")
    endif ()
	
	# make sure cmake finds it
	list (APPEND CMAKE_MODULE_PATH 
		"${${pile_include__name_u}_SOURCE_DIR}/")
    list (REMOVE_DUPLICATES 
        CMAKE_MODULE_PATH)

	# save the path to the pile
	string (REGEX REPLACE 
		"[/\\]cmake$"
		"" 
		${pile_include__name_u}_SOURCE_DIR 
		"${${pile_include__name_u}_SOURCE_DIR}")
    
	pileCmakeOutputPath (
		${pile_include__name_u}_BINARY_DIR
		"${${pile_include__name_u}_SOURCE_DIR}")
    set (${pile_include__name_u}_BINARY_DIR "${${pile_include__name_u}_BINARY_DIR}" CACHE STRING "path where this pile generates output")


    # include the actual pile code
    include (${pile_include__name_l})
	
    pileDebugMessage (
		"${pile_include__name_camel_case}"
        "source dir: ${${pile_include__name_u}_SOURCE_DIR}")
	
    pileDebugMessage (
		"${pile_include__name_camel_case}"
        "binary dir: ${${pile_include__name_u}_BINARY_DIR}")
	
    pileDebugMessage (
		"${pile_include__name_camel_case}"
        "including pile ${pile_include__name_camel_case} / ${pile_include__name_u} / ${pile_include__name_l} / ${pile_include__path}")
    
endmacro ()

# ============================================================================
