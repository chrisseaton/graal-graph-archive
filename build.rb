#!/usr/bin/env ruby

require 'fileutils'

Dir.glob('java/*.java') do |source|
  system 'javac', '-d', '.', source
  name = File.basename(source, '.java')

  jvm_args = [
    '-Xbatch',                                          # Make compilation synchronous, for simplicity
    '-XX:-TieredCompilation',                           # We're only interested in Graal, as the top-tier compiler
    '-XX:-UseOnStackReplacement',                       # Don't compile loop bodies separately, for simplicity
    '-XX:CompileCommand=dontinline,*::*',               # Don't inline, for simplicity
    '-XX:CompileCommand=compileonly,Example::example',  # Only compile the Example::example method - that's the only graph we want
    '-XX:+PrintCompilation',                            # Print when compilation happens, so we know when our method has been compiled
    '-Dgraal.PrintBackendCFG=true',                     # Dump the CFG file
    '-Dgraal.PrintGraphWithSchedule=true',              # Including scheduling information in the graph
    '-Dgraal.Dump=:1'                                   # Dump basic graphs
  ]

  raise if Dir.exist?('graal_dumps')

  IO.popen(['java', *jvm_args, 'Example'], :err=>[:child, :out]) do |pipe|
    loop do
      if pipe.readline =~ /Example::example/
        sleep 3 # https://github.com/oracle/graal/issues/4695
        Process.kill 'KILL', pipe.pid
        Process.wait pipe.pid
        break
      end
    end
  end

  FileUtils.copy Dir.glob('graal_dumps/**/HotSpotCompilation-*Example.example*.bgv').first, "#{name}.bgv"
  FileUtils.copy Dir.glob('graal_dumps/**/HotSpotCompilation-*Example.example*.cfg').first, "#{name}.cfg"
ensure
  system 'rm', '-rf', 'graal_dumps'
end
