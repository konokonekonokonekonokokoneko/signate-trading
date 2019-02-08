# 0/1のデータを整形して合計1.0のベクトルにします
require 'csv'
# csvモジュールはいらんわな。JK
data_file = "./result_20190118.csv"
processed_file = "./processed_20190118.csv"
# この辺に挟撃法のメソッドが入ることになりそう
    
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

open(data_file) do |fp|
    CSV.open(processed_file, 'w') do |csv|
        line = fp.gets
        line.chomp!
        line_csv = line.split(',') # 懐かしい
        p line_csv.length # 567であって欲しい
        # 要素の大きさを求めます
        result_arr = adjust(line_csv)
        # ここでもう出力しちゃっていいですよ
        # submit用のファイルを作る
        arr = []
        567.times do |num|
            arr << 0
        end
        arr_0 = [0].concat(arr)
        arr_1 = [1].concat(arr)    
        csv << arr_0    
        csv << arr_1    
        (2..3572).each do |num|     
            csv << [num].concat(result_arr)    
        end
    end            
end
