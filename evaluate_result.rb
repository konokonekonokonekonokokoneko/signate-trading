# 実行結果を評価するやつはやっぱりいるんですよね
require 'csv'

# テストデータが要ります
test_data_file = "files/test_case_5_data.csv"
test_data = CSV.read(test_data_file, :headers => false, :converters => :numeric)
# 計算対象の重みです
#target_data_file = "files/test_case_5_target.csv"
target_data_file = "files/case8_result.csv"
target_data = CSV.read(target_data_file, :headers => false, :converters => :numeric)

# 計算ロジックを入れます
def calculate(weight, ret_value, cost_value, turnover_value)    
    # 普通に計算します    
    val = 0.0
    weight.zip(ret_value, cost_value).each do |data|
        val += data[0] * data[1] - data[2]
    end
    return val
end

# データの長さは全部同じです
data_count = test_data.length
data_length = test_data[0].length / 4
#p data_length

# 処理です
total_amount = 0.0
for i in 0..data_count - 1
    # データを切り出さないといけないですから
    amount = calculate(target_data[i], test_data[i].slice(data_length, data_length), test_data[i].slice(data_length * 2, data_length), test_data[i].slice(data_length * 3, data_length))
    #p amount
    total_amount += amount
end
p total_amount
