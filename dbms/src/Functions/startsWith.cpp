#include <DataTypes/DataTypeString.h>
#include <Functions/FunctionFactory.h>
#include <Functions/FunctionStartsEndsWith.h>

#include <Functions/Vectorization/Target.h>

namespace DB
{

using Vectorization::TargetArch;
using Vectorization::BuildTarget;

using FunctionStartsWith = FunctionStartsEndsWith<NameStartsWith>;

template<TargetArch>
void registerFunctionStartsWith(FunctionFactory & factory);

template<>
void registerFunctionStartsWith<BuildTarget>(FunctionFactory & factory)
{
    factory.registerFunction<FunctionStartsWith>();
}

}
