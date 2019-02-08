# データの読み込みを別クラスにしてみます
# 何か良いことがあるかもしれない
class DataSource
    require 'csv'
    def initialize # パラメータいるかな？
        # ファイルから読み込んで名前をつける
        @data_sources = {}
        # ファイル名とラベルの組です
        # 雑いファイルの指定方法だ
        data_files = [["cost", "files/TrainValid_Cost.csv"], ["return", "files/TrainValid_Return.csv"], ["turnover", "files/TrainValid_Turnover.csv"]]
        # 読むよ
        data_files.each do |source|
            @data_sources[source[0]] = CSV.read(source[1], :headers => false, :converters => :numeric).slice(1..-1) # 一行目は邪魔
            # 最初の要素もいらないよ、実は
            @data_sources[source[0]].map! {|data| data.slice(1..-1)}
        end
    end

    # 必要な名前のデータを読み出します
    def get_data(name)    
        return @data_sources[name]
    end
end