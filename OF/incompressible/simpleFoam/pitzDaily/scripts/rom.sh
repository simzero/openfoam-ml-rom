#/bin/bash

#  Creating directories
NAME=$(basename "$(pwd)")

foamJob -screen steady
# foamJob -screen steady -online -Ux 10.0 -nu 0.00001
# foamToVTK -case ITHACAoutput/Reconstruction

foamToVTK -ascii -time 0 -fields 'none' -no-point-data

mv VTK/${NAME}_*/internal.vtu ./${NAME}.vtu

#  - Copying ROM data to the global surrogates folder
#  Pack PPE
if [ -d ITHACAoutput/Matrices/G ];then
  zip -j ${NAME}.zip \
         ITHACAoutput/Matrices/D_mat.txt \
         ITHACAoutput/Matrices/M_mat.txt \
         ITHACAoutput/Matrices/K_mat.txt \
         ITHACAoutput/Matrices/B_mat.txt \
         ITHACAoutput/Matrices/bt_mat.txt \
         ITHACAoutput/Matrices/BC3_mat.txt \
         ITHACAoutput/Matrices/coeffL2_mat.txt \
         ITHACAoutput/Matrices/C/C*_mat.txt \
         ITHACAoutput/Matrices/G/G*_mat.txt \
         ITHACAoutput/Matrices/ct1/ct1*_mat.txt \
         ITHACAoutput/Matrices/ct2/ct2*_mat.txt \
         ITHACAoutput/weightsPPE/wRBF_*mat.txt \
         ITHACAoutput/Parameters/par.txt \
         ITHACAoutput/POD/EigenModes_U_mat.txt \
         ITHACAoutput/POD/EigenModes_p_mat.txt \
         ITHACAoutput/POD/EigenModes_nut_mat.txt
else
#  Pack SUP
  zip -j ${NAME}.zip \
         ITHACAoutput/Matrices/P_mat.txt \
         ITHACAoutput/Matrices/M_mat.txt \
         ITHACAoutput/Matrices/K_mat.txt \
         ITHACAoutput/Matrices/B_mat.txt \
         ITHACAoutput/Matrices/bt_mat.txt \
         ITHACAoutput/Matrices/coeffL2_mat.txt \
         ITHACAoutput/Matrices/C/C*_mat.txt \
         ITHACAoutput/Matrices/ct1/ct1*_mat.txt \
         ITHACAoutput/Matrices/ct2/ct2*_mat.txt \
         ITHACAoutput/weightsSUP/wRBF_*mat.txt \
         ITHACAoutput/Parameters/par.txt \
         ITHACAoutput/POD/EigenModes_U_mat.txt \
         ITHACAoutput/POD/EigenModes_p_mat.txt \
         ITHACAoutput/POD/EigenModes_nut_mat.txt
fi
