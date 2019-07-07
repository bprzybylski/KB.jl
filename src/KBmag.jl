module KBmag

using Libdl

deps_file = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")

if isfile(deps_file)
    include(deps_file)
else
    error("KBmag not properly installed. Please (re) build KBmag and restart Julia")
end

include("types.jl")
include("RWS.jl")
include("reduce.jl")

include("debug.jl")

end # module
