#!/usr/bin/env ruby
# usage: duel.rb file1 file1 [s]

if ARGV.size < 2
  puts "usage: duel.rb a.rb b.rb "
  puts "       duel.rb a.rb b.rb s   #silent mode"
end

silent = (ARGV[2] && ARGV[2].start_with?("s")) ? "true" : "false"

path1 = File.expand_path(ARGV[0])
path2 = File.expand_path(ARGV[1])
cmd = "ltg -silent #{silent} match #{path1} #{path2}"

system cmd
