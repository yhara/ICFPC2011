# -*- coding: utf-8 -*-
require "card"

# 環境を表現する。
class World
  # プレイヤーのスロット数。
  NUM_SLOTS = 256

  # バイタリティの初期値。
  DEFAULT_VITALITY = 10000
  
  # フィールドの初期値。
  DEFAULT_FIELD = Card["I"]
  
  # プレイヤー。
  attr_accessor :players

  # 自分のプレイヤー。
  attr_accessor :mine
  
  # 現在のプレイヤー番号。
  attr_accessor :current_player_no
  
  # ターン番号。(1〜100,000)
  attr_accessor :turn_no

  # mine_no: 自分のプレイヤー番号
  def initialize(mine_no)
    @players = [Player.new(0), Player.new(1)]
    @mine = @players[mine_no]
    @current_player_no = 0
    @turn_no = 1
    @@instance = self
  end

  def self.instance
    raise if !@@instance
    return @@instance
  end

  def proponent
    return @players[@current_player_no]
  end
  
  def opponent
    return @players[@current_player_no == 0 ? 1 : 0]
  end
end
