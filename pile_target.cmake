
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

    string (TOUPPER "${pile_target__name}" pile_target__name_u)
    string (TOLOWER "${pile_target__name}" pile_target__name_l)

    message (STATUS "${pile_target__name_u}: target initialization")
	
	# prepare variables
	set( ${pile_target__name_u}_SOURCES )
	set( ${pile_target__name_u}_HEADERS )
	set( ${pile_target__name_u}_UIS )
	set( ${pile_target__name_u}_RES )
	set( ${pile_target__name_u}_LIBS )
	set( ${pile_target__name_u}_QT_MODS )

	# name of the target
	set( ${pile_target__name_u}_TARGET "${pile_target__name_l}")
	
endmacro ()

# ============================================================================

# Constructs the target based on the provided options
# 
# Arguments
#     - name: the user name for the target
#     - kind: either "exe", "shared" or "static"
#
# The macro defines or changes
#		<PILE>_UIS_SRC: the list of source files generated from <PILE>_UIS
#		<PILE>_RES_SRC: the list of source files generated from <PILE>_RES
macro    (pileEndTarget
          pile_end_target__name
		  pile_end_target__kind)

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
	
	# all sources used to build the target
	set( ${pile_end_target__name_u}_ALL_SRCS
			${${pile_end_target__name_u}_SOURCES}
			${${pile_end_target__name_u}_UIS_SRC}
			${${pile_end_target__name_u}_RES_SRC}
			${${pile_end_target__name_u}_HEADERS})
	
	# create appropriate target type
	if ("${pile_end_target__kind}" STREQUAL "exe")
		add_executable("${${pile_end_target__name_u}_TARGET}"
			${${pile_end_target__name_u}_ALL_SRCS})
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
	endif()
	
    message (STATUS "${pile_end_target__name_u}: target created")

endmacro ()

# ============================================================================

