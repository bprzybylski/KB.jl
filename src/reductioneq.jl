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
