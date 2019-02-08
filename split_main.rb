# 処理の流れを決めるファイルです
require './split_data_source.rb'
require './ga.rb'
require 'csv'
require 'parallel'
require 'optparse'
# とりあえず
params = ARGV.getopts('c:r:t:')

# とりあえずデータは全部読んでしまったほうがいい感じですよ
data_source = DataSource.new(params["c"], params["r"], params["t"])
ret_value = data_source.get_data('return')
cost_value = data_source.get_data('cost')
# いろんな決めごと
#seeds = [10, 11, 12, 13, 14, 15, 16, 17, 18 ,19]
seeds = [10, 11, 12, 13, 14, 15]
#seeds = [10, 11, 12]
PREFIX = "split_data" # ファイルを区別する名前です

# データ毎に最適な遺伝子を選びます
def optimize_genes(ret_value, cost_value, random)
    genes = []
    ret_value.each_with_index do |ret, i|
        # データを使って計算します
        p "乱数#{random}の#{i}回目のデータ"
        new_gene = Ga.new(ret, cost_value[i], random).calculate
        genes.push(new_gene)
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
        break if df >= 0.0 && df < er
        # 三項演算子使いまくりだ
        df > 0.0 ? dv -= dt : dv += dt
        # 正負の符号が変わった場合です
        df_o / df < 0.0 ? dt = dt / 4.0 : # 何もしない
        df_o = df
    end
    # 面倒なので再度計算して返します
    return arr.map {|i| i.to_f / dv}    
end

# 本体です
# まず乱数のシードを変更しながらseedsの回数だけ遺伝子の最適化を行います
genes = Parallel.map(seeds, in_processes: 3) do |seed|
    random = Random.new(seed)
    optimize_genes(ret_value, cost_value, random)
end

# GAの計算は終わったので重みだけ取り出しましょう
weights = [] # 明らかに英語がおかしい
genes.each do |gene|
    arr = []
    gene.each do |g|
        arr.push(g.weight)
    end
    weights.push(arr)
end

# まずデータ全域に渡って足すということをちゃんと認識する必要があります
# seedの数 / データの数 / 遺伝子の長さ　のマトリックスになっています
new_genes = []
for i in 0..weights[0].length - 1 # これがデータの長さね
    # 仮のアレイを一回作っときましょう
    arr = []
    # またforかよ
    for j in 0..seeds.length - 1 # 繰り返しの回数分ね
        # これで取り出せるぜ
        #arr.push(weights[j][i])
        arr.concat(weights[j][i]) # データをseeds個分くっつけています
    end
    # transposeできるようになった（はず）
    #new_genes.push(adjust(arr.transpose.map{|a| a.reduce(:+) })) # あってるはず
    new_games.push(arr) # adjustはしないです。整数の方が計算が早そう
end

# 計算のベースになるデータをダンプします
CSV.open("files/train_#{PREFIX}_#{Time.now.to_i}.csv", 'w') do |csv|
    # 提出用にここは隠しておく。予測には使用する
    for i in 0..new_genes.length - 1 # 下のロジックを借りました。行番号とか余計なものはいりません
        csv << new_genes[i]
    end
end

=begin
# ここから計算しますがとりあえずファイルに出力しますよ
CSV.open("files/output_#{PREFIX}.csv", 'w') do |csv|
    arr = []    
    567.times do |num|    
        arr << 0    
    end    
    arr_0 = [0].concat(arr)
    arr_1 = [1].concat(arr)        
    csv << arr_0        
    csv << arr_1
    # 提出用にここは隠しておく。予測には使用する
    for i in 2..new_genes.length - 1
        csv << [i].concat(new_genes[i])
    end
    # これは本当は予測するはずのデータですよ
    csv << [new_genes.length].concat(new_genes[-1])# 超適当
    csv << [new_genes.length + 1].concat(new_genes[-1])
end
=end