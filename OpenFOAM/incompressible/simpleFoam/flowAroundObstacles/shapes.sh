#!/bin/bash

LANG=en_US

cad="shapes.scad"
cadDir=constant/triSurface

if [ ! -d constat/triSurface ]; then
   mkdir -p ${cadDir}
fi

# - Shapes per parameter
n_shapes=$(foamDictionary -entry shapesPerParameter inputs -value)

side_min=$(foamDictionary -entry sideMin inputs -value)
side_max=$(foamDictionary -entry sideMax inputs -value)

dz_min=$(foamDictionary -entry dzMin inputs -value)
dz_max=$(foamDictionary -entry dzMax inputs -value)

angle_min=$(foamDictionary -entry angleMin inputs -value)
angle_max=$(foamDictionary -entry angleMax inputs -value)

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
randomShape "hexagonal" ${n_shapes} ${n_shapes} ${n_shapes}
randomShape "halfCircle" ${n_shapes} ${n_shapes} ${n_shapes}
randomShape "ellipse" ${n_shapes} ${n_shapes} ${n_shapes}
