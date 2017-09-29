module CachedCalls

import Base.show

export AbstractCachedCall,
        CachedCall,
        description,
        func,
        func_args,
        result,
        call!,
        uncall!

abstract type AbstractCachedCall{F<:Function, A<:Tuple, R} end

description(cc::AbstractCachedCall) = cc.description
func(cc::AbstractCachedCall) = cc.f
func_args(cc::AbstractCachedCall) = cc.args
result(cc::AbstractCachedCall) = get(cc.result) #This will throw an error if cc hasn't been executed

is_executed(cc::AbstractCachedCall) = !isnull(cc.result)


#uncall! and call! are also applied recursively to any args that are AbstractCachedCalls
function call!(cc::AbstractCachedCall)
    if !is_executed(cc)
        cc.result = Nullable(func(cc)(call!(func_args(cc)...)...))
    end
    return result(cc)
end

call!() = ()
call!(a::CC, args...) where CC <: AbstractCachedCall = (call!(a), call!(args...)...)
call!(a, args...) = (a, call!(args...)...)

function uncall!(cc::AbstractCachedCall{F,A,R}) where {F, A, R}
    if is_executed(cc)
        cc.result = Nullable{R}()
        cc.args = uncall!(func_args(cc)...)
    end
    return cc
end

uncall!() = ()
uncall!(a::AbstractCachedCall{F,A,R}, args...) where {F, A, R} = (uncall!(a), uncall!(args...)...)
uncall!(a, args...) = (a, uncall!(args...)...)

function Base.show(s::IO, cc::AbstractCachedCall{F, A, R}) where {F, A, R}
    stat = "Unexecuted"
    if is_executed(cc)
        stat = "Executed"
    end
    write(s, "$stat cached call of function $(func(cc)) with arguments:")
    for a in func_args(cc)
        write(s, "\n$a")
    end
    if is_executed(cc)
        write(s, "\nResult: $(result(cc))")
    end
end

mutable struct CachedCall{F<:Function, A, R} <: AbstractCachedCall{F, A, R}
    description::String
    f::F
    args::A
    result::Nullable{R}
end

CachedCall(description::String, f::F, args::A, result_type = Any) where {F<:Function, A<:Tuple} = CachedCall{F, A, result_type}(description, f, args, Nullable{result_type}())
CachedCall(f::F, args::A, result_type = Any) where {F<:Function, A<:Tuple} = CachedCall("", f, args, Nullable{result_type}())

end # module
