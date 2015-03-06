
if (NOT DEFINED COPYFILES_DEBUG_MSG)
    set (COPYFILES_DEBUG_MSG OFF)
endif()

# ============================================================================

# creates a target to copy files
#
# If base_path is provided then the path structure is going to be preserved,
# otherwise all files are going to be copied in same directory
macro    (pileCreateCopyTarget
          pile_create_copy_target__target_name
          pile_create_copy_target__target_description 
          pile_create_copy_target__destination_path 
          pile_create_copy_target__files_list)
    set (pile_create_copy_target__argn ${ARGN})

    if (pile_create_copy_target__argn)
        list(GET pile_create_copy_target__argn 0 pile_create_copy_target__base_path)
    endif()

    pileDebugMessage ("COPYFILES"
        "PILE_CREATE_COPY_TARGET: target_name = ${pile_create_copy_target__target_name}")
    pileDebugMessage ("COPYFILES"
        "PILE_CREATE_COPY_TARGET: target_description =  ${pile_create_copy_target__target_description}")
    pileDebugMessage ("COPYFILES"
        "PILE_CREATE_COPY_TARGET: destination_path =  ${pile_create_copy_target__destination_path}")
    pileDebugMessage ("COPYFILES"
        "PILE_CREATE_COPY_TARGET: files_list =  ${pile_create_copy_target__files_list}")
    pileDebugMessage ("COPYFILES"
        "PILE_CREATE_COPY_TARGET: base_path =  ${pile_create_copy_target__base_path}")

	if(NOT EXISTS "${pile_create_copy_target__destination_path}")
		file(MAKE_DIRECTORY "${pile_create_copy_target__destination_path}")
	endif()
	
    add_custom_target(
        "${pile_create_copy_target__target_name}" ALL
        WORKING_DIRECTORY "${pile_create_copy_target__destination_path}"
        COMMENT "${pile_create_copy_target__target_description}"
        VERBATIM
        DEPENDS ${pile_create_copy_target__files_list})
    if (pile_create_copy_target__base_path)
        foreach (iter_h ${pile_create_copy_target__files_list})
            string (REPLACE 
                "${pile_create_copy_target__base_path}"
                ""
                iter_h_name
                "${iter_h}")
            add_custom_command (
                TARGET "${pile_create_copy_target__target_name}"
                PRE_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different "${iter_h}" "${pile_create_copy_target__destination_path}/${iter_h_name}")
            #message (STATUS "iter_h = ${iter_h}")
            #message (STATUS "dest = ${pile_create_copy_target__destination_path}/${iter_h_name}")
        endforeach (iter_h ${MSGPILE_HEADERS})
    else (pile_create_copy_target__base_path)
        foreach (iter_h ${pile_create_copy_target__files_list})
            get_filename_component (iter_h_name ${iter_h} NAME)
            add_custom_command (
                TARGET "${pile_create_copy_target__target_name}"
                PRE_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different "${iter_h}" "${pile_create_copy_target__destination_path}/${iter_h_name}")
            #message (STATUS "iter_h = ${iter_h}")
            #message (STATUS "dest = ${pile_create_copy_target__destination_path}/${iter_h_name}")
        endforeach (iter_h ${MSGPILE_HEADERS})
    endif (pile_create_copy_target__base_path)
endmacro ()

# ============================================================================

# creates a target that copies the headers from a pile to build directory
#
# Name of the new target is copy_pile_headers.
# The files are copied to ${CMAKE_BINARY_DIR}/build/include
# It is assumed that PILE_HEADERS and PILE_PATH are defined.
macro    (pileCopyHeaders
          pile_copy_headers__pile_name_camel_case)

    string (TOUPPER "${pile_copy_headers__pile_name_camel_case}" pile_copy_headers__name_u)
    string (TOLOWER "${pile_copy_headers__pile_name_camel_case}" pile_copy_headers__name_l)

    pileCreateCopyTarget (
        "copy_${pile_copy_headers__name_l}_headers"
        "${pile_copy_headers__pile_name_camel_case} headers are being copied"
        "${PROJECT_BINARY_DIR}/build/include/${pile_copy_headers__name_l}"
        "${${pile_copy_headers__name_u}_HEADERS}")
        #"${${pile_copy_headers__name_u}_SOURCE_DIR}")

endmacro ()

# ============================================================================

