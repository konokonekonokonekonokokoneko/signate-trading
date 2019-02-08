# トレーニングファイルを作ります
# まずcsv群を読みます
require './data_source.rb'
data_source = DataSource.new
cost_data = data_source.get_data('cost')
p cost_data.length
return_data = data_source.get_data('return')
p return_data.length
turnover_data = data_source.get_data('turnover')
p turnover_data.length
# 重みのファイルも読みます
require 'csv'
gene_data = 'files/train_test_case_5.csv'
genes = CSV.read(gene_data, :headers => false, :converters => :numeric)
p genes.length

# 書き出します
CSV.open("files/train_case_5_data.csv", 'w') do |csv|
    for i in 0..genes.length - 103 # 2個分少なくしないといかんですよ
        # コンカチするよ
        arr = []
        arr.concat(genes[i]).concat(cost_data[i]).concat(return_data[i]).concat(turnover_data[i])
        csv << arr
    end
end

CSV.open("files/train_case_5_target.csv", 'w') do |csv|
    for i in 2..genes.length - 101 # 2始まりなのよこれが
        # コンカチするものはない
        csv << genes[i] # 冗長じゃない？
    end
end

CSV.open("files/test_case_5_data.csv", 'w') do |csv|
    for i in genes.length - 102..genes.length - 3 # 2個分少なくしないといかんですよ
        # コンカチするよ
        arr = []
        arr.concat(genes[i]).concat(cost_data[i]).concat(return_data[i]).concat(turnover_data[i])
        csv << arr
    end
end

# いらないけど
CSV.open("files/test_case_5_target.csv", 'w') do |csv|
    for i in genes.length - 100..genes.length - 1 # 2始まりなのよこれが
        # コンカチするものはない
        csv << genes[i] # 冗長じゃない？
    end
end

# 書き出します
CSV.open("files/train_case_5_full_data.csv", 'w') do |csv|
    for i in 0..genes.length - 3 # 2個分少なくしないといかんですよ
        # コンカチするよ
        arr = []
        arr.concat(genes[i]).concat(cost_data[i]).concat(return_data[i]).concat(turnover_data[i])
        csv << arr
    end
end

CSV.open("files/train_case_5_full_target.csv", 'w') do |csv|
    for i in 2..genes.length - 1 # 2始まりなのよこれが
        # コンカチするものはない
        csv << genes[i] # 冗長じゃない？
    end
end