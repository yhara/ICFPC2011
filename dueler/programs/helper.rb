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
def make_about_num(slot, num)
  o slot, "zero" # => 0
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
    # それ以外は指定の数に近いn**2を生成
    now_num = (num - (1 << dbl_cnt)).abs
    onemore_dbl_num = (num - (1 << (dbl_cnt+1))).abs
    if now_num > onemore_dbl_num
      o "dbl", slot
    end
  end
end

# 指定するスロットのcardの引数に指定した数値をbindする
# TODO: スロットが死んだらreviveしなければならない
def bind(slot, num)
  o "put", 0
  make_about_num(0, num)
  o "K", slot      # s: K(card)
  o "S", slot      # s: S(K(card))
  o slot, "get"    # s: S(K(card))(get)
  o slot, "zero"   # s: S(K(card))(get)(zero) => card(i)
end
