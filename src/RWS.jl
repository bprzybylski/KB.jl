function load(filename::String,
              rws::RewritingSystem = RewritingSystem(),
              check::Bool = true)

    open(filename, "r") do file_hdlr
        c_file_hdlr = Libc.FILE(file_hdlr)

        # Called function name: read_kbinput
        # Source: ./deps/src/kbmag-1.5.8/standalone/lib/rwsio.c:224
        ccall((:read_kbinput, fsalib),
            Cvoid,
            (Ptr{Cvoid}, Bool, Ref{RewritingSystem}),
            c_file_hdlr, check, Ref(rws))
    end

    return rws
end

function save(filename::String,
              rws::RewritingSystem)

    open(filename, "w") do file_hdlr
        c_file_hdlr = Libc.FILE(file_hdlr)

        # Called function name: print_kboutput
        # Source: ./deps/src/kbmag-1.5.8/standalone/lib/rwsio.c:579
        ccall((:print_kboutput, fsalib),
            Cvoid,
            (Ptr{Cvoid}, Ref{RewritingSystem}),
            c_file_hdlr, Ref(rws))
    end

    @info "Succesfully written file $filename"
    return nothing
end

function knuthbendix!(rws::RewritingSystem)
    @info "Running Knuth-Bendix completion"

    # Called function name: kbprog
    # Source: ./deps/src/kbmag-1.5.8/standalone/lib/kbfns.c:129
    r = return ccall((:kbprog, fsalib),
                 Cint,
                 (Ref{RewritingSystem},),
                 Ref(rws))

    iszero(r) || "Knuth-Bendix completion returned non-zero status: $r"

    return rws
end

function gen_names(rws::RewritingSystem)
    # In the following, we ommit the first element of rws.eqns as it is garbage
    # (kbmag does not use array elements indexed with zero)
    v = [unsafe_load(rws.gen_name, i) for i in 2:rws.num_gens+1]
    return String.(reinterpret.(UInt8, unsafe_load_ptrGen.(v)))
end

# In the following, we ommit the first element of rws.eqns as it is garbage
# (kbmag does not use array elements indexed with zero)
eqns(rws::RewritingSystem) = [unsafe_load(rws.eqns, i) for i in 2:rws.num_eqns+1]

function Init(rws::RewritingSystem = RewritingSystem(),
              cosets::Bool = false)

    # Pointer to rws
    rws_ptr = Base.unsafe_convert(Ptr{RewritingSystem}, Ref(rws))

    # Called function name: set_defaults
    # Source: ./deps/src/kbmag-1.5.8/standalone/lib/kbfns.c:59
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
