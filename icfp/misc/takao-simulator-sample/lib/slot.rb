# -*- coding: utf-8 -*-
require "world"

# 各スロットを表現する。
class Slot
  # バイタリティ。
  attr_accessor :vitality

  # フィールド。
  attr_accessor :field
  
  def initialize(vitality = World::DEFAULT_VITALITY,
                 field = World::DEFAULT_FIELD)
    @vitality = vitality
    @field = field
  end
  
  # 生存しているかどうか。
  def alived?
    return @vitality > 0
  end
  
  # ゾンビ状態かどうか。
  def zombied?
    return @vitality == -1
  end
end
