using Groups

"""
    load(filename::String,
         rws::RewritingSystem = RewritingSystem(),
         check::Bool = true)

Reads an RWS description from a file determined by the `filename` parameter. Returns a `RewritingSystem` structure that reflects the input file. If the `rws` parameter points to an existing structure, the file will be loaded into that structure. The `check` parameter determines whether words in equations should be additionally checked.
"""
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

"""
    save(filename::String,
         rws::RewritingSystem)

Saves the RWS described by the `rws` parameter into a file determines by the `filename` parameter.
"""
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

"""
    clean(rws::RewritingSystem)

Prepares `rws` to be removed from memory. It frees the memory allocated by Julia and calls an internal `kbmag` function to free the memory allocated by C.
"""
function clean(rws::RewritingSystem)
    rws.gen_name = C_NULL
    rws.inv_of = C_NULL

    #= In `rwsiob.c:421` we have the loop:
     =     for (i = 1; i <= rwsptr->num_gens + 1; i++)
     = so we set rws.num_gens to -1 in order to avoid
     = executing this loop
     =#
    rws.num_gens = -1

    # Called function name: rws_clear
    # Source: ./deps/src/kbmag-1.5.8/standalone/lib/rwsiob.c:413
    ccall((:rws_clear, fsalib),
                 Cvoid,
                 (Ref{RewritingSystem},),
                 Ref(rws))
end

"""
    knuthbendix!(rws::RewritingSystem)

Runs a Knuth-Bendix completion on a given `RewritingSystem` structure determined by the `rws` parameter.
"""
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
    return String.(reinterpret.(UInt8, unsafe_load.(v)))
end

# In the following, we ommit the first element of rws.eqns as it is garbage
# (kbmag does not use array elements indexed with zero)
eqns(rws::RewritingSystem) = [unsafe_load(rws.eqns, i) for i in 2:rws.num_eqns+1]

"""
    Init(rws::RewritingSystem = RewritingSystem(),
         cosets::Bool = false)

Generates and returns a new `RewritingSystem` structure that has its fields set up. If the `rws` parameter points to an existing structure, the setup will be performed on this structure. The `cosets` parameter determines the initial value of the `cosets` field of the returned structure.
"""
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

"""
    BuildRWS(G::FPGroup)

Builds a RewritingSystem based on a finitely-presented group.
This function is based on the ./deps/src/kbmag-1.5.8/standalone/lib/rwsio.c:224-525 implementation.
"""
function BuildRWS(G::Groups.FPGroup;
                  isConfluent = false,
                  tidyint = 0,
                  maxeqns = 32767,
                  maxstates = 0,
                  confnum = 500,
                  sorteqns = false,
                  maxoplen = 0,
                  maxlenleft = 0,
                  maxlenright = 0,
                  maxoverlaplen = 0,
                  maxwdiffs = 512,
                  maxreducelen = 32767,
                  rkminlen = 0,
                  rkmineqns = 0,
                  check = true,
                  ordering::KBMOrderings = SHORTLEX)
    rws = Init()

    # Set basic parameters
    if isConfluent && !rws.resume_with_orig
        error("System is already confluent!")
    end

    if !rws.tidyintset && tidyint > 0
        rws.tidyint = tidyint
        rws.tidyintset = true # This was not in the original file
    end

    if rws.inv_of != C_NULL
        error("Input error: 'maxeqns' field must precede 'inverses' field")
    elseif !rws.maxeqnsset && !rws.resume_with_orig && maxeqns > 16
        rws.maxeqns = maxeqns
        rws.maxeqnsset = true # This was not in the original file
    end

    if rws.inv_of != C_NULL
        error("Input error: 'maxstates' field must precede 'inverses' field")
    elseif !rws.maxstatesset && maxstates > 128
        rws.maxstates = maxstates
        rws.maxstatesset = true # This was not in the original file
    end

    if !rws.confnumset && confnum > 0
        rws.confnum = confnum
        rws.confnumset = true # This was not in the original file
    end

    rws.sorteqns = sorteqns

    if rws.maxoplen == 0 && maxoplen >= 0
        rws.sorteqns = true
        rws.maxoplen = maxoplen
    end

    if maxlenleft > 0 && maxlenright > 0 && rws.maxlenleft == 0 && rws.maxlenright == 0
        rws.maxlenleft = maxlenleft
        rws.maxlenright = maxlenright
    end

    if maxoverlaplen > 0
        rws.maxoverlaplen = maxoverlaplen
    end

    if !rws.maxwdiffset && maxwdiffs > 16
        rws.maxwdiffs = maxwdiffs
        rws.maxwdiffset = true # This was not in the original file
    end

    if !rws.maxreducelenset && maxreducelen > 4096
        rws.maxreducelen = maxreducelen
        rws.maxreducelenset = true # This was not in the original file
    end

    if rkminlen > 0 && rkmineqns > 0 && rws.rkminlen == 0 && rws.rkmineqns == 0
        rws.rkminlen = rkminlen
        rws.rkmineqns = rkmineqns
        rk_on = true # This was not in the original file
    end

    if !rws.orderingset
        rws.ordering = ordering
        rws.orderingset = true # This was not in the original file
    end

    #=
        mutable struct FPGroup <: AbstractFPGroup
            gens::Vector{FPSymbol}
            rels::Dict{FPGroupElem, FPGroupElem}
        end
    =#

    # Generators
    symmetric_gens = unique([G.gens; inv.(G.gens)])

    C = Symbol[Symbol(""); unique_id.(symmetric_gens)]
    # Get the number of generators
    rws.num_gens = length(C) - 1
    # Move the generators to the RWS. Warning. These are not processed and are assumed to be correct.
    ref_C = Base.cconvert(Ptr{Ptr{Int8}}, C)
    rws.gen_name = Base.unsafe_convert(Ptr{Ptr{Int8}}, ref_C)

    # Called function name: process_names
    # Source: ./deps/src/kbmag-1.5.8/standalone/lib/miscio.c:362
    ccall((:process_names, fsalib), Cvoid, (Ptr{Ptr{Int8}}, Cint), ref_C, rws.num_gens)

    # Weights
    # [Ignored]
    rws.ordering == WTLEX && throw("Unimplemented")

    # Level
    # [Ignored]
    rws.ordering == WREATHPROD && throw("Unimplemented")

    # Inverses
    # We assume that every generator has an inversion
    inv_of = Int32[0; map(g->findfirst(==(inv(g)), symmetric_gens), symmetric_gens)]
    rws.inv_of = pointer(inv_of)

    # Initialize equations
    # Called function name: initialise_eqns
    # Source: ./deps/src/kbmag-1.5.8/standalone/lib/rwsio.c:89
    ccall((:initialise_eqns, fsalib), Cvoid, (Ref{RewritingSystem},), rws)

    t = tempname()
    open(t, "w") do file_hdlr
        write(file_hdlr, compatible_eqnstr(G))
    end

    open(t, "r") do file_hdlr
        c_file_hdlr = Libc.FILE(file_hdlr)

        # Called function name: read_eqns
        # Source: ./deps/src/kbmag-1.5.8/standalone/lib/rwsio.c:115
        ccall((:read_eqns, fsalib),
            Cvoid,
            (Ptr{Cvoid}, Bool, Ref{RewritingSystem}),
            c_file_hdlr, check, Ref(rws))
    end

    # Done
    # [non-applicable]

    # Free eqn_no allocated in initialize_eqns
    Libc.free(rws.eqn_no)

    return rws, (ref_C, inv_of)
end

########
# To be separated

function compatible_wordstr(s::Groups.GSymbol, translate_names = unique_id)
    isone(s) && return ""
    return join(
        (translate_names(s) for _ in 1:abs(s.pow)),
        "*")
end

function compatible_wordstr(w::Groups.GWord, translate_names = unique_id)
    isone(w) && return "IdWord"
    return join(
        (compatible_wordstr(s, translate_names) for s in w.symbols),
        "*")
end

function compatible_eqnstr(lhs, rhs, f = compatible_wordstr)
    return "[$(f(lhs)),$(f(rhs))]"
end

function compatible_eqnstr(G::Groups.AbstractFPGroup)
    return "[" * join((compatible_eqnstr(r...) for r in G.rels), ",") * "]"
end

function unique_id(s::Groups.GSymbol)
    if s.pow > 0
        return(Symbol(lowercase(string(s.id))))
    elseif s.pow < 0
        return(Symbol(uppercase(string(s.id))))
    else # s.pow == 0
        return Symbol("IdWord")
    end
end
