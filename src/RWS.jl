function Load(filename::String,
              rws::RewritingSystem = RewritingSystem(),
              check::Bool = false)
    # Pointer to rws
    rws_ptr = Base.unsafe_convert(Ptr{RewritingSystem}, Ref(rws))

    file_hdlr = open(filename, "r")
    c_file_hdlr = Libc.FILE(file_hdlr)

    # Called function name: read_kbinput
    # Source: ./deps/src/kbmag-1.5.6/standalone/lib/rwsio.c:224
    ccall((:read_kbinput, fsalib),
          Cvoid,
          (Ptr{Cvoid}, Bool, Ptr{RewritingSystem}),
          c_file_hdlr, check, rws_ptr)

    close(file_hdlr)

    return rws
end

function Init(rws::RewritingSystem = RewritingSystem(),
              cosets::Bool = false)

    # Pointer to rws
    rws_ptr = Base.unsafe_convert(Ptr{RewritingSystem}, Ref(rws))

    # Called function name: set_defaults
    # Source: ./deps/src/kbmag-1.5.6/standalone/lib/kbfns.c:59
    ccall((:set_defaults, fsalib),
          Cvoid,
          (Ptr{RewritingSystem}, Bool),
          rws_ptr, cosets)

    # Set values
    rws.num_gens = Int32(0)
    rws.num_eqns = Int32(0)
    rws.num_inveqns = Int32(0)
    rws.current_maxstates = Int32(0)
    rws.Gislevel = false

    # Set pointers
    rws.name = ntuple(_->Cchar(0), 256)
        #rws.weight = C_NULL
        #rws.level = C_NULL
        #rws.inv_of = C_NULL
    rws.gen_name = C_NULL
    rws.eqns = C_NULL
    rws.reduction_fsa = C_NULL
    rws.wd_fsa = C_NULL
        #rws.new_wd = C_NULL
    rws.history = C_NULL
    rws.slowhistory = C_NULL
    rws.slowhistorysp = C_NULL
    rws.preflen = C_NULL
    rws.prefno = C_NULL
    rws.testword1 = C_NULL
    rws.testword2 = C_NULL
    rws.eqn_no = C_NULL
        #rws.wd_record = C_NULL
        #rws.wd_alphabet = C_NULL
        #rws.subwordsG = C_NULL

    return rws
end

function Prog(rws::RewritingSystem)::Int
    # Called function name: kbprog
    # Source: ./deps/src/kbmag-1.5.6/standalone/lib/kbfns.c:129
    return ccall((:kbprog, fsalib),
                 Cint,
                 (Ptr{RewritingSystem},),
                 Ref(rws))
end

function Reduce(w::String,
                rws::RewritingSystem)::Int

    rs = ReductionStruct()
    rs.rws = Ptr{RewritingSystem}(pointer_from_objref(rws))
    rs.wd_fsa = rws.wd_fsa
    separator = rws.num_gens
    wa = C_NULL
    weight = rws.weight
    maxreducelen = Int32(32767)

    # Called function name: rws_reduce
    # Source: ./deps/src/kbmag-1.5.6/standalone/lib/rwsreduce.c:27
    return ccall((:rws_reduce, fsalib),
                 Cint,
                 (Ptr{Gen}, Ptr{ReductionStruct}),
                 pointer(w), Ref(rs))
end
