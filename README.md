# openfoam-ml-rom

Examples for generating OpenFOAM ML and ROM surrogates.

## Usage

Initialize the third-party submodules with:

```
git submodule update --init --recursive
```

### Requirements

Common:
* [OpenFOAM](https://develop.openfoam.com/Development/openfoam) after v2106
* Python3

ML-based
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
