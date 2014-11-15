
# ============================================================================

# creates a target to copy files
#
# If base_path is provided then the path structure is going to be preserved,
# otherwise all files are going to be copied in same directory
macro    (pileUsedBy
          pile_used_by__pile_name
          pile_create_copy_target__target)

    string (TOUPPER "${pile_used_by__pile_name}" pile_used_by__pile_name_u)
    string (TOLOWER "${pile_used_by__pile_name}" pile_used_by__pile_name_l)

    message (STATUS "pile_create_copy_target__target = ${pile_create_copy_target__target}")
    message (STATUS "copy_${pile_used_by__pile_name_l}_headers = ${copy_${pile_used_by__pile_name_l}_headers}")
    add_dependencies (
        "${pile_create_copy_target__target}"
        "copy_${pile_used_by__pile_name_l}_headers")


endmacro ()

# ============================================================================

