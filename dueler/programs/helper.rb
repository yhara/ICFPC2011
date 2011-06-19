# -*- coding: utf-8 -*-
$stdout.sync = true

def read
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

read if ARGV[0] == "1"

def command(a, b, c)
  if $TRACE
    $stderr.puts "【俺のターン】#{b}(#{c})"
  end
  puts a
  puts b
  puts c
  read
end

def o(arg1, arg2)
  apply = arg1.class == String ? 1 : 2
  command apply, arg1, arg2
end

# スロット番号を生成する場合、2**nの位置を指定するとターン数を減らせる
def make_num(slot, num)
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

# 指定するスロットのcardの引数に指定した数値をbindする
# TODO: スロットが死んだらreviveしなければならない
def bind(slot, num, options={})
  o "put", 0
  make_num(0, num)
  options[:apply_to_zero] ||= []
  options[:apply_to_zero].each do |card|
    o card, 0
  end
  o "K", slot      # s: K(card)
  o "S", slot      # s: S(K(card))
  o slot, "get"    # s: S(K(card))(get)
  o slot, "zero"   # s: S(K(card))(get)(zero) => card(i)
end
