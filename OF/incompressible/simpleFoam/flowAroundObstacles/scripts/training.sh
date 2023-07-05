#!/bin/bash

NAME=$(foamDictionary config -entry name -value -disableFunctionEntries)
NET=$(foamDictionary config -entry net -value -disableFunctionEntries)
LEARNING_RATE=$(foamDictionary config -entry learningRate -value -disableFunctionEntries)
KERNEL_SIZE=$(foamDictionary config -entry kernelSize -value -disableFunctionEntries)
EPOCHS=$(foamDictionary config -entry epochs -value -disableFunctionEntries)
BATCH_SIZE=$(foamDictionary config -entry batchSize -value -disableFunctionEntries)
FILTERS=$(foamDictionary config -entry filters -value -disableFunctionEntries)
FILTERS=$(echo $FILTERS | tr -d \")

python3 -m deepcfd \
        --net $NET \
        --model-input DeepCFD/${NAME}X.pkl \
        --model-output DeepCFD/${NAME}Y.pkl \
        --output DeepCFD/${NAME}.pt \
        --kernel-size $KERNEL_SIZE \
        --learning-rate $LEARNING_RATE \
        --filters $FILTERS \
        --epochs $EPOCHS \
        --batch-size $BATCH_SIZE
