cmake_minimum_required(VERSION 3.16)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)

find_package(Qt6 COMPONENTS Core Qml REQUIRED)

qt_add_library(Slippi SHARED
  slippiparser.h
  slippireplay.h
  slippiparser.cpp
  slippireplay.cpp

  slippc/src/analysis.h
  slippc/src/analyzer.h
  slippc/src/compressor.h
  slippc/src/enums.h
  slippc/src/lzma.h
  slippc/src/parser.h
  slippc/src/picohash.h
  slippc/src/replay.h
  slippc/src/schema.h
  slippc/src/util.h
  slippc/src/analysis.cpp
  slippc/src/analyzer.cpp
  slippc/src/compressor.cpp
  slippc/src/parser.cpp
  slippc/src/replay.cpp
)

target_include_directories(Slippi PUBLIC
  slippc/src
  ${Qt6Core_INCLUDE_DIRS}
  ${Qt6Qml_INCLUDE_DIRS}
)

qt_add_qml_module(Slippi
  URI Slippi
  PLUGIN_TARGET Slippi
  OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml/Slippi"
  VERSION 1.0
)

# assume little endian since <endian.h> doesn't exist
target_compile_definitions(Slippi PUBLIC __LITTLE_ENDIAN__)

if(WIN32)
  add_library(lzma STATIC IMPORTED)
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set_property(TARGET lzma PROPERTY IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/slippc/lib-win/liblzma.a")
  else()
    set_property(TARGET lzma PROPERTY IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/slippc/lib-win/liblzma-x86.a")
  endif()
elseif(APPLE)
  # lzma already exists on macOS
elseif(UNIX)
  add_library(lzma STATIC IMPORTED)
  set_property(TARGET lzma PROPERTY IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/slippc/lib-lin/liblzma.a")
endif()

target_link_libraries(Slippi PUBLIC lzma)
set_property(
  TARGET Slippi PROPERTY INTERFACE_LINK_LIBRARIES
  Qt6::Core Qt6::Qml
)
