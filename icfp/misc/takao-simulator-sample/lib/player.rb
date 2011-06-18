# -*- coding: utf-8 -*-
require "world"
require "slot"

# プレイヤーを表現する。
class Player
  # プレイヤー番号。
  # 0: 先攻
  # 1: 後攻
  attr_accessor :no

  # 全てのスロット。
  attr_accessor :slots
  
  def initialize(no)
    @no = no
    @slots = Array.new(Word::NUM_SLOTS) { Slot.new }
  end
end
