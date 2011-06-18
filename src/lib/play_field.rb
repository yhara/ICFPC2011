# -*- coding: utf-8 -*-
require "player"

class PlayField
  def initialize(first_player=:myself)
    @myself = Player.new(:myself)
    @enemy = Player.new(:enemy)
    @turn = 0
    @opponent = @myself
    @proponent = @enemy
    @first_player = first_player
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
    if @opponent.name == :myself
      @opponent = @enemy
      @proponent = @myself
    else
      @opponent = @myself
      @proponent = @enemy
    end
    change_turn if @opponent.name == @first_player
  end

  # ソンビが動く！！
  def zombies!
    # TODO:
  end

  private
  def change_turn
    @turn+=1
    zombies!
  end

  def deepclone
    return Marshal.load(Marshal.dump(self))
  end
end
