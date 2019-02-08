# 訓練データを何ていうか取り扱います
class TrainDataSource
    require 'csv'
    def initialize(file_name) # パラメータいるかな？
        # ファイルから読み込んで名前をつける
        @data_sources = {}
        # ファイル名とラベルの組です
        # 雑いファイルの指定方法だ
        data_files = [["train", "files/#{file_name}"]]
        # 読むよ
        data_files.each do |source|
            @data_sources[source[0]] = CSV.read(source[1], :headers => false, :converters => :numeric)
        end
    end

    # 必要な名前のデータを読み出します
    def get_data(name)    
        return @data_sources[name]
    end
end