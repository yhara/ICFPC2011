# -*- coding: utf-8 -*-
# 各スロットを表現する。
class Slot
  INITIAL_VITALITY = 10000
  INITIAL_FIELD = [:I]

  # バイタリティ。
  attr_accessor :vitality

  # フィールド。
  attr_accessor :field
  
  def initialize(vitality = INITIAL_VITALITY,
                 field = INITIAL_FIELD)
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
