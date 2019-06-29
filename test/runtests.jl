using Test
using KB

# Library integration
m = "hello, world!"
@test length(m) == ccall((:stringlen, KB.fsalib), Cint, (Cstring,), m)
