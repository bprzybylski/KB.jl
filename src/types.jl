export Fsa

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
    Date: 2019-03-12
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
    Date: 2019-03-12
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
