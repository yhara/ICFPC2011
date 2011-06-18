# -*- coding: utf-8 -*-
require 'singleton'
require 'vm'
require 'play_field'
require 'errors'
require 'solver'
require 'player'
require 'slot'

# 環境を表現する。
class World
  include Singleton

  # プレイヤーのスロット数。
  NUM_SLOTS = 256

  attr_reader :play_field

  def initialize
    @solver = Solver.new
    @play_field = PlayField.new
  end

  # 環境を初期化する
  def reset
    @play_field = PlayField.new
  end

  # 実行
  def run
    first_player = gets
    first_player = first_player == "0" ? :mine : :enemy
    @play_field = PlayField.new(first_player)
    loop {
      if @play_field.my_turn?
        answer = @solver.solve
        puts answer
      else
        answer = get_enemy_answer
      end
      @play_field.run(*answer)
      @play_field.swap_players
    }
  end

  private
  def get_enemy_answer
    lr = gets
    lr = lr == "1" ? :left : :right
    card = gets
    slot = gets.to_i
    return [lr, card, slot]
  end
end
