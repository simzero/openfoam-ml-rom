### :heavy_check_mark: New cases will soon be added

# openfoam-ml-rom

Examples for generating OpenFOAM ML and ROM surrogates:

- [flowAroundObstacles](https://github.com/simzero/openfoam-ml-rom/tree/main/OpenFOAM/incompressible/simpleFoam/flowAroundObstacles)

## Usage

Initialize the third-party submodules with:

```
git submodule update --init --recursive
```

### Requirements

Common:
* [OpenFOAM](https://develop.openfoam.com/Development/openfoam) (after v2106)
* Python3

ML-based:
* [openfoam-sdf-label](https://github.com/simzero/openfoam-sdf-label)
* [deepcfd](https://github.com//carpemonf/deepcfd)
* [cfdonnx](https://github.com/simzero/cfdonnx)
* [OpenSCAD](https://openscad.org/downloads.html)

ROM-based
* ITHACA-FV 3.0 ([@carpemonf fork](https://github.com/carpemonf/ITHACA-FV))

## ML-based

You can build the thirdparty packages with:

```
make thirdparty
```

This will build OpenFOAM and related tools in the thirdparty folder. `OpenSCAD` is needed for some examples and needs to be installed separately. For Ubuntu, run:


```
sudo apt-get install openscad
```

You can now run the whole workflow specifying the number of `CORES`. This will generate CFD data, train the ML model and export to ONNX format.

```
CORES=30 make ml
```

Alternatively, you can use your own installation and navigate to the OpenFOAM examples and run `./Allrun 30`.

## Disclaimer

This offering is not approved or endorsed by OpenCFD Limited, producer and distributor of the OpenFOAM software via www.openfoam.com, and owner of the OPENFOAM® and OpenCFD® trade marks. This offering is not approved or endorsed by any software packages mentioned above or their respective owners, and should not be considered as such.
