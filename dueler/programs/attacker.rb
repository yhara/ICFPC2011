#!/usr/bin/env ruby
require_relative 'helper.rb'
require_relative 'putter.rb'; include Putter

def set_constant(num, slot)
  o "put", slot 
  bin = []
  while num > 0
    num, r = num.divmod(2)
    bin << r
  end
  o slot, "zero"
  while i=bin.pop
    o "succ", slot if i==1
    o "dbl",  slot unless bin.empty?
  end
end

def exec_attack(i,j,n,slot)
  set slot, attack
  bind(slot, i)
  bind(slot, j)
  bind(slot, n)
end

slot1 = 10
target = 0

target.upto(2550) do |i|
  j = i*2 + slot1 + 1
  exec_attack j  , i, 10000, slot1
  exec_attack j+1, i, 10000, slot1
end
