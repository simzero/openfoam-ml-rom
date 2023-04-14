# flowAroundObstacles

Workflow for solving the flow around different obstacles using simpleFoam.

Usage:

```
./Allrun ${cores}

e.g.:

./Allrun 30
```

The output of the worflow is the ONNX model at DeepCFD/flowAroundObstacles.onnx.

You can test its use at https://play.simzero.com/#D3SFTH#7.

## Case

![Scheme](imgs/scheme.png)

## OpenFOAM vs DeepCFD

![Data](imgs/data.png)

## Curves

![Curves](imgs/curves.png)
