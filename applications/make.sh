#!/bin/bash

BUILD_ROOT=../thirdparty/

echo "#############################"
echo  Offline tools
echo "#############################"

ITHACAFV_ROOT=$BUILD_ROOT/ithaca-fv
OPENFOAM_ROOT=$BUILD_ROOT/openfoam

source $OPENFOAM_ROOT/etc/bashrc

source $ITHACAFV_ROOT/etc/bashrc

(cd steady/offline && wmake)

echo "#############################"
echo  Online tools
echo "#############################"

npm install --prefix steady/online
