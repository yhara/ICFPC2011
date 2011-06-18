# -*- coding: utf-8 -*-
require "errors"

class Slots < Array
  # i番目のスロットを取得する。iは0から255。
  # 範囲外のスロットへのアクセス時にルールとしてエラーを発生させる。
  def [](i)
    raise IndexNativeError, "index #{i} outside of slots" if i < 0 || i >= length
    return fetch(i)
  end
end
