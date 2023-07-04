#!/bin/bash

NAME=${PWD##*/}

NX=$(foamDictionary config -entry boxLength -value -disableFunctionEntries)
NY=$(foamDictionary config -entry boxHeight -value -disableFunctionEntries)

python3 scripts/createDataset.py \
        --nx ${NX} \
        --ny ${NY} \
        --model-input DeepCFD/${NAME}X.pkl \
        --model-output DeepCFD/${NAME}Y.pkl
