set(FILE ${CMAKE_ARGV3})
set(REGEX ${CMAKE_ARGV4})
message("StripRegexFromFile.cmake: deleting REGEX ${REGEX} from file ${FILE}}")
# create list of lines form the contents of a file
file (STRINGS ${FILE} LINES)

# overwrite the file
file(WRITE ${FILE} "")

# loop through the lines, remove unwanted parts and write the (changed) line
foreach(LINE IN LISTS LINES)
    string(REGEX REPLACE ${REGEX} "" STRIPPED "${LINE}")
    file(APPEND ${FILE} "${STRIPPED}\n")
endforeach()
