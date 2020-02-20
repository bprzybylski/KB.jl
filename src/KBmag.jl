module KBmag

using Libdl

deps_file = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")

if isfile(deps_file)
    include(deps_file)
else
    error("KBmag not properly installed. Please (re) build KBmag and restart Julia")
end

include("types.jl")

KBType = Union{
    ReductionStruct,
    RewritingSystem,
    ReductionEquation,
    WDR,
    FSA,
    TableStruc,
    Srec
}

include("RWS.jl")
include("reduce.jl")
include("reductioneq.jl")

include("util.jl")
include("show.jl")

include("BinWrapper.jl")

end # module
