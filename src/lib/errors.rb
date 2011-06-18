# -*- coding: utf-8 -*-

# エラー
class NativeError < StandardError
end

# ロジックエラー。これが発生するとプログラムに重大な欠陥があることを示
# す。
class LogicError < RuntimeError
end
