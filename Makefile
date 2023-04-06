.PHONY: build

SHELL := /bin/bash

openfoam-dir := thirdparty/openfoam/etc/bashrc

install:
	npm install
thirdparty:
	cd thirdparty && ./make.sh
ml:
	source $(openfoam-dir) && cd OpenFOAM && ./Allrun.ml ${CORES}

clean:
	source $(openfoam-dir) && cd OpenFOAM && ./Allclean

native-thirdparty-emcc:
	$(web-wasm) /bin/bash -c "cd thirdparty && ./make-emcc.sh && cd .. && ./make.sh"
native-build:
	npm run build && \
                npm install --prefix applications/steady/online

