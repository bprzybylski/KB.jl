function reduce!(w::Vector{Gen}, rws::RewritingSystem)
    rs = ReductionStruct(rws)
    @info "Reducing $w via RewritingSystem"
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
    # the first one holds garbage?
    v = [unsafe_load(rws.gen_name, i) for i in 2:rws.num_gens+1]
    return String.(reinterpret.(UInt8, unsafe_load_ptrGen.(v)))
end

