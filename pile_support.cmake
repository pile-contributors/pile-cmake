# ============================================================================
#
# Introduction
# ------------
# 
# This file contains support CMake script for piles as described
# at http://tnick.github.io/ideas/2014/05/24/micromodules.html
#
# Usage
# -----
#
# The user may need to do something along these lines if
# the file is not present in CMake search paths:
#
#    cmake ../src -DCMAKE_MODULE_PATH=G:/prog/testpiles/pile_support
#
# Conventions
# -----------
#
# All macros and variables in this file start with the string `pile_`.
# Support variable names are all small caps with underscore
# separating the words; arguments and internal variables 
# start with the name of the macro.
#
# Macro names are camelCased, with first letter being small case.
#
# When the actual name of the pile is referenced it is going to be
# enclosed in angle brackets like so: <PILE> or <pile>.
#
# All variables at the global scope are at the top of the file.
#
# ============================================================================

# This is a general Debug Message switch; if OFF absolutely 
# no message will be shown by  pileDebugMessage;
# if ON then the behaviour is determined by individual pile settings
# using <PILE>_DEBUG_MSG.
set (PILE_SUPPORT_DEBUG ON)

# ============================================================================

# Show a debug message on behalf of the  pile
# 
# For the message to be actually printed PILE_SUPPORT_DEBUG
# must be set to ON and <PILE>_DEBUG_MSG
macro    (pileDebugMessage
          pile_debug_message__name
          pile_debug_message__message)
		  
	# general switch
	if (PILE_SUPPORT_DEBUG)
		# pile-level switch
		string (TOUPPER ${pile_debug_message__name} pile_debug_message__name_u)
		if    (${pile_debug_message__name_u}_DEBUG_MSG)
			# ok, go ahead
			message (STATUS "${pile_debug_message__name_u}: ${pile_debug_message__message}")
		endif (${pile_debug_message__name_u}_DEBUG_MSG)
	endif (PILE_SUPPORT_DEBUG)
	
endmacro ()

# ============================================================================

include(pile_init)
include(pile_include)
include(pile_headers)
include(pile_used_by)
