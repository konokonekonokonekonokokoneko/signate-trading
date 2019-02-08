# まあデータを足し合わせて見ましょう
require './train_data_source.rb'
require './adjust.rb'
require 'csv'

# まずデータを読み込みます
data_source = TrainDataSource.new('train_test_200.csv')
train_data = data_source.get_data('train') # 明らかにおかしな設計。猛省を促したい

# まあ足しこんでadjustします
ARRAY_SIZE = 567 # これはデータの構造に影響するやつじゃね？
ORDER_RANGE = 10 # じっこ分のデータだけ使えるかどうか検証しましょう
PREFIX = "test_200"
adjuster = Adjust.new(ARRAY_SIZE, 10, 0.00001)
genes = []
train_data.each do |data|
    arr = []
    # ARRAY_SIZE毎に区切ります
    arr.concat(data.slice(0, ARRAY_SIZE))
    #p arr
    for i in 1..ORDER_RANGE - 1
        # 切り取りです
        arr = arr.zip(data.slice(i * ARRAY_SIZE, ARRAY_SIZE)).map {|a, b| a + b}
    end
    #p i
    #p arr
    # 足しこんだら修正しないと
    genes.push(adjuster.evaluate(arr))
end

# 最後は出力します
CSV.open("files/result_#{PREFIX}.csv", 'w') do |csv|
    # 提出用にここは隠しておく。予測には使用する
    genes.each do |g|
        csv << g # おっ、めっちゃシンプルだな
    end
end

# 仮に提出用も作ってみますか
CSV.open("files/submit_#{PREFIX}.csv", 'w') do |csv|
    arr = []    
    567.times do |num|    
        arr << 0    
    end    
    arr_0 = [0].concat(arr)
    arr_1 = [1].concat(arr)        
    csv << arr_0        
    csv << arr_1
    # 提出用にここは隠しておく。予測には使用する
    for i in 2..genes.length - 1
        csv << [i].concat(genes[i])
    end
    # これは本当は予測するはずのデータですよ
    csv << [genes.length].concat(genes[-1])# 超適当
    csv << [genes.length + 1].concat(genes[-1])
end
