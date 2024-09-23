#########
# Setup #
#########

cmake_minimum_required(VERSION 3.25)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(Versioning)

########
# Main #
########

# After installation this project can be found by 'find_package' command:
#
#    find_package(libcreate REQUIRED)
#    target_link_libraries(... libcreate)
#

project(
  libcreate 
  VERSION ${TAG_VERSION_MAJOR}.${TAG_VERSION_MINOR}.${TAG_VERSION_PATCH}
)

set(PACKAGE_VERSION ${TAG_VERSION_MAJOR}.${TAG_VERSION_MINOR}.${TAG_VERSION_PATCH})

option(LIBCREATE_BUILD_TESTS "Enable the build of tests." ON)

find_package(Boost REQUIRED COMPONENTS system thread)
find_package(Threads REQUIRED)

# Default to C++11
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 11)
endif()

#########
# Build #
#########

set(LIBRARY_NAME create)

# Specify locations of header files
include_directories(
  include
)

# Declare cpp library
add_library(${LIBRARY_NAME} SHARED
  src/create.cpp
  src/serial.cpp
  src/serial_stream.cpp
  src/serial_query.cpp
  src/data.cpp
  src/packet.cpp
  src/types.cpp
)

target_compile_options(${LIBRARY_NAME} PRIVATE -Wall -Wextra -Wpedantic -Werror)

# Manually link to thread library for build on ARM
if(THREADS_HAVE_PTHREAD_ARG)
  set_property(TARGET ${LIBRARY_NAME} PROPERTY COMPILE_OPTIONS "-pthread")
  set_property(TARGET ${LIBRARY_NAME} PROPERTY INTERFACE_COMPILE_OPTIONS "-pthread")
endif()

if(CMAKE_THREAD_LIBS_INIT)
  target_link_libraries(${LIBRARY_NAME} "${CMAKE_THREAD_LIBS_INIT}")
endif()

# Link to Boost
target_link_libraries(${LIBRARY_NAME}
  ${Boost_LIBRARIES}
)

# Declare example executables
set(EXAMPLES
  battery_level
  bumpers
  cliffs
  drive_circle
  leds
  packets
  play_song
  wheeldrop
)

foreach(EXAMPLE ${EXAMPLES})
  add_executable(${EXAMPLE} examples/${EXAMPLE}.cpp)

  target_link_libraries(${EXAMPLE}
    ${Boost_LIBRARIES}
    ${LIBRARY_NAME}
  )
endforeach()

#################
# Configuration #
#################

include(GNUInstallDirs)

# set(CMAKE_INSTALL_PREFIX "/usr/") // complib needs  this, riplib doesn't

###########
# Install #
###########

# Install targets
install(
    TARGETS ${LIBRARY_NAME}
    EXPORT ${LIBRARY_NAME}-config
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

# Install config
install(
    EXPORT ${LIBRARY_NAME}-config
    NAMESPACE create::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${LIBRARY_NAME})

# Install headers
install(DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/include/${LIBRARY_NAME}/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${LIBRARY_NAME})

# Install package.xml (for catkin)
install(
  FILES package.xml
  DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}
)

###########
# Testing #
###########

if(LIBCREATE_BUILD_TESTS)
  find_package(GTest)
  include_directories(${GTEST_INCLUDE_DIRS})
endif()

if(LIBCREATE_BUILD_TESTS AND ${GTEST_FOUND})
  message("GTest installation found. Building tests.")

  enable_testing()

  # Add tests
  set(LIBCREATE_TESTS
    test_create
    test_data
    test_packet
    test_robot_model
    test_serial_stream
    test_serial_query
  )

  foreach(LIBCREATE_TEST ${LIBCREATE_TESTS})
    add_executable(${LIBCREATE_TEST} tests/${LIBCREATE_TEST}.cpp)

    target_link_libraries(${LIBCREATE_TEST}
      ${LIBRARY_NAME}
      ${GTEST_LIBRARIES}
      gtest_main
    )

    add_test(
      NAME ${LIBCREATE_TEST}
      COMMAND ${LIBCREATE_TEST}
    )
  endforeach()
else()
  message("No GTest installation found. Skipping tests.")
endif()

#############
# Packaging #
#############

include(Packing)