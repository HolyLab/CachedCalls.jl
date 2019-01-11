module CachedCalls

import Base.show

export AbstractCachedCall,
        CachedCall,
        description,
        func,
        func_args,
        result,
        call!,
        uncall!,
        is_executed

abstract type AbstractCachedCall{F<:Function, A<:Tuple, R} end

description(cc::T) where {T<:AbstractCachedCall} = cc.description
func(cc::T) where {T<:AbstractCachedCall}  = cc.f
func_args(cc::T) where {T<:AbstractCachedCall} = cc.args
result(cc::T) where {T<:AbstractCachedCall} =
    is_executed(cc) ? cc.result : error("Call has not been executed.")

is_executed(cc::T) where {T<:AbstractCachedCall} = !(cc.result === nothing)

#uncall! and call! are also applied recursively to any args that are AbstractCachedCalls
function call!(cc::AbstractCachedCall)
    if !is_executed(cc)
        cc.result = func(cc)(call!(func_args(cc)...)...)
    end
    return result(cc)
end

call!() = ()
call!(a::CC, args...) where CC <: AbstractCachedCall = (call!(a), call!(args...)...)
call!(a, args...) = (a, call!(args...)...)

function uncall!(cc::AbstractCachedCall{F,A,R}) where {F, A, R}
    if is_executed(cc)
        cc.result = nothing
        uncall!(func_args(cc)...)
    end
    return cc
end

uncall!() = ()
uncall!(a::AbstractCachedCall{F,A,R}, args...) where {F, A, R} =
    begin uncall!(a); uncall!(args...) end
uncall!(a, args...) = uncall!(args...)

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

mutable struct CachedCall{F, A, R} <: AbstractCachedCall{F, A, R}
    description::String
    f::F
    args::A
    result::Union{R, Nothing}
end

CachedCall(description::String, f::F, args::A, result_type = Any) where {F<:Function, A<:Tuple} =
    CachedCall{F, A, result_type}(description, f, args, nothing)
CachedCall(f::F, args::A, result_type = Any) where {F<:Function, A<:Tuple} = CachedCall("", f, args, result_type)

end # module
