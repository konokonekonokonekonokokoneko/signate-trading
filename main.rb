# 処理の流れを決めるファイルです
require './data_source.rb'
require './ga.rb'
require 'csv'
require 'parallel'

# とりあえずデータは全部読んでしまったほうがいい感じですよ
data_source = DataSource.new
ret_value = data_source.get_data('return')
cost_value = data_source.get_data('cost')
# おもすぎです
# これはとりあえずこのまま持っておきます
=begin
timestamp = []
for i in 0..ret_value.length - 1
    # とりあえず一つにします
    timestamp.push(ret_value.zip(cost_value))
end
=end
# いろんな決めごと
#seeds = [10, 11, 12, 13, 14, 15, 16, 17, 18 ,19]
#seeds = [10, 11, 12, 13, 14, 15]
#seeds = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19 ,20, 21] # ケース1/2/5
seeds = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19 ,20, 21, 22, 23, 24] # ケース3/4/6
#PREFIX = "test_12_10_21" # ファイルを区別する名前です。ケース1
#PREFIX = "test_case_2" # ケース2
#PREFIX = "test_case_3" # ケース3
#PREFIX = "test_case_4" # ケース4
#PREFIX = "test_case_5" # ケース5
PREFIX = "test_case_6" # ケース6
# データ毎に最適な遺伝子を選びます
def optimize_genes(ret_value, cost_value, random)
    genes = []
    ret_value.each_with_index do |ret, i|
        # データを使って計算します
        p "乱数#{random}の#{i}回目のデータ"
        new_gene = Ga.new(ret, cost_value[i], random).calculate
        #p new_gene
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

# 本体です
# まず乱数のシードを変更しながら10回遺伝子の最適化を行います
#genes = []
genes = Parallel.map(seeds, in_processes: 3) do |seed|
#seeds.each do |seed|
    random = Random.new(seed)
    # 評価するですよ
    #p "最初"
    #p "ret_value"
    #p ret_value.length
    #p "cost_value"
    #p cost_value.length
    optimize_genes(ret_value, cost_value, random)
end
=begin
# 各遺伝子の値を正規化します
#genes.map {|gene| p "==="; p gene}
#new_genes = []
genes.map {|gene| gene.weight.transpose.map{|a| a.reduce(:+) }}.each do |gene| # 10回分は予め足し合わせておかないと
    new_genes.push(adjust(gene))
end
=end

# GAの計算は終わったので重みだけ取り出しましょう
weights = [] # 明らかに英語がおかしい
genes.each do |gene|
    #p "計算後"
    #p gene.length
    arr = []
    gene.each do |g|
        arr.push(g.weight)
    end
    weights.push(arr)
end

# 案の定わかんなくなった
=begin
# やばい。複雑で訳わかんなくなりそう
p "重み"
p weights.length
p weights[0].length
p weights[0][0].length
new_genes = []
weights.map {|weight| weight.transpose.map{|a| a.reduce(:+) }}.each do |weight| # 繰り返した分は足しておかないと
    # ここで初めてadjustできるです
    new_genes.push(adjust(weight))
end
=end

# まずデータ全域に渡って足すということをちゃんと認識する必要があります
# seedの数 / データの数 / 遺伝子の長さ　のマトリックスになっています
new_genes = []
for i in 0..weights[0].length - 1 # これがデータの長さね
    # 仮のアレイを一回作っときましょう
    arr = []
    # またforかよ
    for j in 0..seeds.length - 1 # 繰り返しの回数分ね
        # これで取り出せるぜ
        arr.push(weights[j][i])
    end
    # transposeできるようになった（はず）
    new_genes.push(adjust(arr.transpose.map{|a| a.reduce(:+) })) # あってるはず
end

#p "new_genes"
#p new_genes.length
#p new_genes[0].length

# ここでやっとt+2の予測を始めます。
# 過去N回分のデータから予測しましょう

# 計算のベースになるデータをダンプします
CSV.open("files/train_#{PREFIX}.csv", 'w') do |csv|
    # 提出用にここは隠しておく。予測には使用する
    for i in 0..new_genes.length - 1 # 下のロジックを借りました。行番号とか余計なものはいりません
        csv << new_genes[i]
    end
end

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
