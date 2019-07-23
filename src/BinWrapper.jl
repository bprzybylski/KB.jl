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

function low_level_exec_wrapper(program::String; params = (), input::String = "", force_dir = ".")
  call_dir = pwd()
  bin_dir = joinpath(dirname(@__FILE__), "..", "deps", "usr", "bin", "")

  if force_dir != "."
    cd(force_dir)
  end

  result = low_level_exec(`$bin_dir$program $(params)`; input = input)

  if force_dir != "."
    cd(call_dir)
  end

  return result
end

function kbprog_wrapper(groupname::String;
                        dir = joinpath(dirname(@__FILE__), "..", "deps", "src", "kbmag-1.5.8", "standalone", "kb_data"))
  return low_level_exec_wrapper("kbprog"; params = (groupname, ), force_dir = dir)
end

function wordreduce_wrapper(groupname::String,
                            words;
                            dir = joinpath(dirname(@__FILE__), "..", "deps", "src", "kbmag-1.5.8", "standalone", "kb_data"))

  raw_input = join(words, ",") * ";"
  res = low_level_exec_wrapper("wordreduce"; params = ("-kbprog", groupname), input = raw_input, force_dir = dir)
  output = []

  for i in eachmatch(r"([^ ]*[^.:])\n", res.out)
    if i.captures[1] == "IdWord"
      push!(output, "")
    else
      push!(output, i.captures[1])
    end
  end

  return output
end
