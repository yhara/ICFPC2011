#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require_relative "helper"

# ザラキ!! 1ターンで70スロットが死亡
#   S(S(S(help)(I))(K(8192)))(S(S(K(copy))(K(1)))(succ))
#     f <- g x : S(S(help)(0))(K(8192))(0)
#       h <- f x : S(help)(0)(0)
#         h <- f x : help(0)
#         y <- g x : I(0)
#         r <- h y : help(0)(0)
#       y <- g x : K(8192)(0)
#       h <- h y : help(0)(0)(8192) => 実行!!
#     y <- g x : S(S(K(copy))(K(1)))(succ)(0)
#       h <- f x : S(K(copy))(K(1))(0)
#         h <- f x : K(copy)(0) -> copy
#         y <- g x : K(1)(0) -> 1
#         r <- h y : copy(1) -> 自分自身をコピー
#       y <- g x : succ(0) -> 1
#       r <- h y : (..copyされたもの.)(succされた数字)
#           .... 続く
def zaraki(n)
  # 2: S(S(help)(I))(K(8192))
  o "put", 2
  o 2, "help"                          # 2: help
  o "S", 2                             # 2: S(help)
  o 2, "I"                             # 2: S(help)(I)
  o "S", 2                             # 2: S(S(help)(I))
  bind(2, 8192, apply_to_zero: ["K"])  # 2: S(S(help)(I))(K(8192))

  # 1: S(S(K(copy))(K(1)))(succ)
  o "put", 1
  o 1, "copy"                          # 1: copy
  o "K", 1                             # 1: K(copy)
  o "S", 1                             # 1: S(K(copy))
  bind(1, 1, apply_to_zero: ["K"])     # 1: S(K(copy))(K(1))
  o "S", 1                             # 1: S(S(K(copy))(K(1)))
  o 1, "succ"                          # 1: S(S(K(copy))(K(1)))(succ)

  # Merge S(2)(1) => S(2)(1)
  o "S", 2    # 2: S(2)
  o "K", 2    # 2: K(S(2))
  o "S", 2    # 2: S(K(S(2)))
  o 2, "get"  # 2: S(K(S(2)))(get)
  o "K", 2    # 2: K(S(K(S(2)))(get))
  o "S", 2    # 2: S(K(S(K(S(2)))(get)))
  o 2, "succ" # 2: S(K(S(K(S(2)))(get)))(succ)
  o 2, "zero" # 2: S(K(S(K(S(2)))(get)))(succ)(zero) => S(2)(1) => loop

  # 1==2, 自分自身のcopyって簡単だったのか…。
  o "put", 1
  o 1, "zero"
  o "succ", 1
  o "succ", 1
  o "get", 1

  # target set
  # S(K(loop))(K(n)) => zombieで I が渡ってもnの値を返す
  o "K", 2    # 2: K(loop)
  o "S", 2    # 2: S(K(loop))
  bind(2, n, apply_to_zero: ["K"]) # 2: S(S(K(loop)))(K(n))
end

def merge
end

def zombie_powder(target_slot, slot, func_slot)
  o "put", slot
  o slot, "zombie"        # 2: zombie
  bind(slot, target_slot) # 2: zombie(target_slot)
  o "K", slot             # 2: S(zombie(target_slot))
  o "S", slot             # 2: S(K(zombie(target_slot))))
  o slot, "get"           # 2: S(K(zombie(target_slot)))(get)
  o "K", slot             # 2: K(S(K(zombie(target_slot)))(get))
  o "S", slot             # 2: S(K(S(K(zombie(target_slot)))(get)))
  make_num 0, func_slot
  o slot, "get"
  o slot, "zero"
end


def attack(i, j, n, slot)
  o slot, "attack" # 1: attack
  bind(slot, i)    # 1: attack(i)
  bind(slot, j)    # 1: attack(i)(j)
  bind(slot, n)    # 1: attack(i)(j)(n)
end

slot = 1
# 255スロットを確実にぶっ殺す
attack(128, 0, 8196, slot)
attack(129, 0, 8196, slot)

# 以下、470ターンで勝利
zaraki(0)
zombie_powder(0, 3, 2)
o "put", 1
o "put", 2

zaraki(71)
zombie_powder(0, 3, 2)
o "put", 1
o "put", 2

zaraki(142)
zombie_powder(0, 3, 2)
o "put", 1
o "put", 2

zaraki(213)
zombie_powder(0, 3, 2)
o "put", 1
o "put", 2

