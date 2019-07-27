using Test
using KBmag

@testset "KBmag" begin
    # test that calls to fsa work
    m = "hello, world!"
    @test length(m) == ccall((:stringlen, KBmag.fsalib), Cint, (Cstring,), m)

    @test KBmag.RewritingSystem() isa KBmag.RewritingSystem

    kbmag_data_dir = joinpath("..", "deps", "src", "kbmag-1.5.8", "standalone", "kb_data")

    @testset "237" begin
        fname = joinpath(kbmag_data_dir, "237")
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

    # WARNING: This testset covers default data directories only!
    @testset "237-bin" begin
        groupname = "237"
        #=_RWS := rec(
            isRWS := true,
            ordering := "shortlex",
            tidyint := 20,
            generatorOrder := [a,A,b,B,c],
            inverses := [A,a,B,b,c],
            equations := [
            [a*a*a*a,A*A*A], [b*b,B], [B*A,c]
        ]);=#

        # remove kbprog output files
        for ext in [ ".kbprog", ".kbprog.ec", ".kbprog.reduce" ]
            s = joinpath(kbmag_data_dir, groupname * ext)
            isfile(s) && rm(s)
        end

        # call the kbprog binary
        r = KBmag.kbprog_call(groupname; execution_dir = kbmag_data_dir)
        # check whether output files exist
        for ext in [ ".kbprog", ".kbprog.ec", ".reduce" ]
            s = joinpath(kbmag_data_dir, groupname * ext)
            @test isfile(s)
        end

        # call the wordreduce bin (single input string)
        res = KBmag.wordreduce_call(groupname, ["a*a*a*a"]; execution_dir = kbmag_data_dir)
        @test length(res) == 1
        @test res[1] == "A^3"

        # call the wordreduce bin (all the quations plus one IdWord)
        res = KBmag.wordreduce_call(groupname, ["a*a*a*a", "a^4", "b*b", "B*A", "a*A"]; execution_dir = kbmag_data_dir)
        @test length(res) == 5
        @test res == ["A^3", "A^3", "B", "c", ""]

        # remove kbprog output files
        for ext in [ ".kbprog", ".kbprog.ec", ".reduce" ]
            s = joinpath(kbmag_data_dir, groupname * ext)
            isfile(s) && rm(s)
        end

        # what if the kbprog function was *not* called in advance?
        # call the wordreduce bin (single input string)
        res = KBmag.wordreduce_call(groupname, ["a*a*a*a"]; execution_dir = kbmag_data_dir)
        @test length(res) == 1
        @test res[1] == "A^3"

        # call the wordreduce bin (all the quations plus one IdWord)
        res = KBmag.wordreduce_call(groupname, ["a*a*a*a", "a^4", "b*b", "B*A", "a*A"]; execution_dir = kbmag_data_dir)
        @test length(res) == 5
        @test res == ["A^3", "A^3", "B", "c", ""]

        # non-proper wordreduceinput
        @test_throws ErrorException("#Input error: invalid entry in word.\n") KBmag.wordreduce_call(groupname, ["nonproperinput"]; execution_dir = kbmag_data_dir)

        # remove kbprog output files
        for ext in [ ".kbprog", ".kbprog.ec", ".reduce" ]
            s = joinpath(kbmag_data_dir, groupname * ext)
            isfile(s) && rm(s)
        end

        # test error-handling
        if !isfile(joinpath(kbmag_data_dir, "nonexistingfile"))
            @test_throws ErrorException("Error: cannot open file nonexistingfile\n") KBmag.kbprog_call("nonexistingfile"; execution_dir = kbmag_data_dir)
            # in the following test, there are no kbprog files so the error should be thrown by kbprog
            @test_throws ErrorException("Error: cannot open file nonexistingfile\n") KBmag.wordreduce_call("nonexistingfile", [""]; execution_dir = kbmag_data_dir)
        end
    end
end
