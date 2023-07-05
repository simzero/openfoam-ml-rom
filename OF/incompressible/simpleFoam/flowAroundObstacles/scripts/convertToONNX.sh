#!/bin/bash

NAME=$(foamDictionary config -entry name -value -disableFunctionEntries)

REPO="https://github.com/simzero/openfoam-ml-rom"
CASE_PATH="OpenFOAM/incompressible/simpleFoam/flowAroundObstacles"
METADATA='''{
    "source": "'${REPO}${CASE_PATH}'"
}'''

NET=$(foamDictionary config -entry net -value -disableFunctionEntries)

python3 -m cfdonnx \
        --net $NET \
        --input DeepCFD/${NAME}.pt \
        --output ${NAME}.onnx \
        --metadata "${METADATA}"
