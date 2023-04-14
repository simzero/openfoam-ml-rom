#!/bin/bash

name=${PWD##*/}

repoURL="https://github.com/simzero/openfoam-ml-rom"
path="OpenFOAM/incompressible/simpleFoam/flowAroundObstacles"
metadata='''{
    "source": "'${repoURL}${path}'"
}'''

python3 -m cfdonnx \
        --net UNetEx \
        --input DeepCFD/${name}.pt \
        --output DeepCFD/${name}.onnx \
        --metadata "${metadata}" > log.convertToONNX
