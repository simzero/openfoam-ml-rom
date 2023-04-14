#!/bin/bash

name=${PWD##*/}

python3 -m deepcfd \
        --net UNetEx \
        --model-input DeepCFD/${name}X.pkl \
        --model-output DeepCFD/${name}Y.pkl \
        --output DeepCFD/${name}.pt \
        --kernel-size 5 \
        --learning-rate 0.001 \
        --filters 8,16,32,32 \
        --epochs 1000 \
        --batch-size 32 > log.deepcfd
