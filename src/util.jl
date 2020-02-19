c_pointer(x::T) where T = Base.unsafe_convert(Ref{T}, Base.cconvert(Ref{T}, x))
