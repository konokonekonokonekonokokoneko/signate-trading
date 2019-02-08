# 他でも使うのでアジャストする部分は別クラスにしましょう
class Adjust
    def initialize(array_size, step_value, minimum_error) # 初期のパラメータいっぱい
        # まあ詰めます
        @dv = array_size
        @dt = step_value
        @er = minimum_error
    end

    def evaluate(arr) # 評価するです
        # 初期値をもらいます
        dv = @dv
        dt = @dt
        df = 0.0
        df_o = 0.0 # 古い値を持って置かないといかんのだよ
        loop do
            # 割り算しますよ
            new_arr = arr.map {|i| i.to_f / dv}
            df = 1.0 - new_arr.reduce {|sum, i| sum + i}
            break if df >= 0.0 && df < @er
            # 三項演算子使いまくりだ
            df > 0.0 ? dv -= dt : dv += dt
            # 正負の符号が変わった場合です
            df_o / df < 0.0 ? dt = dt / 4.0 : # 何もしない
            df_o = df
        end
        # 面倒なので再度計算して返します
        return arr.map {|i| i.to_f / dv}
    end
end