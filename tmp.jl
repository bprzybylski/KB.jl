using Pkg
Pkg.activate(".")
# Pkg.build()

using KB

msg = "hi!"
ccall((:stringlen, KB.fsalib), Cint, (Cstring,), msg)

rws = KB.RewritingSystem()



begin
    kb_data_dir = joinpath("deps", "src", "kbmag-1.5.6", "standalone", "kb_data")

    kb_examples = readdir(kb_data_dir)
    ex = joinpath(kb_data_dir, kb_examples[1])
end

RewritingSystem(ex, rws)

