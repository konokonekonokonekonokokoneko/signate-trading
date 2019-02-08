# 非線形モデルです
#
# "9x9.py" # Primary multiplication set
#
#  an example of keras (with tensorflow by Google)
#   by U.minor
#    free to use with no warranty
#
# usage:
# python 9x9.py 10000
#
# last number (10000) means learning epochs, default=1000 if omitted

import tensorflow as tf
import keras
from keras.optimizers import SGD
import numpy as np
#from numpy.random import *
import matplotlib.pyplot as plt
import sys
import time
import pandas as pd

np.random.seed(10)

argvs = sys.argv

# 訓練データをロードします
train_data = "files/train_case_5_data.csv"
train_target = "files/train_case_5_target.csv"
test_data = "files/test_case_5_data.csv"
#test_target = "files/test_case_5_target.csv"
# トレーニングデータだ
train_x = pd.read_csv(train_data, engine='python', header=None)
train_x = train_x.values.astype('float32')
train_y = pd.read_csv(train_target, engine='python', header=None)
train_y = train_y.values.astype('float32')
# こっちはテストデータだ
test_x = pd.read_csv(test_data, engine='python', header=None)
test_x = test_x.values.astype('float32')
#test_y = pd.read_csv(test_target, engine='python', header=None)
#test_y = test_y.values.astype('float32')

from keras.layers import Dense, Activation
from keras.callbacks import EarlyStopping
model = keras.models.Sequential()

# neural network model parameters
# hidden_units = 3000 # case 1
hidden_units = 10000  # case 2/3/4
layer_depth = 1  # case 1/2/4/5
# layer_depth = 2  # case 3
act = 'sigmoid'  # seems better than 'relu' for this model.
bias = True

# first hidden layer
model.add(Dense(units=hidden_units, input_dim=2268, use_bias=bias))
model.add(Activation(act))

# additional hidden layers (if necessary)
for i in range(layer_depth - 1):
    model.add(Dense(units=hidden_units, input_dim=hidden_units, use_bias=bias))
    model.add(Activation(act))

# output layer
model.add(Dense(units=567, use_bias=bias))
model.add(Activation('linear'))

# Note: Activation is not 'softmax' for the regression model.

sgd = SGD(lr=0.01, decay=1e-6, momentum=0.9, nesterov=True)
model.compile(loss='mean_squared_error', optimizer=sgd)
#model.compile(loss = 'mean_absolute_percentage_error', optimizer = sgd)
#model.compile(loss = 'mean_squared_logarithmic_error', optimizer = sgd)

# Note: loss is not 'sparse_categorical_crossentropy' for the regression model.
#        metrics = ['accuracy'] does not seem suitable.

# training
if len(argvs) > 1 and argvs[1] != '':
    ep = int(argvs[1])  # from command line
else:
    ep = 50  # case 1


start_fit = time.time()
#early_stopping = EarlyStopping(patience=0, verbose=1)
early_stopping = EarlyStopping('loss', min_delta = 1e-4, patience = 1)
#history = model.fit(train_x, train_y, epochs=ep, verbose=1, validation_split=0.1, callbacks=[early_stopping])
history = model.fit(train_x, train_y, epochs = ep, verbose = 1, callbacks = [early_stopping])
elapsed = time.time() - start_fit
print("elapsed = {:.1f} sec".format(elapsed))

# predict
# データは一気に作ってしまうのが吉
a = []
for x in range(len(test_x)):
    a.append(test_x[x])
# numpyにするのは重要
p = np.array(a)
print(p)
r = model.predict(p)
print(r)
# なんかよくわかんないけど一回データフレームにしました。column名を消すのが面倒いことは知ってます
pd.DataFrame(r).to_csv("files/result.csv", index=False)
# printできるのかな？
print(history)
