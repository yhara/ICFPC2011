#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require_relative "helper"

# 1: S(K(help(1)(2)))(K(16384))
def help_for_zombie(i, j)
  o 1, "help"           # 1: help
  bind(1, i)            # 1: help(i)
  bind(1, j)            # 1: help(i)(j)
  o "K", 1              # 1: K(help(i)(j))
  o "S", 1              # 1: S(K(help(i)(j)))
  bind(1, 15000, ["K"]) # 1: S(K(help(1)(2)))(K(16384))
end

# 1: S(K(attack(1)(2)))(K(16384))
def attack_for_zombie(i, j)
  o 1, "attack"         # 1: attack
  bind(1, i)            # 1: attack(i)
  bind(1, j)            # 1: attack(i)(j)
  o "K", 1              # 1: K(attack(i)(j))
  o "S", 1              # 1: S(K(attack(i)(j)))
  bind(1, 15000, ["K"]) # 1: S(K(attack(1)(2)))(K(16384))
end

# 送り込むzomibeを準備
# 2: S(K(S(zombie(target_slot))(get)))(succ)(zero)
def zomie_powdar(target_slot)
  o 2, "zombie"        # 2: zombie
  bind(2, target_slot) # 2: zombie(target_slot)
  o "S", 2             # 2: S(zombie(target_slot))
  o 2, "get"           # 2: S(zombie(target_slot))(get)
  o "K", 2             # 2: K(S(zombie(target_slot))(get))
  o "S", 2             # 2: S(K(S(zombie(target_slot))(get)))
  o 2, "succ"          # 2: S(K(S(zombie(target_slot))(get)))(succ)

  # zobie powder!!!!!!!!!!!!!!!!!!!!
  o 2, "zero"          # s: S(K(S(zombie(target_slot))(get)))(succ)(zero)
end

# [:I]を受け取ったときに強力なhelp or attackを呼び出したい
# help(i)(j)(n)
#  v[i] -= n
#  v[j] -= n * 1.1
# i, j, n に強力な数字を保持し、Iで起動するように

# 0で数値を生成する =>
# S(K(attack(by0)(by0)))(K(by0)) => 1において
# S(K(S(zombie(i))(get)))(succ)(zero)   => 2において

# 最短のケース。52ターンで攻撃可能。
help_for_zombie(0, 1)
zomie_powdar(0)
