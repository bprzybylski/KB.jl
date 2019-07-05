module KBmag

using Libdl

if isfile(joinpath(dirname(@__FILE__), "..", "deps", "deps.jl"))
    include("../deps/deps.jl")
else
    error("KBmag not properly installed. Please (re) build KBmag and restart Julia")
end

# Wrapping functions
include("BinWrapper.jl")

end # module
