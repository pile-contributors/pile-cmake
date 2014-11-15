
# ============================================================================

# Computes the relative path
# 
# If the paths are the same "." is returned
# 	- for input /a/b/c and reference /a/b the result is ".."
# 	- for input /a/b and reference /a/b/c the result is "c"
# 	- for input /a/1/2/3 and reference /a/b/c the result is " ../../../b/c"
# Both paths must start with a slash or both should not start
# with one.
macro    (pileRelativePath
          pile_relative_path__output
          pile_relative_path__reference
          pile_relative_path__input)

	# get a list from path components
	string (REGEX REPLACE 
		"[/\\]"
		";" 
		pile_relative_path__reference_l
		"${pile_relative_path__reference}")
 	string (REGEX REPLACE 
		"[/\\]"
		";" 
		pile_relative_path__input_l
		"${pile_relative_path__input}")

	# get lengths
	list (LENGTH 
		  pile_relative_path__reference_l 
		  pile_relative_path__reference_c)
	list (LENGTH 
		  pile_relative_path__input_l
		  pile_relative_path__input_c)
	
	# common parts
	set (pile_relative_path__i 0)
	set (pile_relative_path__ok ON)
	while (pile_relative_path__ok AND 
	       pile_relative_path__i LESS pile_relative_path__input_c AND 
		   pile_relative_path__i LESS pile_relative_path__reference_c)
		
		
		# get the components at this index
		list (GET pile_relative_path__reference_l ${pile_relative_path__i} 
		      pile_relative_path__reference_crt)
		list (GET pile_relative_path__input_l ${pile_relative_path__i} 
		      pile_relative_path__input_crt)
			  
		# if they are not the same break the loop
		if (NOT "${pile_relative_path__reference_crt}" STREQUAL "${pile_relative_path__input_crt}")
			set (pile_relative_path__ok OFF)
		else ()
			# next one
			math (EXPR 
				pile_relative_path__i 
				"${pile_relative_path__i} + 1")
		endif()
	endwhile()
 
	# pile_relative_path__i has the index of first mismatch
	# and the number of common components
	set (pile_relative_path__common ${pile_relative_path__i})
	
	# add ../../.. things
	while (pile_relative_path__i LESS pile_relative_path__input_c)
		
		if (pile_relative_path__result)
			set (pile_relative_path__result 
				"../${pile_relative_path__result}")
		else ()
			set (pile_relative_path__result "..")
		endif()
		
		# next one
		math (EXPR 
			pile_relative_path__i 
			"${pile_relative_path__i} + 1")
	endwhile()
 
    # If enabled, this would generate relative paths that start with ./
	#if (pile_relative_path__result)
	#	set (pile_relative_path__result "${pile_relative_path__result}")
	#else ()
	#	set (pile_relative_path__result ".")
	#endif()
 
	set (pile_relative_path__i ${pile_relative_path__common})
	while (pile_relative_path__i LESS pile_relative_path__reference_c)
	
		# get the components at this index
		list (GET pile_relative_path__reference_l ${pile_relative_path__i} 
		      pile_relative_path__reference_crt)
	
		if (pile_relative_path__result)
			set (pile_relative_path__result 
					"${pile_relative_path__result}/${pile_relative_path__reference_crt}")
		else ()
			set (pile_relative_path__result 
					"${pile_relative_path__reference_crt}")
		endif()
		
		# next one
		math (EXPR 
			pile_relative_path__i 
			"${pile_relative_path__i} + 1")
	endwhile()
	
	set (${pile_relative_path__output} "${pile_relative_path__result}")
	
endmacro ()

# ============================================================================
