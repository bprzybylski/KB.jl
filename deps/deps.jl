const fsalib = joinpath(dirname(@__FILE__), "usr/lib/fsalib.$(Libdl.dlext)")

function check_deps(lib)
    if !isfile(lib)
        error("$(lib) does not exist, Please re-run using Pkg; Pkg.build(\"KB\"), and restart Julia.")
    end
    if Libdl.dlopen_e(lib) == C_NULL
        error("$(lib) cannot be opened, Please re-run using Pkg; Pkg.build(\"KB\"), and restart Julia.")
    end
end
