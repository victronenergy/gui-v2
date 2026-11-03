#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#

# Compiles a test plugin with tools/gui-v2-plugin-compiler.py, as a plugin author would:
#
#   cmake -DPYTHON=<python> -DCOMPILER=<compiler> -DLUPDATE=<lupdate> -DLRELEASE=<lrelease>
#         -DRCC=<rcc> -DSOURCE_DIR=<plugin sources> -DWORK_DIR=<folder> -DOUTPUT=<json>
#         -P compile_test_plugin.cmake -- <compiler arguments>
#
# The compiler packs every file in its working folder, and the folder must have the plugin's name.
# So WORK_DIR is emptied, and SOURCE_DIR's files are copied into it.

file(REMOVE_RECURSE "${WORK_DIR}")
file(COPY "${SOURCE_DIR}/" DESTINATION "${WORK_DIR}")

# The compiler runs lupdate and lrelease, and looks for rcc, on PATH. Put the folders of the tools
# that this build uses first.
if (CMAKE_HOST_WIN32)
	set(pathSeparator ";")
else()
	set(pathSeparator ":")
endif()
foreach(tool IN ITEMS "${LUPDATE}" "${LRELEASE}" "${RCC}")
	get_filename_component(toolDir "${tool}" DIRECTORY)
	file(TO_NATIVE_PATH "${toolDir}" toolDir)
	set(ENV{PATH} "${toolDir}${pathSeparator}$ENV{PATH}")
endforeach()

set(compilerArgs "")
set(afterSeparator FALSE)
math(EXPR lastArg "${CMAKE_ARGC} - 1")
foreach(i RANGE ${lastArg})
	if (afterSeparator)
		list(APPEND compilerArgs "${CMAKE_ARGV${i}}")
	elseif ("${CMAKE_ARGV${i}}" STREQUAL "--")
		set(afterSeparator TRUE)
	endif()
endforeach()

execute_process(
	COMMAND "${PYTHON}" "${COMPILER}" ${compilerArgs}
	WORKING_DIRECTORY "${WORK_DIR}"
	RESULT_VARIABLE result
)
if (NOT result EQUAL 0)
	message(FATAL_ERROR "The plugin compiler failed in ${WORK_DIR}")
endif()

get_filename_component(pluginName "${WORK_DIR}" NAME)
get_filename_component(outputDir "${OUTPUT}" DIRECTORY)
file(MAKE_DIRECTORY "${outputDir}")
file(COPY_FILE "${WORK_DIR}/${pluginName}.json" "${OUTPUT}")
