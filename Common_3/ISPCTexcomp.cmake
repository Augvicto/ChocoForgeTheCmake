# ISPCTexcomp.cmake - ChocoForge v1.60+
# Intel ISPC Texture Compressor library

set(ISPC_TEXCOMP_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../ChocoForge/Common_3/Tools/ThirdParty/OpenSource/ISPCTextureCompressor)

# Find ISPC compiler
if(APPLE)
    set(ISPC_COMPILER ${ISPC_TEXCOMP_DIR}/ISPC/osx/ispc)
elseif(UNIX)
    set(ISPC_COMPILER ${ISPC_TEXCOMP_DIR}/ISPC/linux/ispc)
elseif(WIN32)
    set(ISPC_COMPILER ${ISPC_TEXCOMP_DIR}/ISPC/win/ispc.exe)
endif()

# Check if ISPC compiler exists and is executable
if(EXISTS ${ISPC_COMPILER})
    message(STATUS "Found ISPC compiler: ${ISPC_COMPILER}")

    set(ISPC_SRC_DIR ${ISPC_TEXCOMP_DIR}/ispc_texcomp)
    set(KERNEL_ISPC ${ISPC_SRC_DIR}/kernel.ispc)
    set(KERNEL_ASTC_ISPC ${ISPC_SRC_DIR}/kernel_astc.ispc)
    set(KERNEL_ISPC_H ${ISPC_SRC_DIR}/kernel_ispc.h)
    set(KERNEL_ASTC_ISPC_H ${ISPC_SRC_DIR}/kernel_astc_ispc.h)

    # Set ISPC target based on platform
    if(APPLE)
        if(CMAKE_OSX_ARCHITECTURES MATCHES "arm64" OR CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "arm64")
            set(ISPC_TARGET "neon-i32x4")
            set(ISPC_ARCH "aarch64")
        else()
            set(ISPC_TARGET "sse4-i32x4")
            set(ISPC_ARCH "x86-64")
        endif()
    elseif(UNIX)
        set(ISPC_TARGET "sse4-i32x4")
        set(ISPC_ARCH "x86-64")
    elseif(WIN32)
        set(ISPC_TARGET "sse4-i32x4")
        set(ISPC_ARCH "x86-64")
    endif()

    set(KERNEL_ISPC_O ${CMAKE_BINARY_DIR}/kernel_ispc.o)
    set(KERNEL_ASTC_ISPC_O ${CMAKE_BINARY_DIR}/kernel_astc_ispc.o)

    # Generate kernel headers AND object files with ISPC
    if(NOT EXISTS ${KERNEL_ISPC_H} OR NOT EXISTS ${KERNEL_ISPC_O})
        message(STATUS "Compiling ISPC kernels...")
        execute_process(
            COMMAND ${ISPC_COMPILER} -O2 --target=${ISPC_TARGET} --arch=${ISPC_ARCH} --pic
                    ${KERNEL_ISPC} -o ${KERNEL_ISPC_O} -h ${KERNEL_ISPC_H}
            WORKING_DIRECTORY ${ISPC_SRC_DIR}
            RESULT_VARIABLE ISPC_RESULT
        )
        if(NOT ISPC_RESULT EQUAL 0)
            message(WARNING "Failed to compile kernel.ispc")
        endif()
    endif()

    if(NOT EXISTS ${KERNEL_ASTC_ISPC_H} OR NOT EXISTS ${KERNEL_ASTC_ISPC_O})
        execute_process(
            COMMAND ${ISPC_COMPILER} -O2 --target=${ISPC_TARGET} --arch=${ISPC_ARCH} --pic
                    ${KERNEL_ASTC_ISPC} -o ${KERNEL_ASTC_ISPC_O} -h ${KERNEL_ASTC_ISPC_H}
            WORKING_DIRECTORY ${ISPC_SRC_DIR}
            RESULT_VARIABLE ISPC_ASTC_RESULT
        )
        if(NOT ISPC_ASTC_RESULT EQUAL 0)
            message(WARNING "Failed to compile kernel_astc.ispc")
        endif()
    endif()

    # Check if headers AND objects were generated successfully
    if(EXISTS ${KERNEL_ISPC_H} AND EXISTS ${KERNEL_ASTC_ISPC_H} AND EXISTS ${KERNEL_ISPC_O} AND EXISTS ${KERNEL_ASTC_ISPC_O})
        set(ISPC_TEXCOMP_AVAILABLE TRUE)

        set(ISPC_TEXCOMP_FILES
            ${ISPC_SRC_DIR}/ispc_texcomp.cpp
            ${ISPC_SRC_DIR}/ispc_texcomp_astc.cpp
            ${ISPC_SRC_DIR}/ispc_texcomp.h
        )

        add_library(ISPCTexcomp STATIC ${ISPC_TEXCOMP_FILES})
        target_include_directories(ISPCTexcomp PUBLIC ${ISPC_SRC_DIR})
        target_link_libraries(ISPCTexcomp PUBLIC ${KERNEL_ISPC_O} ${KERNEL_ASTC_ISPC_O})
        set_property(TARGET ISPCTexcomp PROPERTY CXX_STANDARD 17)

        message(STATUS "ISPC Texture Compressor enabled")
    else()
        set(ISPC_TEXCOMP_AVAILABLE FALSE)
        message(WARNING "ISPC headers could not be generated - texture compression disabled")
    endif()
else()
    set(ISPC_TEXCOMP_AVAILABLE FALSE)
    message(WARNING "ISPC compiler not found at ${ISPC_COMPILER} - texture compression disabled")
endif()
