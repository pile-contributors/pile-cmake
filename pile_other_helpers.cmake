
# ============================================================================

# Set the name
#
# Sets the name to either the simple form or with a version.
#
# LOC_PRJ_NAME is set to the final form of the name.
#

macro    (pileSetLocalName pile_local_name)
    IF(WIN32)
        SET ( LOC_PRJ_NAME "${pile_local_name}" )
        SET ( ${pile_local_name}  "${LOC_PRJ_NAME}" CACHE INTERNAL "${pile_local_name}")
    ELSE(WIN32)
        SET ( LOC_PRJ_NAME "${pile_local_name}-${${PROJECT_NAME_UPPER}_VERSION}" )
        SET ( ${pile_local_name}  "${LOC_PRJ_NAME}" CACHE INTERNAL "${pile_local_name}")
    ENDIF(WIN32)
endmacro ()

# ============================================================================
