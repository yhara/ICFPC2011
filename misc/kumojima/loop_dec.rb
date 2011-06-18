#!/usr/bin/env ruby

def command(a, b, c)
  puts a
  puts b
  puts c
end

def o(arg1, arg2)
  apply = arg1.class == String ? 1 : 2
  command apply, arg1, arg2
end

slot1 = 0
slot2 = 1
o slot1, "get"
o "S", slot1

o slot2, "dec"
o "S", slot2
o slot2, "I"

o "K", slot1
o "S", slot1
o slot1, "get"
o "K", slot1
o "S", slot1
o slot1, "succ"
o slot1, "zero"
o slot1, "zero"
o 255, "zero"


