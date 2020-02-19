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

function Base.show(io::IO, ::MIME"text/plain", re::ReductionEquation)
    println(io, "ReductionEquation (in rws generators):")
    print(io, "\t$(lhs(re)) → $(rhs(re))")
end
Base.show(io::IO, re::ReductionEquation) = print(io, "$(lhs(re)) → $(rhs(re))")

function show_equations(rws::RewritingSystem)
    names = gen_names(rws)
    lhs_rhs = [
        (join((names[l] for l in lhs(eq)), "*"),
         join((names[r] for r in rhs(eq)), "*")) for eq in eqns(rws)]
    k = maximum(x->length(first(x)), lhs_rhs)
    for (l,r) in lhs_rhs
        if isempty(r)
            r = "(id)"
        end
        println(lpad(l, k+2), "\t→\t", r)
    end
end
