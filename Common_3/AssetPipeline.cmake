# AssetPipeline.cmake - ChocoForge v1.60+
# Asset processing command-line tool

set(ASSET_PIPELINE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../ChocoForge/Common_3/Tools/AssetPipeline)
set(TRESSFX_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../ChocoForge/Common_3/Resources/AnimationSystem/ThirdParty/OpenSource/TressFX)
set(MESHOPT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../ChocoForge/Common_3/Tools/ThirdParty/OpenSource/meshoptimizer/src)
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

# Meshoptimizer source files
set(MESHOPTIMIZER_FILES
    ${MESHOPT_DIR}/allocator.cpp
    ${MESHOPT_DIR}/clusterizer.cpp
    ${MESHOPT_DIR}/indexcodec.cpp
    ${MESHOPT_DIR}/indexgenerator.cpp
    ${MESHOPT_DIR}/overdrawanalyzer.cpp
    ${MESHOPT_DIR}/overdrawoptimizer.cpp
    ${MESHOPT_DIR}/simplifier.cpp
    ${MESHOPT_DIR}/spatialorder.cpp
    ${MESHOPT_DIR}/stripifier.cpp
    ${MESHOPT_DIR}/vcacheanalyzer.cpp
    ${MESHOPT_DIR}/vcacheoptimizer.cpp
    ${MESHOPT_DIR}/vertexcodec.cpp
    ${MESHOPT_DIR}/vertexfilter.cpp
    ${MESHOPT_DIR}/vfetchanalyzer.cpp
    ${MESHOPT_DIR}/vfetchoptimizer.cpp
)

set(ASSET_PIPELINE_FILES
    ${ASSET_PIPELINE_DIR}/src/AssetPipeline.cpp
    ${ASSET_PIPELINE_DIR}/src/AssetPipeline.h
    ${ASSET_PIPELINE_DIR}/src/AssetPipelineCmd.cpp
    ${ASSET_PIPELINE_DIR}/src/AssetPipelineConfig.h
    ${TRESSFX_DIR}/TressFXAsset.cpp
    ${TRESSFX_DIR}/TressFXAsset.h
    ${TRESSFX_DIR}/TressFXFileFormat.h
    ${MESHOPTIMIZER_FILES}
    ${TOOL_FILESYSTEM_FILES}
)

# Texture processing requires ISPC texture compressor
if(ISPC_TEXCOMP_AVAILABLE)
    list(APPEND ASSET_PIPELINE_FILES ${ASSET_PIPELINE_DIR}/src/AssetPipeline_Textures.cpp)
endif()

add_executable(AssetPipelineCmd ${ASSET_PIPELINE_FILES})
target_include_directories(AssetPipelineCmd PRIVATE
    ${ASSET_PIPELINE_DIR}/src
    ${TRESSFX_DIR}
    ${MESHOPT_DIR}
)
# Link libraries
set(ASSET_PIPELINE_LIBS OS Renderer BunyLib ${RENDER_LIBRARIES})
if(ISPC_TEXCOMP_AVAILABLE)
    list(APPEND ASSET_PIPELINE_LIBS ISPCTexcomp)
endif()
target_link_libraries(AssetPipelineCmd ${ASSET_PIPELINE_LIBS})

# Enable dead code stripping to handle duplicate TinyKtx/TinyDDS symbols (same as Xcode project)
if(APPLE)
    target_link_options(AssetPipelineCmd PRIVATE "LINKER:-dead_strip")
endif()
set_property(TARGET AssetPipelineCmd PROPERTY CXX_STANDARD 17)

# On Apple platforms, compile as Objective-C++ due to Foundation header dependencies
if(APPLE_PLATFORM)
    set(OBJCXX_FILES
        ${ASSET_PIPELINE_DIR}/src/AssetPipeline.cpp
        ${ASSET_PIPELINE_DIR}/src/AssetPipelineCmd.cpp
        ${TRESSFX_DIR}/TressFXAsset.cpp
    )
    if(ISPC_TEXCOMP_AVAILABLE)
        list(APPEND OBJCXX_FILES ${ASSET_PIPELINE_DIR}/src/AssetPipeline_Textures.cpp)
    endif()
    set_source_files_properties(${OBJCXX_FILES}
        PROPERTIES LANGUAGE OBJCXX COMPILE_FLAGS "-fobjc-arc"
    )
endif()

# Enable ARC for Objective-C files
if(TARGET_MACOS)
    set_source_files_properties(
        ${OS_DIR}/Darwin/CocoaToolsFileSystem.mm
        PROPERTIES COMPILE_FLAGS "-fobjc-arc"
    )
endif()
