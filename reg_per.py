# 多層パーセプトロンでとりあえず予測してみましょう
import numpy as np
np.random.seed(10)
import pandas as pd

from sklearn.model_selection import train_test_split

from keras.models import Sequential
from keras.layers.core import Dense, Activation
from keras.utils import np_utils
from sklearn import preprocessing


def build_multilayer_perceptron():
    # 多層パーセプトロンモデルを構築
    model = Sequential()
    model.add(Dense(16, input_shape=(2268, )))  # 隠れ層が16層で入力層が2268
    model.add(Activation('relu'))
    model.add(Dense(567))  # 出力層は567です
    model.add(Activation('softmax'))
    return model


if __name__ == "__main__":
    # 訓練データをロードします
    train_data = "files/train_case_5_data.csv"
    train_target = "files/train_case_5_target.csv"
    test_data = "files/test_case_5_data.csv"
    test_target = "files/test_case_5_target.csv"
    # トレーニングデータだ
    train_x = pd.read_csv(train_data, engine='python', header=None)
    train_x = train_x.values.astype('float32')
    train_y = pd.read_csv(train_target, engine='python', header=None)
    train_y = train_y.values.astype('float32')
    # こっちはテストデータだ
    test_x = pd.read_csv(test_data, engine='python', header=None)
    test_x = test_x.values.astype('float32')
    test_y = pd.read_csv(test_target, engine='python', header=None)
    test_y = test_y.values.astype('float32')

    # モデル構築
    model = build_multilayer_perceptron()
    model.compile(optimizer='adam',
                  loss='categorical_crossentropy',
                  metrics=['accuracy'])

    # モデル訓練
    model.fit(train_x, train_y, nb_epoch=50, batch_size=1, verbose=1)
