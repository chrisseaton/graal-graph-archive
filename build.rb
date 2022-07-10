#!/usr/bin/env ruby

raise 'Linux only' unless RUBY_PLATFORM =~ /linux/

require 'fileutils'

build_name = ARGV.first || 'dev'

release = 'https://github.com/graalvm/graalvm-ce-builds/releases/download'
graals = [
  ["#{release}/vm-19.3.0/graalvm-ce-java11-linux-amd64-19.3.0.tar.gz",      'graalvm-ce-java11-19.3.0',   '19.3.0'    ],
  ["#{release}/vm-19.3.0.2/graalvm-ce-java11-linux-amd64-19.3.0.2.tar.gz",  'graalvm-ce-java11-19.3.0.2', '19.3.0.2'  ],
  ["#{release}/vm-19.3.1/graalvm-ce-java11-linux-amd64-19.3.1.tar.gz",      'graalvm-ce-java11-19.3.1',   '19.3.1'    ],
  ["#{release}/vm-19.3.2/graalvm-ce-java11-linux-amd64-19.3.2.tar.gz",      'graalvm-ce-java11-19.3.2',   '19.3.2'    ],
  ["#{release}/vm-19.3.3/graalvm-ce-java11-linux-amd64-19.3.3.tar.gz",      'graalvm-ce-java11-19.3.3',   '19.3.3'    ],
  ["#{release}/vm-19.3.4/graalvm-ce-java11-linux-amd64-19.3.4.tar.gz",      'graalvm-ce-java11-19.3.4',   '19.3.4'    ],
  ["#{release}/vm-19.3.5/graalvm-ce-java11-linux-amd64-19.3.5.tar.gz",      'graalvm-ce-java11-19.3.5',   '19.3.5'    ],
  ["#{release}/vm-19.3.6/graalvm-ce-java11-linux-amd64-19.3.6.tar.gz",      'graalvm-ce-java11-19.3.6',   '19.3.6'    ],
  ["#{release}/vm-20.0.0/graalvm-ce-java11-linux-amd64-20.0.0.tar.gz",      'graalvm-ce-java11-20.0.0',   '20.0.0'    ],
  ["#{release}/vm-20.1.0/graalvm-ce-java11-linux-amd64-20.1.0.tar.gz",      'graalvm-ce-java11-20.1.0',   '20.1.0'    ],
  ["#{release}/vm-20.2.0/graalvm-ce-java11-linux-amd64-20.2.0.tar.gz",      'graalvm-ce-java11-20.2.0',   '20.2.0'    ],
  ["#{release}/vm-20.3.0/graalvm-ce-java11-linux-amd64-20.3.0.tar.gz",      'graalvm-ce-java11-20.3.0',   '20.3.0'    ],
  ["#{release}/vm-20.3.1/graalvm-ce-java11-linux-amd64-20.3.1.tar.gz",      'graalvm-ce-java11-20.3.1',   '20.3.1'    ],
  ["#{release}/vm-20.3.1.2/graalvm-ce-java11-linux-amd64-20.3.1.2.tar.gz",  'graalvm-ce-java11-20.3.1.2', '20.3.1.2'  ],
  ["#{release}/vm-20.3.2/graalvm-ce-java11-linux-amd64-20.3.2.tar.gz",      'graalvm-ce-java11-20.3.2',   '20.3.2'    ],
  ["#{release}/vm-20.3.3/graalvm-ce-java11-linux-amd64-20.3.3.tar.gz",      'graalvm-ce-java11-20.3.3',   '20.3.3'    ],
  ["#{release}/vm-20.3.4/graalvm-ce-java11-linux-amd64-20.3.4.tar.gz",      'graalvm-ce-java11-20.3.4',   '20.3.4'    ],
  ["#{release}/vm-20.3.5/graalvm-ce-java11-linux-amd64-20.3.5.tar.gz",      'graalvm-ce-java11-20.3.5',   '20.3.5'    ],
  ["#{release}/vm-20.3.6/graalvm-ce-java11-linux-amd64-20.3.6.tar.gz",      'graalvm-ce-java11-20.3.6',   '20.3.6'    ],
  ["#{release}/vm-21.0.0/graalvm-ce-java11-linux-amd64-21.0.0.tar.gz",      'graalvm-ce-java11-21.0.0',   '21.0.0'    ],
  ["#{release}/vm-21.0.0.2/graalvm-ce-java11-linux-amd64-21.0.0.2.tar.gz",  'graalvm-ce-java11-21.0.0.2', '21.0.0.2'  ],
  ["#{release}/vm-21.1.0/graalvm-ce-java11-linux-amd64-21.1.0.tar.gz",      'graalvm-ce-java11-21.1.0',   '21.1.0'    ],
  ["#{release}/vm-21.2.0/graalvm-ce-java11-linux-amd64-21.2.0.tar.gz",      'graalvm-ce-java11-21.2.0',   '21.2.0'    ],
  ["#{release}/vm-21.3.0/graalvm-ce-java17-linux-amd64-21.3.0.tar.gz",      'graalvm-ce-java17-21.3.0',   '21.3.0'    ],
  ["#{release}/vm-21.3.1/graalvm-ce-java17-linux-amd64-21.3.1.tar.gz",      'graalvm-ce-java17-21.3.1',   '21.3.1'    ],
  ["#{release}/vm-21.3.2/graalvm-ce-java17-linux-amd64-21.3.2.tar.gz",      'graalvm-ce-java17-21.3.2',   '21.3.2'    ],
  ["#{release}/vm-22.0.0.2/graalvm-ce-java17-linux-amd64-22.0.0.2.tar.gz",  'graalvm-ce-java17-22.0.0.2', '22.0.0.2'  ],
  ["#{release}/vm-22.1.0/graalvm-ce-java17-linux-amd64-22.1.0.tar.gz",      'graalvm-ce-java17-22.1.0',   '22.1.0'    ]
]

# Historical glitches - not worth investigation:

# Some Graal releases don't seem to include Ruby? I think Ruby didn't change
# is the reason why, but if the compiler changed it would still make a
# difference to Ruby.
missing_ruby = [
  '19.3.5',
  '19.3.6',
  '20.3.1',
  '20.3.1.2',
  '20.3.2',
  '20.3.3',
  '20.3.4',
  '20.3.5',
  '20.3.6',
  '21.0.0',
  '21.0.0.2',
  '21.3.1',
  '21.3.2'     # incompatible rather than not available?
]

# Some Graal releases don't seem to generate CFG files for Truffle compilation?
no_truffle_cfg = [
  '20.2.0',
  '20.3.0',
  '20.3.1',
  '20.3.1.2',
  '21.1.0',
  '21.2.0',
  '21.3.0',
  '22.0.0.2',
  '22.1.0'
]

no_truffle_inline_only = [
  '19.3.0',
  '19.3.0.2',
  '19.3.1',
  '19.3.2',
  '19.3.3',
  '19.3.4',
  '19.3.5',
  '19.3.6',
  '20.0.0',
  '20.1.0',
  '20.2.0',
  '20.3.0',
  '20.3.1',
  '20.3.1.2',
  '20.3.2',
  '20.3.3',
  '20.3.4',
  '20.3.5',
  '20.3.6',
  '21.0.0',
  '21.0.0.2',
  '21.1.0',
  '21.2.0'
]

graals.each do |url, dir, version|
  tarball = File.basename(url)
  system 'wget', url unless File.exist?(tarball)
  system 'tar', '-xzf', tarball unless Dir.exist?(dir)

  Dir.glob('java/*.java') do |source|
    name = File.basename(source, '.java')

    bgv_file = "java/#{name}-#{version}.bgv"
    cfg_file = "java/#{name}-#{version}.cfg"
    bgvz_file = "#{bgv_file}.gz"
    cfgz_file = "#{cfg_file}.gz"

    unless File.exist?(bgv_file) && File.exist?(cfg_file)
      jvm_args = [
        '-Xbatch',                                          # Make compilation synchronous, for simplicity
        '-XX:-TieredCompilation',                           # We're only interested in Graal, as the top-tier compiler
        '-XX:-UseOnStackReplacement',                       # Don't compile loop bodies separately, for simplicity
        '-XX:CompileCommand=dontinline,*::*',               # Don't inline, for simplicity
        '-XX:CompileCommand=compileonly,Example::example',  # Only compile the Example::example method - that's the only graph we want
        '-XX:+PrintCompilation',                            # Print when compilation happens, so we know when our method has been compiled
        '-Dgraal.PrintBackendCFG=true',                     # Dump the CFG file
        '-Dgraal.PrintGraphWithSchedule=true',              # Including scheduling information in the graph
        '-Dgraal.Dump=:3'                                   # Dump detailed graphs
      ]

      puts "#{version} #{source}"

      raise if Dir.exist?('graal_dumps')

      system "#{dir}/bin/javac", '-d', '.', source
      
      IO.popen(["#{dir}/bin/java", *jvm_args, 'Example'], :err=>[:child, :out]) do |pipe|
        loop do
          if pipe.readline =~ /\bExample::example\b/
            sleep 3 # https://github.com/oracle/graal/issues/4695
            Process.kill 'KILL', pipe.pid
            Process.wait pipe.pid
            break
          end
        end
      end

      FileUtils.copy Dir.glob('graal_dumps/**/HotSpotCompilation-*Example.example*.bgv').first, bgv_file
      FileUtils.copy Dir.glob('graal_dumps/**/HotSpotCompilation-*Example.example*.cfg').first, cfg_file
    end

    system 'gzip', '-k9', bgv_file unless File.exist?(bgvz_file)
    system 'gzip', '-k9', cfg_file unless File.exist?(cfgz_file)
  ensure
    system 'rm', '-rf', 'graal_dumps'
  end

  unless missing_ruby.include?(version)
    system "#{dir}/bin/gu", 'install', 'ruby' unless File.exist?("#{dir}/bin/ruby")

    Dir.glob('ruby/*.rb') do |source|
      name = File.basename(source, '.rb')

      bgv_file = "ruby/#{name}-#{version}.bgv"
      cfg_file = "ruby/#{name}-#{version}.cfg"
      bgvz_file = "#{bgv_file}.gz"
      cfgz_file = "#{cfg_file}.gz"

      no_cfg = no_truffle_cfg.include?(version)

      unless File.exist?(bgv_file) && (File.exist?(cfg_file) || no_cfg)
        ruby_args = [
          '--jvm',                                            # Use the JVM
          '--experimental-options',
          '--engine.BackgroundCompilation=false',             # Make compilation synchronous, for simplicity
          '--engine.MultiTier=false',                         # We're only interested in top-tier compilation
          '--engine.OSR=false',                               # Don't compile loop bodies separately, for simplicity
          '--engine.CompileOnly=example',                     # Only compile the example method
          '--engine.TraceCompilation',                        # Print when compilation happens, so we know when our method has been compiled
          '--vm.Dgraal.Dump=Truffle:3'                        # Dump detailed graphs
        ]

        if File.read(source) =~ /opaque/
          if no_truffle_inline_only.include?(version)
            # We can't compile this one! We can't stop the opaque calls being
            # inlined because the version of Truffle doesn't support
            # --engine.InlineOnly.
            next
          else
            ruby_args << '--engine.InlineOnly=~opaque'
          end
        end

        puts "#{version} #{source}"

        raise if Dir.exist?('graal_dumps')

        IO.popen(["#{dir}/bin/ruby", *ruby_args, source], :err=>[:child, :out]) do |pipe|
          loop do
            if pipe.readline =~ /\bopt done\s+(id=\d+\s+)?Object#example\b/
              sleep 3 # similar to https://github.com/oracle/graal/issues/4695 ?
              Process.kill 'KILL', pipe.pid
              Process.wait pipe.pid
              break
            end
          end
        end

        FileUtils.copy Dir.glob('graal_dumps/**/TruffleHotSpotCompilation-*#example*.bgv').first, bgv_file
        FileUtils.copy Dir.glob('graal_dumps/**/TruffleHotSpotCompilation-*#example*.cfg').first, cfg_file unless no_cfg
      end

      system 'gzip', '-k9', bgv_file unless File.exist?(bgvz_file)
      system 'gzip', '-k9', cfg_file unless File.exist?(cfgz_file) || no_cfg
    ensure
      system 'rm', '-rf', 'graal_dumps'
    end
  end
end

dir_name = "graal-graph-archive-#{build_name}"
at_exit { system 'rm', '-rf', dir_name }

system 'mkdir', '-p', "#{dir_name}/java"
system "cp java/*.java java/*.bgv.gz java/*.cfg.gz #{dir_name}/java"

system 'mkdir', '-p', "#{dir_name}/ruby"
system "cp ruby/*.rb ruby/*.bgv.gz ruby/*.cfg.gz #{dir_name}/ruby"

system 'tar', '-cf', "#{dir_name}.tar", dir_name
system 'gzip', '-f9', "#{dir_name}.tar"
