function fopen(filename::String, mode::String="r")
    file = ccall(:fopen,
                 Ptr{Cvoid},
                 (Cstring, Cstring),
                 filename, mode)
    file == C_NULL && error("Error while reading $filename.")
    return file
end

fclose(file) = ccall(:fclose,
                     Cint,
                     (Ptr{Cvoid},),
                     file)

function RewritingSystem(filename::String,
    rws::RewritingSystem=RewritingSystem(); check::Bool=false)

    rws_ptr = Base.unsafe_convert(Ptr{RewritingSystem}, Ref(rws))
    input = fopen(filename)

    ccall((:read_kbinput, fsalib),
          Cvoid,
          (Ptr{Cvoid}, Bool, Ptr{RewritingSystem}),
          input, check, rws_ptr)

    fclose(input)

    return rws
end


export RewritingSystemInit, ReadKBInput

function RewritingSystemInit(rws::KB.RewritingSystem, cosets::Bool)
    # Called function name: set_defaults
    # Source: ./deps/src/kbmag-1.5.6/standalone/lib/kbfns.c:59
    ccall((:set_defaults, KB.fsalib),
          Cvoid,
          (Ptr{KB.RewritingSystem}, Bool),
          Base.unsafe_convert(Ptr{RewritingSystem}, Ref(rws)), cosets)

    # Set values
    rws.num_gens = Int32(0)
    rws.num_eqns = Int32(0)
    rws.num_inveqns = Int32(0)
    rws.current_maxstates = Int32(0)
    rws.Gislevel = false

    # Set pointers
    rws.name = C_NULL
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
end

RewritingSystemInit(rws::KB.RewritingSystem) = RewritingSystemInit(rws, false)

RewritingSystemLoad(rws::KB.RewritingSystem, filename::String) = RewritingSystemLoad(rws, filename, false)
