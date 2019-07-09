function reduce!(w::Vector{Gen}, rws::RewritingSystem)
    rs = ReductionStruct(rws)

    # Called function name: rws_reduce
    # Source: ./deps/src/kbmag-1.5.6/standalone/lib/rwsreduce.c:27
    r = ccall((:rws_reduce, fsalib),
                 Cint,
                 (Ptr{Gen}, Ref{ReductionStruct}),
                 w, rs)

    iszero(r) || error(
        "Call to rws_reduce in $fsalib returned non-zero output: $r")
    return w
end

function gen_names(rws::RewritingSystem)
    # In the following, we ommit the first element of rws.eqns as it is garbage
    # (kbmag does not use array elements indexed with zero)
    v = [unsafe_load(rws.gen_name, i) for i in 2:rws.num_gens+1]
    return String.(reinterpret.(UInt8, unsafe_load_ptrGen.(v)))
end

function replace_pows(s::AbstractString)
    reg = r"(\w+)\^(\d+)"
    m = match(reg, s)
    isnothing(m) && return [s]

    letter = m.captures[1]
    pow = parse(Int, m.captures[2])

    return [letter for _ in 1:pow]
end

function break_into_letters(w::AbstractString)
    syllables = split(w, "*")
    letters = vcat(replace_pows.(syllables)...)
    return letters
end

function reduce(w::String, rws::RewritingSystem)
    gensn = gen_names(rws)
    gensd = Dict(name=>Gen(i) for (i, name) in enumerate(gensn))

    letters = break_into_letters(w)
    for l in unique(letters)
        @assert haskey(gensd, l) "Invalid letter in provided word: $l\n"
    end

    letters_int8 = [gensd[l] for l in letters]
    reduce!(letters_int8, rws)

    len = findfirst(iszero, letters_int8) - 1
    return join([gensn[letters_int8[i]] for i in 1:len], "*")
end
