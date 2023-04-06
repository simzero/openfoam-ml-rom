name=${PWD##*/}
nx=$(foamDictionary -entry boxLength inputs -value)
ny=$(foamDictionary -entry boxHeight inputs -value)

python3 createDataset.py \
        --nx ${nx} \
        --ny ${ny} \
        --modelInput DeepCFD/${name}X.pkl \
        --modelOutput DeepCFD/${name}Y.pkl > log.createDataset

python3 -m deepcfd \
        --modelInput DeepCFD/${name}X.pkl \
        --modelOutput DeepCFD/${name}Y.pkl \
	-e 10 \
        --output DeepCFD/${name}.pt > log.DeepCFD

repoURL="https://github.com/simzero-oss/rom-js/tree/b1dc91848"
path="/examples/OpenFOAM/incompressible/simpleFoam/flowAroundObstacles"

metadata="{\
    'author': 'Carlos Peña-Monferrer',\
    'source': '${repoURL}${path}'\
}"

python3 -m cfdonnx \
        --input DeepCFD/${name}.pt \
        --output DeepCFD/${name}.onnx \
        --metadata ${metadata} > log.cfdonnx
