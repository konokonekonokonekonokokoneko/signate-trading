# やることは決まっている
# ベクトルが0/1の特別な場合ですよ。アンサンブルで利用するの前提です。収束のスピードを考慮に入れます
# 各遺伝子がどのくらいの利得が取れるかを計算します
### エラー処理とかちゃんとやってないですよ。データをきちんと流し込んでください
class Gene
    attr_accessor :name, :weight
    # uuidはユニークな事が証明されていますからね
    require 'securerandom'
    
    # やっぱり空っぽのgeneが必要と言うことになりました
    def initialize(g_length, random)
        @weight = []
        @random = random
        # 初期値を入れちゃいます
        g_length.times {
            @weight.push(@random.rand(2)) # まあ0/1よ。
        }
    end
    
    # 長さを返す専用のメソッド作る
    def length
        return @weight.length
    end

    # いつもメソッドの名前で悩むんだよな
    # 遺伝子ごとの利得です
    def profit(weight, ret_value, cost_value)
        # 普通に計算します
        val = 0.0
        weight.zip(ret_value, cost_value).each do |data|
            val += data[0] * data[1] - data[2]
        end
        return val
    end

    # 表出なんだけど
    def express(ret_value, cost_value)
        # 簡単になった
        return [profit(@weight, ret_value, cost_value)]
    end

end