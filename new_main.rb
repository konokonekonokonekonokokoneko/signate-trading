# 処理の流れを決めるファイルです
require './data_source.rb'
require './ga_multi.rb'
require 'csv'
require 'parallel'

# とりあえずデータは全部読んでしまったほうがいい感じですよ
data_source = DataSource.new
ret_value = data_source.get_data('return')
cost_value = data_source.get_data('cost')
# いろんな決めごと
SEED = 300
ORDER_RANGE = 11
PREFIX = "test_300" # ファイルを区別する名前です

# データ毎に最適な遺伝子を選びます
def optimize_genes(ret_value, cost_value, random, num) # num個遺伝子を持ってくる
    data_range = (0..ret_value.length - 1).to_a
    genes = Parallel.map(data_range, in_processes: 3) do |i|
        p "#{i}回目のデータ"
        Ga.new(ret_value[i], cost_value[i], random).calculate(num)
    end
    return genes
end

# 合計が1.0の配列に調整するメソッドです
def adjust(arr)
    # どう調整するか？わかんないから挟撃法でいきます
    dv = 567 # 初期値な
    dt = 10 # 刻み幅の初期値な
    er = 0.00001 # ここまで詰めよう
    df = 0.0
    df_o = 0.0 # 古い値を持って置かないといかんのだよ
    loop do
        # 割り算しますよ
        new_arr = arr.map {|i| i.to_f / dv}
        df = 1.0 - new_arr.reduce {|sum, i| sum + i}
        #p df
        break if df >= 0.0 && df < er
        # 三項演算子使いまくりだ
        df > 0.0 ? dv -= dt : dv += dt
        # 正負の符号が変わった場合です
        df_o / df < 0.0 ? dt = dt / 4.0 : # 何もしない
        df_o = df
        #p dv
        #p dt 
    end
    # 面倒なので再度計算して返します
    return arr.map {|i| i.to_f / dv}    
end

# やばい。繰り返しがなくなったらシンプルになりすぎ
p Time.now

# 本体です
random = Random.new(SEED)

# 遺伝子ごとの最適化したものを集めます
genes = optimize_genes(ret_value, cost_value, random, ORDER_RANGE)
#p genes

# GAの計算は終わったので重みだけ取り出しましょう
weights = [] # 明らかに英語がおかしい
genes.each do |set|
    arr = []
    set.each do |gene|
        arr.push(gene.weight)
    end
    weights.push(arr)
end

# データの数 / 順位の数 / 遺伝子の長さ　のマトリックスになっています
new_genes = []
weights.each do |weight|
    # weightには遺伝子が10個詰まっています
    # 個別にadjustしてくっつけてしまいましょう
    arr = []
    weight.each do |w|
        #arr.concat(adjust(w))
        arr.concat(w) # もうこの段階でadjustする時代じゃない
    end
    new_genes.push(arr)
end

# まあ計算はとりあえず終わりました
p Time.now

# 計算のベースになるデータをダンプします
CSV.open("files/train_#{PREFIX}.csv", 'w') do |csv|
    # 提出用にここは隠しておく。予測には使用する
    new_genes.each do |gene|
        csv << gene # おっ、めっちゃシンプルだな
    end
end
