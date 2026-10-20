# The real link libraries of the Victron modules. Include this at the end of the
# top-level CMakeLists.txt, after every target_link_libraries() call.
#
# tools/moduledependencies.py checks the same link rules in the CMake source.
# This reads the link libraries CMake computed, so a link added by a helper is
# seen too, and a commented-out target_link_libraries() is not a link. It does
# not depend on the build tool or the generator.
#
# Victron.VenusOS must not link Victron.GuiPlugins. Victron.Branding, when that
# target exists, must not link another Victron library. The app and the tests
# may link Victron.GuiPlugins. See "Module dependencies" in
# .github/architecture.md.

# The library name in one link entry. $<LINK_ONLY:VictronGuiPlugins> is the name
# inside the generator expression. A path is the file that was linked, so a
# directory named Victron is not a Victron library.
function(_victron_link_name item out_var)
    set(name "${item}")
    while(name MATCHES "^\\$<([^:<>]+):(.*)>$")
        set(name "${CMAKE_MATCH_2}")
    endwhile()
    if(name MATCHES "[/\\\\]")
        cmake_path(GET name FILENAME name)
    endif()
    set(${out_var} "${name}" PARENT_SCOPE)
endfunction()

# Adds one message to out_var if target links a library whose name matches
# name_regex. match_raw also searches the unparsed entry, so a generator
# expression this function does not unwrap is still seen. Do not set that for a
# pattern that can occur in a directory name, such as Victron.
function(_victron_forbidden_links target name_regex match_raw message out_var)
    set(problems "${${out_var}}")
    if(NOT TARGET ${target})
        set(${out_var} "${problems}" PARENT_SCOPE)
        return()
    endif()
    set(found "")
    foreach(property LINK_LIBRARIES INTERFACE_LINK_LIBRARIES)
        get_target_property(libraries ${target} ${property})
        if(NOT libraries)
            continue()
        endif()
        foreach(library ${libraries})
            _victron_link_name("${library}" name)
            if(name MATCHES "${name_regex}")
                list(APPEND found "${name}")
            elseif(match_raw AND library MATCHES "${name_regex}")
                list(APPEND found "${library}")
            endif()
        endforeach()
    endforeach()
    if(found)
        list(REMOVE_DUPLICATES found)
        string(APPEND problems "${message} It links: ${found}\n")
    endif()
    set(${out_var} "${problems}" PARENT_SCOPE)
endfunction()

set(_victron_link_problems "")
_victron_forbidden_links(VictronVenusOS "(^|[^A-Za-z0-9_])VictronGuiPlugins" TRUE
    "VictronVenusOS links Victron.GuiPlugins. Victron.VenusOS must not use it."
    _victron_link_problems)
_victron_forbidden_links(VictronBranding "(^|[^A-Za-z0-9_])Victron" FALSE
    "VictronBranding links another Victron module. Victron.Branding must not use one."
    _victron_link_problems)
if(_victron_link_problems)
    message(FATAL_ERROR "${_victron_link_problems}")
endif()
