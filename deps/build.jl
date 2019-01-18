using Libdl

version = "1.5.6"

src_uri = "https://github.com/gap-packages/kbmag/releases/download/v$version/kbmag-$version.tar.gz"

download_dir = joinpath(@__DIR__, "downloads")
src_dir = joinpath(@__DIR__, "src")
patches_dir = joinpath(@__DIR__, "patches")
dst_dir = joinpath(@__DIR__, "usr", "lib")
mkpath(download_dir)
mkpath(src_dir)
mkpath(patches_dir)
mkpath(dst_dir)

standalone_lib_dir = joinpath(src_dir, "kbmag-$version", "standalone", "lib")
target = joinpath(dst_dir, "fsalib.$(Libdl.dlext)")

function getsources(src_uri, destination, force=false)
    if force || !isfile(destination)
        download(src_uri, destination)
    end
end

function unpack(source_tarball, destination_dir, force=false)
    unpack_dir = joinpath(destination_dir, split(basename(source_tarball),".")[1])
    if force || !isdir(unpack_dir)
        run(`tar -xvzf $source_tarball -C $destination_dir`)
    end
end

function build(build_dir, make_target; j=4)
    current_dir = pwd()
    cd(build_dir)

    run(`make -j$j $make_target`)

    cd(current_dir)
end

function patch(sources, patches)
    # Awwww :/
    run(`bash -c "cp -Rf $patches/* $sources"`)
end

if !isfile(target)
    sources = joinpath(download_dir, "kbmag-$version.tar.gz")
    getsources(src_uri, sources)
    unpack(sources, src_dir)

    patch(src_dir, patches_dir)

    build(standalone_lib_dir, "fsalib.$(Libdl.dlext)")
    mv(joinpath(standalone_lib_dir, "fsalib.$(Libdl.dlext)"), target)
end
