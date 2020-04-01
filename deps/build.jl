using Libdl
using SHA

# constant directories
const download_dir = joinpath(@__DIR__, "downloads");       mkpath(download_dir)
const sources_dir = joinpath(@__DIR__, "src");              mkpath(sources_dir)
const patches_dir = joinpath(@__DIR__, "patches");          mkpath(patches_dir)
const target_lib_dir = joinpath(@__DIR__, "usr", "lib");    mkpath(target_lib_dir)
const target_bin_dir = joinpath(@__DIR__, "usr", "bin");    mkpath(target_bin_dir)

function check_sha512(fname, hash_value::String)
    h = open(fname) do f
        SHA.sha512(f)
    end
    return bytes2hex(h) == hash_value
end

# common functions
function getsources(src_uri, destination, force=false)
    if force || !isfile(destination) || !check_sha512(destination, sources_sha512[basename(destination)])
        download(src_uri, destination)
    end
    @assert check_sha512(destination, sources_sha512[basename(destination)])
end

function unpack(source_tarball, destination_dir, force=false)
    unpack_dir = joinpath(destination_dir, split(basename(source_tarball),".")[1])
    if force || !isdir(unpack_dir)
        run(`tar -xvzf $source_tarball -C $destination_dir`)
    end
end

function build(build_dir, make_target, force=false; j=4)
    current_dir = pwd()
    cd(build_dir)
    force && run(`make clean`)
    run(`make -j$j $make_target`)
    cd(current_dir)
end

function patch(package)
    patch_dir = joinpath(patches_dir, package)
    if isdir(patch_dir)
        run(`cp -Rf $patch_dir $sources_dir`)
    end
end

# kbmag dependency
function installkbmag(version::VersionNumber, force=false)
    src_uri = "https://github.com/gap-packages/kbmag/releases/download/v$version/kbmag-$version.tar.gz"

    if force
        sources = joinpath(download_dir, "kbmag-$version.tar.gz")
        getsources(src_uri, sources, force)
        unpack(sources, sources_dir, force)
    end

    standalone_lib_dir      = joinpath(sources_dir, "kbmag-$version", "standalone", "lib")
    standalone_sources_dir  = joinpath(sources_dir, "kbmag-$version", "standalone", "src")
    standalone_bin_dir      = joinpath(sources_dir, "kbmag-$version", "standalone", "bin");   mkpath(standalone_bin_dir)

    target_lib              = joinpath(target_lib_dir, "fsalib.$(Libdl.dlext)")

    # static lib (step 1)
    if force || !isfile(target_lib)
        build(standalone_lib_dir, "fsalib.a", force)
    end

    # binary files (step 2)
    if force
        build(standalone_sources_dir, "all", force)
        mv(standalone_bin_dir, target_bin_dir, force=true)
    end

    # dynamic lib (step 3)
    if force || !isfile(target_lib)
        patch("kbmag-$version")
        build(standalone_lib_dir, "fsalib.$(Libdl.dlext)", force)
        mv(joinpath(standalone_lib_dir, "fsalib.$(Libdl.dlext)"), target_lib, force=true)
    end
end

sources_sha512 = Dict(
"kbmag-1.5.8.tar.gz" => "d424b10599251b890f724dc4b5eb05bd7ee227c1d03be06a34e8330abf8fdce5e864cac287ab684c3716e34e4d412c53a722ce788d0ff96366728c6d785f2c8c",
)

# download and build dependencies
installkbmag(v"1.5.8", true)
