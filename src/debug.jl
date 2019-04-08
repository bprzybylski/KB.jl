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
