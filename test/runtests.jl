using Test
using KBmag

@testset "KBmag" begin
    # test that calls to fsa work
    m = "hello, world!"
    @test length(m) == ccall((:stringlen, KBmag.fsalib), Cint, (Cstring,), m)

    @test KBmag.RewritingSystem() isa KBmag.RewritingSystem

    kb_data_dir = joinpath("..", "deps", "src", "kbmag-1.5.6", "standalone", "kb_data")

    @testset "237" begin
        fname = joinpath(kb_data_dir, "237")
        #=_RWS := rec(
            isRWS := true,
            ordering := "shortlex",
            tidyint := 20,
            generatorOrder := [a,A,b,B,c],
            inverses := [A,a,B,b,c],
            equations := [
            [a*a*a*a,A*A*A], [b*b,B], [B*A,c]
        ]);=#

        @test KBmag.load(fname) isa KBmag.RewritingSystem
        rws = KBmag.load(fname)
        @test rws.num_eqns == 8
        @test KBmag.knuthbendix!(rws) == 0
        @test rws.num_eqns == 32

        (a,A,b,B,c) = [String(UInt8[i]) for i in 1:5]
        for w in [ a*A, A*a, b*B, B*b ] #trivial words
            v = Int8.(Vector{UInt8}(w))
            @test iszero(KBmag.reduce!(v, rws)[1])
        end

        for (lhs, rhs) in [(a*a*a*a, A*A*A), (b*b, B), (B*A, c)] #relations
            v = Int8.(Vector{UInt8}(lhs))
            KBmag.reduce!(v, rws)
            # @show v rhs
            @test all(v[i] == Vector{UInt8}(rhs)[i] for i in eachindex(rhs))
        end

        for w in [c*c, b*b*b, a*a*a*a*a*a*a, B*A*c]
            v = Int8.(Vector{UInt8}(w))
            @test iszero(KBmag.reduce!(v, rws)[1])
        end
    end
end
