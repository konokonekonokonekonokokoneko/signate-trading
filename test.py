# 計算用のクラスを読んできて使います
import pandas as pd

# 訓練データをロードします
train_data = "files/train_case_5_full_data.csv"
train_target = "files/train_case_5_full_target.csv"
# トレーニングデータだ
train_x = pd.read_csv(train_data, engine='python', header=None)
train_x = train_x.values.astype('float32')
train_y = pd.read_csv(train_target, engine='python', header=None)
train_y = train_y.values.astype('float32')
# パラメータ
in_sample_term = 105
out_sample_term = 28
# 期間のコントロール
#init_count = in_sample_term
#data_limit = 3569

# クラスを持ってきます
from perceptron_regression import PerceptronRegression
# name, seed, hidden_units, sgd_lr, sgd_dekey, sdg_momentum, input_dim, output_units, epochs
# reg = PerceptronRegression("test_model", 10, 10000, 0.01, 1e-6, 0.9, 2268, 567, 50)

# ついに計算です
# とりあえず既存分やります
name = "test_model"
current_term = 1  # 最小単位以下は0にしたときの影響よな
# データを切り出します
terms = range(current_term, 129)  # 終端は含まない
for term in terms:
    # テストデータは次の期間のデータです
    test_start = term * out_sample_term
    test_end = test_start + out_sample_term if test_start + \
        out_sample_term < 3570 else 3570
    test_x_c = train_x[test_start:test_end]
    print("term")
    print(term)
    if test_end < 3570:  # 端数についてはモデルの再学習しません
        # 毎回モデルを作り直しましょう
        reg = PerceptronRegression(
            name, 10, 10000, 0.01, 1e-6, 0.9, 2268, 567, 50)
        # 切り出しの開始と終了を決めます
        start_point = term * out_sample_term - in_sample_term if term * \
            out_sample_term - in_sample_term > 0 else 0  # なんで三項演算子はこうも書き方が違うかな
        end_point = test_start  # 終端が含まれないことを前提にしているので、すこしおかしな表現になってしまうですね
        train_x_c = train_x[start_point:end_point]  # 終端は入りません
        train_y_c = train_y[start_point:end_point]
        model = reg.fit(train_x_c, train_y_c, term)
    result = model.predict(test_x_c, term)
    print("result")
    print(result)
    pd.DataFrame(result).to_csv('files/result_%s_%s.csv' %
                                (name, term), index=False)
