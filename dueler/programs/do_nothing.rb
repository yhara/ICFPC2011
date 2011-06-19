#!/usr/bin/env ruby
$stdout.sync = true

def opp
  case $stdin.gets
  when "1\n"
    card = $stdin.gets
    slot = $stdin.gets
  when "2\n"
    slot = $stdin.gets
    card = $stdin.gets
  else
    exit
  end
end

#$stderr.puts "****#{ARGV.inspect}****"

opp if ARGV[0] == "1"
loop do
  puts "1"
  puts "I"
  puts "0"
  opp
end
