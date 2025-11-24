set (ASSET_PIPELINE_FILES
    ../ChocoForge/Common_3/Tools/FileSystem/IToolFileSystem.h
    ../ChocoForge/Common_3/ThirdParty/OpenSource/TressFX/TressFXAsset.cpp
    ../ChocoForge/Common_3/ThirdParty/OpenSource/TressFX/TressFXAsset.h
    ../ChocoForge/Common_3/ThirdParty/OpenSource/TressFX/TressFXFileFormat.h
    ../ChocoForge/Common_3/Tools/AssetPipeline/src/AssetPipeline.cpp
    ../ChocoForge/Common_3/Tools/AssetPipeline/src/AssetPipeline.h
    ../ChocoForge/Common_3/Tools/AssetPipeline/src/AssetPipelineCmd.cpp
    ../ChocoForge/Common_3/ThirdParty/OpenSource/EASTL/eastl.cpp
)

if(${APPLE_PLATFORM} MATCHES ON)
    set(ASSET_PIPELINE_FILES ${ASSET_PIPELINE_FILES}
        ../ChocoForge/Common_3/Tools/FileSystem/CocoaToolsFileSystem.mm
    )
endif()

if(${WINDOWS} MATCHES ON)
    set(ASSET_PIPELINE_FILES ${ASSET_PIPELINE_FILES}
        ../ChocoForge/Common_3/Tools/FileSystem/WindowsToolsFileSystem.cpp
    )
endif()

if(${LINUX} MATCHES ON)
    set(ASSET_PIPELINE_FILES ${ASSET_PIPELINE_FILES}
        ../ChocoForge/Common_3/Tools/FileSystem/LinuxToolsFileSystem.cpp
    )
endif()

add_executable(AssetPipelineCmd ${ASSET_PIPELINE_FILES})
target_link_libraries(AssetPipelineCmd ChocoForge ${RENDER_LIBRARIES})
set_property(TARGET AssetPipelineCmd PROPERTY CXX_STANDARD 17)

if (${APPLE_PLATFORM} MATCHES ON)
    set_property (TARGET AssetPipelineCmd APPEND_STRING PROPERTY COMPILE_FLAGS "-fobjc-arc")
endif()
