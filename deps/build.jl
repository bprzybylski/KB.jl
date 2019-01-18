using BinDeps
using Libdl

@BinDeps.setup

fsalib = library_dependency("fsalib")

version = "1.5.6"

provides(Sources, URI("https://github.com/gap-packages/kbmag/releases/download/v$version/kbmag-$version.tar.gz"), fsalib, unpacked_dir="kbmag-$version")

src_dir = joinpath(BinDeps.depsdir(fsalib), "src")
dst_dir = joinpath(BinDeps.depsdir(fsalib), "usr", "lib")
@show dst_dir
@show isfile(joinpath(dst_dir, "fsalib.$(Libdl.dlext)"))

if Sys.isapple()
    nothing
end

provides(SimpleBuild, (@build_steps begin
    GetSources(fsalib)
    CreateDirectory(dst_dir)
    @build_steps begin
      FileRule([joinpath(dst_dir, "fsalib.$(Libdl.dlext)")], 
        @build_steps begin
          ChangeDirectory(joinpath(src_dir, "kbmag-$version", "standalone", "lib"))
          `make fsalib.so`
          `mv fsalib.$(Libdl.dlext) $dst_dir`
        end)
    end
  end), fsalib)

@BinDeps.install Dict(:fsalib => :fsalib)
