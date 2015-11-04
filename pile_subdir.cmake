
# ============================================================================

# gets a list of subdirectories
#
# Example:
#   set (SUBDIR_LST)
#   YT_SUBDIRLIST(${CMAKE_CURRENT_SOURCE_DIRECTORY} SUBDIR_LST)
#
MACRO(pileSubDirList result curdir)
  FILE(GLOB children RELATIVE "${curdir}" "${curdir}/*")
  SET(dirlist)
  FOREACH(child ${children})
    IF(IS_DIRECTORY ${curdir}/${child})
        SET(dirlist ${dirlist} ${child})
    ENDIF()
  ENDFOREACH()
  SET(${result} ${dirlist})
ENDMACRO()

# ============================================================================

# gets a list of subdirectories that follow a specific pattern
#
# Example:
#   set (SUBDIR_LST)
#   pileSubDirListPtrn(${CMAKE_CURRENT_SOURCE_DIRECTORY} SUBDIR_LST "plugin_*")
#
MACRO(pileSubDirListPtrn result curdir ptrn)
  FILE(GLOB children RELATIVE "${curdir}" ${curdir}/${ptrn})
  SET(dirlist)
  FOREACH(child ${children})
    IF(IS_DIRECTORY ${curdir}/${child})
        SET(dirlist ${dirlist} ${child})
    ENDIF()
  ENDFOREACH()
  SET(${result} ${dirlist})
ENDMACRO()

# ============================================================================
