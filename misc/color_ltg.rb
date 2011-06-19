#!/usr/bin/env ruby
# Filter program to colorize output of ltg
#
# install:
#   $ gem install rainbow
#
# usage: 
#   $ ltg match prog1 prog2 |& color_ltg.rb
#   (be careful to '|&', not '|')
#
require 'rainbow'

prop = nil
ARGF.each do |line|
  case line
  when /^###### turn /
    puts
    print line.color(:yellow)
  when /^\*\*\* player 0's turn, with slots:/
    prop = 0
    print line.color(:green)
  when /^\*\*\* player 1's turn, with slots:/
    prop = 1
    puts
    print line.color(:red)
  when /^(\d+)=\{.*\}$/
    if prop == 0
      print line.color(:green)
    else
      print line.color(:red)
    end
  else
    print line
  end
end
