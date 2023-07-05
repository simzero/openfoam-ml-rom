#/bin/bash

exec 3>/dev/tty

run_case () {
  mkdir -p runs/$k/constant && \
  cp -r 0 runs/$k/ && \
  cp config runs/$k/ && \
  cp constant/transportProperties runs/$k/constant/ && \
  cd runs/$k/constant && \
  ln -s ../../../constant/polyMesh polyMesh && \
  ln -s ../../../constant/turbulenceProperties turbulenceProperties && \
  cd .. && \
  ln -s ../../system system && \

  foamDictionary constant/transportProperties -entry nu -set ${NU_PARAMS[$k]} -disableFunctionEntries && \
  foamDictionary config -entry Ux -set ${U_PARAMS[$k]} -disableFunctionEntries && \
  foamJob -wait simpleFoam && \

  RESULTS_DIR=$(foamListTimes -latestTime) && \
  OUTPUT_DIR=$(($k + 1))
  cd ../../ITHACAoutput/Offline && \
  ln -s ../../runs/$k/${RESULTS_DIR} ${OUTPUT_DIR}
}

#  - Configuration
CORES=$1
LANG=en_US
LC_ALL=C

NAME=$(foamDictionary config -entry name -value -disableFunctionEntries)

#  - Parameter ranges
U_MIN=$(foamDictionary config -entry UMin -value -disableFunctionEntries)
U_MAX=$(foamDictionary config -entry UMax -value -disableFunctionEntries)
U_STEP=$(foamDictionary config -entry UStep -value -disableFunctionEntries)

NU_MIN=$(foamDictionary config -entry nuMin -value -disableFunctionEntries)
NU_MIN=$(printf "%.6f" $NU_MIN)
NU_MAX=$(foamDictionary config -entry nuMax -value -disableFunctionEntries)
NU_STEP=$(foamDictionary config -entry nuStep -value -disableFunctionEntries)

#  - Creating directories
OFFLINE_PATH="ITHACAoutput/Offline"
PARAM_PATH="ITHACAoutput/Parameters"

if [ ! -d runs ];then
  mkdir -p runs
fi

if [ ! -d ${PARAM_PATH} ];then
  mkdir -p ${PARAM_PATH}
fi

if [ ! -d ${OFFLINE_PATH} ];then
  mkdir -p ${OFFLINE_PATH}
fi

if [ ! -d results ];then
  mkdir -p results
fi

#  - Running the offline workflow
ln -s ../../0 ${OFFLINE_PATH}/0
ln -s ../../constant ${OFFLINE_PATH}/constant
ln -s ../../system ${OFFLINE_PATH}/system

N_PARAMS=0

for U in $(seq $U_MIN $U_STEP $U_MAX); do
  for nu in $(seq $NU_MIN $NU_STEP $NU_MAX); do
    let "N_PARAMS=N_PARAMS+1"
    U_PARAMS=( "${U_PARAMS[@]}" "$U" )
    NU_PARAMS=( "${NU_PARAMS[@]}" "$nu" )
  done
done

echo -n > ${PARAM_PATH}/par.txt

# The following executes a number single cores runs in parallel determined by
# ${cores}. It is a straightforward way of running the workload for the
# tutorials but other solutions might be more efficient in HPC environments.
k=0
while [ $k -lt ${N_PARAMS} ]
do
  echo Running samples "$(($k + 1))-$(($k + $CORES)) of $N_PARAMS" >&3

  for i in `seq ${CORES}`
  do
    if [ $k -lt ${N_PARAMS} ]; then
      (run_case $k ${U_PARAMS[$k]} ${NU_PARAMS[$k]}) &
      echo "${U_PARAMS[$k]} 0.0 ${NU_PARAMS[$k]}" >> ${PARAM_PATH}/par.txt
      let "k=k+1"
    fi
  done
  wait
done

touch ITHACAoutput/Offline/foam.foam
