> :warning: **This project is currently in active development**: Expect frequent updates and potential changes. Feel free to contribute or raise issues as needed.

# openfoam-ml-rom

Models and workflows for generating and deploying OpenFOAM surrogate models:

* Machine Learning (ML)
  - flowAroundObstacles ( [demo](https://simzero.github.io/openfoam-ml-rom/OF/incompressible/simpleFoam/flowAroundObstacles/view.html) | [model](https://simzero.github.io/pg/v0.2/onnx/flowAroundObstacles.onnx) | [mesh](https://simzero.github.io/pg/v0.2/onnx/flowAroundObstacles.vtu) | [source](https://github.com/simzero/openfoam-ml-rom/tree/main/OF/incompressible/simpleFoam/flowAroundObstacles) )

* Reduced Order Modeling (non-ML)
  - pitzDaily ( [demo](https://simzero.github.io/openfoam-ml-rom/OF/incompressible/simpleFoam/pitzDaily/view.html) | [model]() | [mesh]()  | [source](https://github.com/simzero/openfoam-ml-rom/tree/main/OF/incompressible/simpleFoam/pitzDaily) )
  - windAroundBuildings (WIP)

## Usage with Docker

We provide a Docker image for directly running the models. You need Docker-CE to be [installed](https://docs.docker.com/engine/install) and [configured](https://docs.docker.com/engine/install/linux-postinstall) in your machine. The workflows include ML trainning for which support of CPU is automatically enabled, but GPU is highly recommended. To enable the use of GPUs from inside the container you need to install [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html).

You can create an alias for the docker run command and options for convenience:

```bash
alias runModel='docker run --gpus all -it --user "$(id -u):$(id -g)" -w /model -v ${PWD}:/model ghcr.io/simzero/openfoam-ml-rom:v0.2.0'
```

`runModel` is a Docker command designed to run specific models with specified options. This command makes use of GPU acceleration and mounts your current directory to the Docker container.

```bash
runModel [OPTIONS]

Example: runModel -m OF/incompressible/simpleFoam/pitzDaily -j 30

OPTIONS:

-l, --list: List all available models, e.g.: `runModel` -l to get the list of models.

-m, --model: Run a specified model, e.g.: `runModel` -m OF/incompressible/simpleFoam/flowAroundObstacles.
-s, --skipTraining: Flag to skip training and evaluation steps.
-j: Specify the number of cores for the run, .e.g.: `-j 4`.

-c, --command: Instead of running a model, specify a command to run, e.g.: `runModel -c blockMesh`.

-h, --help: Display help text, including the list of options and their descriptions.
```

For `--skipTraining`, no GPUs are used and `--gpus all` is not required.

## Usage from the repository

### Installation requirements

Initialize the thirdparty submodules with:

```
git submodule update --init --recursive
```

This project requires several packages to be installed on your system.

Common:
* Python3
* [Node.js](https://github.com/nodejs/node)
* [jsfluids](https://github.com/simzero/jsfluids)

ML-based:
* [OpenFOAM](https://develop.openfoam.com/Development/openfoam) (>= v2106)
* [openfoam-sdf-label](https://github.com/simzero/openfoam-sdf-label)
* [deepcfd](https://github.com//carpemonf/deepcfd)
* [cfdonnx](https://github.com/simzero/cfdonnx)
* [OpenSCAD](https://openscad.org/downloads.html)

ROM-based
* [OpenFOAM](https://develop.openfoam.com/Development/openfoam) (v2106)
* ITHACA-FV 3.0 ([@carpemonf fork](https://github.com/carpemonf/ITHACA-FV))


If you are using a Debian-based Linux distribution, such as Ubuntu, you can install the following dependencies with the following command. Note that this step requires sudo access:

```
make requirements-debian
```

You can build the thirdparty packages with:

```
CORES=8 make thirdparty
```

This will build OpenFOAM and related tools in the thirdparty folder.

### Running models

You can now run all the models specifying the number of `CORES`. This will:

- Generate the CFD data
- Train the ML model, or build the ROM
- Export to ONNX format if suitable
- Evaluate models

```
CORES=30 make models
```

Alternatively, you can navigate to the OpenFOAM examples and run `./Allrun 30`.

## Disclaimer

This offering is not approved or endorsed by OpenCFD Limited, producer and distributor of the OpenFOAM software via www.openfoam.com, and owner of the OPENFOAM® and OpenCFD® trade marks. This offering is not approved or endorsed by any software packages mentioned above or their respective owners, and should not be considered as such.
