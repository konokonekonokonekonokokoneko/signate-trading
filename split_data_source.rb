# データの読み込みを別クラスにしてみます
# 何か良いことがあるかもしれない
class DataSource
    require 'csv'
    def initialize(cost_file, return_file, turnover_file) # パラメータいるかな？
        # ファイルから読み込んで名前をつける
        @data_sources = {}
        # ファイル名とラベルの組です
        # 雑いファイルの指定方法だ
        data_files = [["cost", "files/#{cost_file}"], ["return", "files/#{return_file}"], ["turnover", "files/#{turnover_file}"]]
        # 読むよ
        data_files.each do |source|
            @data_sources[source[0]] = CSV.read(source[1], :headers => false, :converters => :numeric)
            # 最初の要素もいらないよ、実は
            @data_sources[source[0]].map! {|data| data.slice(1..-1)}
        end
    end

    # 必要な名前のデータを読み出します
    def get_data(name)    
        return @data_sources[name]
    end
end