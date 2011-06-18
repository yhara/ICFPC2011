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
  def run(first_player_type)
    $stdout.sync = true
    $stdin.sync = true
    first_player = first_player_type == "0" ? :mine : :enemy
    @play_field = PlayField.new(first_player)
    loop {
      if @play_field.my_turn?
        answer = @solver.solve
        answer_output(answer)
      else
        answer = get_enemy_answer
      end
      @play_field.run(*answer)
      @play_field.swap_players
    }
  end

  private
  def get_enemy_answer
    lr = $stdin.gets.chomp
    lr = (lr == "1") ? :left : :right
    card = $stdin.gets.chomp
    slot = $stdin.gets.chomp.to_i
    return [lr, card.to_sym, slot]
  end

  def answer_output(answer)
    out = []
    out[0] = answer[0] == :left ? "1" : "2"
    out[1] = answer[1].to_s
    out[2] = answer[2].to_s
    puts out[0].to_s
    puts out[1].to_s
    puts out[2].to_s
  end
end
