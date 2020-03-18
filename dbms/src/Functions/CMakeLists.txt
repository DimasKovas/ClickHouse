configure_file(config_functions.h.in ${ConfigIncludePath}/config_functions.h)

include(${ClickHouse_SOURCE_DIR}/cmake/dbms_glob_sources.cmake)
add_headers_and_sources(clickhouse_functions .)

list(REMOVE_ITEM clickhouse_functions_sources IFunctionImpl.cpp FunctionFactory.cpp FunctionHelpers.cpp)
list(REMOVE_ITEM clickhouse_functions_headers IFunctionImpl.h FunctionFactory.h FunctionHelpers.h)

add_library(clickhouse_functions ${clickhouse_functions_sources})



macro(process_target TARGET ENABLE_LINIKNG)

    target_link_libraries(${TARGET}
    PUBLIC
        clickhouse_dictionaries
        clickhouse_dictionaries_embedded
        dbms
        ${CONSISTENT_HASHING_LIBRARY}
        consistent-hashing-sumbur
        ${CITYHASH_LIBRARIES}
        ${FARMHASH_LIBRARIES}
        ${METROHASH_LIBRARIES}
        murmurhash
        ${BASE64_LIBRARY}
        ${FASTOPS_LIBRARY}

    PRIVATE
        ${ZLIB_LIBRARIES}
        ${Boost_FILESYSTEM_LIBRARY}
)

    if (OPENSSL_CRYPTO_LIBRARY)
        if (${ENABLE_LINIKNG})
            target_link_libraries(${TARGET} PUBLIC ${OPENSSL_CRYPTO_LIBRARY})
        endif()
    endif()

    target_include_directories(${TARGET} SYSTEM PRIVATE ${DIVIDE_INCLUDE_DIR} ${METROHASH_INCLUDE_DIR} ${SPARSEHASH_INCLUDE_DIR})

    if (CONSISTENT_HASHING_INCLUDE_DIR)
        target_include_directories (${TARGET} PRIVATE ${CONSISTENT_HASHING_INCLUDE_DIR})
    endif ()

    if (CMAKE_BUILD_TYPE_UC STREQUAL "RELEASE" OR CMAKE_BUILD_TYPE_UC STREQUAL "RELWITHDEBINFO" OR CMAKE_BUILD_TYPE_UC STREQUAL "MINSIZEREL")
        # Won't generate debug info for files with heavy template instantiation to achieve faster linking and lower size.
        target_compile_options(${TARGET} PRIVATE "-g0")
    endif ()

    if (USE_ICU)
        if (${ENABLE_LINIKNG})
            target_link_libraries (${TARGET} PRIVATE ${ICU_LIBRARIES})
        endif()
        target_include_directories(${TARGET} SYSTEM PRIVATE ${ICU_INCLUDE_DIRS})
    endif ()

    if (USE_VECTORCLASS)
        target_include_directories (${TARGET} SYSTEM PRIVATE ${VECTORCLASS_INCLUDE_DIR})
    endif ()

    if (USE_FASTOPS)
        target_include_directories (${TARGET} SYSTEM PRIVATE ${FASTOPS_INCLUDE_DIR})
    endif ()

    if (USE_EMBEDDED_COMPILER)
        if (${ENABLE_LINIKNG})
            target_link_libraries(${TARGET} PRIVATE ${REQUIRED_LLVM_LIBRARIES})
        endif()
        target_include_directories(${TARGET} SYSTEM BEFORE PUBLIC ${LLVM_INCLUDE_DIRS})
    endif ()

    if (USE_BASE64)
        target_include_directories(${TARGET} SYSTEM PRIVATE ${BASE64_INCLUDE_DIR})
    endif()

    if (USE_XXHASH)
        if (${ENABLE_LINIKNG})
            target_link_libraries(${TARGET} PRIVATE ${XXHASH_LIBRARY})
        endif()
        target_include_directories(${TARGET} SYSTEM PRIVATE ${XXHASH_INCLUDE_DIR})
    endif()

    if (USE_H3)
        if (${ENABLE_LINIKNG})
            target_link_libraries(${TARGET} PRIVATE ${H3_LIBRARY})
        endif()
        target_include_directories(${TARGET} SYSTEM PRIVATE ${H3_INCLUDE_DIR})
    endif()

    if (USE_HYPERSCAN)
        if (${ENABLE_LINIKNG})
            target_link_libraries(${TARGET} PRIVATE ${HYPERSCAN_LIBRARY})
        endif()
        target_include_directories(${TARGET} SYSTEM PRIVATE ${HYPERSCAN_INCLUDE_DIR})
    endif()

    if (USE_SIMDJSON)
        if (${ENABLE_LINIKNG})
            target_link_libraries(${TARGET} PRIVATE ${SIMDJSON_LIBRARY})
        endif()
    endif()

    if (USE_RAPIDJSON)
        target_include_directories(${TARGET} SYSTEM PRIVATE ${RAPIDJSON_INCLUDE_DIR})
    endif()
endmacro()

process_target(clickhouse_functions YES)

if (ENABLE_TESTS)
    add_subdirectory (tests)
endif ()

option(USE_DYNAMIC_TARGET "Use dt" ON)

if (USE_DYNAMIC_TARGET)
    set(DYNAMIC_TARGETS
        startsWith.cpp
        endsWith.cpp
    )

    add_library(clickhouse_functions_sse4 ${DYNAMIC_TARGETS})
    process_target(clickhouse_functions_sse4 YES)
    target_compile_definitions(clickhouse_functions_sse4 PRIVATE _TARGET_SSE4)

    add_library(clickhouse_functions_avx ${DYNAMIC_TARGETS})
    process_target(clickhouse_functions_avx YES)
    target_compile_definitions(clickhouse_functions_avx PRIVATE _TARGET_AVX)

    add_library(clickhouse_functions_avx2 ${DYNAMIC_TARGETS})
    process_target(clickhouse_functions_avx2 YES)
    target_compile_definitions(clickhouse_functions_avx2 PRIVATE _TARGET_AVX2)

    target_link_libraries(clickhouse_functions PRIVATE
        clickhouse_functions_sse4
        clickhouse_functions_avx
        clickhouse_functions_avx2
    )
endif()

add_subdirectory(GatherUtils)
target_link_libraries(clickhouse_functions PRIVATE clickhouse_functions_gatherutils)

add_subdirectory(URL)
target_link_libraries(clickhouse_functions PRIVATE clickhouse_functions_url)

add_subdirectory(array)
target_link_libraries(clickhouse_functions PRIVATE clickhouse_functions_array)
