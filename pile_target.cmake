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
#		<PILE>_SOURCES: the list of source files
#		<PILE>_HEADERS: the list of headers
#		<PILE>_UIS: the list of UI files
#		<PILE>_RES: the list of resource files
#		<PILE>_LIBS: the list of libraries to link against
#		<PILE>_QT_MODS: the list of Qt modules to link against
#		<PILE>_TARGET: the actual name of the target
macro    (pileTarget
          pile_target__name)
    set(pile_target__argn ${ARGN})

    string (TOUPPER "${pile_target__name}" pile_target__name_u)
    string (TOLOWER "${pile_target__name}" pile_target__name_l)

    message (STATUS "${pile_target__name_u}: target initialization")

    set(pile_target__gui_app OFF)
    if (pile_target__argn)
        list(GET pile_target__argn 0 pile_target__gui_app)
        if("${pile_target__gui_app}" STREQUAL "GUI")
            set(pile_target__gui_app ON)
        endif()
    endif()

	# prepare variables
	set( ${pile_target__name_u}_SOURCES )
	set( ${pile_target__name_u}_HEADERS )
	set( ${pile_target__name_u}_UIS )
	set( ${pile_target__name_u}_RES )
	set( ${pile_target__name_u}_LIBS )
	set( ${pile_target__name_u}_QT_MODS )
    set( ${pile_target__name_u}_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")

	# name of the target
	set( ${pile_target__name_u}_TARGET "${pile_target__name_l}")

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
#		<PILE>_UIS_SRC: the list of source files generated from <PILE>_UIS
#		<PILE>_RES_SRC: the list of source files generated from <PILE>_RES
macro    (pileEndTarget
          pile_end_target__name
          pile_end_target__kind)
    set(pile_end_target__argn ${ARGN})

    set(pile_end_target__copy_headers OFF)
    if (pile_end_target__argn)
        list(GET pile_end_target__argn 0 pile_end_target__copy_headers)
        if("${pile_end_target__copy_headers}" STREQUAL "COPY")
            set(pile_end_target__copy_headers ON)
        endif()
    endif()

    string (TOUPPER "${pile_end_target__name}" pile_end_target__name_u)
    string (TOLOWER "${pile_end_target__name}" pile_end_target__name_l)
	
	# expand uis
	set( ${pile_end_target__name_u}_UIS_SRC )
    if    (${pile_end_target__name_u}_UIS)
        qt5_wrap_ui (${pile_end_target__name_u}_UIS_SRC 
			${${pile_end_target__name_u}_UIS})
    endif ()
	
	# expand resources
    set( ${pile_end_target__name_u}_RES_SRC)
    if    (${pile_end_target__name_u}_RES)
        qt5_add_resources( ${pile_end_target__name_u}_RES_SRC 
			${${pile_end_target__name_u}_RES})
    endif ()	
	
    # make sure all paths are absolute
    set (pile_end_target__temp_list )
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

    # remove duplicates from lists
    if (${pile_end_target__name_u}_SOURCES)
        list(REMOVE_DUPLICATES ${pile_end_target__name_u}_SOURCES)
    endif()
    if (${pile_end_target__name_u}_HEADERS)
        list(REMOVE_DUPLICATES ${pile_end_target__name_u}_HEADERS)
    endif()
    if (${pile_end_target__name_u}_LIBS)
        list(REMOVE_DUPLICATES ${pile_end_target__name_u}_LIBS)
    endif()
    if (${pile_end_target__name_u}_QT_MODS)
        list(REMOVE_DUPLICATES ${pile_end_target__name_u}_QT_MODS)
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
                COMPONENT applications)
            endif()
        endif()
	elseif ("${pile_end_target__kind}" STREQUAL "shared")
		add_library("${${pile_end_target__name_u}_TARGET}" SHARED
			${${pile_end_target__name_u}_ALL_SRCS})
	else ()
		add_library("${${pile_end_target__name_u}_TARGET}" STATIC
			${${pile_end_target__name_u}_ALL_SRCS})
	endif()

	# link libraries
	if (${pile_end_target__name_u}_LIBS)
		target_link_libraries( ${${pile_end_target__name_u}_TARGET}
			${${pile_end_target__name_u}_LIBS})
	endif()

	# link / use Qt modules
	if (${pile_end_target__name_u}_QT_MODS)
		qt5_use_modules( ${${pile_end_target__name_u}_TARGET}
			${${pile_end_target__name_u}_QT_MODS})
	endif()

	# what to install where
    install(
        TARGETS "${${pile_end_target__name_u}_TARGET}"
        ARCHIVE
            DESTINATION lib
            COMPONENT applications
        LIBRARY
            DESTINATION lib
            COMPONENT applications
        RUNTIME
            DESTINATION bin
            COMPONENT applications)
	
	if (${pile_end_target__name_u}_HEADERS)
		install(
			FILES ${${pile_end_target__name_u}_HEADERS}
			DESTINATION include
			COMPONENT headers)
        if (pile_end_target__copy_headers)
            pileCreateCopyTargetTarget("${pile_end_target__name}")
            add_dependencies(
                "${${pile_end_target__name_u}_TARGET}"
                "copy_${pile_end_target__name_l}_headers")
        endif()
	endif()
	

    message (STATUS "${pile_end_target__name_u}: target created")

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

    set (pile_copy_target_target__argn ${ARGN})

    set(pile_copy_target_target__destination "${INCLUDE_OUTPUT_PATH}")
    if (pile_copy_target_target__argn)
        list(GET pile_copy_target_target__argn 0 pile_copy_target_target__destination)
    endif()

    string (TOUPPER "${pile_copy_target_target__name}" pile_copy_target_target__name_u)
    string (TOLOWER "${pile_copy_target_target__name}" pile_copy_target_target__name_l)

    pileCreateCopyTarget (
        "copy_${pile_copy_target_target__name_l}_headers"
        "${pile_copy_target_target__name} headers are being copied"
        "${pile_copy_target_target__destination}"
        "${${pile_copy_target_target__name_u}_HEADERS}")
        #"${${pile_copy_target_target__name_u}_SOURCE_DIR}")

endmacro ()

# ============================================================================

