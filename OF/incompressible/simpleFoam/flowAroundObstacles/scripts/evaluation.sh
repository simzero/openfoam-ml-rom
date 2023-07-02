#/bin/bash

process_dir () {
  cd $DIR

  foamToVTK -latestTime

  STL=$(foamDictionary config -entry stlName -value -disableFunctionEntries)
  IFS='_' read -ra ADDR <<< "$STL"
  SIZE=${ADDR[1]}
  DZ=${ADDR[2]}
  SHAPE=${STL%%_*}
  ROTATION=${ADDR[3]%%.*}

  cd ../../evaluation
  ln -s ../$DIR/base/VTK/base_0/internal.vtu OpenFOAM_${SHAPE}_${SIZE}_${DZ}_${ROTATION}.vtu
  cd ..

  ML_PATH=evaluation/ml_${SHAPE}_${SIZE}_${DZ}_${ROTATION}.vtu
  CFD_PATH=evaluation/OpenFOAM_${SHAPE}_${SIZE}_${DZ}_${ROTATION}.vtu
  PNG_PATH=evaluation/screenshot_${SHAPE}_${SIZE}_${DZ}_${ROTATION}.png
  STL_PATH=constant/triSurface/${STL}
  TITLE="Velocity inlet $U m/s - Viscosity $NU m²/s"
  # CFD_PATH=$DIR/runs/VTK/base_*/internal.vtu

  if [[ $DZ == n* ]]; then
    DZ=${DZ#n}
    DZ=$(echo "-1 * $DZ" | bc)
  fi

  if [[ $ROTATION == n* ]]; then
    ROTATION=${ROTATION#n}
    ROTATION=$(echo "-1 * $ROTATION" | bc)
  fi

  node ${APP} -g ${NAME}.vtu \
                     -m ${MODEL_PATH} \
                     -s ${STL_PATH} \
                     -o ${ML_PATH} \
                     -x ${NX} \
                     -y ${NY} \
                     -d ${SIZE} \
                     -z ${DZ} \
                     -r ${ROTATION}

  python3 scripts/plot.py $CFD_PATH $ML_PATH $PNG_PATH "$TITLE"  
}

export PYVISTA_OFF_SCREEN=true

CORES=$1
LANG=en_US
LC_ALL=C

APP=scripts/generateVtu.mjs

NAME=$(basename "$(pwd)")
MODEL_PATH=${NAME}.onnx

if [ ! -d evaluation ];then
  mkdir -p evaluation
fi

# - Saving OpenFOAM runs for verification
NX=$(foamDictionary config -entry nCellsX -value -disableFunctionEntries)
NY=$(foamDictionary config -entry nCellsZ -value -disableFunctionEntries)
N_TESTS=$(foamDictionary config -entry nTests -value -disableFunctionEntries)
SELECTED=($(ls -d runs/* | shuf | head -n $N_TESTS))

k=0
while [ $k -lt ${N_TESTS} ]
do
  for i in `seq ${CORES}`
  do
    if [ $k -lt ${#SELECTED[@]} ]; then
      DIR=${SELECTED[$k]}
      RUN=$(basename $DIR)
      echo "Processing $DIR"

      (process_dir $DIR $NX $NY) &

      k=$((k+1))
    fi
  done
  wait
done
