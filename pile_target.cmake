# ============================================================================
#
# Target Helpers
# ==============
#
# This file contains support CMake script for targets.
#
# Usage
# -----
#
# The file is included by pile_support.cmake, so all the
# user has to do to use it is to:
#
#    include(pile_support)
#
# The purpose is to abstract away complex but repetitive statements from
# target specific CMakeLists.txt file.
#
# In the target file start with
#
#   pileTarget( "example")
#
# then fill the lists mentioned in `pileTarget` macro, then en with
#
#   pileEndTarget( "example" "exe")
#
# to create an executable target.
#
# ============================================================================

# ============================================================================

# Prepares a target for being constructed
#
# The macro defines or changes
#        <PILE>_SOURCES: the list of source files
#        <PILE>_HEADERS: the list of headers
#        <PILE>_UIS: the list of UI files
#        <PILE>_RES: the list of resource files
#        <PILE>_DLLS: the list of .dll libraries that should be included in package
#        <PILE>_LIBRARIES: the list of libraries to link against
#        <PILE>_QT_MODS: the list of Qt modules to link against
#        <PILE>_TARGET: the actual name of the target
macro    (pileTarget
          pile_target__name)
    set(pile_target__argn ${ARGN})

    string (TOUPPER "${pile_target__name}" pile_target__name_u)
    string (TOLOWER "${pile_target__name}" pile_target__name_l)

    set(pile_target__gui_app OFF)
    if (pile_target__argn)
        list(GET pile_target__argn 0 pile_target__gui_app)
        if("${pile_target__gui_app}" STREQUAL "GUI")
            set(pile_target__gui_app ON)
        endif()
    endif()

    # prepare variables
    set( ${pile_target__name_u}_INCLUDES )
    set( ${pile_target__name_u}_SOURCES )
    set( ${pile_target__name_u}_HEADERS )
    set( ${pile_target__name_u}_UIS )
    set( ${pile_target__name_u}_RES )
    set( ${pile_target__name_u}_DLLS )
    set( ${pile_target__name_u}_LIBRARIES )
    set( ${pile_target__name_u}_QT_MODS )
    set( ${pile_target__name_u}_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")

    # name of the target
    set( ${pile_target__name_u}_TARGET "${pile_target__name_l}")

    unset(THIS_TARGET)
    set(THIS_TARGET "${pile_target__name}")
    unset(THIS_TARGET_PILES)

    if (${pile_target__gui_app})
        set( ${pile_target__name_u}_GUI_FLAG "WIN32")
    endif()
endmacro ()

# ============================================================================

# Constructs the target based on the provided options
#
# Arguments
#     - name: the user name for the target
#     - kind: either "exe", "shared" or "static"
#     - copy_headers (optional): ON or COPY to copy the headers to output
#       directory for headers (uses pileCreateCopyTargetTarget)
#
# The macro defines or changes
#        <PILE>_UIS_SRC: the list of source files generated from <PILE>_UIS
#        <PILE>_RES_SRC: the list of source files generated from <PILE>_RES
macro    (pileEndTarget
          pile_end_target__name
          pile_end_target__kind)
    set(pile_end_target__argn ${ARGN})

    unset(pile_end_target__copy_headers)
    if (pile_end_target__argn)
        list(GET pile_end_target__argn 0 pile_end_target__copy_headers)
        if("${pile_end_target__copy_headers}" STREQUAL "COPY")
            set(pile_end_target__copy_headers ON)
        endif()
    endif()

    string (TOUPPER "${pile_end_target__name}" pile_end_target__name_u)
    string (TOLOWER "${pile_end_target__name}" pile_end_target__name_l)

    # expand uis
    unset(${pile_end_target__name_u}_UIS_SRC)
    if (${pile_end_target__name_u}_UIS)
        qt5_wrap_ui (${pile_end_target__name_u}_UIS_SRC
            ${${pile_end_target__name_u}_UIS})
    endif ()

    # expand resources
    unset(${pile_end_target__name_u}_RES_SRC)
    if (${pile_end_target__name_u}_RES)
        qt5_add_resources( ${pile_end_target__name_u}_RES_SRC
            ${${pile_end_target__name_u}_RES})
    endif ()

    # make sure all paths are absolute
    unset(pile_end_target__temp_list )
    if (${pile_end_target__name_u}_HEADERS)
        foreach(pile_end_target__iter ${${pile_end_target__name_u}_HEADERS})
            if (NOT IS_ABSOLUTE "${pile_end_target__iter}")
                get_filename_component(
                    pile_end_target__iter
                    "${pile_end_target__iter}"
                    ABSOLUTE)
            endif()
            list (APPEND pile_end_target__temp_list
                "${pile_end_target__iter}")
        endforeach()
        set (${pile_end_target__name_u}_HEADERS
            ${pile_end_target__temp_list})
    endif()

    # install components
    if (NOT ${pile_end_target__name_u}_COMP_BIN)
        set(${pile_end_target__name_u}_COMP_BIN "applications")
    endif()
    if (NOT ${pile_end_target__name_u}_COMP_ARCH)
        set(${pile_end_target__name_u}_COMP_ARCH "archives")
    endif()
    if (NOT ${pile_end_target__name_u}_COMP_LIB)
        set(${pile_end_target__name_u}_COMP_LIB "applications")
    endif()
    if (NOT ${pile_end_target__name_u}_COMP_INC)
        set(${pile_end_target__name_u}_COMP_INC "headers")
    endif()


    # remove duplicates from lists
    if (${pile_end_target__name_u}_SOURCES)
        list(REMOVE_DUPLICATES ${pile_end_target__name_u}_SOURCES)
    endif()
    if (${pile_end_target__name_u}_HEADERS)
        list(REMOVE_DUPLICATES ${pile_end_target__name_u}_HEADERS)
    endif()
    if (${pile_end_target__name_u}_DLLS)
        list(REMOVE_DUPLICATES ${pile_end_target__name_u}_DLLS)
    endif()
    if (${pile_end_target__name_u}_LIBRARIES)
        list(REMOVE_DUPLICATES ${pile_end_target__name_u}_LIBRARIES)
    endif()
    if (${pile_end_target__name_u}_QT_MODS)
        list(REMOVE_DUPLICATES ${pile_end_target__name_u}_QT_MODS)
    endif()
    if (${pile_end_target__name_u}_INCLUDES)
        list(REMOVE_DUPLICATES ${pile_end_target__name_u}_INCLUDES)
        include_directories(${${pile_end_target__name_u}_INCLUDES})
    endif()


    # all sources used to build the target
    set( ${pile_end_target__name_u}_ALL_SRCS
            ${${pile_end_target__name_u}_SOURCES}
            ${${pile_end_target__name_u}_UIS_SRC}
            ${${pile_end_target__name_u}_RES_SRC}
            ${${pile_end_target__name_u}_HEADERS})

    # create appropriate target type
    if ("${pile_end_target__kind}" STREQUAL "exe")
        add_executable("${${pile_end_target__name_u}_TARGET}" ${${pile_end_target__name_u}_GUI_FLAG}
            ${${pile_end_target__name_u}_ALL_SRCS})
        if (WIN32)
            if(EXISTS "${EXECUTABLE_OUTPUT_PATH}/${${pile_end_target__name_u}_TARGET}.exe.manifest")
            install(
                FILES "${EXECUTABLE_OUTPUT_PATH}/${${pile_end_target__name_u}_TARGET}.exe.manifest"
                DESTINATION bin
                COMPONENT ${${pile_end_target__name_u}_COMP_BIN})
            endif()
        endif()
        pileSignBinary("${${pile_end_target__name_u}_TARGET}")
    elseif ("${pile_end_target__kind}" STREQUAL "shared")
        add_library("${${pile_end_target__name_u}_TARGET}" SHARED
            ${${pile_end_target__name_u}_ALL_SRCS})
        pileSignBinary("${${pile_end_target__name_u}_TARGET}")
    else ()
        add_library("${${pile_end_target__name_u}_TARGET}" STATIC
            ${${pile_end_target__name_u}_ALL_SRCS})
    endif()

    # link libraries
    if (${pile_end_target__name_u}_LIBRARIES)
        target_link_libraries( ${${pile_end_target__name_u}_TARGET}
            ${${pile_end_target__name_u}_LIBRARIES})
    endif()
    # message(STATUS "${pile_end_target__name_u}_TARGET    = ${${pile_end_target__name_u}_TARGET}")
    # message(STATUS "${pile_end_target__name_u}_LIBRARIES = ${${pile_end_target__name_u}_LIBRARIES}")

    # install dlls
    if (${pile_end_target__name_u}_DLLS)
        # add modules to list of files to be installed
        unset(local_dep_list)
        set (local_dep_list
            ${PILE_PROJECT_DEP_LIBRARIES}
            ${${pile_end_target__name_u}_DLLS} )
        set (PILE_PROJECT_DEP_LIBRARIES ${local_dep_list}
             CACHE INTERNAL "The list of dlls to install and package" FORCE)
    endif()
    # message (STATUS "${pile_end_target__name_u}_DLLS = ${${pile_end_target__name_u}_DLLS}")
    # message (STATUS "PILE_PROJECT_DEP_LIBRARIES = ${PILE_PROJECT_DEP_LIBRARIES}")

    # link / use Qt modules
    if (${pile_end_target__name_u}_QT_MODS)
        qt5_use_modules( ${${pile_end_target__name_u}_TARGET}
            ${${pile_end_target__name_u}_QT_MODS})

        # add modules to list of files to be installed
        unset(local_dep_list)
        set (local_dep_list
            ${PILE_PROJECT_DEP_LIBRARIES}
            ${${pile_end_target__name_u}_QT_MODS} )
        set (PILE_PROJECT_DEP_LIBRARIES ${local_dep_list}
             CACHE INTERNAL "The list of dlls to install and package" FORCE)

        # see if there are some plug-ins we also want
        unset(local_dep_list)
        set (local_dep_list ${PILE_PROJECT_QT_PLUGINS})
        foreach(qt_mod ${${pile_end_target__name_u}_QT_MODS})
            string(TOLOWER "${qt_mod}" qt_mod_std)
            if (qt_mod_std STREQUAL "printsupport")
                if (TARGET_SYSTEM_WIN32)
                    list(APPEND local_dep_list "printsupport/windowsprintersupport")
                endif()
            endif()
            unset(qt_mod_std)
        endforeach()

        set (PILE_PROJECT_QT_PLUGINS ${local_dep_list}
             CACHE INTERNAL "The list of Qt plug-ins to install and package" FORCE)
    endif()

    # what to install where
    if (NOT ${pile_end_target__name_u}_INSTALL_LIB)
        set (${pile_end_target__name_u}_INSTALL_LIB lib)
    endif()
    if (NOT ${pile_end_target__name_u}_INSTALL_ARCH)
        set (${pile_end_target__name_u}_INSTALL_ARCH lib)
    endif()
    if (NOT ${pile_end_target__name_u}_INSTALL_BIN)
        set (${pile_end_target__name_u}_INSTALL_BIN bin)
    endif()
    if (NOT ${pile_end_target__name_u}_INSTALL_INC)
        set (${pile_end_target__name_u}_INSTALL_INC include)
    endif()


    # message(STATUS "bin component of target ${pile_end_target__name_u} is ${${pile_end_target__name_u}_COMP_BIN}")
    # message(STATUS "arch component of target ${pile_end_target__name_u} is ${${pile_end_target__name_u}_COMP_ARCH}")
    # message(STATUS "lib component of target ${pile_end_target__name_u} is ${${pile_end_target__name_u}_COMP_LIB}")
    # message(STATUS "inc component of target ${pile_end_target__name_u} is ${${pile_end_target__name_u}_COMP_INC}")


    install(
        TARGETS "${${pile_end_target__name_u}_TARGET}"
        ARCHIVE
            DESTINATION ${${pile_end_target__name_u}_INSTALL_ARCH}
            COMPONENT ${${pile_end_target__name_u}_COMP_ARCH}
        LIBRARY
            DESTINATION ${${pile_end_target__name_u}_INSTALL_LIB}
            COMPONENT ${${pile_end_target__name_u}_COMP_LIB}
        RUNTIME
            DESTINATION ${${pile_end_target__name_u}_INSTALL_BIN}
            COMPONENT ${${pile_end_target__name_u}_COMP_BIN})

    if (${pile_end_target__name_u}_HEADERS)
        install(
            FILES ${${pile_end_target__name_u}_HEADERS}
            DESTINATION ${${pile_end_target__name_u}_INSTALL_INC}
            COMPONENT ${${pile_end_target__name_u}_COMP_INC})
        if (pile_end_target__copy_headers)
            pileCreateCopyTargetTarget("${pile_end_target__name}")
            add_dependencies(
                "${${pile_end_target__name_u}_TARGET}"
                "copy_${pile_end_target__name_l}_headers")
        else()
            unset(pile_iter)
            foreach(pile_iter ${THIS_TARGET_PILES})
                unset(pile_lower)
                string(TOLOWER  "${pile_iter}" pile_lower)
                add_dependencies(
                    "${${pile_end_target__name_u}_TARGET}"
                    "copy_${pile_lower}_headers")
            endforeach()

            if (${pile_end_target__name_u}_OWN_HEADERS)
                pileCreateCopyTarget (
                    "copy_${pile_end_target__name_l}_headers"
                    "${pile_iter} headers are being copied"
                    "${INCLUDE_OUTPUT_PATH}"
                    "${${pile_end_target__name_u}_OWN_HEADERS}")
                add_dependencies(
                    ${${pile_end_target__name_u}_TARGET}
                    "copy_${pile_end_target__name_l}_headers")
            endif()

        endif()
    endif()

endmacro ()

# ============================================================================

# Creates the target that copies headers
#
# Arguments
#     - name: the user name for the target
#     - destination (optional): where to copy; by default this is INCLUDE_OUTPUT_PATH
#
macro    (pileCreateCopyTargetTarget
          pile_copy_target_target__name)

    unset(pile_copy_target_target__argn)
    set (pile_copy_target_target__argn ${ARGN})

    unset(pile_copy_target_target__destination)
    set(pile_copy_target_target__destination "${INCLUDE_OUTPUT_PATH}")
    if (pile_copy_target_target__argn)
        list(GET pile_copy_target_target__argn 0 pile_copy_target_target__destination)
    endif()

    unset(pile_copy_target_target__name_u)
    string (TOUPPER "${pile_copy_target_target__name}" pile_copy_target_target__name_u)
    unset(pile_copy_target_target__name_l)
    string (TOLOWER "${pile_copy_target_target__name}" pile_copy_target_target__name_l)
    unset(pile_copy_target_target__target_u)
    string (TOUPPER "${THIS_TARGET}" pile_copy_target_target__target_u)
    unset(pile_copy_target_target__target_l)
    string (TOLOWER "${THIS_TARGET}" pile_copy_target_target__target_l)

    pileCreateCopyTarget (
        "copy_${pile_copy_target_target__name_l}_headers"
        "${pile_copy_target_target__name} headers are being copied"
        "${pile_copy_target_target__destination}"
        "${${pile_copy_target_target__name_u}_HEADERS}")
        #"${${pile_copy_target_target__name_u}_SOURCE_DIR}")

    unset(pile_iter)
    foreach(pile_iter ${THIS_TARGET_PILES})
        unset(pile_upper)
        string(TOUPPER  "${pile_iter}" pile_upper)
        unset(pile_lower)
        string(TOLOWER  "${pile_iter}" pile_lower)

        add_dependencies(
            ${${pile_copy_target_target__target_u}_TARGET}
            "copy_${pile_lower}_headers")
        pileCopyHeaders(${pile_iter})


    endforeach()

    if (${pile_copy_target_target__target_u}_OWN_HEADERS)
        pileCreateCopyTarget (
            "copy_${pile_copy_target_target__target_l}_headers"
            "${pile_iter} headers are being copied"
            "${INCLUDE_OUTPUT_PATH}"
            "${${pile_copy_target_target__target_u}_OWN_HEADERS}")
        add_dependencies(
            ${${pile_copy_target_target__target_u}_TARGET}
            "copy_${pile_copy_target_target__target_l}_headers")
    endif()
endmacro ()

# ============================================================================

# Adds specified piles to current target
#
# Arguments
#     - all: are the names of the piles
#
# The macro defines or changes
#        <PILE>_UIS_SRC: the list of source files generated from <PILE>_UIS
#        <PILE>_RES_SRC: the list of source files generated from <PILE>_RES
#
macro    (pileTargetSubPiles)

    set(THIS_TARGET_PILES ${ARGN})
    unset(pile_iter)
    foreach(pile_iter ${THIS_TARGET_PILES})
        # message(STATUS "pile_iter = ${pile_iter}")

        unset(pile_upper)
        string(TOUPPER  "${pile_iter}" pile_upper)
        unset(pile_lower)
        string(TOLOWER  "${pile_iter}" pile_lower)
        unset(pile_target_upper)
        string(TOUPPER  "${THIS_TARGET}" pile_target_upper)

        pileInclude (${pile_iter})
        pileCallByName("${pile_lower}Init" PILE_SHARED)

        # message(STATUS "${pile_upper}_INCLUDES = ${${pile_upper}_INCLUDES}")
        list(APPEND ${pile_target_upper}_INCLUDES ${${pile_upper}_INCLUDES})

        # message(STATUS "${pile_upper}_LIBRARIES = ${${pile_upper}_LIBRARIES}")
        list(APPEND ${pile_target_upper}_LIBRARIES ${${pile_upper}_LIBRARIES})

        # message(STATUS "${pile_upper}_SOURCES = ${${pile_upper}_SOURCES}")
        list(APPEND ${pile_target_upper}_SOURCES ${${pile_upper}_SOURCES})

        # message(STATUS "${pile_upper}_HEADERS = ${${pile_upper}_HEADERS}")
        list(APPEND ${pile_target_upper}_HEADERS ${${pile_upper}_HEADERS})

        # message(STATUS "${pile_upper}_UIS = ${${pile_upper}_UIS}")
        list(APPEND ${pile_target_upper}_UIS ${${pile_upper}_UIS})

        # message(STATUS "${pile_upper}_QT_MODS = ${${pile_upper}_QT_MODS}")
        list(APPEND ${pile_target_upper}_QT_MODS ${${pile_upper}_QT_MODS})

        # message(STATUS "${pile_upper}_DLLS = ${${pile_upper}_DLLS}")
        list(APPEND ${pile_target_upper}_DLLS ${${pile_upper}_DLLS})

        if (${pile_target_upper}_QT_MODS)
            list(REMOVE_DUPLICATES ${pile_target_upper}_QT_MODS)
        endif()
        pileCopyHeaders("${pile_iter}")
    endforeach()
    if (${pile_target_upper}_SOURCES)
        list (REMOVE_DUPLICATES ${pile_target_upper}_SOURCES)
        # message(STATUS "${pile_target_upper}_SOURCES = ${${pile_target_upper}_SOURCES}")
    endif()
    if (${pile_target_upper}_HEADERS)
        list (REMOVE_DUPLICATES ${pile_target_upper}_HEADERS)
        # message(STATUS "${pile_target_upper}_HEADERS = ${${pile_target_upper}_HEADERS}")
    endif()
    if (${pile_target_upper}_UIS)
        list (REMOVE_DUPLICATES ${pile_target_upper}_UIS)
        # message(STATUS "${pile_target_upper}_UIS = ${${pile_target_upper}_UIS}")
    endif()
    if (${pile_target_upper}_LIBRARIES)
        list (REMOVE_DUPLICATES ${pile_target_upper}_LIBRARIES)
        # message(STATUS "${pile_target_upper}_LIBRARIES = ${${pile_target_upper}_LIBRARIES}")
    endif()
    if (${pile_target_upper}_DLLS)
        list (REMOVE_DUPLICATES ${pile_target_upper}_DLLS)
        # message(STATUS "${pile_target_upper}_DLLS = ${${pile_target_upper}_DLLS}")
    endif()

endmacro()
# ============================================================================

