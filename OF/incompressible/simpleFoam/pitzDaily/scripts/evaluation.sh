#/bin/bash

process_dir () {
  cd $dir
  U=$(foamDictionary config -entry Ux -value -disableFunctionEntries)
  NU=$(foamDictionary constant/transportProperties -entry nu -value -disableFunctionEntries)
  U=$(printf "%.1f" $U)
  NU=$(printf "%.1e" $NU)
  TITLE="Velocity inlet $U m/s - Viscosity $NU m²/s"
  CFD_PATH=evaluation/OpenFOAM_U_${U}_nu_${NU}.vtu
  ROM_PATH=evaluation/rom_U_${U}_nu_${NU}.vtu
  PNG_PATH=evaluation/screenshot_U_${U}_nu_${NU}.png
  cd ../..

  foamToVTK -case $dir -latestTime
  mv $dir/VTK/${RUN}_*/internal.vtu $CFD_PATH
  node ${APP} -g ${NAME}.vtu \
                     -m ${MODEL_PATH} \
                     -o ${ROM_PATH} \
                     --Ux ${U} \
                     --Uy 0.0 \
                     --nu ${NU}

  python3 scripts/plot.py $CFD_PATH $ROM_PATH $PNG_PATH "$TITLE"  
}

export PYVISTA_OFF_SCREEN=true

CORES=$1
LANG=en_US
LC_ALL=C

ROOT=../../../..
APP=scripts/generateVtu.mjs

NAME=$(foamDictionary config -entry name -value -disableFunctionEntries)
MODEL_PATH=${NAME}.zip

if [ ! -d evaluation ];then
  mkdir -p evaluation
fi

# - Saving OpenFOAM runs for verification
N_TESTS=$(foamDictionary config -entry nTests -value -disableFunctionEntries)
SELECTED=($(ls -d runs/* | shuf | head -n $N_TESTS))

k=0
while [ $k -lt ${N_TESTS} ]
do
  for i in `seq ${CORES}`
  do
    if [ $k -lt ${#SELECTED[@]} ]; then
      dir=${SELECTED[$k]}
      RUN=$(basename $dir)
      echo "Processing $dir"

      (process_dir $dir) &

      k=$((k+1))
    fi
  done
  wait
done
