#=
    Enum name: SrecType
    Original enum name: srec_type
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/fsa.h:29-38
=#
@enum SrecType begin
    SIMPLE
    IDENTIFIERS
    WORDS
    LISTOFWORDS
    LISTOFINTS
    STRINGS
    LABELED
    PRODUCT
end

#=
    Enum name: StorageType
    Original enum name: storage_type
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/fsa.h:40
=#
@enum StorageType begin
    DENSE
    SPARSE
    COMPACT
end

#=
    Enum name: KBMFlagStrings
    Original enum name: kbm_flag_strings
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/fsa.h:41-50
=#
@enum KBMFlagStrings begin
    DFA
    NFA
    MIDFA
    MINIMIZED
    BFS
    ACCESSIBLE
    TRIM
    RWS
end

#=
    Enum name: KBMOrderings
    Original enum name: kbm_orderings
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/rws.h:15-22
=#
@enum KBMOrderings begin
    SHORTLEX
    RECURSIVE
    RT_RECURSIVE
    WTLEX
    WREATHPROD
    NONE
end

#=
    Type name: Gen (Char)
    Original type name: gen (char)
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/defs.h:46
=#
const Gen = Cchar

#=
    Type name: SetToLabelsType
    Original type name: setToLabelsType
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/fsa.h:55
=#
const SetToLabelsType = Int8

#=
    Const name: MaxChar / MaxGen
    Original const name: MAXCHAR / MAXGEN
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/defs.h:20,45
=#
const MaxChar = MaxGen = 127

#=
    Struct name: Srec
    Original struct name: srec
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/fsa.h:57-86
=#
mutable struct Srec
    type::SrecType
    size::Int32
    names::Ptr{Ptr{Cchar}}
    words::Ptr{Ptr{Gen}}
    wordslist::Ptr{Ptr{Ptr{Gen}}}
    intlist::Ptr{Ptr{Int}}
    arity::Int32
    padding::Cchar
    alphabet::Ptr{NTuple{MaxGen+1,Cchar}} # Originally char *alphabet[MAXGEN + 1]
    alphabet_size::Int32
    base::Ptr{Srec}
    labels::Ptr{Srec}
    setToLabels::Ptr{SetToLabelsType}
end

#=
    Struct name: TableStruc
    Original struct name: table_struc
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/fsa.h:88-164
=#
mutable struct TableStruc
    filename::Ptr{Cchar}
    table_type::StorageType
    printing_format::StorageType
    comment_state_numbers::Bool
    numTransitions::Int32
    maxstates::Int32
    denserows::Int32
    table_data_ptr::Ptr{Ptr{Int}}
    table_data_dptr::Ptr{Ptr{Ptr{Int}}}
    ctable_data_ptr::Ptr{Ptr{UInt}}
end

#=
    Const name: NumKBMFlagStrings
    Original const name: num_kbm_flag_strings
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/defs.h:51
=#
const NumKBMFlagStrings = 8

#=
    Struct name: FSA
    Original struct name: fsa
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/fsa.h:166-194
=#
mutable struct FSA
    states::Ptr{Srec}
    alphabet::Ptr{Srec}
    num_initial::Int32
    initial::Ptr{Int}
    is_initial::Ptr{Bool}
    num_accepting::Int32
    accepting::Ptr{Int}
    is_accepting::Ptr{Bool}
    is_accessible::Ptr{Bool}
    flags::NTuple{NumKBMFlagStrings, Bool} # Originally boolean flags[num_kbm_flag_strings]
    table::Ptr{TableStruc}
    # Constructor
    FSA() = new()
end

#=
    Struct name: WDR
    Original struct name: wdr
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/rws.h:115-119
=#
mutable struct WDR
    num_eqns::Int32
    num_states::Int32
    num_diff::Int32
end

#=
    Struct name: ReductionEquation
    Original struct name: reduction_equation
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/rws.h:34-40
=#
mutable struct ReductionEquation
    lhs::Ptr{Gen}
    rhs::Ptr{Gen}
    done::Bool
    changed::Bool
    eliminated::Bool
end

#=
    Struct name: RewritingSystem
    Original struct name: rewriting_system
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/rws.h:42-160
=#
mutable struct RewritingSystem
    name::NTuple{256,Cchar} # Originally char name[256] (what to do about that?)
    ordering::KBMOrderings
    weight::Ptr{Int}
    level::Ptr{Int}
    confluent::Bool
    num_gens::Int32
    num_eqns::Int32
    num_inveqns::Int32
    inv_of::Ptr{Int}
    gen_name::Ptr{Ptr{Cchar}}
    eqns::Ptr{ReductionEquation}
    reduction_fsa::Ptr{FSA}
    num_states::Int32
    worddiffs::Bool
    wd_fsa::Ptr{FSA}
    cosets::Bool
    wd_reorder::Bool
    new_wd::Ptr{Bool}
    maxlenleft::Int32
    maxlenright::Int32
    maxoverlaplen::Int32
    hadlongoverlap::Bool
    rkminlen::Int32
    rkmineqns::Int32
    rk_on::Bool
    history::Ptr{Int}
    slowhistory::Ptr{Ptr{Int}}
    slowhistorysp::Ptr{Int}
    preflen::Ptr{Int}
    prefno::Ptr{Int}
    maxpreflen::Int32
    outputprefixes::Bool
    testword1::Ptr{Gen}
    testword2::Ptr{Gen}
    sorteqns::Bool
    tidyint::Int32
    eqn_no::Ptr{Int}
    nneweqns::Int32
    tot_eqns::Int32
    hadct::Int32
    maxhad::Int32
    maxoplen::Int32
    print_eqns::Bool
    maxeqns::Int32
    hadmaxeqns::Bool
    confnum::Int32
    oldconfnum::Int32
    maxslowhistoryspace::Int32
    maxreducelen::Int32
    maxstates::Int32
    current_maxstates::Int32
    double_states::Bool
    init_fsaspace::Int32
    maxwdiffs::Int32
    exit_status::Int32
    tidyon::Bool
    tidyon_now::Bool
    wd_record::Ptr{WDR}
    num_cycles::Int32
    eqn_factor::Int32
    states_factor::Int32
    halting_factor::Int32
    min_time::Int32
    halting::Bool
    do_conf_test::Bool
    lostinfo::Bool
    resume::Bool
    resume_with_orig::Bool
    tidyintset::Bool
    maxeqnsset::Bool
    maxstatesset::Bool
    orderingset::Bool
    silentset::Bool
    verboseset::Bool
    confnumset::Bool
    maxreducelenset::Bool
    maxwdiffset::Bool
    separator::Int32
    maxlhsrellen::Int32
    maxsubgenlen::Int32
    maxcosetlen::Int32
    finitestop::Bool
    Hoverlaps::Bool
    Gislevel::Bool
    Hislevel::Bool
    Hhasinverses::Bool
    wd_alphabet::Ptr{Srec}
    subwordsG::Ptr{Ptr{Gen}}
    # Constructor
    function RewritingSystem()
        rws = new(ntuple(_->Cchar(0), 256))
        rws_ptr = Base.unsafe_convert(Ptr{RewritingSystem}, Ref(rws))
        ccall((:set_defaults, fsalib),
            Cvoid,
            (Ptr{RewritingSystem}, Bool),
            rws_ptr, false)
        return rws
    end
end

#=
    Struct name: ReductionStruct
    Original struct name: reduction_struct
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/rws.h:166-174
=#
mutable struct ReductionStruct
    rws::Ptr{RewritingSystem}
    wd_fsa::Ptr{FSA}
    separator::Int32
    wa::Ptr{FSA}
    weight::Ptr{Int}
    maxreducelen::Int32
    # Constructor
    ReductionStruct() = new()
end
