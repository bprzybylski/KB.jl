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

# kbmag stores gen* NUL terminated (like strings)
function Base.unsafe_load(v::Ptr{Gen})
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

lhs(eq::ReductionEquation) = unsafe_load(eq.lhs)
rhs(eq::ReductionEquation) = unsafe_load(eq.rhs)

function Base.show(io::IO, re::ReductionEquation)
    lhs, rhs = unsafe_load(re.lhs), unsafe_load(re.rhs)
    println(io, "ReductionEquation (in rws generators):")
    println(io, "\t$lhs  → $rhs")
end
