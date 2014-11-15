
include (pile_relative_path)

# ============================================================================

# Computes the output path just like CMake does
# 
# Both paths must start with a slash or both should not start
# with one.
macro    (pileCmakeOutputPath
          pile_cmake_output_path__output
          pile_cmake_output_path__input)
	
	# get relative path with erspect to project path
	set (pile_cmake_output_path__rel_path "")
	pileRelativePath(
          pile_cmake_output_path__rel_path
          ${pile_cmake_output_path__input}
          ${PROJECT_SOURCE_DIR})
	
	set (${pile_cmake_output_path__output} 
		"${PROJECT_BINARY_DIR}/${pile_cmake_output_path__rel_path}")
	
endmacro ()

# ============================================================================
