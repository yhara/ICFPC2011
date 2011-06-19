# -*- coding: utf-8 -*-

# エラー
class NativeError < StandardError
end

# 範囲外のインデックスを参照したことを表す例外。
class IndexNativeError < NativeError
end

# 処理の回数が上限に達したことを表す例外。
class ApplicationLimitNativeError < NativeError
end

# ロジックエラー。これが発生するとプログラムに重大な欠陥があることを示
# す。
class LogicError < RuntimeError
end
