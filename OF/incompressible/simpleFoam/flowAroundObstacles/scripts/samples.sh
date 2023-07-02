#/bin/bash

exec 3>/dev/tty

run_case () {
  CASE_DIR="runs/$k"

  mkdir -p ${CASE_DIR}/constant
  cp -r system 0.orig scripts/Allrun.case config ${CASE_DIR}
  # cp constant/transportProperties ${CASE_DIR}/constant/

  cd ${CASE_DIR}/constant
  ln -s ../../../constant/transportProperties transportProperties
  ln -s ../../../constant/turbulenceProperties turbulenceProperties
  ln -s ../../../constant/triSurface triSurface
  cd ..

  fileName=$(basename ${STL_FILES[$k]})
  filePath=${STL_FILES[$k]}

  # eval foamDictionary config -entry stlNameFull -set \'\"${filePath}\"\' -disableFunctionEntries 
  foamDictionary config -entry stlName -set $fileName -disableFunctionEntries
  foamDictionary config -entry Ux -set ${U_PARAMS[$k]} -disableFunctionEntries

  shape=$(foamDictionary -entry stlName config -value -disableFunctionEntries)
  echo ${shape%.*} > shape
  ./Allrun.case

  OUTPUT_DIR=$(($k + 1))
  cd ../../sequencedVTU
  ln -s ../${CASE_DIR}/base/0 ${OUTPUT_DIR}
  cd ../sequencedSTL
  ln -s ../constant/triSurface/$fileName ${OUTPUT_DIR}.stl
}

#  - Configuration
CORES=$1
LANG=en_US
NAME=flowAroundObstacles

OFFLINE_PATH=sequencedVTU
STL_PATH=sequencedSTL

#  - Parameter ranges
U_MIN=$(foamDictionary config -entry UMin -value -disableFunctionEntries)
U_MAX=$(foamDictionary config -entry UMax -value -disableFunctionEntries)
U_STEP=$(foamDictionary config -entry UStep -value -disableFunctionEntries)

if [ ! -d ${OFFLINE_PATH} ];then
  mkdir -p ${OFFLINE_PATH}
  (cd ${OFFLINE_PATH} &&
  ln -s ../constant constant &&
  ln -s ../system system)
fi

if [ ! -d ${STL_PATH} ];then
  mkdir -p ${STL_PATH}
fi

N_PARAMS=0
for stl in constant/triSurface/*.stl; do
  for U in $(seq $U_MIN $U_STEP $U_MAX); do
    let "N_PARAMS=N_PARAMS+1"
    U_PARAMS=( "${U_PARAMS[@]}" "$U" )
    STL_FILES=( "${STL_FILES[@]}" "$stl" )
  done
done

k=0
while [ $k -lt ${N_PARAMS} ]
do
  echo Running samples "$(($k + 1))-$(($k + $CORES)) of $N_PARAMS" >&3

  for i in `seq ${CORES}`
  do
    if [ $k -lt ${N_PARAMS} ]; then
      (run_case $k ${U_PARAMS[$k]} ${STL_FILES[$k]}) &
      let "k=k+1"
    fi
  done
  wait
done
