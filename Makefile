.PHONY: thirdparty

SHELL := /bin/bash

openfoam-dir := thirdparty/openfoam/etc/bashrc

install:
	npm install

thirdparty:
	cd thirdparty && ./make.sh && pip3 install -r requirements.txt

ml:
	source $(openfoam-dir) && cd OpenFOAM && ./Allrun.ml ${CORES}

clean:
	source $(openfoam-dir) && cd OpenFOAM && ./Allclean
