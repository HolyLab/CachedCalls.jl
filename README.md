# CachedCalls
[![Build Status](https://travis-ci.org/HolyLab/CachedCalls.svg?branch=master)](https://travis-ci.com/HolyLab/CachedCalls.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/y3d4brokc6kq6aga?svg=true)](https://ci.appveyor.com/project/Cody-G/cachedcalls/branch/master)
[![codecov](https://codecov.io/gh/HolyLab/CachedCalls/branch/master/graph/badge.svg)](https://codecov.io/gh/HolyLab/CachedCalls.jl)

When created, a `CachedCall` stores a function, its arguments, and optionally a text description.

One can then run the function via `call!(cc::CachedCall)`.  The result of the function is stored in the object itself and can be retrieved again later with `result(cc::CachedCall)`.  A function that has already been `call!`ed will not execute again unless its cache is cleared with `uncall!(cc::Cachedcall)`.

Importantly if any of the function args stored in a `CachedCall` is itself of type `CachedCall` then it is also executed when `call!` runs on the parent.  Thus `call!` is recursive.

So far CachedCalls seem useful when all of the following coincide:
- It's desirable to store both a function and its arguments
- The return value of the funcion is needed more than once
- The call is too expensive to re-run every time
