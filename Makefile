.PHONY: thirdparty

SHELL := /bin/bash

openfoam-dir := thirdparty/openfoam/etc/bashrc
ithacafv-dir := thirdparty/ithaca-fv/etc/bashrc

CORES?=1

models: ml rom

install:
	npm install

install-nvidia-docker:
	sudo -E bash -c '\
        curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | gpg --dearmor | tee /usr/share/keyrings/nvidia-docker.gpg >/dev/null; \
        DISTRIBUTION=$$(lsb_release -cs); \
        curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu$$DISTRIBUTION/nvidia-docker.list > /etc/apt/sources.list.d/nvidia-docker.list; \
        apt -y install nvidia-container-toolkit; \
        systemctl restart docker \
        '
requirements-debian:
	sudo apt-get install build-essential autoconf autotools-dev cmake gawk gnuplot flex libfl-dev libreadline-dev zlib1g-dev openmpi-bin libopenmpi-dev mpi-default-bin mpi-default-dev libgmp-dev libmpfr-dev libmpc-dev nodejs openscad libgl1-mesa-glx xvfb \
	&& pip3 install -r requirements.txt

thirdparty:
	cd thirdparty && CORES=${CORES} ./make.sh && cd .. && pip3 install -r requirements.txt && npm i

tools:
	npm install --prefix applications/steady/online

ml:
	source $(openfoam-dir) && cd OF && ./Allrun.ml ${CORES}

rom:
	source $(openfoam-dir) && source $(ithacafv-dir) && cd OF && ./Allrun.rom ${CORES}

clean:
	source $(openfoam-dir) && cd OF && ./Allclean
