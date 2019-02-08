import tensorflow as tf
import keras
from keras.optimizers import SGD
import numpy as np
import matplotlib.pyplot as plt
import sys
import time
import pandas as pd
from keras.layers import Dense, Activation
from keras.callbacks import EarlyStopping


class PerceptronRegression(object):
    def __init__(self, name, seed, hidden_units, sgd_lr, sgd_dekey, sdg_momentum, input_dim, output_units, epochs):
        # 乱数ここでやっても大丈夫なんだっけ？
        self.np_rand = np.random.seed(seed)
        self.name = name
        self.hidden_units = hidden_units
        self.sgd_lr = sgd_lr
        self.sgd_dekey = sgd_dekey
        self.sdg_momentum = sdg_momentum
        self.input_dim = input_dim
        self.output_units = output_units
        self.ep = epochs
        self.model = keras.models.Sequential()
        # パラメータ多いな
        # データは抱かえません

    def fit(self, x_train, y_train, term):
        # 追加のパラメータです
        act = 'sigmoid'
        bias = True
        early_stopping = EarlyStopping('loss', min_delta=1e-4, patience=1)
        # いよいよ訓練です
        self.model.add(Dense(units=self.hidden_units,
                             input_dim=self.input_dim, use_bias=bias))
        self.model.add(Activation(act))
        self.model.add(Dense(units=self.output_units, use_bias=bias))
        self.model.add(Activation('linear'))
        sgd = SGD(lr=self.sgd_lr, decay=self.sgd_dekey,
                  momentum=self.sdg_momentum, nesterov=True)
        self.model.compile(loss='mean_squared_error', optimizer=sgd)
        self.model.fit(
            x_train, y_train, epochs=self.ep, verbose=1, callbacks=[early_stopping])
        # 作成したらsaveするのが普通です
        self.model.save('files/model_%s_%s.h5' %
                        (self.name, term), include_optimizer=False)
        return self.model  # これを返さないと。明示的に

    def predict(self, x_test, term):
        # データは一気に作ってしまうのが吉
        a = []
        for x in range(len(x_test)):
            a.append(x_test[x])
        # numpyにするのは重要
        print(a)
        p = np.array(a)
        r = self.model.predict(p)
        # やっと戻せます
        return r
