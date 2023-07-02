> :warning: **This project is currently in active development**: Expect frequent updates and potential changes. Feel free to contribute or raise issues as needed.

# openfoam-ml-rom

Models and workflos for generating and deploying OpenFOAM surrogate models:

* Machine Learning (ML)
  - [flowAroundObstacles](https://github.com/simzero/openfoam-ml-rom/tree/main/OF/incompressible/simpleFoam/flowAroundObstacles) ([demo](https://simzero.github.io/openfoam-ml-rom/OF/incompressible/simpleFoam/flowAroundObstacles/view.html))

* Reduced order modeling (non-ML)
  - [pitzDaily](https://github.com/simzero/openfoam-ml-rom/tree/main/OF/incompressible/simpleFoam/pitzDaily)

## Installation requirements

Initialize the thirdparty submodules with:

```
git submodule update --init --recursive
```

This project requires several packages to be installed on your system.

Common:
* [OpenFOAM](https://develop.openfoam.com/Development/openfoam) (after v2106)
* Python3
* [Node.js](https://github.com/nodejs/node)
* [jsfluids](https://github.com/simzero/jsfluids)

ML-based:
* [openfoam-sdf-label](https://github.com/simzero/openfoam-sdf-label)
* [deepcfd](https://github.com//carpemonf/deepcfd)
* [cfdonnx](https://github.com/simzero/cfdonnx)
* [OpenSCAD](https://openscad.org/downloads.html)

ROM-based
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


## Usage

You can now run all the models specifying the number of `CORES`. This will:

- Generate the CFD data
- Train the ML model, or build the ROM
- Export to ONNX format if suitable
- Evaluate models

```
CORES=30 make models
```

Alternatively, you can use your own installation and navigate to the OpenFOAM examples and run `./Allrun 30`.

## Disclaimer

This offering is not approved or endorsed by OpenCFD Limited, producer and distributor of the OpenFOAM software via www.openfoam.com, and owner of the OPENFOAM® and OpenCFD® trade marks. This offering is not approved or endorsed by any software packages mentioned above or their respective owners, and should not be considered as such.
