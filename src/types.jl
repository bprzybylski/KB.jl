export Fsa

#=
    Enum name: SrecType
    Original enum name: srec_type
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/ [29--38]
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
    Source: ./deps/src/kbmag-1.5.6/standalone/lib/ [40]
    Date: 2019-03-12
=#
@enum StorageType begin
    DENSE
    SPARSE
    COMPACT
end
