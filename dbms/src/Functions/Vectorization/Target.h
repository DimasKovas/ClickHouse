#pragma once

namespace DB::Vectorization
{

enum class TargetArch : int {
    Scalar = 0,
    SSE3   = 1,
    SSE4   = 2,
    AVX    = 2,
    AVX2   = 4,
    AVX512 = 5,
};

#ifdef _USE_DYNAMIC_TARGET
    static constexpr bool UseDynamicTarget = true;
#else
    static constexpr bool UseDynamicTarget = true;
#endif

// BuildTarget is used for generating template for specific architecture.
#if defined(_TARGET_AVX512)
    // Well, actualy there are many different "AVX512" instruction sets...
    static constexpr const TargetArch BuildTarget = TargetArch::AVX512;
    #error "TODO"
#elif defined(_TARGET_AVX2)
    static constexpr const TargetArch BuildTarget = TargetArch::AVX2;
    #if defined(__clang__)
        #define BEGIN_VECTORIZABLE \
            #pragma clang attribute push (__attribute__((target("sse,sse2,sse3,ssse3,sse4,popcnt,abm,mmx,avx,avx2"))))
        #define END_VECTORIZABLE \
            #pragma clang attribute pop
    #elif defined(__GNUC__)
        #define BEGIN_VECTORIZABLE \
            #pragma GCC push_options \
            #pragma GCC target("sse,sse2,sse3,ssse3,sse4,popcnt,abm,mmx,avx,avx2,tune=native")
        #define END_VECTORIZABLE \
            #pragma GCC pop_options
    #else
        #error "Only CLANG and GCC compilers are supported"
    #endif
#elif defined(_TARGET_AVX)
    static constexpr const TargetArch BuildTarget = TargetArch::AVX;
    #if defined(__clang__)
        #define BEGIN_VECTORIZABLE \
            #pragma clang attribute push (__attribute__((target("sse,sse2,sse3,ssse3,sse4,popcnt,abm,mmx,avx"))))
        #define END_VECTORIZABLE \
            #pragma clang attribute pop
    #elif defined(__GNUC__)
        #define BEGIN_VECTORIZABLE \
            #pragma GCC push_options \
            #pragma GCC target("sse,sse2,sse3,ssse3,sse4,popcnt,abm,mmx,avx,tune=native")
        #define END_VECTORIZABLE \
            #pragma GCC pop_options
    #else
        #error "Only CLANG and GCC compilers are supported"
    #endif
#elif defined(_TARGET_SSE4)
    static constexpr const TargetArch BuildTarget = TargetArch::SSE4;
    #if defined(__clang__)
        #define BEGIN_VECTORIZABLE \
            #pragma clang attribute push (__attribute__((target("sse,sse2,sse3,ssse3,sse4,popcnt,abm,mmx"))))
        #define END_VECTORIZABLE \
            #pragma clang attribute pop
    #elif defined(__GNUC__)
        #define BEGIN_VECTORIZABLE \
            #pragma GCC push_options \
            #pragma GCC target("sse,sse2,sse3,ssse3,sse4,popcnt,abm,mmx,tune=native")
        #define END_VECTORIZABLE \
            #pragma GCC pop_options
    #else
        #error "Only CLANG and GCC compilers are supported"
    #endif
#else
    static constexpr const TargetArch BuildTarget = TargetArch::Scalar;
    #define BEGIN_VECTORIZABLE
    #define END_VECTORIZABLE
#endif

TargetArch GetRuntimeArch(); // Not implemented now.

} // namespace DB::Vectorization
