#!/bin/bash
#------------------------------------------------------------------------------
. ${WM_PROJECT_DIR:?}/bin/tools/RunFunctions        # Tutorial run functions
. ${WM_PROJECT_DIR:?}/bin/tools/CleanFunctions      # Tutorial clean functions
#------------------------------------------------------------------------------

NAME=$(foamDictionary config -entry name -value -disableFunctionEntries)

OPTIONS="-wait -log-app"

STL_FILE=$(ls constant/triSurface | head -n 1)
STL_PATH=constant/triSurface/${STL_FILE}

echo STL_PATH $STL_PATH

foamJob ${OPTIONS} blockMesh
restore0Dir
foamDictionary config -entry stlName -set $STL_FILE -disableFunctionEntries
foamJob ${OPTIONS} sdf
foamJob ${OPTIONS} labelRegion
foamJob ${OPTIONS} foamToVTK -ascii -time 0 -fields '(sdf2 flowRegion)' -no-point-data
mv VTK/${NAME}_*/internal.vtu ./${NAME}.vtu
