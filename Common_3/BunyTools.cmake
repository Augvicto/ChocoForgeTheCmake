# BunyTools.cmake - ChocoForge v1.60+
# Buny Archive library and command-line tool

set(BUNY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../ChocoForge/Common_3/Tools/BunyArchive)
set(UTIL_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../ChocoForge/Common_3/Utilities)
set(OS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../ChocoForge/Common_3/OS)

# Tool FileSystem files (needed for command-line tools)
set(TOOL_FILESYSTEM_FILES
    ${UTIL_DIR}/FileSystem/ToolFileSystem.c
)

# Platform-specific tool filesystem
if(TARGET_MACOS)
    list(APPEND TOOL_FILESYSTEM_FILES ${OS_DIR}/Darwin/CocoaToolsFileSystem.mm)
endif()
if(TARGET_IOS)
    list(APPEND TOOL_FILESYSTEM_FILES ${OS_DIR}/Darwin/iOSToolsFileSystem.mm)
endif()
if(WINDOWS)
    list(APPEND TOOL_FILESYSTEM_FILES ${OS_DIR}/Windows/WindowsToolsFileSystem.cpp)
endif()
if(LINUX)
    list(APPEND TOOL_FILESYSTEM_FILES ${OS_DIR}/Linux/LinuxToolsFileSystem.c)
endif()

# Compression files needed for archive creation (not in main OS library)
set(UTIL_LZ4_DIR ${UTIL_DIR}/ThirdParty/OpenSource/lz4)
set(UTIL_ZSTD_DIR ${UTIL_DIR}/ThirdParty/OpenSource/zstd)

set(COMPRESSION_FILES
    # LZ4 High Compression
    ${UTIL_LZ4_DIR}/lz4hc.c
    ${UTIL_LZ4_DIR}/lz4hc.h
    # ZSTD compression
    ${UTIL_ZSTD_DIR}/compress/fse_compress.c
    ${UTIL_ZSTD_DIR}/compress/hist.c
    ${UTIL_ZSTD_DIR}/compress/huf_compress.c
    ${UTIL_ZSTD_DIR}/compress/zstd_compress.c
    ${UTIL_ZSTD_DIR}/compress/zstd_compress_literals.c
    ${UTIL_ZSTD_DIR}/compress/zstd_compress_sequences.c
    ${UTIL_ZSTD_DIR}/compress/zstd_compress_superblock.c
    ${UTIL_ZSTD_DIR}/compress/zstd_double_fast.c
    ${UTIL_ZSTD_DIR}/compress/zstd_fast.c
    ${UTIL_ZSTD_DIR}/compress/zstd_lazy.c
    ${UTIL_ZSTD_DIR}/compress/zstd_ldm.c
    ${UTIL_ZSTD_DIR}/compress/zstd_opt.c
    ${UTIL_ZSTD_DIR}/compress/zstdmt_compress.c
)

# BunyLib - static library for archive creation/extraction
set(BUNY_LIB_FILES
    ${BUNY_DIR}/Buny.c
    ${BUNY_DIR}/Buny.h
    ${BUNY_DIR}/utf8.h
    ${TOOL_FILESYSTEM_FILES}
    ${COMPRESSION_FILES}
)

add_library(BunyLib STATIC ${BUNY_LIB_FILES})
target_include_directories(BunyLib PUBLIC ${BUNY_DIR})
target_link_libraries(BunyLib PUBLIC OS)
set_property(TARGET BunyLib PROPERTY C_STANDARD 11)

# On Apple platforms, enable ARC for Objective-C files
if(TARGET_MACOS)
    set_source_files_properties(
        ${OS_DIR}/Darwin/CocoaToolsFileSystem.mm
        PROPERTIES COMPILE_FLAGS "-fobjc-arc"
    )
endif()

# BunyTool - command-line executable
set(BUNY_TOOL_FILES
    ${BUNY_DIR}/BunyTool.c
)

add_executable(BunyTool ${BUNY_TOOL_FILES})
target_link_libraries(BunyTool PRIVATE BunyLib OS Renderer ${RENDER_LIBRARIES})
set_property(TARGET BunyTool PROPERTY C_STANDARD 11)
