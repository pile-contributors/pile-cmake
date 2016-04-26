# Only interpret ``if()`` arguments as variables or keywords when unquoted
cmake_policy(SET CMP0054 NEW)

# ============================================================================

# Set dependencies for a pile
#
# The list can be empty. Basically the macro creates a variable
# <PILE>_DEPENDENCIES and, if debugging is enabled, informs the
# user about them
macro    (pileSetDependencies
          pile_set_dependencies__name
          pile_set_dependencies__dependencies)

    string (TOUPPER ${pile_set_dependencies__name} pile_set_dependencies__name_u)

    set (${pile_set_dependencies__name_u}_DEPENDENCIES
          ${pile_set_dependencies__dependencies} CACHE STRING "piles that current pile depends on")
    if ( ${pile_set_dependencies__name_u}_DEPENDENCIES)
        pileDebugMessage (
            "${pile_set_dependencies__name}"
            "dependencies: ${pile_set_dependencies__dependencies}")
    else ()
        pileDebugMessage (
            "${pile_set_dependencies__name}"
            "no dependencies")
    endif()
endmacro ()

# ============================================================================

# Set the category for a pile
#
# The list can be empty; if there are more than one items in
# the list they are interpreted to be components of a path.
#
# A pile has a single category and multiple tags. All the
# components of the category list are added as tags.
# pileSetCategory("p1" "a;b;c") is thus interpreted like
# a/b/c/p1 by a tool looking to store the piles.
#
# The macro defines or changes <PILE>_CATEGORY
# and <PILE>_TAGS variables.
macro    (pileSetCategory
          pile_set_category__name
          pile_set_category__category)

    string (TOUPPER ${pile_set_category__name} pile_set_category__name_u)

    # set the variable for this pile
    set (${pile_set_category__name_u}_CATEGORY
          ${pile_set_category__category})
    pileDebugMessage (
        "${pile_set_category__name}"
        "category: ${pile_set_category__category}")
    list (APPEND ${pile_set_tags__name_u}_TAGS
        ${pile_set_category__category})
    list (REMOVE_DUPLICATES
        ${pile_set_tags__name_u}_TAGS)

endmacro ()

# ============================================================================

# Set tags for a pile
#
# The list can be empty.
#
# The macro defines or changes <PILE>_TAGS variable.
macro    (pileSetTags
          pile_set_tags__name
          pile_set_tags__tags)

    string (TOUPPER ${pile_set_tags__name} pile_set_tags__name_u)
    list (APPEND ${pile_set_tags__name_u}_TAGS
        ${pile_set_tags__tags})
    list (REMOVE_DUPLICATES
        ${pile_set_tags__name_u}_TAGS  )
    pileDebugMessage (
        "${pile_set_tags__name}"
        "tags: ${pile_set_tags__tags}")
endmacro ()

# ============================================================================

# Set the version for a pile
#
# The list should contain major, minor and patch components.
#
# The macro defines or changes
#		<PILE>_MAJOR_VERSION
#		<PILE>_MINOR_VERSION
#		<PILE>_PATCH_VERSION
#		<PILE>_VERSION_STRING
#		<PILE>_DEBUG and <PILE>_RELEASE
macro    (pileSetVersion
          pile_set_version__name
          pile_set_version__value)

    string (TOUPPER
        ${pile_set_version__name}
        pile_set_version__name_u)

    # input may not be a variable name and LIST expects one
    set (pile_set_version__value_var "${pile_set_version__value}")
    list (GET pile_set_version__value_var 0
        ${pile_set_version__name_u}_MAJOR_VERSION)
    list (GET pile_set_version__value_var 1
        ${pile_set_version__name_u}_MINOR_VERSION)
    list (GET pile_set_version__value_var 2
        ${pile_set_version__name_u}_PATCH_VERSION)
    list (GET pile_set_version__value_var 3
        pile_set_version__debug_decider)
    set (${pile_set_version__name_u}_VERSION_STRING
            "${${pile_set_version__name_u}_MAJOR_VERSION}.${${pile_set_version__name_u}_MINOR_VERSION}.${${pile_set_version__name_u}_PATCH_VERSION}")

    string(TIMESTAMP
        ${pile_set_version__name_u}_BUILD_TIME
        UTC)

    pileDebugMessage (
        "${pile_set_version__name}"
        "version: ${${pile_set_version__name_u}_VERSION_STRING} build on: ${${pile_set_version__name_u}_BUILD_TIME}")

    if (pile_set_version__debug_decider)
        string (TOLOWER
            "${pile_set_version__debug_decider}"
            pile_set_version__debug_decider)
        if (${pile_set_version__debug_decider} STREQUAL "d")
            set (${pile_set_version__name_u}_DEBUG ON)
            set (${pile_set_version__name_u}_RELEASE OFF)
        elseif (${pile_set_version__debug_decider} STREQUAL "dbg")
            set (${pile_set_version__name_u}_DEBUG ON)
            set (${pile_set_version__name_u}_RELEASE OFF)
        elseif (${pile_set_version__debug_decider} STREQUAL "debug")
            set (${pile_set_version__name_u}_DEBUG ON)
            set (${pile_set_version__name_u}_RELEASE OFF)
        else()
            set (${pile_set_version__name_u}_DEBUG ON)
            set (${pile_set_version__name_u}_RELEASE OFF)
        endif()
    else ()
        set (${pile_set_version__name_u}_DEBUG OFF)
        set (${pile_set_version__name_u}_RELEASE ON)
    endif()



endmacro ()

# ============================================================================

# Set the mode
macro    (pileCreateLib
          pile_create_lib__name
          pile_create_lib__kind)

    string (TOUPPER
        ${pile_create_lib__name}
        pile_create_lib__name_u)
    string (TOLOWER
        ${pile_create_lib__name}
        pile_create_lib__name_l)

    add_library(
        "${${pile_create_lib__name_u}_LIBRARY}" ${pile_create_lib__kind}
        ${${pile_create_lib__name_u}_HEADERS}
        ${${pile_create_lib__name_u}_SOURCES})

    pileDebugMessage (
        "${pile_create_lib__name}"
        "library: ${${pile_create_lib__name_u}_LIBRARY}")

    if (${pile_create_lib__name_u}_QT_MODS)
        qt5_use_modules(
            "${${pile_create_lib__name_u}_LIBRARY}"
            ${${pile_create_lib__name_u}_QT_MODS})
        pileDebugMessage (
            "${pile_create_lib__name}"
            "library Qt dependencies: ${${pile_create_lib__name_u}_QT_MODS}")
    endif ()

    set (pile_create_lib__libs )
    foreach(pile_create_lib__dep_pile ${${pile_create_lib__name_u}_DEPENDENCIES})
        string (TOUPPER
            ${pile_create_lib__dep_pile}
            pile_create_lib__dep_pile_u)
        pileDebugMessage (
            "${pile_create_lib__name}"
            "Is ${pile_create_lib__dep_pile} a library?")
        if (${pile_create_lib__dep_pile_u}_LIBRARY)
            list(APPEND pile_create_lib__libs ${${pile_create_lib__dep_pile_u}_LIBRARY})
        endif ()
    endforeach()

    pileDebugMessage (
        "${pile_create_lib__name}"
        "library pile dependencies: ${pile_create_lib__libs}")

    if (pile_create_lib__libs)
        target_link_libraries(
            "${${pile_create_lib__name_u}_LIBRARY}"
            ${pile_create_lib__libs})
    endif()

endmacro ()

# ============================================================================

# Set the mode
macro    (pileSetMode
          pile_set_mode__name
          pile_set_mode__mode)

    string (TOUPPER
        ${pile_set_mode__name}
        pile_set_mode__name_u)
    string (TOLOWER
        ${pile_set_mode__name}
        pile_set_mode__name_l)

    if ("${pile_set_mode__mode}" STREQUAL "")
        set (${pile_set_mode__name_u}_PILE_MODE
            "PILE")
    else ()
        string (TOUPPER
            "${pile_set_mode__mode}"
            ${pile_set_mode__name_u}_PILE_MODE)
    endif()

    if ("${${pile_set_mode__name_u}_PILE_MODE}" STREQUAL "STATIC")
        set (${pile_set_mode__name_u}_STATIC ON)
        set (${pile_set_mode__name_u}_PILE   OFF)
        set (${pile_set_mode__name_u}_SHARED OFF)
        set (${pile_set_mode__name_u}_LIBRARY "${pile_set_mode__name_l}")
    elseif ("${${pile_set_mode__name_u}_PILE_MODE}" STREQUAL "PILE")
        set (${pile_set_mode__name_u}_STATIC OFF)
        set (${pile_set_mode__name_u}_PILE   ON)
        set (${pile_set_mode__name_u}_SHARED OFF)
        set (${pile_set_mode__name_u}_LIBRARY )
    elseif ("${${pile_set_mode__name_u}_PILE_MODE}" STREQUAL "PILE_SHARED")
        set (${pile_set_mode__name_u}_STATIC OFF)
        set (${pile_set_mode__name_u}_PILE   OFF)
        set (${pile_set_mode__name_u}_SHARED ON)
        set (${pile_set_mode__name_u}_LIBRARY )
    elseif ("${${pile_set_mode__name_u}_PILE_MODE}" STREQUAL "SHARED")
        set (${pile_set_mode__name_u}_STATIC OFF)
        set (${pile_set_mode__name_u}_PILE   OFF)
        set (${pile_set_mode__name_u}_SHARED ON)
        set (${pile_set_mode__name_u}_LIBRARY "${pile_set_mode__name_l}")
    else ()
        message (FATAL_ERROR "${pile_set_mode__name}: Unknown pile mode - ${${pile_set_mode__name_u}_PILE_MODE}")
    endif ()
    set (${pile_set_mode__name_u}_LIBRARY
        ${${pile_set_mode__name_u}_LIBRARY}
        CACHE INTERNAL "${${pile_set_mode__name_u}_LIBRARY} pile"
        FORCE)

    pileDebugMessage (
        "${pile_set_mode__name}"
        "pile mode: ${${pile_set_mode__name_u}_PILE_MODE}")
    pileDebugMessage (
        "${pile_set_mode__name}"
        "pile library: ${${pile_set_mode__name_u}_LIBRARY}")

    if (${pile_set_mode__name_u}_STATIC)
        pileCreateLib (${pile_set_mode__name} STATIC)
        #        add_library(
        #            "${${pile_set_mode__name_u}_LIBRARY}" STATIC
        #            ${${pile_set_mode__name_u}_HEADERS}
        #            ${${pile_set_mode__name_u}_SOURCES})
        #        if (${pile_set_mode__name_u}_QT_MODS)
        #            qt5_use_modules(
        #                "${${pile_set_mode__name_u}_LIBRARY}"
        #                ${${pile_set_mode__name_u}_QT_MODS})
        #        endif ()
    elseif (${pile_set_mode__name_u}_SHARED)
        if (NOT "${${pile_set_mode__name_u}_PILE_MODE}" STREQUAL "PILE_SHARED")
            pileCreateLib (${pile_set_mode__name} SHARED)
            #            add_library(
            #                "${${pile_set_mode__name_u}_LIBRARY}" SHARED
            #                ${${pile_set_mode__name_u}_HEADERS}
            #                ${${pile_set_mode__name_u}_SOURCES})
            #            if (${pile_set_mode__name_u}_QT_MODS)
            #                qt5_use_modules(
            #                    "${${pile_set_mode__name_u}_LIBRARY}"
            #                    ${${pile_set_mode__name_u}_QT_MODS})
            #            endif ()
        endif ()
        add_definitions(-D${pile_set_mode__name_u}_SHARED)
    endif ()

endmacro ()

# ============================================================================

# Prepare a config file
#
macro    (pileConfigFile
          pile_config_file__name)

    string (TOUPPER
        ${pile_config_file__name}
        pile_config_file__name_u)
    string (TOLOWER
        ${pile_config_file__name}
        pile_config_file__name_l)

    if (NOT ${pile_config_file__name_u}_BINARY_DIR)
        message (FATAL_ERROR "${pile_config_file__name_u}_BINARY_DIR must be set before calling pileConfigFile(), for example by calling pileInclude()")
    endif()
    if (NOT ${pile_config_file__name_u}_SOURCE_DIR)
        message (FATAL_ERROR "${pile_config_file__name_u}_SOURCE_DIR must be set before calling pileConfigFile(), for example by calling pileInclude()")
    endif()

    # create a configuration file for the project
    set (${pile_config_file__name_u}_CONFIG_FILE
        "${${pile_config_file__name_u}_BINARY_DIR}/${pile_config_file__name_l}-config.h")
    set (${pile_config_file__name_u}_CONFIG_FILE_IN
        "${${pile_config_file__name_u}_SOURCE_DIR}/${pile_config_file__name_l}-config.h.in")

    configure_file (
        "${${pile_config_file__name_u}_CONFIG_FILE_IN}"
        "${${pile_config_file__name_u}_CONFIG_FILE}")
    include_directories (${${pile_config_file__name_u}_BINARY_DIR})

    list (APPEND
        ${pile_set_sources__name_u}_HEADERS
        "${${pile_set_sources__name_u}_CONFIG_FILE}")
    list (REMOVE_DUPLICATES
        ${pile_set_sources__name_u}_HEADERS)

    pileDebugMessage (
        "${pile_config_file__name}"
        "config file template: ${${pile_config_file__name_u}_CONFIG_FILE_IN}")
    pileDebugMessage (
        "${pile_config_file__name}"
        "config file: ${${pile_config_file__name_u}_CONFIG_FILE}")

endmacro ()

# ============================================================================

# Set the list of sources
#
macro    (pileSetSources
          pile_set_sources__name
          pile_set_sources__headers
          pile_set_sources__sources)

    set (pile_set_sources__argn ${ARGN})

    # load optional name pattern
    unset(pile_set_sources__uis)
    if (pile_set_sources__argn)
        set(pile_set_sources__uis ${pile_set_sources__argn})
    endif()

    string (TOUPPER
        "${pile_set_sources__name}"
        pile_set_sources__name_u)
    string (TOLOWER
        "${pile_set_sources__name}"
        pile_set_sources__name_l)

    set (pile_set_sources__hdr "${${pile_set_sources__name_u}_CONFIG_FILE}")
    foreach(pile_set_sources__iter ${pile_set_sources__headers})
        list (APPEND
            pile_set_sources__hdr
            "${${pile_set_sources__name_u}_SOURCE_DIR}/${pile_set_sources__iter}")
    endforeach()
    if (pile_set_sources__hdr)
        list (REMOVE_DUPLICATES pile_set_sources__hdr)
    endif()

    unset (pile_set_sources__src )
    foreach(pile_set_sources__iter ${pile_set_sources__sources})
        list (APPEND
            pile_set_sources__src
            "${${pile_set_sources__name_u}_SOURCE_DIR}/${pile_set_sources__iter}")
    endforeach()
    if (pile_set_sources__src)
        list (REMOVE_DUPLICATES pile_set_sources__src)
    endif()

    unset (pile_set_sources__ui)
    foreach(pile_set_sources__iter ${pile_set_sources__uis})
        list (APPEND
            pile_set_sources__ui
            "${${pile_set_sources__name_u}_SOURCE_DIR}/${pile_set_sources__iter}")
    endforeach()
    if (pile_set_sources__ui)
        list (REMOVE_DUPLICATES pile_set_sources__ui)
    endif()

    set (${pile_set_sources__name_u}_HEADERS
        ${pile_set_sources__hdr})
    set (${pile_set_sources__name_u}_SOURCES
        ${pile_set_sources__src})
    set (${pile_set_sources__name_u}_UIS
        ${pile_set_sources__ui})

    pileDebugMessage (
        "${pile_set_sources__name}"
        "sources: ${pile_set_sources__src}")
    pileDebugMessage (
        "${pile_set_sources__name}"
        "headers: ${pile_set_sources__hdr}")
    pileDebugMessage (
        "${pile_set_sources__name}"
        "uis: ${pile_set_sources__ui}")

endmacro ()

# ============================================================================

# Set common characteristics in one call
#
# See individual macros for variables and behavior.
macro    (pileSetCommon
          pile_set_common__name
          pile_set_common__version
          pile_set_common__config
          pile_set_common__mode
          pile_set_common__dependencies
          pile_set_common__category
          pile_set_common__tags)

    pileSetDependencies(
        "${pile_set_common__name}"
        "${pile_set_common__dependencies}")
    pileSetCategory(
        "${pile_set_common__name}"
        "${pile_set_common__category}")
    pileSetTags(
        "${pile_set_common__name}"
        "${pile_set_common__tags}")
    pileSetVersion(
        "${pile_set_common__name}"
        "${pile_set_common__version}")
    pileSetMode(
        "${pile_set_common__name}"
        "${pile_set_common__mode}")

    if ("${pile_set_common__config}")
        pileConfigFile(
            "${pile_set_common__name}")
    endif ()
endmacro ()

# ============================================================================
