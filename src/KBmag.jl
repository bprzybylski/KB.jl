module KBmag

using Libdl

deps_file = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")

if isfile(deps_file)
    include(deps_file)
else
    error("KBmag not properly installed. Please (re) build KBmag and restart Julia")
end

include("types.jl")         # struct types that reflect original structs from fsalib
include("RWS.jl")           # loading/saving and preparing rewriting systems
include("reduce.jl")        # word reduction
include("BinWrapper.jl")    # a wrapper for standalone binary files from the kbmag library

include("debug.jl")         # independent debug functions (ready to be removed at any moment)

end # module
