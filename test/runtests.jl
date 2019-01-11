using CachedCalls
using Test

descr = "subtr"
f = -
args = (5,2)

cc = CachedCall(descr, f, args)
cc2 = CachedCall(f, args)

@test call!(cc) == call!(cc2) == 3

@test is_executed(cc)
@test func_args(cc) == args
@test func(cc) == f
@test result(cc) == 3
@test isequal(description(cc), descr)
#test show (uncalled)
@test isa(repr(cc), AbstractString)
uncall!(cc)
@test !is_executed(cc)

#test show (called)
@test isa(repr(cc), AbstractString)

##### test recursive args #####
ccr = CachedCall(descr, f, (4, cc))
@test call!(ccr) == 1 # 4-3
@test is_executed(ccr)
@test func_args(ccr) == (4, cc)
@test is_executed(cc) #the arg should be executed
@test func(ccr) == f
@test result(ccr) == 1
@test isa(repr(ccr), AbstractString)
uncall!(ccr)
@test !is_executed(ccr)
@test !is_executed(cc) #the arg should be unexecuted
@test isa(repr(ccr), AbstractString)
