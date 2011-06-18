# -*- coding: utf-8 -*-
require "player"

class PlayField
  def initialize(first_player_name = :myself)
    @myself = Player.new(:myself)
    @enemy = Player.new(:enemy)
    @players = {}
    @players[@myself.name] = @myself
    @players[@enemy.name] = @enemy
    @first_player_name = first_player_name
    @turn = 0
    @proponent = @players[@first_player_name]
    @opponent = @players[@first_player_name == :myself ? :enemy : :myself]
    @apply_cnt = 0
  end

  attr_reader :myself, :enemy, :turn, :opponent, :proponent
  attr_accessor :apply_cnt

  def run(lr, card, slot, opts={})
    VM.simulate(self) do |vm|
      vm.run(lr, card, slot, opts)
    end
  end

  # 自身を複製してrunする
  def apply(lr, card, slot, opts={})
    dup = deepclone
    VM.simulate(dup) do |vm|
      vm.run(lr, card, slot, opts)
    end
    return dup
  end

  # プレイヤー変更
  def swap_players
    @apply_cnt = 0
    if my_turn?
      @proponent = @enemy
      @opponent = @myself
    else
      @proponent = @myself
      @opponent = @enemy
    end
    @turn += 1 if @proponent.name == @first_player_name
  end

  def my_turn?
    @proponent.name == :myself
  end

  private

  def deepclone
    return Marshal.load(Marshal.dump(self))
  end
end
