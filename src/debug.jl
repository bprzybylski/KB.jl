KBType = Union{
    ReductionStruct,
    RewritingSystem,
    ReductionEquation,
    WDR,
    FSA,
    TableStruc,
    Srec
}

function Base.show(io::IO, kbt::KBType)
    println(io, typeof(kbt), ":")
    for name in fieldnames(typeof(kbt))
        if isdefined(kbt, name)
            c = getfield(kbt, name)
            content = "[$(typeof(c))] $c"
        else
            content = "#undef"
        end
        println(io, " • ", name, " → ", content)
    end
end

# kbmag stores gen* NULL terminated (like strings)
function unsafe_load_ptrGen(v::Ptr{Gen})
    result = Vector{Gen}()
    idx = 1
    while true
        a = unsafe_load(v, idx)
        iszero(a) && break
        push!(result, a)
        idx += 1
    end
    return result
end

function Base.show(io::IO, re::ReductionEquation)
    lhs, rhs = unsafe_load_ptrGen(re.lhs), unsafe_load_ptrGen(re.rhs)
    println(io, "ReductionEquation (in rws generators):")
    println(io, "\t$lhs  → $rhs")
end
