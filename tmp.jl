using Pkg
Pkg.activate(".")
# Pkg.build()
using KBmag

function name(rws::KBmag.RewritingSystem)
    k = findfirst(iszero, rws.name)
    k == 1 && return ""
    return String(reinterpret(UInt8, collect(rws.name[1:k-1])))
end

example_rws, rws_rec_string = let
    kb_data_dir = joinpath("deps", "src", "kbmag-1.5.6", "standalone", "kb_data")
    kb_examples = readdir(kb_data_dir)
    fname = joinpath(kb_data_dir, kb_examples[1])
    lines = open(fname, "r") do f
        readlines(f)
    end
    fcontent = join(lines, "\n")
    fname, fcontent
end

println(rws_rec_string)

begin
    rws = KBmag.RewritingSystem();
    KBmag.load(example_rws, rws);
    @show name(rws);
    @show rws.num_eqns
    KBmag.knuthbendix!(rws)
    @show rws.num_eqns
    KBmag.save("/tmp/aaa", rws)
end;

KBmag.ReductionStruct(rws)

let (a,A,b,B,c) = [String(UInt8[i]) for i in 1:5]
    w = b*b
    v= reinterpret(Int8, Vector{UInt8}(w))
    @show w v
    KBmag.reduce!(v, rws)
    @show v
end;

@show KBmag.gen_names(rws)

let w = "b*b"
    @show w
    @show KBmag.reduce(w, rws)
end
