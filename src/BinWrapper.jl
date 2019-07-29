const kbmag_bin_dir = joinpath(dirname(@__FILE__), "..", "deps", "usr", "bin")

# This function executes a given command (including call parameters)
# with a given input, based on an in-memory (tempfile = false)
# or in-file (tempfile = true) implementation.
# It returns a tuple of stdout (as String), stderr (as String) and exit code (as Integer)
# WARNING: Input string should not be terminated.
function low_level_exec(cmd::Cmd; input::String = "", tempfile = false)
  # tempfile-based implementation
  if tempfile
    # create temporary files
    cmdin_p, cmdin    = mktemp()
    cmdout_p, cmdout  = mktemp()
    cmderr_p, cmderr  = mktemp()

    # save input
    write(cmdin, input)
    close(cmdin)
    cmdin = open(cmdin_p)

    # run a process
    process = run(pipeline(ignorestatus(cmd), stdin=cmdin, stdout=cmdout, stderr=cmderr))

    # read out/err of a command
    cmdout = open(cmdout_p)
    cmderr = open(cmderr_p)

    out = read(cmdout, String)
    err = read(cmderr, String)

    # return all the needed data
    return (
      out     = out,
      err     = err,
      ret     = process.exitcode
    )
  else # non-tempfile-based implementation
    # create pipes/buffers for in/out/err of a command
    cmdin  = IOBuffer(input)
    cmdout = IOBuffer()
    cmderr = IOBuffer()

    if VERSION < v"1.1"
      cmdin  = Pipe()
      cmdout = Pipe()
      cmderr = Pipe()
    end

    # run a process
    process = run(pipeline(ignorestatus(cmd), stdin=cmdin, stdout=cmdout, stderr=cmderr), wait=!(VERSION < v"1.1"))

    if VERSION < v"1.1"
      # close unnecessary communication tunnels of pipes initialized by pipeline()
      close(cmdout.in)
      close(cmderr.in)

      # pass the input to the process and close the related pipe
      # note: this could be also `write(process, input)`, but then `cmdin` would not be used which is not cool
      write(cmdin, input)
      close(cmdin)

      # asynchronously read the outputs of the command
      out = @async String(read(cmdout))
      err = @async String(read(cmderr))

      # return all the needed data
      return (
        out     = fetch(out),
        err     = fetch(err),
        ret     = process.exitcode
      )
    end # if VERSION < v"1.1"

    # read the outputs of the command
    out = String(take!(cmdout))
    err = String(take!(cmderr))

    # return all the needed data
    return (
      out     = out,
      err     = err,
      ret     = process.exitcode
    )
  end
end

# This function wraps the binaries that come with the original kbmag library.
# Here, all the parameters are passed as Strings
function kbmag_bin_wrapper(program::String;
                           params::Array{String,1} = [],
                           input::String = "",
                           execution_dir::String = ".")

  # remember the current working directory
  call_dir = pwd()
  result = ()

  try
    # WARNING: when calling a kbmag binary we need to make sure that
    # all the input files are in the current working directory
    cd(execution_dir)

    call_path = joinpath(kbmag_bin_dir, program)
    result = low_level_exec(`$call_path $(params)`; input = input)
  catch x
    error("Exception handled: ", x)
  finally
    # change the current working directory back to the previous one
    cd(call_dir)
  end

  return result # (out, err, ret)
end

# This function wraps a kbprog binary
#     groupname::String   --- input file name
#     dir::String         --- working directory
function kbprog_call(basepath::String)
  # generate an absolute path to the file
  basepath = abspath(basepath)
  # check whether it exists
  isfile(basepath) || error("The $basepath file could not be found.")
  # divide the path into two parts
  basepath_dir, groupname = dirname(basepath), basename(basepath)

  # call a proper binary
  res = kbmag_bin_wrapper("kbprog"; params = [groupname], execution_dir = basepath_dir)

  # assure that the call was successful
  res.ret == 0 || error(res.err)

  # return the whole result
  return res
end

# This function wraps a kbprog binary
#     groupname::String   --- input files basename
#     words               --- a tuple of input strings
#     dir::String         --- working directory
function wordreduce_call(basepath::String, words::Array{String,1})
  # generate an absolute path to the file
  basepath = abspath(basepath)
  # check whether it exists
  isfile(basepath) || error("The $basepath file could not be found.")
  # divide the path into two parts
  basepath_dir, groupname = dirname(basepath), basename(basepath)

  kbprog_output_files = [
    joinpath(basepath_dir, groupname * ".kbprog"),
    joinpath(basepath_dir, groupname * ".kbprog.ec"),
    joinpath(basepath_dir, groupname * ".reduce")
  ]

  # check whether input files exist and if not, call kbprog
  if !all(isfile.(kbprog_output_files))
    kbprog_res = kbprog_call(basepath)
    # assure that the call was successful
    kbprog_res.ret == 0 || error(kbprog_res.err)
  end

  # prepare a raw input for the wordreduce binary
  raw_input = join(words, ",") * ";"
  # call the wordreduce binary
  res = kbmag_bin_wrapper("wordreduce"; params = ["-kbprog", groupname], input = raw_input, execution_dir = basepath_dir)
  # assure that the call was successful
  res.ret == 0 || error(res.err)

  # prepare an array for the reduced strings...
  output = []
  # ...and fill it with the words extracted from the output of the wordreduce call
  # WARNING: "IdWord" constant is replaced by an empty string for further concat
  for i in eachmatch(r"([^ ]*[^.:])\n", res.out)
    push!(output, i.captures[1] == "IdWord" ? "" : i.captures[1])
  end

  # return the array
  return output
end
