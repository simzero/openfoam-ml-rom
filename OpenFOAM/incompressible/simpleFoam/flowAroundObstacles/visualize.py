import os
import time
import deepcfd
import torch
import pickle
import matplotlib
import numpy as np
from cfdonnx.models.UNetEx import UNetEx
from matplotlib import pyplot as plt

matplotlib.use('tkagg')

filename="checkpoint.pt"
kernel_size = 5
filters = [8, 16, 32, 32]
bn = False
wn = False

model = UNetEx(
    3,
    3,
    filters=filters,
    kernel_size=kernel_size,
    batch_norm=bn,
    weight_norm=wn
)

x = pickle.load(open("DeepCFD/flowAroundObstaclesX.pkl", "rb"))
y = pickle.load(open("DeepCFD/flowAroundObstaclesY.pkl", "rb"))

x = torch.FloatTensor(x)
y = torch.FloatTensor(y)

# state_dict = torch.load("DeepCFD/flowAroundObstacles.pt")

while not os.path.isfile(filename):
    time.sleep(1)

last_mtime = os.path.getmtime(filename)

def update_plot():
    index = 110
    state_dict = torch.load(filename)
    model.load_state_dict(state_dict)
    out = model(x[:index])[:index].detach().numpy()

    # minu = np.min(out[0, 0, :, :])
    # maxu = np.max(out[0, 0, :, :])
    minu = 0
    maxu = 0.1

    print(minu, maxu)

    truth = y[:index].cpu().detach().numpy()
    inputs = x[:index].cpu().detach().numpy()

    plt.figure()
    fig = plt.gcf()
    fig.set_size_inches(15, 10)
    plt.ylabel('Ux', fontsize=18)
    plt.title('CNN', fontsize=18)
    plt.imshow(out[0, 0, :, :], cmap='jet', origin='lower', extent=[0,256,0,128])
    plt.colorbar(orientation='horizontal')
    plt.show()

update_plot()
plt.show(block=False)

while True:
    time.sleep(10)

    # check if the file has been modified since the last loop
    if os.path.isfile(filename):
        mtime = os.path.getmtime(filename)
        if mtime > last_mtime:
            # clear the previous plot and update with new data
            plt.clf()
            update_plot()
            plt.draw()
            last_mtime = mtime
