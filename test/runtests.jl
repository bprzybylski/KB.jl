using Test
using KB

m = "hello, world!"
@test length(m) == ccall((:stringlen, KB.fsalib), Cint, (Cstring,), m)
