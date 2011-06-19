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

def zombie(i, x)
  slot = 1
  command 2, slot, "zombie"
  command 1, "K", slot
  command 1, "S", slot
  command 2, slot, "get"
  set_constant(i, 0)
  command 2, slot, "zero"
  command 1, "K", slot
  command 1, "S", slot
  command 2, slot, "I"
  command 2, slot, x
end

def attack(i, j, n)
  slot = 1
  command 2, slot, "attack" # 1: attack
  command 1, "K", slot      # 1: K(attack)
  command 1, "S", slot      # 1: S(K(attack))
  command 2, slot, "get"    # 1: S(K(attack))(get)
  set_constant(i, 0)        # 0: 100 = i
  command 2, slot, "zero"   # 0: S(K(attack))(get)(zero) => attack(100)
  command 1, "K", slot      # 0: K(attack(100))
  command 1, "S", slot      # 0: S(K(attack(100)))
  command 2, slot, "get"
  set_constant(j, 0)
  command 2, slot, "zero"
  command 1, "K", slot
  command 1, "S", slot
  command 2, slot, "get"
  set_constant(n, 0)
  command 2, slot, "zero"
end

100000.times do |i|
  n = (i+1)*2
  (n..(n+1)).each do |j|
    attack(j, i, 5556)
  end
end
