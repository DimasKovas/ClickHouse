#include "config_functions.h"

#include <Functions/Vectorization/Target.h>

namespace DB
{

class FunctionFactory;

void registerFunctionRepeat(FunctionFactory &);
void registerFunctionEmpty(FunctionFactory &);
void registerFunctionNotEmpty(FunctionFactory &);
void registerFunctionLength(FunctionFactory &);
void registerFunctionLengthUTF8(FunctionFactory &);
void registerFunctionIsValidUTF8(FunctionFactory &);
void registerFunctionToValidUTF8(FunctionFactory &);
void registerFunctionLower(FunctionFactory &);
void registerFunctionUpper(FunctionFactory &);
void registerFunctionLowerUTF8(FunctionFactory &);
void registerFunctionUpperUTF8(FunctionFactory &);
void registerFunctionReverse(FunctionFactory &);
void registerFunctionReverseUTF8(FunctionFactory &);
void registerFunctionsConcat(FunctionFactory &);
void registerFunctionFormat(FunctionFactory &);
void registerFunctionSubstring(FunctionFactory &);
void registerFunctionCRC(FunctionFactory &);
void registerFunctionAppendTrailingCharIfAbsent(FunctionFactory &);
template <Vectorization::TargetArch Target>
void registerFunctionStartsWith(FunctionFactory &);
template <Vectorization::TargetArch Target>
void registerFunctionEndsWith(FunctionFactory &);
void registerFunctionTrim(FunctionFactory &);
void registerFunctionRegexpQuoteMeta(FunctionFactory &);

#if USE_BASE64
void registerFunctionBase64Encode(FunctionFactory &);
void registerFunctionBase64Decode(FunctionFactory &);
void registerFunctionTryBase64Decode(FunctionFactory &);
#endif

void registerFunctionsString(FunctionFactory & factory)
{
    registerFunctionRepeat(factory);
    registerFunctionEmpty(factory);
    registerFunctionNotEmpty(factory);
    registerFunctionLength(factory);
    registerFunctionLengthUTF8(factory);
    registerFunctionIsValidUTF8(factory);
    registerFunctionToValidUTF8(factory);
    registerFunctionLower(factory);
    registerFunctionUpper(factory);
    registerFunctionLowerUTF8(factory);
    registerFunctionUpperUTF8(factory);
    registerFunctionReverse(factory);
    registerFunctionCRC(factory);
    registerFunctionReverseUTF8(factory);
    registerFunctionsConcat(factory);
    registerFunctionFormat(factory);
    registerFunctionSubstring(factory);
    registerFunctionAppendTrailingCharIfAbsent(factory);
    registerFunctionStartsWith<Vectorization::TargetArch::Scalar>(factory);
    registerFunctionEndsWith<Vectorization::TargetArch::Scalar>(factory);
// #if USE_DYNAMIC_TARGET
#if 1
    registerFunctionStartsWith<Vectorization::TargetArch::SSE4>(factory);
    registerFunctionEndsWith<Vectorization::TargetArch::SSE4>(factory);
    registerFunctionStartsWith<Vectorization::TargetArch::AVX>(factory);
    registerFunctionEndsWith<Vectorization::TargetArch::AVX>(factory);
    registerFunctionStartsWith<Vectorization::TargetArch::AVX2>(factory);
    registerFunctionEndsWith<Vectorization::TargetArch::AVX2>(factory);
#endif
    registerFunctionTrim(factory);
    registerFunctionRegexpQuoteMeta(factory);
#if USE_BASE64
    registerFunctionBase64Encode(factory);
    registerFunctionBase64Decode(factory);
    registerFunctionTryBase64Decode(factory);
#endif
}

}
