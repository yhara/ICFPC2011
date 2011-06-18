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
    @play_field = PlayField.new
  end

  # 環境を初期化する
  def reset
    @play_field = PlayField.new
  end

  # 実行
  def run(lr, card, slot)
    # TODO
  end
end
