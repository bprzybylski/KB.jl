"""
    reduce!(w::Vector{Gen},
            rws::RewritingSystem)

Reduces `w` in-place based on `rws`. Here, `w` is a vector of indices that correspond to proper generators in `rws`.
"""
function reduce!(w::AbstractVector{Gen}, rws::RewritingSystem)
    rs = ReductionStruct(rws)

    # Called function name: rws_reduce
    # Source: ./deps/src/kbmag-1.5.6/standalone/lib/rwsreduce.c:27
    r = ccall((:rws_reduce, fsalib),
                 Cint,
                 (Ref{Gen}, Ref{ReductionStruct}),
                 w, rs)

    iszero(r) || error(
        "Call to rws_reduce in $fsalib returned non-zero output: $r")
    return w
end

"""
    replace_pows(s::AbstractString)

For a given string `s` in a form of `·^n` returns an array of `n` copies of `·`.

# Examples
```julia-repl
julia> KBmag.replace_pows("xyz^3")
3-element Array{SubString{String},1}:
 "xyz"
 "xyz"
 "xyz"
```

```julia-repl
julia> KBmag.replace_pows("xyz")
1-element Array{String,1}:
 "xyz"
```
"""
function replace_pows(s::AbstractString)
    reg = r"(\w+)\^(\d+)"
    m = match(reg, s)
    isnothing(m) && return [s]

    letter = m.captures[1]
    pow = parse(Int, m.captures[2])

    return [letter for _ in 1:pow]
end

"""
    break_into_letters(w::AbstractString)

Converts a string `w` in a form of a product of powers into an array of proper factors.

# Examples
```julia-repl
julia> KBmag.break_into_letters("xyz^3*u*w^2")
6-element Array{SubString{String},1}:
 "xyz"
 "xyz"
 "xyz"
 "u"
 "w"
 "w"
```
"""
function break_into_letters(w::AbstractString)
    syllables = split(w, "*")
    letters = vcat(replace_pows.(syllables)...)
    return letters
end

"""
    reduce(w::String,
           rws::RewritingSystem)

Reduces `w` based on `rws`. Here, `w` is a string in a form of a product of powers of generators. The function returns a string that represents a reduced word.
"""
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
