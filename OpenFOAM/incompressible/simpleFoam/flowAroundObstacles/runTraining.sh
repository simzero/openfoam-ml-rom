name=${PWD##*/}

python3 -m deepcfd \
        --net UNetEx \
        --model-input DeepCFD/${name}X.pkl \
        --model-output DeepCFD/${name}Y.pkl \
        --output DeepCFD/${name}.pt \
        --kernel-size 5 \
        --filters 8,16,32,32 \
        --epochs 2000 \
        --batch-size 32 > log.deepcfd

