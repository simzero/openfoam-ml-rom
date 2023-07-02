#!/bin/bash

PROC=6
BUILD_ROOT=.

if [[ -v CORES && -n "${CORES}" ]]; then
  PROC=${CORES}
fi

echo "#############################"
echo  INITIALIZING THIRD PARTY CODE
echo "#############################"

git submodule update --init --recursive

echo "#############################"
echo  BUILDING OpenFOAM
echo "#############################"

OPENFOAM_SDF_LABEL=$BUILD_ROOT/openfoam-sdf-label
OPENFOAM_ROOT=$BUILD_ROOT/openfoam
THIRDPARTY_ROOT=$OPENFOAM_ROOT/ThirdParty

(cd $OPENFOAM_ROOT && ln -s ../openfoam-thirdparty ThirdParty)

source $OPENFOAM_ROOT/etc/bashrc

SCOTCH_URL=https://gforge.inria.fr/frs/download.php/file/38352/${SCOTCH_VERSION}.tar.gz
wget ${SCOTCH_URL} -P ${THIRDPARTY_ROOT}
tar -xf ${THIRDPARTY_ROOT}/${SCOTCH_VERSION}.tar.gz -C ${THIRDPARTY_ROOT}

(cd $OPENFOAM_ROOT && ./Allwmake -j${PROC})
(cd $OPENFOAM_SDF_LABEL && ./Allwmake)

echo "#############################"
echo  BUILDING ITHACA-FV
echo "#############################"

ITHACAFV_ROOT=$BUILD_ROOT/ithaca-fv
APPLICATIONS=../applications

source $ITHACAFV_ROOT/etc/bashrc

(cd $ITHACAFV_ROOT && ./Allwmake -j${PROC})
(cd ${APPLICATIONS}/offline/steady && wmake)
