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

np.random.seed(10)

argvs = sys.argv

i_train, o_train = [], []

ticks = 10
max = float(ticks ** 2)

# generate sample data
for x in range(1, ticks, 2):
    for y in range(0, ticks, 1):
        c = x * y / max
        i_train.append([x, y])
        o_train.append(c)

i_train = np.array(i_train)

print(i_train)
print(o_train)

from keras.layers import Dense, Activation
model = keras.models.Sequential()

# neural network model parameters
hidden_units = 3
layer_depth = 1
act = 'sigmoid'  # seems better than 'relu' for this model.
bias = True

# first hidden layer
model.add(Dense(units=hidden_units, input_dim=2, use_bias=bias))
model.add(Activation(act))

# additional hidden layers (if necessary)
for i in range(layer_depth - 1):
    model.add(Dense(units=hidden_units, input_dim=hidden_units, use_bias=bias))
    model.add(Activation(act))

# output layer
model.add(Dense(units=1, use_bias=bias))
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
    ep = 1000  # default

start_fit = time.time()

model.fit(i_train, o_train, epochs=ep, verbose=1)
elapsed = time.time() - start_fit
print("elapsed = {:.1f} sec".format(elapsed))

# predict
a = []
for x in range(0, ticks, 2):
    for y in range(0, ticks, 1):
        a.append([x, y])

p = np.array(a)
print(p)
r = model.predict(p)
r_fact = r * max
print(r)

# Easy evaluation
y = []
for (aa, r_fact_1, r_normal) in zip(p, r_fact, r):
    fact_predicted = r_fact_1[0]
    fact_true = aa[0] * aa[1]
    predict_sqrt = np.sqrt(abs(r_normal[0]))
    true_sqrt = np.sqrt(abs(fact_true))
    y.append(fact_true)

    print('{0:>2} x {1:>2}, true_product={2:>3}, predicted={3:>6.2f}, accuracy(biased_percentage)={4:>6.2f} %'.format(
        aa[0],
        aa[1],
        fact_true,
        fact_predicted,
        (true_sqrt - predict_sqrt + ticks) * 100 / (true_sqrt + ticks)
    ))

# Plot on scatter graph
xn, yn, cp = [], [], []
for i in range(int(ticks / 2) ** 2):
    xn.append(p[i][0])
    yn.append(p[i][1])
    cp.append(float(r[i]))

plt.scatter(p[:, 0], p[:, 1], marker=".", c=[float(a)
                                             for a in r], cmap='Blues')
plt.colorbar()

plt.scatter(i_train[:, 0], i_train[:, 1], marker="*",
            s=100, c=o_train, cmap='Reds')
plt.colorbar()

plt.show()
