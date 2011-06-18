# -*- coding: utf-8 -*-
class Slots < Array
  # 配列の範囲を外れた場合はIndexErrorを発生させる
  def [](i)
    raise IndexError, "index #{i} outside of array" if i < 0
    return self.fetch(i)
  end
end
