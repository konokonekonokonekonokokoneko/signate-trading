# coding: utf-8
class Ga
  #require 'parallel'
  require "./gene.rb"

  # 0. いろいろ決めておくことがあります
  #NUMBER = 300
  NUMBER = 50 # ケース6
  #NUMBER = 30 # ケース1/4/5
  #NUMBER = 20 # ケース2/3
  # NUMBERの内訳
  TOP = 1 # エリート戦略ではTopは一つあればいいです。ルーレットも考えておく必要があるですかね
  CROSSING_OVER_RATE = 0.85
  MUTATION_RATE = 0.01
  #GENERATION = 50 # このくらいの世代数にします
  #GENERATION = 20 # このくらいの世代数にします。ケース1/4
  #GENERATION = 15 # このくらいの世代数にします。ケース2/3
  #GENERATION = 30 # このくらいの世代数にします。ケース5
  GENERATION = 40 # このくらいの世代数にします。ケース6
  GENOTYPE_LENGTH = 567 # 遺伝子の長さはまあここで決めます
  
  def initialize(ret_value, cost_value, random) # データは一行だけやって来ます
    @ret_value = ret_value
    @cost_value = cost_value
    @random = random
    # 1. 初期状態を作ります
    @genes = []
    NUMBER.times {
      gene = Gene.new(GENOTYPE_LENGTH, @random) # 乱数を受け継ぎます。グローバルw
      @genes.push(gene)
    }
  end
=begin
  # 全体をとりあえず評価します
  def evaluate(genes, ret_value, cost_value)
    evaluated_genes = Parallel.map(genes, in_processes: 4) do |gene| # 4コアだから
      #genes.each do |gene|
      # geneのお尻に値をくっつけちゃいましょう。結局Topを決めるのにしか使わないので 
      gene.weight.concat(gene.express(ret_value, cost_value))
      # 最後にgeneを評価します。parallelの戻り値をgeneにするためにね
      gene
      #evaluated_genes.push(gene)
    end
    return evaluated_genes
  end
=end

  # 全体をとりあえず評価します
  def evaluate(genes, ret_value, cost_value)
    evaluated_genes = []
    genes.each do |gene| # 4コアだから
      #genes.each do |gene|
      # geneのお尻に値をくっつけちゃいましょう。結局Topを決めるのにしか使わないので 
      gene.weight.concat(gene.express(ret_value, cost_value))
      evaluated_genes.push(gene)
    end
    return evaluated_genes
  end

  # まあいい戦略な
  def top(evaluated_genes)
    # とりあえずいい感じのgeneを選び出します
    # 単純に配列の最後の要素の大きさでソートします。破壊的なやつね
    evaluated_genes.sort! {|a, b| b.weight[-1] <=> a.weight[-1]}
    #p "リターン"
    #p evaluated_genes.slice(0, TOP) # 確認のため表示だけ
    #p evaluated_genes[0].weight[-1]
    # もう数字はいらないです
    evaluated_genes.map {|gene| gene.weight.slice!(-1)} # 破壊的だよ
    # 上位TOP個を取り出します
    #p evaluated_genes
    top = evaluated_genes.slice!(0, TOP) # また破壊的だよ
    #p TOP
    #p top
    return top, evaluated_genes
  end

  # TOP以外は全部交差や！まあ確率もあっけどな
  def crossing_over(genes)
    # 返す配列を作ります
    ar = []
    genes.each do |gene|
      # 新しい遺伝子を作ります。初期値はコピーですが
      new_gene = Gene.new(gene.length, @random)
      # 深いコピー。浅いとなんか起きたときに面倒だからね
      new_gene.weight = Marshal.load(Marshal.dump(gene.weight))
      if @random.rand < CROSSING_OVER_RATE # 交差を起こす確率の処理ですよ
        # 相手を選択します。ここはかぶってもいいことにしましょう
        pair_gene = genes[@random.rand(genes.length)]
        # どこで交差するか
        idx = @random.rand(gene.length)
        # 必ず後ろですけどいいですよね
        for i in idx..gene.length - 1 do
          new_gene.weight[i] = pair_gene.weight[i]
        end # ダサいな
      end 
      # 配列に詰め込みます
      # やばい。これは配列じゃなかった。切ったり張ったりできない
      ar.push(new_gene)
    end
    # 返します
    return ar
  end

  # これは突然変異
  def mutation(genes, mutation_rate)
    genes.each do |gene|
      # geneの各要素が突然変異を起こすかどうかだよね。JK
      for i in 0..gene.length - 1
        if @random.rand < mutation_rate # 突然変異を起こす確率の処理ですよ。
          # 0/1を入れ替えましょう
          gene.weight[i] == 0 ? 1 : 0
        end # ダサいな
      end
      # 直接書き換えちゃったけどいいよね
    end
    # 返します
    return genes
  end

  # 選択して処理をします
  def selection(genes, ret_value, cost_value)
    # ここで新しいgenesを作ります
    new_genes = []
    # とりあえず評価
    evaluated_genes = evaluate(genes, ret_value, cost_value)
    #p "evaluated"
    #p evaluated_genes
    #p evaluated_genes.length
    # 頭の方がほしいです
    top_genes, other_genes = top(evaluated_genes)
    #p top_genes.length
    #p other_genes.length
    top_genes.each do |gene|
      new_genes.push(gene)
    end
    #new_genes = new_genes.concat(top_genes)
    # 交差の処理をします
    other_genes = crossing_over(other_genes)
    # 突然変異の処理をします
    other_genes = mutation(other_genes, MUTATION_RATE)
    # また連結
    #p other_genes.length
    other_genes.each do |gene|
      new_genes.push(gene)
    end
    # 返します
    #p new_genes.length
    return new_genes
  end

  # 繰り返しの本体です 
  def calculate
    GENERATION.times do |num|
      # 次にselectionを実施して
      #p Time.now
      #p "#{num}回目"
      #p @genes[0]
      new_genes = selection(@genes, @ret_value, @cost_value)
      # ここの交換なー。再帰でいきたいよね
      @genes = new_genes # 死ぬほどダサい
    end
    # 最もいいものを返します
    return @genes[0]
  end
end
