# -*- coding: utf-8 -*-
# 各スロットを表現する。
class Slot
  INITIAL_VITALITY = 10000
  INITIAL_FIELD = [:I]

  # スロット番号。0-255
  attr_accessor :slot_no

  # バイタリティ。
  attr_accessor :vitality

  # フィールド。
  attr_accessor :field
  
  def initialize(slot_no, vitality = INITIAL_VITALITY, field = INITIAL_FIELD)
    @slot_no = slot_no
    @vitality = vitality
    @field = field
  end
  
  # 生存しているかどうか。
  def alived?
    return @vitality > 0
  end
  
  def dead?
    return @vitality <= 0
  end

  # ゾンビ状態かどうか。
  def zombied?
    return @vitality == -1
  end

  def to_s
    s = field.to_s.gsub(/\[:/, "(").gsub(/\]/, ")").gsub(/, /, "").sub(/^\(/, "").sub(/\)$/, "")
    return "#{slot_no}={#{vitality},#{s}}"
  end
end
