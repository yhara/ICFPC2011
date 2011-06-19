# -*- coding: utf-8 -*-
def command(a, b, c)
  puts a
  puts b
  puts c
end

def o(arg1, arg2)
  apply = arg1.class == String ? 1 : 2
  command apply, arg1, arg2
end

# スロット番号を生成する場合、2**nの位置を指定するとターン数を減らせる
def make_about_num(slot, num, options={})
  o slot, "zero" # => 0
  return if num == 0
  o "succ", slot # => 1
  dbl_cnt = Math::log2(num).to_i
  dbl_cnt.times do
    o "dbl", slot
  end
  # スロット番号を生成する場合は精度を高める。
  if num < 255
    succ_cnt = num - (1 << dbl_cnt)
    succ_cnt.times do
      o "succ", slot
    end
  else
    # :lowerが指定されなければ上にする
    unless options[:lower]
      o "dbl", slot
    end
  end
end

# 指定するスロットのcardの引数に指定した数値をbindする
# TODO: スロットが死んだらreviveしなければならない
# :lower optionを指定できる
def bind(slot, num, options={})
  o "put", 0
  make_about_num(0, num, options)
  options[:apply_to_zero] ||= []
  options[:apply_to_zero].each do |card|
    o card, 0
  end
  o "K", slot      # s: K(card)
  o "S", slot      # s: S(K(card))
  o slot, "get"    # s: S(K(card))(get)
  o slot, "zero"   # s: S(K(card))(get)(zero) => card(i)
end
