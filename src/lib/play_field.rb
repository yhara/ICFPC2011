# -*- coding: utf-8 -*-
require "player"

class PlayField
  def initialize(first_player=:myself)
    @myself = Player.new(:myself)
    @enemy = Player.new(:enemy)
    @trun = 0
    @opponent = @myself
    @proponent = @enemy
    @apply_cnt = 0
  end

  attr_reader :myself, :enemy, :trun, :opponent, :proponent
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

  def change_player
  end

  def next_turn
    return [opponent, proponent]
  end

  def before_turn
  end

  def after_turn
  end

  private
  def deepclone
    return Marshal.load(Marshal.dump(self))
  end
end
