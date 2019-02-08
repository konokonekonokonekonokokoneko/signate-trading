# 複数のサンプル領域の計算結果を出します
require 'csv'
require './ga.rb'
require './data_source.rb'
DATA_LENGTH = 3571
SAMPLE_LENGTH = 200 
NUMBER_OF_TERMS = 10 # 何期やるの
r_seeds = [10, 11, 12, 13, 14, 15, 16, 17, 18 ,19] # 乱数のシードは明示的に指定します。上に合わせるよ
PREFIX = "1st" # ファイルを区別する名前です
# windowのサイズを決めます
def window_start_point(base, random)
    # どこから取るか決めますよ
    start_point = 0
    loop do
        start_point = (DATA_LENGTH * random.rand).to_i
        break if start_point < DATA_LENGTH - base # ちゃんと期の中に収まるように。偶然かぶった場合は気にしない
    end
    return start_point
end

NUMBER_OF_TERMS.times do |num|
    # 乱数を作ります
    random = Random.new(r_seeds[num])
    # ファイルポインタです
    wp = CSV.open("files/output_#{PREFIX}_#{num}.csv", 'w')
    # 訓練データです。最初と長さを決めて切り取ります
    data_source = DataSource.new
    timestamp = data_source.get_data("return").slice(window_start_point(SAMPLE_LENGTH, random), SAMPLE_LENGTH)
    # GAで計算するよ
    Ga.new(timestamp, wp, random).calculate # とりあえずな
end