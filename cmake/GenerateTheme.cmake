# Parse theme json files and generate themeobject.h.
# Use DEPENDS to ensure script is only run when the script or theme json files have changed.
find_package(Python3 COMPONENTS Interpreter)
add_custom_command(
    COMMAND ${Python3_EXECUTABLE} ${PROJECT_SOURCE_DIR}/tools/themeparser.py "${PROJECT_SOURCE_DIR}/themes/" "${PROJECT_SOURCE_DIR}/src/themeobjects.h"
    OUTPUT "${PROJECT_SOURCE_DIR}/src/themeobjects.h"
    DEPENDS "${PROJECT_SOURCE_DIR}/themes/animation" "${PROJECT_SOURCE_DIR}/themes/color" "${PROJECT_SOURCE_DIR}/themes/geometry" "${PROJECT_SOURCE_DIR}/themes/typography" ${PROJECT_SOURCE_DIR}/tools/themeparser.py
    COMMENT "Generating themeobjects.h"
)
add_custom_target(
    theme_parser ALL
    DEPENDS "${PROJECT_SOURCE_DIR}/src/themeobjects.h"
)
