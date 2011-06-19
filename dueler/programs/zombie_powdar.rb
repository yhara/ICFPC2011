#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require_relative "num_maker"

# 指定するスロットには対象のcardを入れておかなければならない。
# 引数に数値をbindする
def bind(slot, num)
  o "put", 0
  make_about_num(0, num)
  o "K", slot      # s: K(card)
  o "S", slot      # s: S(K(card))
  o slot, "get"    # s: S(K(card))(get)
  o slot, "zero"   # s: S(K(card))(get)(zero) => card(i)
end

def send_zomie_help(i, j, target_slot)
  o 1, "help"   # s: help
  bind(1, i)
  bind(1, j)
  o "K", 1      # s: K(help(i)(j))
  o "S", 1      # s: S(K(help(i)(j)))
  bind(1, 15000)

  # # 送り込むzomibeを準備
  # make_about_num(0, zombie_slot)
  # o 2, "help" # s: help
  # o "K", 2      # s: K(help)
  # o "S", 2      # s: S(K(help))
  # o 2, "get"    # s: S(K(help))(get)
  # o 2, "zero"   # s: S(K(help))(get)(zero) => help(i)
end


# [:I]を受け取ったときに強力なhelp or attackを呼び出したい
# help(i)(j)(n)
#  v[i] -= n
#  v[j] -= n * 1.1
# i, j, n に強力な数字を保持し、Iで起動するように

# 0で数値を生成する =>
# S(K(attack(by0)(by0)))(K(by0)) => 1において
# S(K(S(zombie(i))(get)))(succ)(zero)   => 2において

send_zomie_help(1, 2, 30)
