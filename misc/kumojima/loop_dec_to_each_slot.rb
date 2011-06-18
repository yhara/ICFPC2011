#!/usr/bin/env ruby

def command(a, b, c)
  puts a
  puts b
  puts c
end

def set_constant(num, slot)
  command 1, "zero", slot 
  bin = []
  while num > 0
    num, r = num.divmod(2)
    bin << r
  end
  command 2, slot, "zero"
  while i=bin.pop
    command 1, "succ", slot if i==1
    command 1, "dbl",  slot unless bin.empty?
  end
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
o slot2, "succ"

o "K", slot1
o "S", slot1
o slot1, "get"
o "K", slot1
o "S", slot1
o slot1, "succ"
o slot1, "zero"

10.times do |i|
  o "put", i + slot2
  o i + slot2, "get"
  o i + slot2, "zero"
end

o slot2, "zero"
o slot2, "zero"
o 255, "zero"


