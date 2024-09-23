find_package(Git)

if(GIT_EXECUTABLE)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} describe --tags
        OUTPUT_VARIABLE TAG_VERSION
        RESULT_VARIABLE ERROR_CODE
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(DEFINED ENV{GITHUB_REF})
        set(TAG_VERSION $ENV{GITHUB_REF})
        message(STATUS "Extracted version from GITHUB_REF")
    endif()

    if(TAG_VERSION STREQUAL "")
        set(TAG_VERSION 0.0.0)
        message(WARNING "Failed to determine version from Git tags. Using default version \"${TAG_VERSION}\".")
    endif()

    message(STATUS "Project version: ${TAG_VERSION}")

    # Split into major, minor, patch
    string(
        REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)"
        TAG_VERSION_MATCH ${TAG_VERSION}
    )
    set(TAG_VERSION_MAJOR ${CMAKE_MATCH_1})
    set(TAG_VERSION_MINOR ${CMAKE_MATCH_2})
    set(TAG_VERSION_PATCH ${CMAKE_MATCH_3})
endif()