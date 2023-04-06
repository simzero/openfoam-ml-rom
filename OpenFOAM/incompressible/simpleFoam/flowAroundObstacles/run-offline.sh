#/bin/bash
#
# Copyright (c) 2022 Carlos Peña-Monferrer. All rights reserved.
# This work is licensed under the terms of the GNU LGPL v3.0 license.
# For a copy, see <https://opensource.org/licenses/LGPL-3.0>.
#


run_case () {
  mkdir -p runs/$k/constant && \
  cp -r 0 runs/$k/ && \
  cp inputs runs/$k/ && \
  cp constant/transportProperties runs/$k/constant/ && \
  cd runs/$k/constant && \
  ln -s ../../../constant/polyMesh polyMesh && \
  ln -s ../../../constant/turbulenceProperties turbulenceProperties && \
  cd .. && \
  ln -s ../../system system && \

  foamDictionary constant/transportProperties -entry nu -set ${NU_PARAMS[$k]} && \
  foamDictionary inputs -entry Ux -set ${U_PARAMS[$k]} -disableFunctionEntries && \
  foamJob -wait simpleFoam && \

  RESULTS_DIR=$(foamListTimes -latestTime) && \
  OUTPUT_DIR=$(($k + 1))
  cd ../../ITHACAoutput/Offline && \
  ln -s ../../runs/$k/${RESULTS_DIR} ${OUTPUT_DIR}
}


#  - Configuration
CORES=$1
LANG=en_US
NAME=pitzDaily


#  - Parameter ranges
U_MIN=0.5
U_MAX=20.0
U_STEP=0.5

NU_MIN=0.000005
NU_MAX=0.0001
NU_STEP=5e-06


#  - Creating directories
ROM_OUTPUT_PATH=../../../../../surrogates/OF/incompressible/simpleFoam/${NAME}

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

if [ ! -d verification ];then
  mkdir -p verification
fi

if [ ! -d ${ROM_OUTPUT_PATH} ];then
  mkdir -p ${ROM_OUTPUT_PATH}
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
  for i in `seq ${CORES}`
  do
    if [ $k -lt ${N_PARAMS} ]; then
      echo "Running $k with U ${U_PARAMS[$k]} and nu ${NU_PARAMS[$k]}"
      (run_case $k ${U_PARAMS[$k]} ${NU_PARAMS[$k]}) &
      echo "${U_PARAMS[$k]} 0.0 ${NU_PARAMS[$k]}" >> ${PARAM_PATH}/par.txt
      let "k=k+1"
    fi
  done
  wait
done


#  - Saving OpenFOAM runs for verification
foamToVTK -case runs/599 -latestTime
foamToVTK -case runs/381 -latestTime
foamToVTK -case runs/49 -latestTime
mv runs/599/VTK/599_*/internal.vtu verification/OpenFOAM_U_15.0_nu_0.0001.vtu
mv runs/381/VTK/381_*/internal.vtu verification/OpenFOAM_U_10.0_nu_0.00001.vtu
mv runs/49/VTK/49_*/internal.vtu verification/OpenFOAM_U_1.5_nu_0.00005.vtu

touch ITHACAoutput/Offline/foam.foam


#  - Running the online ITHACA workflow for verification
# TODO: remove redundancies (e.g. symlinks, POD generation, etc)
# TODO: pass parameters as a list and do a single call of the steady app
mkdir -p ITHACAoutput/Reconstruction
cp inputs ITHACAoutput/Reconstruction/
foamJob -screen steady -online -Ux 1.5 -nu 0.00005
(cd ITHACAoutput/Reconstruction && \
 rm 0 && \
 ln -s ../../0 0 && \
 rm constant && \
 ln -s ../../constant constant && \
 rm system && \
 ln -s ../../system system && \
 mv 1 3 )
rm -r ITHACAoutput/POD
foamJob -screen steady -online -Ux 10.0 -nu 0.00001
(cd ITHACAoutput/Reconstruction && mv 1 2)
rm -r ITHACAoutput/POD
foamJob -screen steady -online -Ux 15.0 -nu 0.0001
foamToVTK -case ITHACAoutput/Reconstruction

mv ITHACAoutput/Reconstruction/VTK/Reconstruction_1/internal.vtu verification/ITHACA_U_15.0_nu_0.0001.vtu
mv ITHACAoutput/Reconstruction/VTK/Reconstruction_2/internal.vtu verification/ITHACA_U_10.0_nu_0.00001.vtu
mv ITHACAoutput/Reconstruction/VTK/Reconstruction_3/internal.vtu verification/ITHACA_U_1.5_nu_0.00005.vtu

rm -r ITHACAoutput/Reconstruction/VTK
touch ITHACAoutput/Offline/foam.foam
touch ITHACAoutput/Reconstruction/foam.foam

foamToVTK -ascii -time 0 -fields 'none' -no-point-data

#  - Copying ROM data to the global surrogates folder
#    Pack PPE
if [ -d ITHACAoutput/Matrices/G ];then
  zip -j ${ROM_OUTPUT_PATH}.zip \
         ITHACAoutput/Matrices/D_mat.txt \
         ITHACAoutput/Matrices/M_mat.txt \
         ITHACAoutput/Matrices/K_mat.txt \
         ITHACAoutput/Matrices/B_mat.txt \
         ITHACAoutput/Matrices/BC3_mat.txt \
         ITHACAoutput/Matrices/coeffL2_mat.txt \
         ITHACAoutput/Matrices/C/C*_mat.txt \
         ITHACAoutput/Matrices/G/G*_mat.txt \
         ITHACAoutput/Matrices/ct1/ct1*_mat.txt \
         ITHACAoutput/Matrices/ct2/ct2*_mat.txt \
         ITHACAoutput/weightsPPE/wRBF_*mat.txt \
         ITHACAoutput/Parameters/par.txt \
         ITHACAoutput/POD/EigenModes_U_mat.txt \
         VTK/*/internal.vtu
else
#   Pack SUP
  zip -j ${ROM_OUTPUT_PATH}.zip \
         ITHACAoutput/Matrices/P_mat.txt \
         ITHACAoutput/Matrices/M_mat.txt \
         ITHACAoutput/Matrices/K_mat.txt \
         ITHACAoutput/Matrices/B_mat.txt \
         ITHACAoutput/Matrices/coeffL2_mat.txt \
         ITHACAoutput/Matrices/C/C*_mat.txt \
         ITHACAoutput/Matrices/ct1/ct1*_mat.txt \
         ITHACAoutput/Matrices/ct2/ct2*_mat.txt \
         ITHACAoutput/weightsSUP/wRBF_*mat.txt \
         ITHACAoutput/Parameters/par.txt \
         ITHACAoutput/POD/EigenModes_U_mat.txt \
         VTK/*/internal.vtu
fi
