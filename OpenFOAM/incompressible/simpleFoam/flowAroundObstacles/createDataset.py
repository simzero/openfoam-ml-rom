import os
import sys
import meshio
import numpy as np
import pickle
import getopt
from tqdm import tqdm

root_dir = 'runs'


def parseOpts(argv):
    nx = 100
    ny = 100
    model_input = "dataX.pkl"
    model_output = "dataY.pkl"

    try:
        opts, args = getopt.getopt(argv,"h:x:y:i:0",["nx=", "ny=", "model-input=", "model-output="])
    except getopt.GetoptError as e:
        print(e)
        print("Usage: dataset.py "
            "\n -x  --nx"
            "\n -y  --ny"
            "\n -i  --model-input dataX.pkl"
            "\n -o  --model-output dataY.pkl\n"
        )
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            print("Usage: dataset.py "
                "\n -x  --nx"
                "\n -y  --ny"
                "\n -i  --model-input dataX.pkl"
                "\n -o  --model-output dataY.pkl\n"
            )
            sys.exit()
        elif opt in ("-x","--nx"):
            nx = int(arg)
        elif opt in ("-y","--ny"):
            ny = int(arg)
        elif opt in ("-i","--model-input"):
            model_input = arg
        elif opt in ("-o","--model-output"):
            model_output = arg

    return nx, ny, model_input, model_output

if __name__ == "__main__":

    nx, ny, model_input, model_output = parseOpts(sys.argv[1:])

    path = os.path.dirname(os.path.realpath(__file__))
    name = os.path.basename(path)

    os.makedirs(os.path.dirname(model_input), exist_ok=True)
    os.makedirs(os.path.dirname(model_output), exist_ok=True)

    input_array = []
    output_array = []

    i = 0
    for case in tqdm(os.listdir(root_dir)):
        shape_label = os.path.join('runs', case, "shape")
        input_path = os.path.join('runs', case, "VTK", case + "_0/internal.vtu")
        output_path = os.path.join('runs', case, "base/VTK/base_0/internal.vtu")

        f = open(shape_label, "r")
        shape = f.readline()

        input_mesh = meshio.read(input_path)
        output_mesh = meshio.read(output_path)

        i = i + 1;

        sdf1 = np.array(input_mesh.cell_data['sdf1'])
        sdf2 = np.array(input_mesh.cell_data['sdf2'])
        flowRegion = np.array(input_mesh.cell_data['flowRegion'])

        U = np.array(output_mesh.cell_data['U'])
        Ux = U[0][:,0]
        Uz = U[0][:,2]
        p = np.array(output_mesh.cell_data['p'])
        p = np.squeeze(p)

        sdf1 = sdf1.reshape(ny, nx)
        sdf2 = sdf2.reshape(ny, nx)
        flowRegion = flowRegion.reshape(ny, nx)

        Ux = Ux.reshape(ny, nx)
        Uz = Uz.reshape(ny, nx)
        p = p.reshape(ny, nx)

        input_array_case = np.stack((sdf1, flowRegion, sdf2), axis=0)
        output_array_case = np.stack((Ux, Uz,  p), axis=0)
    
        input_array.append(input_array_case)
        output_array.append(output_array_case)

    x = np.array(input_array)
    with open(model_input, "wb") as df_file:
        pickle.dump(obj=x, file = df_file)

    y = np.array(output_array)
    with open(model_output, "wb") as df_file:
        pickle.dump(obj=y, file = df_file)
