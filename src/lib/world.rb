# -*- coding: utf-8 -*-
require 'singleton'
require 'vm'
require 'play_field'
require 'errors'
require 'solver'
require 'player'
require 'slot'
require 'utils'

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
  def run(first_player_type, opts={})
    $stdout.sync = true
    $stdin.sync = true
    $stderr.sync = true
    first_player = first_player_type == "0" ? :myself : :enemy
    @play_field = PlayField.new(first_player)
    loop {
        if @play_field.my_turn?
          answer = @solver.solve
          answer_output(answer)
        else
          answer = get_enemy_answer
        end
      begin
        @play_field.run(*(answer << opts))
      rescue NativeError => ex
        log(ex.message)
      end
      @play_field.swap_players
      VM.zombies!(@play_field)
    }
  end

  private
  def get_enemy_answer
    lr = $stdin.gets
    exit(0) if lr.nil?
    lr = lr.chomp
    if lr == "1"
      lr = :left
      card = $stdin.gets.chomp
      slot = $stdin.gets.chomp.to_i
    else
      lr = :right
      slot = $stdin.gets.chomp.to_i
      card = $stdin.gets.chomp
    end
    return [lr, card.to_sym, slot]
  end

  def answer_output(answer)
    out = []
    if answer[0] == :left
      out[0] = "1"
      out[1] = answer[1].to_s
      out[2] = answer[2].to_s
    else
      out[0] = "2"
      out[1] = answer[2].to_s
      out[2] = answer[1].to_s
    end
    puts out[0].to_s
    puts out[1].to_s
    puts out[2].to_s
  end
end
