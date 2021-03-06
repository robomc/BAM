class Runner
  require 'stringio'
  require 'pty'
  attr_reader :buffer, :running

  # Runners run the individual instances of the script for BAM.
  # every runner has an instance_key integer, which is its key in the
  # ScriptInstances hash.
  #
  # To interact with a runner instance, ScriptInstances methods are used, passing in
  # the relevant instance_key...
  #
  # The bulk of the IO work is in the @buffer var
  #
  # The state of the sscript is stored in @running (bool)
  #
  # Both of these have accessors, which are used by methods in ScriptInstances.
  def initialize(script_path, script_name)
    @script_path = script_path
    @script_name = script_name
    @buffer = StringIO.new
    @running = false
  end

  # Resets the buffer.
  def flush
    @buffer = StringIO.new
  end

  # Used for user input (not a finished feature)
  def write(string)
    @input = StringIO.new
    @input = string + "\n"
    puts string
  end

  # The key method, a work in progress - runs the script...
  def run
    @running = true
    @buffer << "<p>$ ruby #{@script_name}</p>"
    cmd = %Q<ruby #{@script_path}>
    #Make the call to ruby a constant defined earlier, which can be passed in...
    # IO.popen(cmd, 'w+') do |subprocess|
    #   # subprocess.write("Starting script")
    #   # subprocess.close_write
    #   subprocess.read.split("\n").each do |line|
    #     @buffer << "<p>#{line}</p>"
    #   end
    # end

    #note - input needs a newline character, or it will break...

    #and buffer it to handle the timing issues, waiting till DONE

    #http://devver.wordpress.com/2009/10/12/ruby-subprocesses-part_3/

    # 03  PTY.spawn(RUBY, '-r', THIS_FILE, '-e', 'hello("PTY", true)') do
    # 04    |output, input, pid|
    # 05    input.write("hello from parent\n")
    # 06    buffer = ""
    # 07    output.readpartial(1024, buffer) until buffer =~ /DONE/
    # 08    buffer.split("\n").each do |line|
    # 09      puts "[parent] output: #{line}"
    # 10    end
    # 11  end

    PTY.spawn(cmd) do |output, input, pid|
      begin
        output.each do |line|
          @buffer << "<p>#{line}</p>"
        end
        # # loop do
        #   @input.each("\n") do |line|
        #     @buffer <<
        #   end
        # # end


        # input.write @input # this will need to be looped? threaded? need to clean itself out after being read in each loop-round?
      rescue Errno::EIO
      end
    end

    @buffer << "<p>Script finished</p>"
    @running = false
  end


end

