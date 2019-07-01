using Test
using KBmag

# Library integration
m = "hello, world!"
@test length(m) == ccall((:stringlen, KBmag.fsalib), Cint, (Cstring,), m)
