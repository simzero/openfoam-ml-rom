#!/bin/bash

LANG=en_US

cad=scripts/shapes.scad
cadDir=constant/triSurface

if [ ! -d constat/triSurface ]; then
   mkdir -p ${cadDir}
fi

# - Shapes per parameter
n_shapes=$(foamDictionary config -entry shapesPerParameter -value -disableFunctionEntries)

side_min=$(foamDictionary config -entry sideMin -value -disableFunctionEntries)
side_max=$(foamDictionary config -entry sideMax -value -disableFunctionEntries)

dz_min=$(foamDictionary config -entry dzMin -value -disableFunctionEntries)
dz_max=$(foamDictionary config -entry dzMax -value -disableFunctionEntries)

angle_min=$(foamDictionary config -entry angleMin -value -disableFunctionEntries)
angle_max=$(foamDictionary config -entry angleMax -value -disableFunctionEntries)

side_d=$(($side_max-$side_min+1))
dz_d=$(($dz_max-$dz_min+1))
angle_d=$(($angle_max-$angle_min+1))

randomShape () {

    shape=$1
    side_n=$2
    dz_n=$3
    angle_n=$4

    for side_i in $(seq 1 $side_n); do
        for dz in $(seq 1 $dz_n); do
            side=$(($(($RANDOM%$side_d))+$side_min)).$((RANDOM%999))
            dz=$(($(($RANDOM%$dz_d))+$dz_min)).$((RANDOM%999))
            dzName=${dz}
            if (( $( echo "$dz < 0" | bc -l) )); then
                dzName=n${dzName#-}
            fi

            name=${side}_${dzName}_0

            if [ ${angle_n} -eq 0 ]; then
                options="
                    -D side=${side}
                    -D diameter=${side}
                    -D dz=${dz}
                    -D angle=0
                "
                 openscad ${options} -D 'shape="circle"' -o ${cadDir}/circle_${name}.stl $cad
	    fi

            for angle in $(seq 1 $angle_n); do
                side=$(($(($RANDOM%$side_d))+$side_min)).$((RANDOM%999))
                angle=$(($(($RANDOM%$angle_d))+$angle_min)).$((RANDOM%999))
                dz=$(($(($RANDOM%$dz_d))+$dz_min)).$((RANDOM%999))
                dzName=${dz}
                if (( $( echo "$dz < 0" | bc -l) )); then
                    dzName=n${dzName#-}
                fi
                angleName=${angle}
                if (( $( echo "$angle < 0" | bc -l) )); then
                    angleName=n${angleName#-}
                fi
                name=${side}_${dzName}_${angleName}
                
		options="
                    -D side=${side}
                    -D diameter=${side}
                    -D dz=${dz}
                    -D angle=${angle}
                    "

                openscad ${options} -D "shape=\"$shape\"" -o ${cadDir}/${shape}_${name}.stl $cad
        done
    done
done
}

randomShape "circle" ${n_shapes} ${n_shapes} 0
randomShape "square" ${n_shapes} ${n_shapes} ${n_shapes}
randomShape "hexagon" ${n_shapes} ${n_shapes} ${n_shapes}
randomShape "halfCircle" ${n_shapes} ${n_shapes} ${n_shapes}
randomShape "ellipse" ${n_shapes} ${n_shapes} ${n_shapes}
