using Libdl

# constant directories
const download_dir = joinpath(@__DIR__, "downloads");   mkpath(download_dir)
const src_dir = joinpath(@__DIR__, "src");              mkpath(src_dir)
const patches_dir = joinpath(@__DIR__, "patches");      mkpath(patches_dir)
const dst_dir = joinpath(@__DIR__, "usr", "lib");       mkpath(dst_dir)

# common functions
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

function patch(package)
    patch_dir = joinpath(patches_dir, package)
    if isdir(patch_dir)
        run(`cp -Rf $patch_dir $src_dir`)
    end
end

# kbmag dependency
function kbmag(version)
    src_uri = "https://github.com/gap-packages/kbmag/releases/download/v$version/kbmag-$version.tar.gz"
    standalone_lib_dir = joinpath(src_dir, "kbmag-$version", "standalone", "lib")
    target = joinpath(dst_dir, "fsalib.$(Libdl.dlext)")

    if !isfile(target)
        sources = joinpath(download_dir, "kbmag-$version.tar.gz")
        getsources(src_uri, sources)
        unpack(sources, src_dir)
        patch("kbmag-$version")
        build(standalone_lib_dir, "fsalib.$(Libdl.dlext)")
        mv(joinpath(standalone_lib_dir, "fsalib.$(Libdl.dlext)"), target)
    end
end

# download and build dependencies
kbmag("1.5.6")
