#!/bin/bash

CORES=$1

(cd incompressible/simpleFoam/flowAroundObstacles && ./Allrun ${CORES})
