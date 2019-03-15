export SrecType, StorageType, KBMFlagStrings, Char, Gen, SetToLabelsType, Srec

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
MaxChar = MaxGen = 127

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
