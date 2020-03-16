#include <DataTypes/DataTypeString.h>
#include <Functions/FunctionFactory.h>
#include <Functions/FunctionStartsEndsWith.h>

#include <Functions/Vectorization/Target.h>

namespace DB
{

using Vectorization::TargetArch;
using Vectorization::BuildTarget;

using FunctionEndsWith = FunctionStartsEndsWith<NameEndsWith>;

template<TargetArch>
void registerFunctionEndsWith(FunctionFactory & factory);

template<>
void registerFunctionEndsWith<BuildTarget>(FunctionFactory & factory)
{
    factory.registerFunction<FunctionEndsWith>();
}

}

