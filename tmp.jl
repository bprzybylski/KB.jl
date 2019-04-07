using Pkg
Pkg.activate(".")
# Pkg.build()

using KB

msg = "hi!"
ccall((:stringlen, KB.fsalib), Cint, (Cstring,), msg)

function name(rws::RewritingSystem)
    k = findfirst(i -> i == 0, rws.name)
    k == 1 && return ""
    return String(reinterpret(UInt8, collect(rws.name[1:k-1])))
end


begin
    kb_data_dir = joinpath("deps", "src", "kbmag-1.5.6", "standalone", "kb_data")

    kb_examples = readdir(kb_data_dir)
    example_file = joinpath(kb_data_dir, kb_examples[14])
    lines = open(ex, "r") do f
        readlines(f)
    end

    println(join(lines, "\n"))
end

rws = KB.RewritingSystem()
name(rws)
RewritingSystem(example_file, rws)
name(rws)
@show rws;

function read_rws(filename, rws; check=false)
    rws_ptr = Base.unsafe_convert(Ptr{KB.RewritingSystem}, Ref(rws))
    r = ccall((:read_rws, KB.fsalib),
        Cint,
        (Cstring, Bool, Ptr{KB.RewritingSystem}),
        filename, false, rws_ptr)

    r == 0 || error("Error while reading $filename.")

    return rws
end

rws = KB.RewritingSystem()
name(rws)
read_rws(example_file, rws)
name(rws)
@show rws;


read_rws(ex, rws)
@show rws;
