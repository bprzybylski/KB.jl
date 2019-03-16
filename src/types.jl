export SrecType, StorageType, KBMFlagStrings, Char, Gen, SetToLabelsType, Srec, TableStruc, FSA

#=
    Enum name: SrecType
    Original enum name: srec_type
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/fsa.h [29--38]
    Date: 2019-03-12
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
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/fsa.h [40]
    Date: 2019-03-14
=#
@enum StorageType begin
    DENSE
    SPARSE
    COMPACT
end

#=
    Enum name: KBMFlagStrings
    Original enum name: kbm_flag_strings
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/fsa.h [41--50]
    Date: 2019-03-14
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
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/rws.h [15-22]
    Date: 2019-03-16
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
    Type name: Char
    Date: 2019-03-14
=#
const Char=UInt8

#=
    Type name: Gen (Char)
    Original type name: gen (char)
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/defs.h [46]
    Date: 2019-03-14
=#
const Gen=Char

#=
    Type name: SetToLabelsType
    Original type name: setToLabelsType
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/fsa.h [55]
    Date: 2019-03-14
=#
const SetToLabelsType=Int8

#=
    Const name: MaxChar / MaxGen
    Original const name: MAXCHAR / MAXGEN
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/defs.h [20 / 45]
    Date: 2019-03-14
=#
const MaxChar = MaxGen = 127

#=
    Struct name: Srec
    Original struct name: srec
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/fsa.h [57--86]
    Date: 2019-03-14
=#
struct Srec
    type::SrecType
    size::Int
    names::Ptr{Ptr{Char}}
    words::Ptr{Ptr{Gen}}
    wordslist::Ptr{Ptr{Ptr{Gen}}}
    intlist::Ptr{Ptr{Int}}
    arity::Int
    padding::Char
    alphabet::Ptr{Ptr{Char}} # Originally char *alphabet[MAXGEN + 1] (what to do about that?)
    alphabet_size::Int
    base::Ptr{Srec}
    labels::Ptr{Srec}
    setToLabels::Ptr{SetToLabelsType}
end

#=
    Struct name: TableStruc
    Original struct name: table_struc
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/fsa.h [88-164]
    Date: 2019-03-15
=#
struct TableStruc
    filename::Ptr{Char}
    table_type::StorageType
    printing_format::StorageType
    comment_state_numbers::Bool
    numTransitions::Int
    maxstates::Int
    denserows::Int
    table_data_ptr::Ptr{Ptr{Int}}
    table_data_dptr::Ptr{Ptr{Ptr{Int}}}
    ctable_data_ptr::Ptr{Ptr{UInt}}
end

#=
    Const name: NumKBMFlagStrings
    Original const name: num_kbm_flag_strings
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/defs.h [51]
    Date: 2019-03-15
=#
const NumKBMFlagStrings = 8

#=
    Struct name: FSA
    Original struct name: fsa
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/fsa.h [166--194]
    Date: 2019-03-15
=#
struct FSA
    states::Ptr{Srec}
    alphabet::Ptr{Srec}
    num_initial::Int
    initial::Ptr{Int}
    is_initial::Ptr{Bool}
    num_accepting::Int
    accepting::Ptr{Int}
    is_accepting::Ptr{Bool}
    is_accessible::Ptr{Bool}
    flags::Ptr{Bool} # Originally boolean flags[num_kbm_flag_strings] (what to do about that?)
    table::Ptr{TableStruc}
end

#=
    Struct name: WDR
    Original struct name: wdr
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/rws.h [115--119]
    Date: 2019-03-16
=#
struct WDR
    num_eqns::Int
    num_states::Int
    num_diff::Int
end

#=
    Struct name: ReductionEquation
    Original struct name: reduction_equation
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/rws.h [34--40]
    Date: 2019-03-16
=#
struct ReductionEquation
    lhs::Ptr{Gen}
    rhs::Ptr{Gen}
    done::Bool
    changed::Bool
    eliminated::Bool
end

#=
    Struct name: RewritingSystem
    Original struct name: rewriting_system
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/rws.h [42--160]
    Date: 2019-03-16
=#
struct RewritingSystem
    name::Ptr{Char} # Originally char name[256] (what to do about that?)
    ordering::KBMOrderings
    weight::Ptr{Int}
    level::Ptr{Int}
    confluent::Bool
    num_gens::Int
    num_eqns::Int
    num_inveqns::Int
    inv_of::Ptr{Int}
    gen_name::Ptr{Ptr{Char}}
    eqns::Ptr{ReductionEquation}
    reduction_fsa::Ptr{FSA}
    num_states::Int
    worddiffs::Bool
    wd_fsa::Ptr{FSA}
    cosets::Bool
    wd_reorder::Bool
    new_wd::Ptr{Bool}
    maxlenleft::Int
    maxlenright::Int
    maxoverlaplen::Int
    hadlongoverlap::Bool
    rkminlen::Int
    rkmineqns::Int
    rk_on::Bool
    history::Ptr{Int}
    slowhistory::Ptr{Ptr{Int}}
    slowhistorysp::Ptr{Int}
    preflen::Ptr{Int}
    prefno::Ptr{Int}
    maxpreflen::Int
    outputprefixes::Bool
    testword1::Ptr{Gen}
    testword2::Ptr{Gen}
    sorteqns::Bool
    tidyint::Int
    eqn_no::Ptr{Int}
    nneweqns::Int
    tot_eqns::Int
    hadct::Int
    maxhad::Int
    maxoplen::Int
    print_eqns::Bool
    maxeqns::Int
    hadmaxeqns::Bool
    confnum::Int
    oldconfnum::Int
    maxslowhistoryspace::Int
    maxreducelen::Int
    maxstates::Int
    current_maxstates::Int
    double_states::Bool
    init_fsaspace::Int
    maxwdiffs::Int
    exit_status::Int
    tidyon::Bool
    tidyon_now::Bool
    wd_record::Ptr{WDR}
    num_cycles::Int
    eqn_factor::Int
    states_factor::Int
    halting_factor::Int
    min_time::Int
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
    separator::Int
    maxlhsrellen::Int
    maxsubgenlen::Int
    maxcosetlen::Int
    finitestop::Bool
    Hoverlaps::Bool
    Gislevel::Bool
    Hislevel::Bool
    Hhasinverses::Bool
    wd_alphabet::Ptr{Srec}
    subwordsG::Ptr{Ptr{Gen}}
end
