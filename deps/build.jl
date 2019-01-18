using BinDeps
using Libdl

@BinDeps.setup

fsalib = library_dependency("fsalib")

version = "1.5.6"

provides(Sources, URI("https://github.com/gap-packages/kbmag/releases/download/v$version/kbmag-$version.tar.gz"), fsalib, unpacked_dir="kbmag-$version")

src_dir = joinpath(BinDeps.depsdir(fsalib), "src")
standalone_lib_dir = joinpath(src_dir, "kbmag-$version", "standalone", "lib")
dst_dir = joinpath(BinDeps.depsdir(fsalib), "usr", "lib")
target_lib = joinpath(dst_dir, "fsalib.$(Libdl.dlext)")

if Sys.isapple()
    nothing
end

fsalib_build =     @build_steps begin
        GetSources(fsalib)
        CreateDirectory(dst_dir)
        FileDownloader(
            "https://raw.githubusercontent.com/gap-packages/kbmag/12a09ba0b9aefa9e4817c9531ac22b9f0b9f3996/standalone/lib/makefile",
            joinpath(standalone_lib_dir, "makefile.new"))

        FileRule(target_lib, @build_steps begin
            ChangeDirectory(standalone_lib_dir)
            `mv makefile.new makefile`
            MakeTargets("fsalib.so")
            `mv fsalib.$(Libdl.dlext) $dst_dir`
        end)
    end

provides(SimpleBuild, fsalib_build, fsalib)

@BinDeps.install Dict(:fsalib => :fsalib)
