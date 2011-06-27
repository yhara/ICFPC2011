# -*- coding: utf-8 -*-
require 'vm'
require 'play_field'
require 'errors'
require 'solver'
require 'player'
require 'slot'
require 'utils'

# 環境を表現する。
class World
  # プレイヤーのスロット数。
  NUM_SLOTS = 256

  attr_reader :play_field

  def initialize
    @solver = Solver.new
    @play_field = PlayField.new
  end

  # 「include Singleton」を使うと以下の例外が発生するので自前
  #   <internal:prelude>:8:in `lock': deadlock; recursive locking (ThreadError)
  @@instance = World.new
  def self.instance
    return @@instance
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
        answer = nil
        begin
          answer = @solver.solve
        rescue Exception => es
          answer = [:left, :I, 0]
          log("Solver#solveの実行中に予期せぬ例外が発生しました。何も変化がない処理を出力させます。 例外クラス=<#{es}> メッセージ=<#{es}> 出力=<#{answer.inspect}>")
          es.backtrace.each do |l|
            log("  #{l}")
          end
          if ENV["yarunee_debug"]
            raise
          end
        end
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
  rescue Exception => e
    log("決闘中にエラーが発生しました。スリープモードに入ります。 例外クラス=<#{e.inspect}> メッセージ=<#{e}>")
    e.backtrace.each do |l|
      log("  #{l}")
    end
    exit
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

  # cardの値が15種類に含まれることを確認する。問題がなければ
  # cardの値を文字列にして返す。
  def validate_card(card)
    card = card.to_sym
    case card
    when :I, :zero, :succ, :dbl, :get, :put, :S, :K, :inc, :dec, :attack, :help, :copy, :revive, :zombie
      return card.to_s
    else
      raise ArgumentError, "cardの値<#{card}>が不正です"
    end
  end
  
  # slotの値が0から255までの整数であることを確認する。問題がなければ
  # slotの値を文字列にして返す。
  def validate_slot(slot)
    slot = slot.to_i
    if !(0..255).include?(slot)
      raise ArgumentError
    end
    return slot.to_s
  end

  def answer_output(answer)
    out = []
    begin
      if answer[0] == :left
        out[0] = "1"
        out[1] = validate_card(answer[1])
        out[2] = validate_slot(answer[2])
      else
        out[0] = "2"
        out[1] = validate_slot(answer[2])
        out[2] = validate_card(answer[1])
      end
    rescue ArgumentError => e
      out = ["1", "I", "0"]
      log("自手の適用に不正な値があります。何も変化がない適用を出力します。 メッセージ=<#{es}> 適用=<#{out.inspect}>")
    end
    puts out[0]
    puts out[1]
    puts out[2]
  end
end
