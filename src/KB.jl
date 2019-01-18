module KB

using Libdl

if isfile(joinpath(dirname(@__FILE__), "..", "deps", "deps.jl"))
    include("../deps/deps.jl")
else
    error("KB not properly installed. Please (re) build KB and restart julia")
end

end # module
