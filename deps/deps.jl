# this function checks whether a given file is a loadable dynamic library
function check_lib(lib)
    if !isfile(lib)
        error("$(lib) does not exist, Please re-run using Pkg; Pkg.build(\"KB\"), and restart Julia.")
    end
    if Libdl.dlopen_e(lib) == C_NULL
        error("$(lib) cannot be opened, Please re-run using Pkg; Pkg.build(\"KB\"), and restart Julia.")
    end
end

# this function checks whether a given file is an executable file
function check_exec(exec)
    if !isfile(exec)
        error("$(exec) does not exist, Please re-run using Pkg; Pkg.build(\"KBmag\"), and restart Julia.")
    end
    if uperm(exec) & 0x01 == 0
        error("$(exec) cannot be executed, Please re-run using Pkg; Pkg.build(\"KBmag\"), and restart Julia.")
    end
end

# libraries paths
const fsalib = joinpath(dirname(@__FILE__), "usr/lib/fsalib.$(Libdl.dlext)");   check_lib(fsalib)

# executables paths
for x in ("kbprog",
          "wordreduce",)
    check_exec(joinpath(dirname(@__FILE__), "usr/bin", x))
end
