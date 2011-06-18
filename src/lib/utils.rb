# -*- coding: utf-8 -*-
# クラスやモジュールに属さないような便利な処理を記述する。

# 環境変数yarunee_debugに何かセットしてあればログを出力する。
if ENV["yarunee_debug"]
  require "logger"
  path = ENV["yarunee_log"] || "yarunee_debug.log"
  $logger = Logger.new(path)
  def log(*args)
    $logger.info(sprintf(*args))
  end
else
  def log(*args)
  end
end
