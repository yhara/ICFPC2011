#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# 狙った数字を狙ったフィールドに書き込む
def command(a, b, c)
  puts a
  puts b
  puts c
end

def o(arg1, arg2)
  apply = arg1.class == String ? 1 : 2
  command apply, arg1, arg2
end

def self.make_num(slot, num)
  o slot, "zero" # => 0
  o "succ", slot # => 1
  dbl_cnt = Math::log2(num).to_i
  dbl_cnt.times do
    o "dbl", slot
  end
  succ_cnt = num - (1 << dbl_cnt)
  succ_cnt.times do
    o "succ", slot
  end
end

make_num(100, 100)
